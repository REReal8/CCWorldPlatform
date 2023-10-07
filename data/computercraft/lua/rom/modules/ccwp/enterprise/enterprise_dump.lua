-- defines the class (nothing special)
local enterprise_dump       = {} --Class.NewClass(Host)

--[[
    The enterprise_dump is not a Host. It remembers the possible depot's for waste processing.
--]]

-- basics
local coredht       = require "coredht"
local corelog       = require "corelog"
local Class         = require "class"
local Host          = require "obj_host"
local InputChecker  = require "input_checker"
local URL           = require "obj_url"

-- interfaces
local IItemDepot = require "i_item_depot"

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

    -- the requested URL, create from table
    local depotLocator = URL:new(dumpData[#dumpData])

    -- we return
    return depotLocator
end

-- add a depot to the dump
function enterprise_dump.ListItemDepot_SSrv(...)
    local checkSuccess, itemDepotLocator, mode = InputChecker.Check([[
        For enlisting a new item depot to the dump

        Return value:
                                    - (table)
            success                 - (boolean) whether the service executed successfully

        Parameters:
            serviceData             - (table) data for the service
                itemDepotLocator    + (URL) the depot locator to add to the dump
                mode                + (string, "append") append or overwrite the last known depot in the dump]], ...)
    if not checkSuccess then corelog.Error("enterprise_dump.ListItemDepot_SSrv: Invalid input") return {succes = false} end

    -- check if the URL is an item depot
    local itemDepot = Host.GetObject(itemDepotLocator)

    -- do some checks
    if not itemDepot                                    then corelog.Error("enterprise_dump.ListItemDepot_SSrv: itemDepotLocator invalid")           return {succes = false} end
    if not Class.IsInstanceOf(itemDepot, IItemDepot)    then corelog.Error("enterprise_dump.ListItemDepot_SSrv: itemDepotLocator not an IItemDepot") return {succes = false} end

    -- do the works
    ListItemDepot(itemDepotLocator, mode)

    -- done!
    return {success = true}
end

-- local function, placed here for readability
function ListItemDepot(itemDepotLocator, mode)

    -- get the data
    local dumpData = LoadData()

    -- add the locator, depending on the mode overwrite or append
    if mode == "overwrite" or mode == "w"   then dumpData[#dumpData] = itemDepotLocator
                                            else table.insert(dumpData, itemDepotLocator)
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