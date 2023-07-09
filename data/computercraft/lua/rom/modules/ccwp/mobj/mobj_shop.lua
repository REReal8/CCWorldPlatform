local Shop = {
    _id                     = "",

    _itemSuppliersLocators  = nil,
}

local corelog = require "corelog"

local Callback = require "obj_callback"
local InputChecker = require "input_checker"
local ObjArray = require "obj_array"

local URL = require "obj_url"

local enterprise_projects = require "enterprise_projects"
local enterprise_isp = require "enterprise_isp"
local enterprise_shop

--[[
    This module implements a Shop.

    A Shop offers services for providing items. It implements it's services by using services of ItemSupplier's registered in the Shop.

    The Shop is an ItemSupplier, hence it implements the required services.

    This allows for the Shop to be passed as ingredientsItemSupplierLocator to an ItemSupplier. The effect of that is that the ItemSupplier can request
    the ingredients from the Shop. The Shop than (by a recursive call to the OrderItems service) tries retrieving the ingredients from an ItemSupplier.
    This recursive order call will result in a successfull items order if the (sub, and sub-sub, etc) ingredients are present and/ or can be provided
    by a registered ItemSupplier.

    <It is envisioned (but not yet implemented) that a shop can also "store" (i.e. the opposite of ordering) items.>
--]]

--    _                                     _   _               _
--   | |                                   | | | |             | |
--   | |__   __ _ ___  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   | '_ \ / _` / __|/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   | |_) | (_| \__ \  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_.__/ \__,_|___/\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

function Shop:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a Shop.

        Parameters:
            o                           + (table, {}) table with object fields
                _id                     - (string) id of the forest
                _itemSuppliersLocators  - (ObjArray) with locators of registered ItemSupplier's
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Shop:new: Invalid input") return {} end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- end
    return o
end

function Shop:getClassName()
    return "Shop"
end

function Shop:getId()
    return self._id
end

function Shop:getItemSuppliersLocators()
    return self._itemSuppliersLocators
end

function Shop.HasFieldsOfType(obj)
    -- check
    if type(obj) ~= "table" then return false end
    if type(obj._id) ~= "string" then return false end
    if not ObjArray.IsOfType(obj._itemSuppliersLocators) then return false end

    -- end
    return true
end

function Shop.HasClassNameOfType(obj)
    -- check
    if not obj.getClassName or obj:getClassName() ~= Shop:getClassName() then return false end

    -- end
    return true
end

function Shop.IsOfType(obj)
    -- check
    local isOfType = Shop.HasFieldsOfType(obj) and Shop.HasClassNameOfType(obj)

    -- end
    return isOfType
end

function Shop:isSame(obj)
    -- check input
    if not Shop.IsOfType(obj) then return false end

    -- check same object
    local isSame =  self._id == obj._id
                and self._itemSuppliersLocators:isSame(obj._itemSuppliersLocators)

    -- end
    return isSame
end

function Shop:copy()
    local copy = Shop:new({
        _id                     = self._id,

        _itemSuppliersLocators  = self._itemSuppliersLocators:copy(),
    })

    return copy
end

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

