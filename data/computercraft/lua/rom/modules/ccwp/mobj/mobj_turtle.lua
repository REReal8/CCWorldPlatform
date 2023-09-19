-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local IItemSupplier = require "i_item_supplier"
local IItemDepot = require "i_item_depot"
local Turtle = Class.NewClass(ObjBase, IItemSupplier, IItemDepot)

--[[
    The Turtle mobj represents a Turtle in the minecraft world and provides services to operate on that Turtle.
--]]

local corelog = require "corelog"
local coreinventory = require "coreinventory"
local coremove = require "coremove"

local InputChecker = require "input_checker"
local Callback = require "obj_callback"
local Location = require "obj_location"
local Inventory = require "obj_inventory"
local ItemTable = require "obj_item_table"

local role_fuel_worker = require "role_fuel_worker"

local enterprise_isp = require "enterprise_isp"
local enterprise_turtle

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function Turtle:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a Turtle.

        Parameters:
            o                           + (table, {}) table with object fields
                _id                     - (string, "any") id of the Turtle
                _fuelPriorityKey        - (string, "") fuel priority key of the Turtle
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Turtle:new: Invalid input") return nil end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- end
    return o
end

function Turtle:getId()
    return self._id
end

function Turtle:getTurtleId()
    return tonumber(self:getId())
end

function Turtle:getFuelPriorityKey()
    return self._fuelPriorityKey
end

function Turtle:setFuelPriorityKey(fuelPriorityKey)
    -- check
    if type(fuelPriorityKey) ~= "string" then corelog.Error("Turtle:setFuelPriorityKey: Invalid fuelPriorityKey(type="..type(fuelPriorityKey)..")") return end

    self._fuelPriorityKey = fuelPriorityKey
end

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

function Turtle:getClassName()
    return "Turtle"
end

--    _____ _____ _                  _____                   _ _                            _   _               _
--   |_   _|_   _| |                / ____|                 | (_)                          | | | |             | |
--     | |   | | | |_ ___ _ __ ___ | (___  _   _ _ __  _ __ | |_  ___ _ __   _ __ ___   ___| |_| |__   ___   __| |___
--     | |   | | | __/ _ \ '_ ` _ \ \___ \| | | | '_ \| '_ \| | |/ _ \ '__| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| |_ _| |_| ||  __/ | | | | |____) | |_| | |_) | |_) | | |  __/ |    | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____|_____|\__\___|_| |_| |_|_____/ \__,_| .__/| .__/|_|_|\___|_|    |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                                              | |   | |
--                                              |_|   |_|

