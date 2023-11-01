-- define module
local coredht = {}

-- ToDo: add proper module description
--[[
    This module ...
--]]

local coreevent = require "coreevent"
local corelog = require "corelog"
local coreutils = require "coreutils"
local coretask = require "coretask"

local InputChecker

local db                = { _version = 0 }
local dbHistory         = { _next = 1, _max = 30}
local dhtReady          = false
local dhtReadyFunctions = {}
local writeToFileQueued = false
local filename          = "/db/dht.lua"
local logfile           = "/log/dht.txt"
local protocol          = "core:dht"

-- initializes the dht
function coredht.Init()
    InputChecker = InputChecker or require "input_checker"

	-- read database from disk
	db = coreutils.ReadTableFromFile(filename)

	-- in case we start for the first time, set a _version
    if type(db) ~= "table"  then db = {}            end
    if db._version == nil   then db._version = 0    end
end

local function CoreDHTEventReadySetup()
	-- startup, read from disk or get data from peers? Why not both!
	coreevent.SendMessage({protocol=protocol, subject="get all data"})

    -- timer instellen voor het geval dat we geen reactie krijgen
    coreevent.CreateTimeEvent(5, protocol, "all data timer")
end

local function DoEventGetAllData(subject, envelope)
    -- send all data back
    coreevent.ReplyToMessage(envelope, "all data", {data = db})
end

local function SaveDBToFile()
    -- no longer in the queue since we are doing it now
    writeToFileQueued = false

    -- check for repetitions