function Shop:bestItemSupplier(item, itemDepotLocator, ingredientsItemSupplierLocator, itemSupplierLocator1, itemSupplierLocator2)
    --[[
        This function returns the best ItemSupplier of two ItemSupplier's for a specific item.

        Return value:
            itemSupplierLocator                 - (URL) locating the best ItemSupplier of the items

        Parameters:
            serviceData                         - (table) data to the query
                item                            + (table) with one item (formatted as [itemName] = itemCount key-value pair) to provide
                itemDepotLocator                + (URL) locating the ItemDepot where the items need to be provided to
                ingredientsItemSupplierLocator  + (URL) locating where ingredients can be retrieved
                itemSupplierLocator1            + (URL) locating the 1st ItemSupplier
                itemSupplierLocator2            + (URL) locating the 2nd ItemSupplier
    --]]

    -- check input
    if not itemSupplierLocator1 then
        return itemSupplierLocator2
    end
    if not itemSupplierLocator2 then
        return itemSupplierLocator1
    end

    -- get needs 1
    local itemLocator1 = itemSupplierLocator1:copy()
    itemLocator1:setQuery(item)
    local itemServiceData = {
        itemsLocator                    = itemLocator1,
        itemDepotLocator                = itemDepotLocator,
        ingredientsItemSupplierLocator  = ingredientsItemSupplierLocator,
    }
    local serviceResults1 = enterprise_isp.NeedsTo_ProvideItemsTo_SSrv(itemServiceData)
    if not serviceResults1.success then corelog.Error("enterprise_shop:bestItemSupplier: Failed obtaining needs for itemLocator1(="..textutils.serialise(itemLocator1)..")") return nil end

    -- get needs 2
    local itemLocator2 = itemSupplierLocator2:copy()
    itemLocator2:setQuery(item)
    itemServiceData = {
        itemsLocator                    = itemLocator2,
        itemDepotLocator                = itemDepotLocator,
        ingredientsItemSupplierLocator  = ingredientsItemSupplierLocator,
    }
    local serviceResults2 = enterprise_isp.NeedsTo_ProvideItemsTo_SSrv(itemServiceData)
    if not serviceResults2.success then corelog.Error("enterprise_shop:bestItemSupplier: Failed obtaining needs for itemLocator2(="..textutils.serialise(itemLocator2)..")") return nil end

    -- check lowest fuelNeed
    local fuelNeed1 = serviceResults1.fuelNeed
    local fuelNeed2 = serviceResults2.fuelNeed
    if fuelNeed1 < fuelNeed2 then
        return itemSupplierLocator1
    elseif fuelNeed2 < fuelNeed1 then
        return itemSupplierLocator2
    else -- both are equal w.r.t. this condition
    end

    -- check ingredientsNeed
    -- ToDo implement

    -- nothing else distinquishes the candidates => take first
    return itemSupplierLocator1
end

function Shop:getCanProvideItemSuppliers(item)
    --[[
        This function returns the ItemSupplier's that can provide a specific item.

        Return value:
            availableItemSupplierLocators   - (table) with locators of ItemSupplier's that can provide the item.

        Parameters:
            item                            + (table) with one item (formatted as [itemName] = itemCount key-value pair) to provide
    --]]

    -- select ItemSuppliers than can provide items
    local canProvideItemSupplierLocators = {}
    for i, itemSupplierLocator in ipairs(self._itemSuppliersLocators) do
        itemSupplierLocator = URL:new(itemSupplierLocator)
        -- determine itemLocator
        local itemsLocator = itemSupplierLocator:copy()
        itemsLocator:setQuery(item)

        -- check ItemSupplier can provide items
        if enterprise_isp.Can_ProvideItems_QSrv({itemsLocator = itemsLocator }).success then
            table.insert(canProvideItemSupplierLocators, itemSupplierLocator)
        end
    end

    -- end
    return canProvideItemSupplierLocators
end

function Shop:delistAllItemSuppliers()
    -- remove all ItemSupplier's from Shop
    local nLocators = #(self._itemSuppliersLocators)
    for i=nLocators, 1, -1 do
        -- cast
        local itemSupplierLocator = URL:new(self._itemSuppliersLocators[i])
        -- remove from list
        corelog.WriteToLog(">Delisting ItemSupplier "..itemSupplierLocator:getURI().." from Shop "..self:getId()..".")
        table.remove(self._itemSuppliersLocators, i)
    end

    -- save Shop
    enterprise_shop = require "enterprise_shop"
    local objLocator = enterprise_shop:saveObject(self)
    if not objLocator then corelog.Error("Shop:delistAllItemSuppliers: Failed saving Shop") return {success = false} end
end

