-- define module
local coreutils = {}

-- ToDo: add proper module description
--[[
    This module ...
--]]

local corelog
local coreenv		= require "coreenv"

local db	= {
	dbFilename  	= "/db/coreutils.lua",
	protocol		= "coreutils",
    serial			= 0,                    -- for unique id's
}

local fsQueue		= {}					-- queue for async write to file

--                                               _ _         _           __ _ _
--                                              (_) |       | |         / _(_) |
--     __ _ ___ _   _ _ __   ___  __      ___ __ _| |_ ___  | |_ ___   | |_ _| | ___
--    / _` / __| | | | '_ \ / __| \ \ /\ / / '__| | __/ _ \ | __/ _ \  |  _| | |/ _ \
--   | (_| \__ \ |_| | | | | (__   \ V  V /| |  | | ||  __/ | || (_) | | | | | |  __/
--    \__,_|___/\__, |_| |_|\___|   \_/\_/ |_|  |_|\__\___|  \__\___/  |_| |_|_|\___|
--               __/ |
--              |___/

local function AddToAsyncQueue(fsWorkId, filename, message, writemode)
	-- make sure we have a queueId
	fsWorkId = fsWorkId or coreutils.NewId()

	-- add to the queue  or  replace item in queue
	fsQueue[fsWorkId] = {
		filename	= filename,
		message		= message,
		writemode	= writemode,
	}

	-- just add dummy event, you never know
	os.queueEvent("dummy")
end

function coreutils.Run()
	-- need this import
	local coresystem	= require "coresystem"

	-- work forever
	while coresystem.IsRunning() do

		-- get random item from the queue
		local fsWorkId, fsWork = next(fsQueue)

		-- got nothing? Then wait
		if fsWorkId ~= nil then

			-- forget this work item
			fsQueue[fsWorkId] = nil

			-- do the file operation
			coreutils.WriteToFileNow(fsWork.filename, fsWork.message, fsWork.writemode)
		else
			-- wait for any event, ignore result
			os.pullEvent()
		end
	end
end

--                _     _ _
--               | |   | (_)
--    _ __  _   _| |__ | |_  ___
--   | '_ \| | | | '_ \| | |/ __|
--   | |_) | |_| | |_) | | | (__
--   | .__/ \__,_|_.__/|_|_|\___|
--   | |
--   |_|

-- laatste serial uit de file lezen?
function coreutils.Init()
	corelog = corelog or require "corelog"

	-- read from file
	local dbFile = coreutils.ReadTableFromFile(db.dbFilename)

	-- check for empty table --> https://stackoverflow.com/questions/1252539/most-efficient-way-to-determine-if-a-lua-table-is-empty-contains-no-entries
	if next(dbFile) ~= nil then db = dbFile end

	-- uniek random nummer
	math.randomseed(os.time())
end

-- niet nodig voor utils
function coreutils.Setup()
	-- set env
	coreenv.RegisterVariable(db.protocol, "write to file async", "boolean", true)
end

-- generates a new id
function coreutils.NewId()

	-- eentje ophogen
	db.serial = db.serial + 1

	-- write to disk
	coreutils.WriteToFile(db.dbFilename, db, "overwrite")

	-- id is een altijd een string
	return os.getComputerID() .. ":" .. db.serial
end

function IdCreator(id)
	local t	= {}

	-- split op :
	for str in string.gmatch(id, "([^:]+)") do table.insert(t, str) end

	-- waarde voor de : is de creator
	return t[0]
end

function IdSerial(id)
	local t	= {}

	-- split op :
	for str in string.gmatch(id, "([^:]+)") do table.insert(t, str) end

	-- waarde voor de : is de creator
	return t[1]
end

function coreutils.ReadTableFromFile(filename)
	-- does the db file exist?
	if fs.exists(filename) then
		-- var's
		local fh = fs.open(filename, 'r')

		-- read from the file
		local text = fh.readAll()

		-- text to table
		local tbl = textutils.unserialize(text)

		-- close the file
		fh.close()

		-- return the table
		return tbl
	end

	-- still here? empty table
	return {}
end

function coreutils.WriteToFile(filename, message, writemode, fsWorkId)
	-- in async mode?
	if coreenv.GetVariable(db.protocol, "write to file async") then
		-- pepare id
		fsWorkId = fsWorkId or coreutils.NewId

		--  queue this one
		AddToAsyncQueue(fsWorkId, filename, message, writemode)
	else
		-- write it now
		coreutils.WriteToFileNow(filename, message, writemode)
	end
end

function coreutils.WriteToFileNow(filename, message, writemode)
		local mode	= "a"

	-- check writemode
	if writemode == "overwrite" then mode = "w" end

	-- if we get a table, make it a string
	if type(message) == "table" then message = textutils.serialize(message)	end

	-- bestandsnaam controleren, moet gewoon een string zijn natuurlijk
	if type(filename) ~= "string" then filename = db.logfile message = message..debug.traceback() end

	-- bestand openen, schrijven en sluiten
	local fileHandle = fs.open(filename, mode)
	if fileHandle then
		fileHandle.writeLine(message)
		fileHandle.close()
	else
		print("Cannot open file "..filename)
	end
end

function coreutils.UniversalTime()
	return 24 * os.day() + os.time() -- https://computercraft.info/wiki/Os.time (waarde tussen 0 en 23.999)
end

function coreutils.DeepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[coreutils.DeepCopy(orig_key)] = coreutils.DeepCopy(orig_value)
        end
        setmetatable(copy, coreutils.DeepCopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function ArrayContainsElement(array,  searchElement)
	-- loop over elements
	for i, element in ipairs(array) do
		-- check if searchElement
		if element == searchElement then
			return true
		end
	end

	-- end
	return false
end

function coreutils.CheckForRepetitions(orig, allTablesArray, duplicatTablesArray)
    local orig_type = type(orig)
	allTablesArray = allTablesArray or {}
	duplicatTablesArray = duplicatTablesArray or {}

	-- check orig is a table
    if orig_type == 'table' then
		-- check table already listed
		if ArrayContainsElement(allTablesArray, orig) then
--			corelog.WriteToLog(" duplicate table found:"..textutils.serialize(orig))
			-- check it is the first time
			if not ArrayContainsElement(duplicatTablesArray, orig) then
				table.insert(duplicatTablesArray, orig)
			end
		else
			table.insert(allTablesArray, orig)
		end

		-- loop on elements in table
        for key, value in pairs(orig) do
            coreutils.CheckForRepetitions(value, allTablesArray, duplicatTablesArray)
        end
    else -- number, string, boolean, etc
    end

	return duplicatTablesArray
end

-- dummy function to claim namespace until the function will be implemented
function coreutils.NIY(msg)
	-- Not implemented yet, do nothing special
	if type(msg) == 'string' then
		print('Not implemented yet: '..msg)
		corelog.WriteToLog('Not implemented yet: '..msg)
	end
end

-- ToDo: consider adding method to check for nested tables (to be able to catch the annoying errors)


return coreutils