--    local duplicatTablesArray = coreutils.CheckForRepetitions(db)
--    for i, duplicateTable in ipairs(duplicatTablesArray) do
--        corelog.Warning("coredht.SaveDBToFile(): duplicate table found:"..textutils.serialise(duplicateTable))
--    end

    -- save the db table to a file (this may take some time with larger dht's)
    coreutils.WriteToFile(filename, db, "overwrite")

    -- create seperate files for each key (if the key is a table)
    for key, value in pairs(db) do

        -- is it a table?
        if type(value) == "table" then
            local fileName = "/debug/dht_"..key..".lua"
            coreutils.WriteToFile(fileName, "-- for manual reading only, changes to this file will be ignored", "overwrite")
            coreutils.WriteToFile(fileName, "local "..key.." =")
            coreutils.WriteToFile(fileName, value)
        end
    end
end

local function SaveDataToDB(data, ...)
    -- actually saves the data to the db
    local ldb = db
    local listOfNodes = {}

    -- make a list of the nodes so we know which is the last one
    for i, node in ipairs(arg) do
        listOfNodes[#listOfNodes + 1] = node
    end

    -- history bijwerken
    dbHistory[ dbHistory["_next"] ] = { data = data, listOfNodes = listOfNodes, version = db._version }
    dbHistory[ "_next" ]            = dbHistory[ "_next" ] % dbHistory[ "_max" ] + 1
--    coreutils.WriteToFile("/log/dht_history.lua", dbHistory, "overwrite")   -- temporary

    -- check for all data
    if #listOfNodes == 0 then
        -- wow, overwriting the root is dangerous!
        if type(data) ~= "table" then corelog.WriteToLog("cvoredht.SaveDataToDB: not allowed to overwrite the dht root with something else then a table. Traceback: "..debug.traceback()) return data end

        -- no keys, full database
        db = data
    else
        -- search the nodes in the data
        for i=1,#listOfNodes-1 do
            local node = listOfNodes[i]

            -- create table if nothing is present
            if ldb[node] == nil then ldb[node] = {} end

            -- move to the next node
---@diagnostic disable-next-line: cast-local-type
            ldb = ldb[node]
        end

        -- ensure a copy of the data (to prevent possible table repetitions in db)
        local dataCopy = textutils.unserialise(textutils.serialise(data))

        -- store the data in the last given node
        ldb[listOfNodes[#listOfNodes]] = dataCopy
    end

    -- save the db table to a file
    if not writeToFileQueued then
        -- now it is in the queue
        writeToFileQueued = true

        -- add to the work queue
        coretask.AddWork(SaveDBToFile)
    end

    -- return the data itself
    return data
end

local function DoDHTReady()
    -- we zijn er klaar voor
    dhtReady = true

	-- seems we are ready, run requested functions
	for i, func in ipairs(dhtReadyFunctions) do func() end

    -- all functions executed, forget about them
	dhtReadyFunctions = {}
end

local function DoEventAllData(subject, envelope)
    -- alleen als de dht nog niet ready is (en ook als we geen table ontvangen hebben)
    if dhtReady or type(envelope.message) ~= "table" then return end

	-- just save the data to the root
	SaveDataToDB(envelope.message.data)

    -- we zijn er klaar voor
    DoDHTReady()
end

local function DoEventAllDataTimer(subject, envelope)
    -- alleen als de dht nog niet ready is
    if not dhtReady then
        -- niet zo best, we hebben geen data gekregen!
        corelog.WriteToLog("coredht: all data timer verlopen zonder iets ontvangen te hebben")

        -- we zetten nu de dht op ready, terwijl we weten dat het niet zo is...
        DoDHTReady()

        -- save the db table to a file, dan maar iets leegs
        coreutils.WriteToFile(filename, db, "overwrite")
    end
end

local function DoEventSaveData(subject, envelope)
    -- check for version differences
    if db._version ~= 0 and db._version + 1 ~= envelope.message.version then
        corelog.WriteToLog("DHT WARNING: Saving data from "..envelope.from.." with version "..envelope.message.version..". Current version is "..db._version)
    end

    -- versie bijwerken
    if db._version < envelope.message.version then db._version = envelope.message.version end

	-- just save the data like a normal request from this computer
	SaveDataToDB(envelope.message.data, table.unpack(envelope.message.arg))
end

function coredht.Setup()
    -- set up stuff when other apis are loading

    -- add handlers to protocol messages
	coreevent.AddEventListener(DoEventGetAllData,    protocol, "get all data")
	coreevent.AddEventListener(DoEventAllData,       protocol, "all data")
	coreevent.AddEventListener(DoEventAllDataTimer,  protocol, "all data timer")
	coreevent.AddEventListener(DoEventSaveData,      protocol, "save data")

	-- start sending messages when we are ready to receive them too
	coreevent.EventReadyFunction(CoreDHTEventReadySetup)
end

function coredht.DHTReadyFunction(func)
    if coredht.IsReady() then
        -- can be executed right away!
        func()
    else
        -- just add function to the list
        dhtReadyFunctions[#dhtReadyFunctions + 1] = func
    end
end

function coredht.IsReady()
    -- is the dht ready?
    return dhtReady
end

-- get data from the dht
function coredht.GetData(...)
    local ldb = db

    -- follow the nodes
    for i, node in ipairs(arg) do
---@diagnostic disable-next-line: cast-local-type
        if type(ldb) == "table" and ldb[node] ~= nil    then ldb = ldb[node]
                                                        else return nil
        end
    end

    -- return the data
    return ldb
end

-- save data to the table db
function coredht.SaveData(data, ...)
    -- safety
    if not dhtReady then corelog.WriteToLog("coredht.SaveData called before dht is ready. Traceback info: "..debug.traceback()) end

    -- for debugging dht issues
    if false then
        coreutils.WriteToFile(logfile, "", "a")
        coreutils.WriteToFile(logfile, "*** Saving data ***", "a")
        coreutils.WriteToFile(logfile, "data =", "a")
        coreutils.WriteToFile(logfile, data, "a")
        coreutils.WriteToFile(logfile, "arg =", "a")
        coreutils.WriteToFile(logfile, arg, "a")
    end

    -- we should have a version readable
    if type(db) ~= "table" or db._version == nil then corelog.WriteToLog("coredht.SaveData db var not ok. Traceback info: "..debug.traceback()) end

    -- update the version
    db._version = db._version + 1

    -- send other what we are about to write (if event is ready ofcourse)
    coreevent.SendMessage({
	    protocol    = protocol,
	    subject     = "save data",
	    message     = {
	        data        = data,
	        arg         = arg,
	        version     = db._version
	    }
    })

    -- save the node in the data
    return SaveDataToDB(data, ...)
end

return coredht