--                        _                           _   _               _
--                       (_)                         | | | |             | |
--    ___  ___ _ ____   ___  ___ ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \  __/ |   \ V /| | (_|  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/\___|_|    \_/ |_|\___\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

function Shop:registerItemSupplier_SOSrv(...)
    -- get & check input from description
    local checkSuccess, itemSupplierLocator = InputChecker.Check([[
        This sync public service registers ("adds") an ItemSupplier in the Shop.

        Note that the ItemSupplier should already be available in the world.

        Return value:
                                    - (table)
                success             - (boolean) whether the service executed successfully

        Parameters:
            serviceData             - (table) data for the service
                itemSupplierLocator + (URL) locating the ItemSupplier
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Shop:registerItemSupplier_SOSrv: Invalid input") return {success = false} end

    -- register the ItemSupplier
    corelog.WriteToLog(">Registering ItemSupplier "..itemSupplierLocator:getURI().." at Shop "..self:getId()..".")
    table.insert(self._itemSuppliersLocators, itemSupplierLocator)

    -- save Shop
    enterprise_shop = require "enterprise_shop"
    local objLocator = enterprise_shop:saveObject(self)
    if not objLocator then corelog.Error("Shop:registerItemSupplier_SOSrv: Failed saving Shop") return {success = false} end

    -- end
    local result = {
        success = true,
    }
    return result
end

function Shop:delistItemSupplier_SOSrv(...)
    -- get & check input from description
    local checkSuccess, itemSupplierLocator = InputChecker.Check([[
        This sync public service delists ("removes") an ItemSupplier from the Shop.

        Note that the ItemSupplier is not removed from the world.

        Return value:
            success                 - (boolean) whether the service executed successfully

        Parameters:
            serviceData             - (table) data for the service
                itemSupplierLocator + (URL) locating the ItemSupplier
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Shop:delistItemSupplier_SOSrv: Invalid input") return {success = false} end

    -- get ItemSuppliers
    local itemSupplierFound = false
--    corelog.WriteToLog("   itemSupplierLocator="..textutils.serialise(itemSupplierLocator))

    for i, registeredItemSupplierLocator in ipairs(self._itemSuppliersLocators) do
        -- cast
        registeredItemSupplierLocator = URL:new(registeredItemSupplierLocator)
        -- check we found it
        if itemSupplierLocator:getURI() == registeredItemSupplierLocator:getURI() then
            -- remove from list
            corelog.WriteToLog(">Delisting ItemSupplier "..itemSupplierLocator:getURI().." from Shop "..self:getId()..".")
            itemSupplierFound = true
            table.remove(self._itemSuppliersLocators, i)

            -- save Shop
            enterprise_shop = require "enterprise_shop"
            local objLocator = enterprise_shop:saveObject(self)
            if not objLocator then corelog.Error("Shop:delistItemSupplier_SOSrv: Failed saving Shop") return {success = false} end
            break
        end
    end

    -- end
    local result = {
        success = itemSupplierFound,
    }
    return result
end

function Shop:getBestItemLocator_SOSrv(...)
    -- get & check input from description
    local checkSuccess, item, itemDepotLocator, ingredientsItemSupplierLocator = InputChecker.Check([[
        This sync services determibes the "best" ItemSupplier that can provide a specific item to an ItemDepot. It returns the
        corresponding itemLocator.

        Return value:
                                                - (table)
                success                         - (boolean) whether the service executed correctly
                itemLocator                     - (URL) locating the best ItemSupplier of the items

        Parameters:
            serviceData                         - (table) data for the service
                item                            + (table) with one item (formatted as [itemName] = itemCount key-value pair) to provide
                itemDepotLocator                + (URL) locating the ItemDepot where the items need to be provided to
                ingredientsItemSupplierLocator  + (URL) locating where ingredients can be retrieved
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("enterprise_shop:getBestItemLocator_SOSrv: Invalid input") return {success = false} end

    -- check input
    if type(item) ~= "table" then corelog.Error("enterprise_shop:getBestItemLocator_SOSrv: Invalid item (type="..type(item)..")") return {success = false} end

    -- select ItemSuppliers than can provide items
    local canProvideItemSupplierLocators = self:getCanProvideItemSuppliers(item)

    -- select best ItemSupplier
    local bestItemSupplierLocator = nil
    for i, itemSupplierLocator in ipairs(canProvideItemSupplierLocators) do
        bestItemSupplierLocator = self:bestItemSupplier(item, itemDepotLocator, ingredientsItemSupplierLocator, bestItemSupplierLocator, itemSupplierLocator)
    end
    if not bestItemSupplierLocator then corelog.Warning("enterprise_shop:getBestItemLocator_SOSrv: No ItemSupplier can provide "..textutils.serialise(item)) return {success = false} end

    -- determine itemLocator
    local itemLocator = bestItemSupplierLocator:copy()
    itemLocator:setQuery(item)

    -- end
    return {
        success             = true,
        itemLocator         = itemLocator,
    }
end

function Shop:provideItemsTo_AOSrv(...)
    -- get & check input from description
    local checkSuccess, provideItems, itemDepotLocator, ingredientsItemSupplierLocator, assignmentsPriorityKey, callback = InputChecker.Check([[
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
                ingredientsItemSupplierLocator  + (URL) locating where the production ingredients can be retrieved
                assignmentsPriorityKey          + (string, "") priorityKey that should be set for all assignments triggered by this service
            callback                            + (Callback) to call once service is ready
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Shop:provideItemsTo_AOSrv: Invalid input") return Callback.ErrorCall(callback) end

    -- determine projectSteps and projectData
    local projectSteps = {}
    local areAllTrueStepDataDef = {}
    local addItemLocatorsStepDataDef = {}
    local projectData = {}

    -- add project step for each of the ordered items
    local iStep = 0
    -- ToDo: do this in parallel by extending enterprise_projects to handle parallel project steps.
    for itemName, itemCount in pairs(provideItems) do
        -- step index
        iStep = iStep + 1
        local iStepStr = tostring(iStep)

        -- add step determining best ItemSupplier for item
        local itemKey = "item"..iStepStr
        table.insert(projectSteps,
            { stepType = "SOSrv", stepTypeDef = { className = "Shop", serviceName = "getBestItemLocator_SOSrv", objStep = 0, objKeyDef = "shop" }, stepDataDef = {
                { keyDef = "item"                           , sourceStep = 0, sourceKeyDef = itemKey },
                { keyDef = "itemDepotLocator"               , sourceStep = 0, sourceKeyDef = "itemDepotLocator" },
                { keyDef = "ingredientsItemSupplierLocator" , sourceStep = 0, sourceKeyDef = "ingredientsItemSupplierLocator" },
            }}
        )

        -- add step data
        local item = { [itemName] = itemCount }
        projectData[itemKey] = item

        -- add success stepDataDef
        table.insert(areAllTrueStepDataDef, { keyDef = "success"..iStepStr  , sourceStep = iStep, sourceKeyDef = "success" })

        --have best ItemSupplier provide item
        iStep = iStep + 1
        iStepStr = tostring(iStep)
        table.insert(projectSteps,
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_isp", serviceName = "ProvideItemsTo_ASrv" }, stepDataDef = {
                { keyDef = "itemsLocator"                   , sourceStep = iStep - 1, sourceKeyDef = "itemLocator" }, -- note: from itemLocator to itemsLocator as ProvideItemsTo_ASrv method could handle multiple
                { keyDef = "itemDepotLocator"               , sourceStep = 0, sourceKeyDef = "itemDepotLocator" },
                { keyDef = "ingredientsItemSupplierLocator" , sourceStep = 0, sourceKeyDef = "ingredientsItemSupplierLocator" },
                { keyDef = "assignmentsPriorityKey"         , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
            }}
        )

        -- add combine stepDataDef
        table.insert(addItemLocatorsStepDataDef, { keyDef = "itemsLocator"..iStepStr  , sourceStep = iStep, sourceKeyDef = "destinationItemsLocator" })

        -- add success stepDataDef
        table.insert(areAllTrueStepDataDef, { keyDef = "success"..iStepStr  , sourceStep = iStep, sourceKeyDef = "success" })
    end

    -- set remaining projectData
    projectData.itemDepotLocator = itemDepotLocator
    -- ToDo: consider first locally gathering the ordered items and sending them in one go to the itemDepotLocator if all off them are obtained.
    projectData.ingredientsItemSupplierLocator = ingredientsItemSupplierLocator
    projectData.assignmentsPriorityKey = assignmentsPriorityKey
    projectData.shop = self:copy() -- ToDo: consider providing locator at some point, to allow for things to change while performing async project

    -- add combining URL's
    iStep = iStep + 1
    table.insert(projectSteps,
        { stepType = "SSrv", stepTypeDef = { moduleName = "enterprise_isp", serviceName = "AddItemsLocators_SSrv" }, stepDataDef = addItemLocatorsStepDataDef}
    )
    local iAddItemsLocatorStep = iStep

    -- add check for all a success
    iStep = iStep + 1
    table.insert(projectSteps,
        { stepType = "SSrv", stepTypeDef = { moduleName = "enterprise_projects", serviceName = "AreAllTrue_QSrv" }, stepDataDef = areAllTrueStepDataDef}
    )
    local iAreAllTrueStep = iStep

    -- create project service data
    local projectDef = {
        steps = projectSteps,
        returnData  = {
            { keyDef = "success"                , sourceStep = iAreAllTrueStep, sourceKeyDef = "success" },
            { keyDef = "destinationItemsLocator", sourceStep = iAddItemsLocatorStep, sourceKeyDef = "itemsLocator" },
        }
    }
    local projectServiceData = {
        projectDef  = projectDef,
        projectData = projectData,
    }

    -- start project
--    corelog.WriteToLog(">Providing "..itemsLocator:getURI().."")
    return enterprise_projects.StartProject_ASrv(projectServiceData, callback)
end

function Shop:can_ProvideItems_QOSrv(...)
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
    if not checkSuccess then corelog.Error("Shop:can_ProvideItems_QOSrv: Invalid input") return {success = false} end

    -- loop on items
    for itemName, itemCount in pairs(provideItems) do
        -- check
        if type(itemName) ~= "string" then corelog.Error("Shop:can_ProvideItems_QOSrv: itemName of wrong type = "..type(itemName)..".") return {success = false} end
        if type(itemCount) ~= "number" then corelog.Error("Shop:can_ProvideItems_QOSrv: itemCount of wrong type = "..type(itemCount)..".") return {success = false} end
        local item = { [itemName] = itemCount }

        -- check for an ItemSupplier to provide item
        local canProvideItemSupplierLocators = self:getCanProvideItemSuppliers(item)
        if table.getn(canProvideItemSupplierLocators) < 1 then
            return {success = false}
        end
    end

    -- end
    return {
        success = true,
    }
end

function Shop:needsTo_ProvideItemsTo_SOSrv(...)
    -- get & check input from description
    local checkSuccess, provideItems, itemDepotLocator, ingredientsItemSupplierLocator = InputChecker.Check([[
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
                ingredientsItemSupplierLocator  + (URL) locating where ingredients can be retrieved
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Shop:needsTo_ProvideItemsTo_SOSrv: Invalid input") return {success = false} end

    -- loop on items
    local fuelNeed = 0
    local ingredientsNeed = {}
    for itemName, itemCount in pairs(provideItems) do
        -- check item
        if type(itemName) ~= "string" then corelog.Error("enterprise_shop.NeedsTo_ProvideItemsTo_SSrv: Invalid itemName (type="..type(itemName)..")") return {success = false} end
        if type(itemCount) ~= "number" then corelog.Error("enterprise_shop.NeedsTo_ProvideItemsTo_SSrv: Invalid itemCount (type="..type(itemCount)..")") return {success = false} end
        local item = { [itemName] = itemCount }

        -- get best itemLocator
        local itemLocator = self:getBestItemLocator_SOSrv({
            item                            = item,
            itemDepotLocator                = itemDepotLocator,
            ingredientsItemSupplierLocator  = ingredientsItemSupplierLocator}
        ).itemLocator
        if not itemLocator then corelog.Error("enterprise_shop.NeedsTo_ProvideItemsTo_SSrv: No ItemSupplier can provide "..itemCount.." "..itemName.."'s") return {success = false} end

        -- get provide needs
        local itemServiceData = {
            itemsLocator                    = itemLocator,
            itemDepotLocator                = itemDepotLocator,
            ingredientsItemSupplierLocator  = ingredientsItemSupplierLocator,
        }
        local serviceResults = enterprise_isp.NeedsTo_ProvideItemsTo_SSrv(itemServiceData)
        if not serviceResults.success then corelog.Error("enterprise_shop.NeedsTo_ProvideItemsTo_SSrv: Failed obtaining needs for "..itemCount.." "..itemName.."'s") return {success = false} end

        -- get fuelNeed to provide
        local fuelNeed_Provide = serviceResults.fuelNeed

        -- add fuelNeed
--        corelog.WriteToLog("S  fuelNeed_Provide="..fuelNeed_Provide.." for "..itemCount.." "..itemName.."'s")
        fuelNeed = fuelNeed + fuelNeed_Provide

        -- add ingredientsNeed
        local itemIngredientsNeed = serviceResults.ingredientsNeed
        if not enterprise_isp.AddItemsTo(ingredientsNeed, itemIngredientsNeed).success then corelog.Error("enterprise_shop.NeedsTo_ProvideItemsTo_SSrv: Failed adding items "..textutils.serialise(itemIngredientsNeed).." to ingredientsNeed.") return {success = false} end
    end

    -- end
    return {
        success         = true,
        fuelNeed        = fuelNeed,
        ingredientsNeed = ingredientsNeed, -- ToDo: consider allowing for non empty list to further generalise Shop into a container of ItemSuppliers
    }
end

return Shop
