local IItemDepot = {
}

local corelog = require "corelog"

local InputChecker = require "input_checker"
local Callback = require "obj_callback"

--[[
    This module implements the interface IItemDepot.

    The IItemDepot interface defines service methods for supplying (providing) items.

    Objects of a class implementing the interface are called ItemSupplier's.
--]]

--    _____ _____ _                 _____                   _                    _   _               _
--   |_   _|_   _| |               |  __ \                 | |                  | | | |             | |
--     | |   | | | |_ ___ _ __ ___ | |  | | ___ _ __   ___ | |_   _ __ ___   ___| |_| |__   ___   __| |___
--     | |   | | | __/ _ \ '_ ` _ \| |  | |/ _ \ '_ \ / _ \| __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| |_ _| |_| ||  __/ | | | | | |__| |  __/ |_) | (_) | |_  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____|_____|\__\___|_| |_| |_|_____/ \___| .__/ \___/ \__| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                                             | |
--                                             |_|

function IItemDepot:storeItemsFrom_AOSrv(...)
    -- get & check input from description
    local checkSuccess, itemsLocator, assignmentsPriorityKey, callback = InputChecker.Check([[
        This async public ItemDepot service stores items from an ItemSupplier.

        An ItemDepot should take special care the transfer from the turtle inventory gets priority over other assignments to the turtle.

        Return value:
                                        - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                        - (table)
                success                 - (boolean) whether the service executed successfully
                destinationItemsLocator - (URL) stating the final ItemDepot and the items that where stored
                                            (upon service succes the "base" component of this URL should be equal to itemDepotLocator
                                            and the "query" should be equal to the "query" component of the itemsLocator)

        Parameters:
            serviceData                 - (table) data about the service
                itemsLocator            + (URL) locating the items to store
                                            (the "base" component of the URL specifies the ItemSupplier that provides the items)
                                            (the "query" component of the URL specifies the items)
                assignmentsPriorityKey  + (string, "") priorityKey that should be set for all assignments triggered by this service
            callback                    + (Callback) to call once service is ready
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("IItemDepot:storeItemsFrom_AOSrv: Invalid input") return Callback.ErrorCall(callback) end

    -- end
    corelog.Error("IItemDepot:storeItemsFrom_AOSrv: Method should be implemented in classes implementing the IItemDepot interface. It should not be called directly.")
    return Callback.ErrorCall(callback)
end

function IItemDepot:can_StoreItems_QOSrv(...)
    -- get & check input from description
    local checkSuccess, itemsLocator = InputChecker.Check([[
        This sync public query service answers the question whether the ItemDepot can store specific items.

        Return value:
                                    - (table)
                success             - (boolean) whether the answer to the question is true

        Parameters:
            serviceData             - (table) data to the query
                itemsLocator        + (URL) locating the items that need to be stored
                                        (the "base" component of the URL specifies the ItemDepot to store the items in)
                                        (the "query" component of the URL specifies the items to query for)
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Chest:can_StoreItems_QOSrv: Invalid input") return {success = false} end

    -- end
    corelog.Error("IItemDepot:can_StoreItems_QOSrv: Method should be implemented in classes implementing the IItemDepot interface. It should not be called directly.")
    return {success = false}
end

function IItemDepot:needsTo_StoreItemsFrom_SOSrv(...)
    -- get & check input from description
    local checkSuccess, itemsLocator = InputChecker.Check([[
        This sync public service returns the needs to store specific items from an ItemSupplier.

        Return value:
                                                - (table)
                success                         - (boolean) whether the service executed correctly
                fuelNeed                        - (number) amount of fuel needed to store items

        Parameters:
            serviceData                         - (table) data to the query
                itemsLocator                    + (URL) locating the items to store
                                                    (the "base" component of the URL specifies the ItemSupplier that provides the items)
                                                    (the "query" component of the URL specifies the items)
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Chest:needsTo_StoreItemsFrom_SOSrv: Invalid input") return {success = false} end

    -- end
    corelog.Error("IItemDepot:needsTo_StoreItemsFrom_SOSrv: Method should be implemented in classes implementing the IItemDepot interface. It should not be called directly.")
    return {success = false}
end

--        _        _   _                       _   _               _
--       | |      | | (_)                     | | | |             | |
--    ___| |_ __ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| __/ _` | __| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ || (_| | |_| | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/\__\__,_|\__|_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

function IItemDepot.ImplementsInterface(obj)
    --[[
        Returns if object 'obj' implements the interface.
    ]]

    -- check
    if not obj.storeItemsFrom_AOSrv then return false end
    if not obj.can_StoreItems_QOSrv then return false end
    if not obj.needsTo_StoreItemsFrom_SOSrv then return false end
    -- ToDo: consider adding checks for method (parameter) signatures.

    -- end
    return true
end

return IItemDepot
