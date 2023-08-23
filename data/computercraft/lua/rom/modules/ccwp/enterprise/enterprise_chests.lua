-- define class
local Class = require "class"
local MObjHost = require "eobj_mobj_host"
local enterprise_chests = Class.NewClass(MObjHost)

local corelog = require "corelog"

local InputChecker = require "input_checker"
local Callback = require "obj_callback"

--[[
    The enterprise_chests is a Host. It hosts Chest's (i.e. Factory's).

    It provides the following specific enterprise services
        UpdateChestRecord_ASrv  - brings the records of a chest up-to-date by fetching parameters
--]]

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

-- note: currently enterprise is treated like a singleton, but by directly using the name of the module
-- ToDo: consider making changes to enteprise to
--          - explicitly make it a singleton (by construction with :newInstance(hostName) and using the singleton pattern)
--          - properly initialise it (by adding and implementing the _init method)
--          - adopt other classes to these changes
enterprise_chests._hostName = "enterprise_chests"

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

function enterprise_chests:getClassName()
    return "enterprise_chests"
end

--                        _                           _   _               _
--                       (_)                         | | | |             | |
--    ___  ___ _ ____   ___  ___ ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \  __/ |   \ V /| | (_|  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/\___|_|    \_/ |_|\___\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

function enterprise_chests.UpdateChestRecord_ASrv(...)
    -- get & check input from description
    local checkSuccess, chestLocator, callback = InputChecker.Check([[
        This async public service brings the records of a chest up-to-date by fetching information and (re)setting the chest records.

        Using this method should normally not be needed as the records should be kept up-to-date by the various enterprise services. It could
        typically be used for development purposes or, if for some reason (e.g. after a turtle crash), the chest records could have been corrupted.

        Return value:
                                - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                - (table)
                success         - (boolean) whether the service executed successfully

        Parameters:
            serviceData         - (table) data about the service
                chestLocator    + (URL) locating the chest
            callback            + (Callback) to call once service is ready
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("enterprise_chests.UpdateChestRecord_ASrv: Invalid input") return Callback.ErrorCall(callback) end

    -- get chest
    local chest = enterprise_chests:getObject(chestLocator)
    if type(chest) ~= "table" then corelog.Error("enterprise_chests.UpdateChestRecord_ASrv: Chest "..chestLocator:getURI().." not found.") return Callback.ErrorCall(callback) end

    -- have chest update it's records
    return chest:updateChestRecord_AOSrv({}, callback)
end

-- ToDo: consider getting from/ moving to Chest
function enterprise_chests.GetItemsLocations_SSrv(...)
    -- get & check input from description
    local checkSuccess, itemsLocator = InputChecker.Check([[
        This sync public service provides the current world locations of different items in an ItemDepot.

        Return value:
                                    - (table)
                success             - (boolean) whether the service executed successfully
                locations           - (table) with Location's of the different items

        Parameters:
            serviceData             - (table) data about this service
                itemsLocator        + (URL) locating the items for which to get the location
                                        (the "base" component of the URL specifies the ItemDepot that provides the items)
                                        (the "query" component of the URL specifies the items)
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("enterprise_chests.GetItemsLocations_SSrv: Invalid input") return {success = false} end

    -- get chest
    local chest = enterprise_chests:getObject(itemsLocator)
    if type(chest) ~= "table" then corelog.Error("enterprise_chests.GetItemsLocations_SSrv: Chest "..itemsLocator:getURI().." not found.") return {success = false} end

    -- get location
    local location = chest:getBaseLocation()

    -- end
    return {
        success     = true,
        locations   = { location:copy() },
    }
end

-- ToDo: consider getting from/ moving to Chest
function enterprise_chests.GetItemDepotLocation_SSrv(...)
    -- get & check input from description
    local checkSuccess, itemDepotLocator = InputChecker.Check([[
        This sync public service provides the world location of an ItemDepot.

        Return value:
                                    - (table)
                success             - (boolean) whether the service executed successfully
                location            - (Location) location of the ItemDepot

        Parameters:
            serviceData             - (table) data about this service
                itemDepotLocator    + (URL) locating the ItemDepot for which to get the location
                                        (the "base" component of the URL should specify this ItemDepot enterprise)
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("enterprise_chests.GetItemDepotLocation_SSrv: Invalid input") return {success = false} end

    -- get chest
    local chest = enterprise_chests:getObject(itemDepotLocator)
    if type(chest) ~= "table" then corelog.Error("enterprise_chests.GetItemDepotLocation_SSrv: Chest "..itemDepotLocator:getURI().." not found.") return {success = false} end

    -- get location
    local location = chest:getBaseLocation()

    -- end
    return {
        success     = true,
        location    = location:copy(),
    }
end

return enterprise_chests
