-- define module
local coreenv = {}

-- ToDo: add proper module description
--[[
[2-12-2023 13:20] Rutger van der Eijk: Dus coreenv is bedoelt voor "environment" settings"? maar dan onze eigen implementatie die synced over workers heen?
[2-12-2023 13:21] : yes
[2-12-2023 13:21] : env settings die voor het systeem gelden, niet voor 1 worker
[2-12-2023 13:21] : en waarvan het een goed idee kan zijn om ze runtime te wijzigen
[2-12-2023 13:22] : (dus geen protocol naam en zo)
[2-12-2023 13:22] Rutger van der Eijk: Ok. Dus dat idee waar je het eerder al over had.
[2-12-2023 13:22] : yes
[2-12-2023 13:22] Rutger van der Eijk: Nice.
[2-12-2023 13:23] Rutger van der Eijk: En waar/ hoe wordt deze data opgeslagen?
[2-12-2023 13:23] : er moet dus nog een scherm bij zodat via een userinterface wijzigingen gemaakt kunnen worden
[2-12-2023 13:23] : memory & /db/env.lua
[2-12-2023 13:23] Rutger van der Eijk: Oh, dat is helemaal cool. Dus dan kunnen we het runtime aanpassen zonder reboots enzo?
[2-12-2023 13:24] : (coreenv werkt voordat dht werkt)
[2-12-2023 13:24] : ja, zonder reboots aanpassen vanaf je pocket computer 😊
[2-12-2023 13:24] Rutger van der Eijk: nice
[2-12-2023 13:24] : zonder reload
[2-12-2023 13:25] Rutger van der Eijk: En leading is wat er in env.lua staat?

En deze worden dus gesynced
[2-12-2023 13:25] : memory is leading, backup wordt naar disk geschreven
[2-12-2023 13:25] : Bij wijziging wordt een berichtje rond gestuurd
[2-12-2023 13:25] : zo vindt sync plaats
[2-12-2023 13:25] Rutger van der Eijk: Check.

En bij opstarten wordt disk ingelezen neem ik aan?
[2-12-2023 13:26] : yes
[2-12-2023 13:26] : goed dat je het noemt, register moet dan niet overschrijven, even aanpassen
[2-12-2023 13:27] Rutger van der Eijk: Leuk idee.

Ik zie nu nog even geen andere toepassing als bulkMode. Maar kan mij voorstellen dat we die nog verzinnen.
[2-12-2023 13:30] : je kan overwegen het energie level van de wereld hier onder te brengen
[2-12-2023 13:30] : of zoals eerder voorgesteld, bos omhakken max 1x1 (spaart tijd)
[2-12-2023 13:31] Rutger van der Eijk: Zou je bovenaan coreenv kort kunnen beschrijven waar deze core module voor bedoelt is. Dus het stukje


    This module ...


?

Dus met eigenlijk wat je hier boven uitlegt.

Dan kunnen we (ik 😉) de bedoeling (zoals het onderscheid met instantie specifieke settings) makkelijk terug vinden.
[2-12-2023 13:31] : disk io heeft ook wel een optie, bufferen of direct wegschrijven
[2-12-2023 13:31] Rutger van der Eijk: Die kan idd nuttig zijn.

--]]

-- imports
local coreevent
local corelog
local coreutils

-- local data
local db        = {
    env                 = {},
    writeToFileQueued   = false,
    filename            = "/db/env.lua",
    protocol            = "core:env",
    kinds               = {["number"]=true, ["string"]=true, ["boolean"]=true, ["table"]=true},
    readyToSync         = false,
}

