-- defines the class (nothing special)
local enterprise_dump       = {} --Class.NewClass(Host)

--[[
    The enterprise_dump is not a Host. It remembers the possible depot's for waste processing.
--]]

-- basics
local coredht       = require "coredht"
local corelog       = require "corelog"
local InputChecker  = require "input_checker"
local URL           = require "obj_url"

-- enterprises
local enterprise_turtle = require "enterprise_turtle"

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

-- get your locator for the best dump (just 1 at the moment)
function enterprise_dump.GetDumpLocator()

    -- get the data
    local dumpData = LoadData()

    -- we return the last known dump, usually the best
    return dumpData[#dumpData]
end

-- add a depot to the dump
function enterprise_dump.ListItemDepot(...)
    local checkSuccess, itemDepotLocator, mode = InputChecker.Check([[
        For enlisting a new item depot to the dump

        Return value:

        Parameters:
            itemDepotLocator        + (URL) the depot locator to add to the dump
            mode                    + (string, "append") append or overwrite the last known depot in the dump]], ...)
    if not checkSuccess then corelog.Error("enterprise_dump.ListItemDepot: Invalid input") return nil end

    -- get the data
    local dumpData = LoadData()

    -- add the locator, depending on the mode
    if mode == "overwrite" or mode == "w" then
        -- overwrite last element
        dumpData[#dumpData] = itemDepotLocator
    else
        -- append at the end of the array
        table.insert(dumpData, itemDepotLocator)
    end

    -- save this shit
    SaveData(dumpData)
end

-- remove a depot to the dump
function enterprise_dump.DelistItemDepot(itemDepotLocator)
    -- vars
    local found     = false
    local dumpData  = LoadData()

    -- check if this one is in our list
    for i, loc in ipairs(dumpData) do

        -- check if both URL's are the same

    end

    -- save this shit
    if found then SaveData(dumpData) end
end

--    _                 _
--   | |               | |
--   | | ___   ___ __ _| |
--   | |/ _ \ / __/ _` | |
--   | | (_) | (_| (_| | |
--   |_|\___/ \___\__,_|_|
--
--

local dhtRoot = "enterprise_dump" -- just a list of available depot locators

function LoadData()
    local dumpData  = nil                       -- silly two liner to suppress lua warning
    dumpData        = coredht.GetData(dhtRoot)  -- silly two liner to suppress lua warning

    -- check data
    if type(dumpData) ~= "table" or type(dumpData[1]) ~= "table" then dumpData = Reset() end

    -- check if we are present...
    return dumpData
end

function SaveData(dumpData)
    -- check if we are present...
    coredht.SaveData(dumpData, dhtRoot)
end

function Reset()
    -- start over
    local dumpData = {}

    -- add any turtle
    table.insert(dumpData, enterprise_turtle.GetAnyTurtleLocator())

    -- save!
    SaveData(dumpData)

    -- yahoo!
    return dumpData

    --    -- if you like one liners, not so readable
--    return SaveData({enterprise_turtle.GetAnyTurtleLocator()})
end

-- done
return enterprise_dump
