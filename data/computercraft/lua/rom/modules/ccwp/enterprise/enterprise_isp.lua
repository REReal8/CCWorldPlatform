-- define module
local enterprise_isp = {}

--[[
    The Item Service Provider (ISP) is an enterprise that provides services to handle items. From the perspective of an enterprise that needs
    items to be handled across (possibly) multiple enterprises the ISP can be seen as a generic entrypoint (or hub or router) for handling
    those items.

    The ISP offers generic IItemSupplier and IItemDepot services by relaying them to the underlying ItemSupplier or ItemDepot based on the "base" component of URL's.
    Besides that the interface of the corresponding ISP services is the same.

    The ISP provides the following additional public services
        NeedsTo_TransferItems_SSrv  - returns the (fuel) needs for the transfer of items from one ItemDepot to another.
        AddItemsLocators_SSrv       - adds the items of multiple itemsLocators into one itemsLocator. The itemsLocators should have the same host/ base component.
--]]

local corelog = require "corelog"

local InputChecker = require "input_checker"
local Callback = require "obj_callback"
local MethodExecutor = require "method_executor"
local URL = require "obj_url"
local Host = require "obj_host"

local role_fuel_worker = require "role_fuel_worker"

--                        _                           _   _               _
--                       (_)                         | | | |             | |
--    ___  ___ _ ____   ___  ___ ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \  __/ |   \ V /| | (_|  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/\___|_|    \_/ |_|\___\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

function enterprise_isp.ProvideItemsTo_ASrv(...)
    -- get & check input from description
    local checkSuccess, itemsLocator, itemDepotLocator, ingredientsItemSupplierLocator, wasteItemDepotLocator, assignmentsPriorityKey, callback = InputChecker.Check([[
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
                itemsLocator                    + (URL) locating the items to provide
                                                    (the "base" component of the URL specifies the ItemSupplier that provides the items)
                                                    (the "query" component of the URL specifies the items)
                itemDepotLocator                + (URL) locating the ItemDepot where the items need to be provided to
                ingredientsItemSupplierLocator  + (URL) locating where the production ingredients can be retrieved
                wasteItemDepotLocator           + (URL) locating where waste material can be delivered
                assignmentsPriorityKey          + (string, "") priorityKey that should be set for all assignments triggered by this service
            callback                            + (Callback) to call once service is ready
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("enterprise_isp.ProvideItemsTo_ASrv: Invalid input") return Callback.ErrorCall(callback) end

    -- get obj
    local itemSupplierLocator = itemsLocator:baseCopy()
    local obj = Host.GetObject(itemSupplierLocator)
    if type(obj) ~= "table" then corelog.Error("enterprise_isp.ProvideItemsTo_ASrv: obj "..itemSupplierLocator:getURI().." not found.") return Callback.ErrorCall(callback) end

    -- have obj provide items
    local provideItems = itemsLocator:getQuery()
    return obj:provideItemsTo_AOSrv({
        provideItems                    = provideItems,
        itemDepotLocator                = itemDepotLocator,
        ingredientsItemSupplierLocator  = ingredientsItemSupplierLocator,
        wasteItemDepotLocator           = wasteItemDepotLocator,
        assignmentsPriorityKey          = assignmentsPriorityKey,
    }, callback)
end

function enterprise_isp.Can_ProvideItems_QSrv(...)
    -- get & check input from description
    local checkSuccess, itemsLocator = InputChecker.Check([[
        This sync public query service answers the question whether the ItemSupplier can provide specific items.

        Return value:
                                    - (table)
                success             - (boolean) whether the answer to the question is true

        Parameters:
            serviceData             - (table) data to the query
                itemsLocator        + (URL) locating the items that need to be queried for providability
                                        (the "base" component of the URL specifies the ItemSupplier that provides the items)
                                        (the "query" component of the URL specifies the items to query for)
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("enterprise_isp.Can_ProvideItems_QSrv: Invalid input") return {success = false} end

    -- get obj
    local itemSupplierLocator = itemsLocator:baseCopy()
    local obj = Host.GetObject(itemSupplierLocator)
    if type(obj) ~= "table" then corelog.Error("enterprise_isp.Can_ProvideItems_QSrv: obj "..itemSupplierLocator:getURI().." not found.") return {success = false} end

    -- check obj can provide items
    local provideItems = itemsLocator:getQuery()
    local canProvide = obj:can_ProvideItems_QOSrv({
        provideItems    = provideItems,
    })

    -- end
    return canProvide
end

function enterprise_isp.NeedsTo_ProvideItemsTo_SSrv(...)
    -- get & check input from description
    local checkSuccess, itemsLocator, itemDepotLocator, ingredientsItemSupplierLocator = InputChecker.Check([[
        This sync public service returns the needs for an ItemSupplier to provide specific items to an ItemDepot.

        Return value:
                                                - (table)
                success                         - (boolean) whether the service executed correctly
                fuelNeed                        - (number) amount of fuel needed to provide items
                ingredientsNeed                 - (table) ingredients needed to provide items

        Parameters:
            serviceData                         - (table) data to the query
                itemsLocator                    + (URL) locating the items to provide
                                                    (the "base" component of the URL specifies the ItemSupplier that provides the items)
                                                    (the "query" component of the URL specifies the items)
                itemDepotLocator                + (URL) locating the ItemDepot where the items need to be delivered to
                ingredientsItemSupplierLocator  + (URL) optionally locating another ItemSupplier where needed ingredient items for the ItemSupplier could be retrieved
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("enterprise_isp.NeedsTo_ProvideItemsTo_SSrv: Invalid input") return {success = false} end

    -- get Obj
    local itemSupplierLocator = itemsLocator:baseCopy()
    local obj = Host.GetObject(itemSupplierLocator)
    if type(obj) ~= "table" then corelog.Error("enterprise_isp.NeedsTo_ProvideItemsTo_SSrv: obj "..itemSupplierLocator:getURI().." not found.") return {success = false} end

    -- determine needs
    local provideItems = itemsLocator:getQuery()
    local needs = obj:needsTo_ProvideItemsTo_SOSrv({
        provideItems                    = provideItems,
        itemDepotLocator                = itemDepotLocator,
        ingredientsItemSupplierLocator  = ingredientsItemSupplierLocator,
    })

    -- end
    return needs
end

function enterprise_isp.NeedsTo_TransferItems_SSrv(...)
    -- get & check input from description
    local checkSuccess, sourceItemsLocator, destinationItemDepotLocator = InputChecker.Check([[
        This sync public service returns the (fuel) needs for the transfer of items from one ItemDepot to another.

        This service is implemented using the following underlying ItemDepot services
            GetItemsLocations_SSrv
            GetItemDepotLocation_SSrv

        Return value:
                                            - (table)
                success                     - (boolean) whether the service executed successfully
                fuelNeed                    - (number) amount of fuel needed to transfer the items

        Parameters:
            transferData                    - (table) data about the transfer
                sourceItemsLocator          + (URL) locating the items that need transfer
                                                (the "query" component of the URL specifies the items to be transferred)
                                                (the "host" component of the URL specifies the ItemDepot where the items are located)
                destinationItemDepotLocator + (URL) locating the ItemDepot that needs to be transferred to
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("enterprise_isp.NeedsTo_TransferItems_SSrv: Invalid input") return {success = false} end

    -- check there are actual items to transfer
    local transferItems = sourceItemsLocator:getQuery()
    if next(transferItems) == nil then
        corelog.Warning("enterprise_isp.NeedsTo_TransferItems_SSrv: There are 0 items to transfer (from "..sourceItemsLocator:getURI().." to "..destinationItemDepotLocator:getURI()..").")
        return {
            success     = true,
            fuelNeed    = 0,
        }
    end

    -- determine sourceItemsLocations
    local serviceResults = enterprise_isp.GetItemsLocations_SSrv({ itemsLocator = sourceItemsLocator })
    if not serviceResults.success then corelog.Error("enterprise_isp.NeedsTo_TransferItems_SSrv: failed obtaining locations for items "..sourceItemsLocator:getURI()..".") return {success = false} end
    local itemsLocations = serviceResults.locations

    -- determine destinationLocation
    serviceResults = enterprise_isp.GetItemDepotLocation_SSrv({ itemDepotLocator = destinationItemDepotLocator })
    if not serviceResults.success then corelog.Error("enterprise_isp.NeedsTo_TransferItems_SSrv: failed obtaining location for ItemDepot "..destinationItemDepotLocator:getURI()..".") return {success = false} end
    local itemDepotLocation = serviceResults.location

    -- determine fuelNeed
    local fuelNeed = 0
    for i, itemlocation in ipairs(itemsLocations) do
        -- ToDo: consider how to handle if path isn't the shortest route, should we maybe modify things to do something like GetTravelDistanceBetween
        fuelNeed = fuelNeed + role_fuel_worker.NeededFuelToFrom(itemDepotLocation, itemlocation)
    end

    -- end
    return {
        success     = true,
        fuelNeed    = fuelNeed,
    }
end

local function GetItemDepotName_SSrv(...)
    -- get & check input from description
    local checkSuccess, itemDepotLocator = InputChecker.Check([[
        This sync private service provides the (enterprise) name of an ItemDepot.

        Return value:
                                    - (table)
                success             - (boolean) whether the service executed successfully
                enterpriseName      - (string) with (enterprise) name of the ItemDepot

        Parameters:
            serviceData             - (table) data about this service
                itemDepotLocator    + (URL) locating the ItemDepot
                                        (the "base" component of the URL should specify an ItemDepot enterprise)
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("enterprise_isp.GetItemDepotName_SSrv: Invalid input") return {success = false} end

    -- determine ItemDepot name
    local host = itemDepotLocator:getHost()
    if type(host) ~= "string" then corelog.Error("enterprise_isp.GetItemDepotName_SSrv: host of wrong type = "..type(host)..".") return {success = false} end
    local enterpriseName = nil
        if host == "enterprise_chests"  then enterpriseName = "enterprise_chests"
    elseif host == "enterprise_turtle"  then enterpriseName = "enterprise_turtle"
    else corelog.Error("enterprise_isp.GetItemDepotName_SSrv: Not implemented for "..host .." host.") return {success = false} end

    -- end
    return {
        success         = true,
        enterpriseName  = enterpriseName,
    }
end

function enterprise_isp.GetItemsLocations_SSrv(...)
    -- get & check input from description
    local checkSuccess, serviceData, itemsLocator = InputChecker.Check([[
        This sync public service provides the current world locations of different items in an ItemDepot.

        Return value:
                                    - (table)
                success             - (boolean) whether the service executed successfully
                locations           - (table) with Location's of the different items

        Parameters:
            serviceData             + (table) data about this service
                itemsLocator        + (URL) locating the items for which to get the location
                                        (the "base" component of the URL specifies the ItemDepot that provides the items)
                                        (the "query" component of the URL specifies the items)
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("enterprise_isp.GetItemsLocations_SSrv: Invalid input") return {success = false} end

    -- get ItemDepot
    local serviceResults = GetItemDepotName_SSrv( { itemDepotLocator = itemsLocator })
    if not serviceResults.success then corelog.Error("enterprise_isp.GetItemsLocations_SSrv: failed obtaining itemDepotName for "..itemsLocator:getURI()..".") return {success = false} end
    local itemDepotName = serviceResults.enterpriseName

    -- call method on ItemDepot
    local serviceName = "GetItemsLocations_SSrv"
    serviceResults = MethodExecutor.DoSyncService(itemDepotName, serviceName, serviceData)

    -- end
    return serviceResults
end

function enterprise_isp.GetItemDepotLocation_SSrv(...)
    -- get & check input from description
    local checkSuccess, serviceData, itemDepotLocator = InputChecker.Check([[
        This sync public service provides the world location of an ItemDepot.

        Return value:
                                    - (table)
                success             - (boolean) whether the service executed successfully
                location            - (Location) location of the ItemDepot

        Parameters:
            serviceData             + (table) data about this service
                itemDepotLocator    + (URL) locating the ItemDepot for which to get the location
                                        (the "base" component of the URL should specify an ItemDepot enterprise)
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("enterprise_isp.GetItemDepotLocation_SSrv: Invalid input") return {success = false} end

    -- get ItemDepot
    local serviceResults = GetItemDepotName_SSrv( { itemDepotLocator = itemDepotLocator })
    if not serviceResults.success then corelog.Error("enterprise_isp.GetItemDepotLocation_SSrv: failed obtaining itemDepotName for "..itemDepotLocator:getURI()..".") return {success = false} end
    local itemDepotName = serviceResults.enterpriseName

    -- call method on ItemDepot
    local serviceName = "GetItemDepotLocation_SSrv"
    serviceResults = MethodExecutor.DoSyncService(itemDepotName, serviceName, serviceData)

    -- end
    return serviceResults
end

function enterprise_isp.AddItemsLocators_SSrv(serviceData)
    --[[
        This sync public service adds the items of multiple itemsLocators into one itemsLocator. The itemsLocators should have the same host/ base component.

        Return value:
                                    - (table)
                success             - (boolean) whether the service executed successfully
                itemsLocator        - (URL) locating all items

        Parameters:
            serviceData             - (table) data about the query
                itemsLocator1       - (URL) a itemsLocator locating items
                                        (the "base" component of the URL specifies the host to query)
                                        (the "query" component of the URL specifies the items to query for)
                [itemsLocator2]     - (URL) another itemsLocator locating items
                [itemsLocatorN]     - (URL) and the final itemsLocator locating items
    --]]

    -- check input
    if type(serviceData) ~= "table" then corelog.Error("enterprise_isp.AddItemsLocators_SSrv: Invalid queryData") return {success = false} end

--    local itemsLocator = queryData.itemsLocator
--    if type(itemsLocator) ~= "table" then corelog.Error("enterprise_isp.AddItemsLocators_SSrv: Invalid itemsLocator") return {success = false} end

    -- use remaining input
    local allTrue = true
    local resultItemsLocator = nil
    for fieldKey, fieldvalue in pairs(serviceData) do
        -- check if it's a URL
        if type(fieldvalue) == "table" then
            -- wrap into URL
            local fieldItemsLocator = URL:new(fieldvalue)

            -- check if first
            if resultItemsLocator == nil then
                -- copy first
                resultItemsLocator = fieldItemsLocator:copy()
            else
                -- check if same host/ base as resultItemsLocator so far
                if not fieldItemsLocator:sameBase(resultItemsLocator) then
                    corelog.Error("enterprise_isp.AddItemsLocators_SSrv: Adding itemsLocator's (resultItemsLocator="..resultItemsLocator:getURI()..", fieldItemsLocator="..fieldItemsLocator:getURI()..") with different base not supported")
                    return {success = false}
                end

                -- add query component's
                local resultItemQuery = resultItemsLocator:getQuery()
                enterprise_isp.AddItemsTo(resultItemQuery, fieldItemsLocator:getQuery())
            end
        else
            corelog.Warning("enterprise_isp.AddItemsLocators_SSrv: Invalid fieldvalue (type="..type(fieldvalue)..")")
        end
    end
    if resultItemsLocator == nil then corelog.Error("enterprise_isp.AddItemsLocators_SSrv: Couldn't construct combined itemsLocator") return {success = false} end

    -- end
    local result = {
        success = allTrue,
        itemsLocator = resultItemsLocator
    }
    return result
end

function enterprise_isp.AddItemsTo(items, itemsToAdd)
    --[[
        This sync public function adds the items of itemsToAdd to items.

        Return value:
                                - (table)
                success         - (boolean) whether the function executed successfully

        Parameters:
            items               - (table) with one or more items (formatted as an array of [itemName] = itemCount key-value pairs)
            itemsToAdd          - (table) with one or more items (formatted as an array of [itemName] = itemCount key-value pairs) to add
    --]]

    -- check input
    if type(items) ~= "table" then corelog.Error("enterprise_isp.AddItemsTo: Invalid items") return {success = false} end
    if type(itemsToAdd) ~= "table" then corelog.Error("enterprise_isp.AddItemsTo: Invalid itemsToAdd") return {success = false} end

    -- add items
    for itemName, itemCount in pairs(itemsToAdd) do
        -- check
        if type(itemName) ~= "string" then corelog.Error("enterprise_isp.AddItemsTo: Invalid itemName (type="..type(itemName)..")") return {success = false} end
        if type(itemCount) ~= "number" then corelog.Error("enterprise_isp.AddItemsTo: Invalid itemCount (type="..type(itemCount)..")") return {success = false} end

        -- add
        items[itemName] = (items[itemName] or 0) + itemCount
    end

    -- end
    return {success = true}
end

return enterprise_isp