--    _                 _
--   | |               | |
--   | | ___   ___ __ _| |
--   | |/ _ \ / __/ _` | |
--   | | (_) | (_| (_| | |
--   |_|\___/ \___\__,_|_|
--
--

local function ToNumber(value)
    -- check value
    if type(value) == "table" or type(value) == "function" then return 0 else return tonumber(value) end
end

local function ToString(value)
    -- check value
    if type(value) == "table" or type(value) == "function" then return "" else return tostring(value) end
end

local function ToBoolean(value)
    -- check for known false types
    if value == false
    or value == "false"
    or value == "False"
    or value == nil     then return false
                        else return true
    end
end

local function ToTable(value)
    -- check for table
    if type(value) ~= "table"   then return {value}
                                else return value
    end
end

local function SaveEnvToFile()
    -- no longer in the queue since we are doing it now
    db.writeToFileQueued = false

    -- save the db table to a file (this may take some time with larger dht's)
    coreutils.WriteToFile(db.filename, db.env, "overwrite")
end

local function Registered(protocol, name, kind, default)
    -- check the kind, must be a known kind
    if not db.kinds[kind] then return false end

    -- maybe registered before, then ignore
    if type(db.env[protocol]) == "table" and type(db.env[protocol][name]) == "table" then return false end

    -- safety
    if type(db.env[protocol]) ~= "table" then db.env[protocol] = {} end

    -- just overwrite current settings
    db.env[protocol][name] = {
        kind    = kind,
        default = default,
        value   = default
    }

    -- save the shit
    SaveEnvToFile()

    -- done
    return true
end

local function Set(protocol, name, value)
    -- check if tables are present
    if type(db.env[protocol]) == "table" and type(db.env[protocol][name]) == "table" then db.env[protocol][name].value = value end

    -- save the shit
    SaveEnvToFile()

    -- done
    return value
end

-- event ready function
local function DoWhenEventReady()
end

--                         _
--                        | |
--     _____   _____ _ __ | |_
--    / _ \ \ / / _ \ '_ \| __|
--   |  __/\ V /  __/ | | | |_
--    \___| \_/ \___|_| |_|\__|
--
--

local function DoEventGetAllData(subject, envelope)
    -- send all data back
    coreevent.ReplyToMessage(envelope, "all data", {data = db.env})
end

local function DoEventAllData(subject, envelope)
    -- just to be sure
    if type(envelope) ~= "table" or type(envelope.message) ~= "table" or type(envelope.message.data) ~= "table" then return end

	-- just overwrite everything
    db.env = envelope.message.data

    -- we are ready now to sync
    db.readyToSync = true

    -- save the shit
    SaveEnvToFile()
end

local function DoEventRegistered(subject, envelope)
    -- do the work
    Registered(envelope.message.protocol, envelope.message.name, envelope.message.kind, envelope.message.default)
end

local function DoEventSet(subject, envelope)
    -- do the work
    Set(envelope.message.protocol, envelope.message.name, envelope.message.value)
end

--                _     _ _
--               | |   | (_)
--    _ __  _   _| |__ | |_  ___
--   | '_ \| | | | '_ \| | |/ __|
--   | |_) | |_| | |_) | | | (__
--   | .__/ \__,_|_.__/|_|_|\___|
--   | |
--   |_|

-- initializes the dht
function coreenv.Init()

    -- do the actual import
    coreevent = coreevent   or require "coreevent"
    corelog   = corelog     or require "corelog"
    coreutils = coreutils   or require "coreutils"

	-- read database from disk
	db.env = coreutils.ReadTableFromFile(db.filename)

	-- safety
    if type(db.env) ~= "table" then db.env = {} end
end

function coreenv.Setup()
    -- add handlers to protocol messages
	coreevent.AddEventListener(DoEventGetAllData,   db.protocol, "get all data")
	coreevent.AddEventListener(DoEventAllData,      db.protocol, "all data")
	coreevent.AddEventListener(DoEventRegistered,   db.protocol, "registered")
	coreevent.AddEventListener(DoEventSet,          db.protocol, "set")

    -- send all data when event is ready
    coreevent.EventReadyFunction(DoWhenEventReady)
end

function coreenv.RegisterVariable(protocol, name, kind, default)
    -- do the registration
    local success = Registered(protocol, name, kind, default)

    -- send other what we just added (if sync ready ofcourse)
    if success and db.readyToSync then

        -- da message
        coreevent.SendMessage({
            protocol    = db.protocol,
            subject     = "registered",
            message     = {
                protocol    = protocol,
                name        = name,
                kind        = kind,
                default     = default,
            }
        })
    end
end

function coreenv.GetVariable(protocol, name)
    -- loop it up
    if type(db.env[protocol]) == "table" and type(db.env[protocol][name]) == "table" then return db.env[protocol][name].value end

    -- guess we shouldn't be here
    return nil
end

function coreenv.SetVariable(protocol, name, value)
    -- just set it in case it has been registered before
    value = Set(protocol, name, value)

    -- send other what we just added (if sync ready ofcourse)
    if db.readyToSync then

        -- da message
        coreevent.SendMessage({
            protocol    = db.protocol,
            subject     = "set",
            message     = {
                protocol    = protocol,
                name        = name,
                value       = value,
            }
        })
    end
end

--        _ _           _
--       | (_)         | |
--     __| |_ ___ _ __ | | __ _ _   _
--    / _` | / __| '_ \| |/ _` | | | |
--   | (_| | \__ \ |_) | | (_| | |_| |
--    \__,_|_|___/ .__/|_|\__,_|\__, |
--               | |             __/ |
--               |_|            |___/

function coreenv.EditEnvDisplay(t, userInput)
    -- import display
    local coredisplay = require "coredisplay"
--[[
    -- did we get user input?
    if false and t.editValue and userInput ~= "e" then

        -- process the new value
        local f, err = load("return "..userInput)
        if f ~= nil and not err then coredht.SaveData(f(), unpack(t.keyList)) end

        -- back to usefull screen
        t.editValue = false
    end

    -- usefull
    local keyList   = t.keyList or {}
    local subRoot   = db

    -- add a new key if present
    if t.newKey ~= nil  then table.insert(keyList, t.newKey) end
    if t.removeKey      then if #keyList == 0 then return true else table.remove(keyList) end end

    -- find the subRoot
    for i, key in ipairs(keyList) do

        -- check and change subroot if oke
        if subRoot[key] ~= nil then subRoot = subRoot[key] else corelog.WriteToLog("coredht.EditDHTDisplay(): Invalid key: "..tostring(key)) end
    end

    -- which keys are present in the subroot?
    local intro     = "Available options:"
    local options   = {{key = "x", desc = "back", func = coreenv.EditEnvDisplay, param = {keyList=keyList, removeKey=true}}}
    local question  = "Make your choice"

    -- loop subroot (if it's a table)
    local lastChar = 97
    if type(subRoot) == "table" then
        for key, _ in pairs(subRoot) do

            -- insert option
            table.insert(options, {key = string.char(lastChar), desc = key, func = coredht.EditDHTDisplay, param = {keyList = keyList, newKey = key }})

            -- update
            lastChar = lastChar + 1
        end
    else

        -- single value, show option for editing?
        if not t.editValue then
            -- different intro and allow editing
            intro = "The value : '"..tostring(subRoot).."'"
            table.insert(options, {key = "e", desc = "edit value", func = coredht.EditDHTDisplay, param = {keyList = keyList, editValue = true }})
        else
            -- we are editing, show screen for user input
            if userInput == "e" then
                -- start the screen to edit the value
                intro    = "Type the new value of this key. Use quotes for strings!!"
                options  = nil
---@diagnostic disable-next-line: cast-local-type
                question = nil
            end
        end
    end

    -- create the next screen
    coredisplay.NextScreen({
        clear = true,
        intro = intro,
        option = options,
        question = question,

        -- only for edit value screen
        func = coreenv.EditEnvDisplay,
        param = t
    })
]]
    -- done!
    return true
end

-- return da class
return coreenv