function Turtle:provideItemsTo_AOSrv(...)
    -- get & check input from description
    local checkSuccess, provideItems, itemDepotLocator, assignmentsPriorityKey, callback = InputChecker.Check([[
        This async public ItemSupplier service provides specific items to an ItemDepot.

        Return value:
                                                - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                                - (table)
                success                         - (boolean) whether the service executed correctly
                destinationItemsLocator         - (URL) locating the final ItemDepot and the items that where transferred to it
                                                    (upon service succes the "host" component of this URL should be equal to itemDepotLocator, and
                                                    the "query" should be equal to orderItems)

        Parameters:
            serviceData                         - (table) data for the service
                provideItems                    + (table) with one or more items (formatted as an array of [itemName] = itemCount key-value pairs) to provide
                itemDepotLocator                + (URL) locating the ItemDepot where the items need to be provided to
                assignmentsPriorityKey          + (string, "") priorityKey that should be set for all assignments triggered by this service
            callback                            + (Callback) to call once service is ready
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Turtle:provideItemsTo_AOSrv: Invalid input") return Callback.ErrorCall(callback) end

    -- check items available in inventory
    local hasItems = self:getInventory():hasItems(provideItems)
    if not hasItems then corelog.Error("Turtle:provideItemsTo_AOSrv: provideItems(="..textutils.serialise(provideItems)..") not (all) available in Turtle") return Callback.ErrorCall(callback) end

    -- create turtleItemsLocator
    enterprise_turtle = enterprise_turtle or require "enterprise_turtle"
    local turtleItemsLocator = enterprise_turtle:getTurtleLocator(tostring(self:getTurtleId())) if not turtleItemsLocator then corelog.Error("Turtle:provideItemsTo_AOSrv: Invalid turtleItemsLocator created.") return Callback.ErrorCall(callback) end
    turtleItemsLocator:setQuery(provideItems)

    -- store items from this turtle to ItemDepot
    local serviceData = {
        itemsLocator                = turtleItemsLocator,
        itemDepotLocator            = itemDepotLocator,
        assignmentsPriorityKey      = assignmentsPriorityKey,
    }
    --    corelog.WriteToLog(">Store "..turtleItemsLocator:getURI().." from Turtle")
    return enterprise_isp.StoreItemsFrom_ASrv(serviceData, callback)
end

function Turtle:can_ProvideItems_QOSrv(...)
    -- get & check input from description
    local checkSuccess, provideItems = InputChecker.Check([[
        This sync public query service answers the question whether the ItemSupplier can provide specific items.

        Return value:
                                    - (table)
                success             - (boolean) whether the answer to the question is true

        Parameters:
            serviceData             - (table) data to the query
                provideItems        + (table) with one or more items (formatted as an array of [itemName] = itemCount key-value pairs) to provide
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Turtle:can_ProvideItems_QOSrv: Invalid input") return {success = false} end

    -- check items in inventory
    local hasItems = self:getInventory():hasItems(provideItems)

    -- end
    return {
        success = hasItems,
    }
end

function Turtle:needsTo_ProvideItemsTo_SOSrv(...)
    -- get & check input from description
    local checkSuccess, provideItems, itemDepotLocator = InputChecker.Check([[
        This sync public service returns the needs for the ItemSupplier to provide specific items to an ItemDepot.

        Return value:
                                                - (table)
                success                         - (boolean) whether the service executed correctly
                fuelNeed                        - (number) amount of fuel needed to provide items
                ingredientsNeed                 - (table) ingredients needed to provide items

        Parameters:
            serviceData                         - (table) data to the query
                provideItems                    + (table) with one or more items (formatted as an array of [itemName] = itemCount key-value pairs) to provide
                itemDepotLocator                + (URL) locating the ItemDepot where the items need to be provided to
                ingredientsItemSupplierLocator  - (URL, nil) locating where ingredients can be retrieved
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Turtle:needsTo_ProvideItemsTo_SOSrv: Invalid input") return {success = false} end

    -- get location
    local turtleLocation = self:getLocation()

    -- loop on items
    local fuelNeed = 0
    for itemName, itemCount in pairs(provideItems) do
        -- check
        if type(itemName) ~= "string" then corelog.Error("Turtle:needsTo_ProvideItemsTo_SOSrv: Invalid itemName (type="..type(itemName)..")") return {success = false} end
        if type(itemCount) ~= "number" then corelog.Error("Turtle:needsTo_ProvideItemsTo_SOSrv: Invalid itemCount (type="..type(itemCount)..")") return {success = false} end

        -- fuelNeed from turtle to itemDepotLocator
        local serviceData = {
            itemDepotLocator = itemDepotLocator,
        }
        local serviceResults =  enterprise_isp.GetItemDepotLocation_SSrv(serviceData)
        if not serviceResults or not serviceResults.success then corelog.Error("Turtle:needsTo_ProvideItemsTo_SOSrv: failed obtaining location for ItemDepot "..type(itemDepotLocator)..".") return {success = false} end
        -- ToDo: consider how to handle if path isn't the shortest route, should we maybe modify things to do something like GetTravelDistanceBetween
        local fuelNeed_FromTurtleToItemDepot = role_fuel_worker.NeededFuelToFrom(serviceResults.location, turtleLocation)

        -- add fuelNeed
--        corelog.WriteToLog("T  fuelNeed_FromTurtleToItemDepot="..fuelNeed_FromTurtleToItemDepot)
        fuelNeed = fuelNeed + fuelNeed_FromTurtleToItemDepot
    end

    -- end
    local ingredientsNeed = {}
    return {
        success         = true,
        fuelNeed        = fuelNeed,
        ingredientsNeed = ingredientsNeed,
    }
end

--    _____ _____ _                 _____                   _                    _   _               _
--   |_   _|_   _| |               |  __ \                 | |                  | | | |             | |
--     | |   | | | |_ ___ _ __ ___ | |  | | ___ _ __   ___ | |_   _ __ ___   ___| |_| |__   ___   __| |___
--     | |   | | | __/ _ \ '_ ` _ \| |  | |/ _ \ '_ \ / _ \| __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| |_ _| |_| ||  __/ | | | | | |__| |  __/ |_) | (_) | |_  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____|_____|\__\___|_| |_| |_|_____/ \___| .__/ \___/ \__| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                                             | |
--                                             |_|

function Turtle:storeItemsFrom_AOSrv(...)
    -- get & check input from description
    local checkSuccess, itemsLocator, assignmentsPriorityKey, callback = InputChecker.Check([[
        This async public ItemDepot service stores items from from an ItemSupplier.

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
    if not checkSuccess then corelog.Error("Turtle:storeItemsFrom_AOSrv: Invalid input") return Callback.ErrorCall(callback) end

    -- check source is a turtle
    enterprise_turtle = enterprise_turtle or require "enterprise_turtle"
    if enterprise_turtle:isLocatorFromHost(itemsLocator) then -- source is a turtle
        -- check same turtle
        local sourceTurtleId = enterprise_turtle.GetTurtleId_SSrv({ turtleLocator = itemsLocator }).turtleId if not sourceTurtleId then corelog.Error("Turtle:storeItemsFrom_AOSrv: Failed obtaining sourceTurtleId from itemsLocator="..itemsLocator:getURI()) return Callback.ErrorCall(callback) end
        local currentTurtleId = os.getComputerID()
        if sourceTurtleId and currentTurtleId ~= sourceTurtleId then corelog.Error("Turtle:storeItemsFrom_AOSrv: Store items from one (id="..sourceTurtleId..") turtle to another (id="..currentTurtleId..") not implemented (?yet).") return Callback.ErrorCall(callback) end

        -- verify turtle has items (aleady)
        local storeItems = itemsLocator:getQuery()
        local hasItems = self:getInventory():hasItems(storeItems)
        if not hasItems then corelog.Error("Turtle:storeItemsFrom_AOSrv: storeItems not (all) items available in Turtle") return Callback.ErrorCall(callback) end

        -- determine destinationItemsLocator
        local destinationItemsLocator = itemsLocator:copy()

        -- end
        local result = {
            success                     = true,
            destinationItemsLocator     = destinationItemsLocator,
        }
        return callback:call(result)
    else -- source is not a turtle
        -- create turtleLocator
        local turtleLocator = enterprise_turtle:getTurtleLocator(tostring(self:getTurtleId())) if not turtleLocator then corelog.Error("Turtle:storeItemsFrom_AOSrv: Invalid turtleLocator created.") return Callback.ErrorCall(callback) end

        -- have source ItemSupplier provideItemsTo Turtle
        local ingredientsItemSupplierLocator = itemsLocator:copy() -- note: this is intended as a dummy ingredientsItemSupplierLocator, it should not be needed here as we are asked to store items from and ItemSupplier so I guess it is safe to assume the ItemSupplier already has the items (otherwise why store it)
        local wasteItemDepotLocator = turtleLocator:copy() -- note: only added because ProvideItemsTo_ASrv asks for it. It will/ should also not be used/ needed as storing items implies no waste.
        local serviceData = {
            itemsLocator                = itemsLocator,
            itemDepotLocator            = turtleLocator,
            ingredientsItemSupplierLocator = ingredientsItemSupplierLocator,
            wasteItemDepotLocator       = wasteItemDepotLocator,
            assignmentsPriorityKey      = assignmentsPriorityKey,
        }
        return enterprise_isp.ProvideItemsTo_ASrv(serviceData, callback)
    end
end

function Turtle:can_StoreItems_QOSrv(...)
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
    if not checkSuccess then corelog.Error("Turtle:can_StoreItems_QOSrv: Invalid input") return {success = false} end

    -- ToDo: implement
    corelog.Warning("Turtle:can_StoreItems_QOSrv: not yet implemented")
    return {success = false}
end

function Turtle:needsTo_StoreItemsFrom_SOSrv(...)
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
    if not checkSuccess then corelog.Error("Turtle:needsTo_StoreItemsFrom_SOSrv: Invalid input") return {success = false} end

    -- ToDo: implement
    corelog.Warning("Turtle:needsTo_StoreItemsFrom_SOSrv: not yet implemented")
    return {success = false}
end

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

function Turtle:getLocation()
    -- check current Turtle
    if self:getTurtleId() ~= os.getComputerID() then corelog.Warning("Turtle:getLocation() not yet supported on other Turtle(="..self:getTurtleId()..") than current(="..os.getComputerID()..")") end

    -- get location
    local location = Location:new(coremove.GetLocation())

    -- end
    return location
end


function Turtle:getInventory()
    -- check current Turtle
    if self:getTurtleId() ~= os.getComputerID() then corelog.Warning("Turtle:getInventory() not yet supported on other Turtle(="..self:getTurtleId()..") than current(="..os.getComputerID()..")") end

    -- get current Turtle inventory slots
    local slotTable = {}
    for slot=1,16 do
        -- get detailed information about this slot
        local itemDetail = coreinventory.GetItemDetail(slot)

        -- right item?
        if type(itemDetail) == "table" then
            -- add to slots, name and count
            slotTable[ slot ] = itemDetail
        end
    end

    -- construct Inventory object
    local inventory = Inventory:newInstance(slotTable)

    -- end
    return inventory
end

function Turtle:getInventoryAsItemTable()
    -- check current Turtle
    if self:getTurtleId() ~= os.getComputerID() then corelog.Warning("Turtle:getInventoryAsItemTable() not yet supported on other Turtle(="..self:getTurtleId()..") than current(="..os.getComputerID()..")") end

    -- why multiline when it can be done in a single line? Well, for readablilty and debugging ofcourse!
    local inventory = Turtle:getInventory()
    local itemTable = inventory:getItemTable()

    -- return the table as an object ItemTable
    return ItemTable:newInstance(itemTable)
end

return Turtle
