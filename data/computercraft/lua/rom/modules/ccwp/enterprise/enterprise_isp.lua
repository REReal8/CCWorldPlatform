-- define module
local enterprise_isp = {}

--[[
    The Item Service Provider (ISP) is an enterprise that provides services to handle items. From the perspective of an enterprise that needs
    items to be handled across (possibly) multiple enterprises the ISP can be seen as a generic entrypoint (or hub or router) for handling
    those items.

    The ISP provides the following additional public services
        AddItemsLocators_SSrv       - adds the items of multiple itemsLocators into one itemsLocator. The itemsLocators should have the same host/ base component.
--]]

local corelog = require "corelog"

local Class = require "class"

local InputChecker = require "input_checker"

local URL = require "obj_url"
local ObjHost = require "obj_host"

local IItemDepot = require "i_item_depot"

local role_energizer = require "role_energizer"

--                        _
--                       (_)
--    ___  ___ _ ____   ___  ___ ___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \
--   \__ \  __/ |   \ V /| | (_|  __/
--   |___/\___|_|    \_/ |_|\___\___|

function enterprise_isp.NeedsTo_TransferItems_SSrv(...)
    -- get & check input from description
    local checkSuccess, sourceItemsLocator, destinationItemDepotLocator = InputChecker.Check([[
        This sync public service returns the (fuel) needs for the transfer of items from one ItemDepot to another.

        This service is implemented using the following underlying ItemDepot services
            getItemDepotLocation

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
    --]], ...)
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

    -- get sourceItemDepot
    local sourceItemDepotLocator = sourceItemsLocator:baseCopy()
    local sourceItemDepot = ObjHost.GetObject(sourceItemDepotLocator)
    if not sourceItemDepot or not Class.IsInstanceOf(sourceItemDepot, IItemDepot) then corelog.Error("enterprise_isp.NeedsTo_TransferItems_SSrv: Failed obtaining an IItemDepot from sourceItemDepotLocator "..sourceItemDepotLocator:getURI()) return {success = false} end

    -- get destinationItemDepot
    local destinationItemDepot = ObjHost.GetObject(destinationItemDepotLocator)
    if not destinationItemDepot or not Class.IsInstanceOf(destinationItemDepot, IItemDepot) then corelog.Error("enterprise_isp:NeedsTo_TransferItems_SSrv: Failed obtaining an IItemDepot from destinationItemDepotLocator "..destinationItemDepotLocator:getURI()) return {success = false} end

    -- get locations
    local sourceItemDepotLocation = sourceItemDepot:getItemDepotLocation()
    local destinationItemDepotLocation = destinationItemDepot:getItemDepotLocation()

    -- determine fuelNeed
    local fuelNeed_FromSourceItemDepotToDestinationItemDepot = role_energizer.NeededFuelToFrom(destinationItemDepotLocation, sourceItemDepotLocation)

    -- end
    return {
        success     = true,
        fuelNeed    = fuelNeed_FromSourceItemDepotToDestinationItemDepot,
    }
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
