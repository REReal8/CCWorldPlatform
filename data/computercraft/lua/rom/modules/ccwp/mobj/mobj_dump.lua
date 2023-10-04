-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local IItemSupplier = require "i_item_supplier"
local Dump = Class.NewClass(ObjBase, IItemSupplier)

--[[
    This module implements a Dump.

    A Dump offers services for providing items. It implements it's services by using services of ItemSupplier's registered in the Dump.

    The Dump is an ItemSupplier, hence it implements the required services.

    This allows for the Dump to be passed as ingredientsItemSupplierLocator to an ItemSupplier. The effect of that is that the ItemSupplier can request
    the ingredients from the Dump. The Dump than (by a recursive call to provideItemsTo_AOSrv) tries retrieving the ingredients from an ItemSupplier.
    This recursive order call will result in a successfull items order if the (sub, and sub-sub, etc) ingredients are present and/ or can be provided
    by a registered ItemSupplier.

    <It is envisioned (but not yet implemented) that a dump can also "store" (i.e. the opposite of ordering) items.>
--]]

local corelog = require "corelog"

local Callback = require "obj_callback"
local InputChecker = require "input_checker"
local Host = require "obj_host"

local enterprise_projects = require "enterprise_projects"
local enterprise_isp = require "enterprise_isp"
local enterprise_dump

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function Dump:_init(...)
    -- get & check input from description
    local checkSuccess, id, itemSuppliersLocators = InputChecker.Check([[
        Initialise a Dump.

        Parameters:
            id                      + (string) id of the Dump
            itemSuppliersLocators   + (ObjArray) with locators of registered ItemSupplier's
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Dump:_init: Invalid input") return nil end

    -- initialisation
    ObjBase._init(self)
    self._id                    = id
    self._itemSuppliersLocators = itemSuppliersLocators
end

-- ToDo: should be renamed to newFromTable at some point
function Dump:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a Dump.

        Parameters:
            o                           + (table, {}) table with object fields
                _id                     - (string) id of the forest
                _itemSuppliersLocators  - (ObjArray) with locators of registered ItemSupplier's
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Dump:new: Invalid input") return {} end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- end
    return o
end

function Dump:getItemSuppliersLocators()
    return self._itemSuppliersLocators
end

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

function Dump:getClassName()
    return "Dump"
end

--    _____ __  __  ____  _     _                  _   _               _
--   |_   _|  \/  |/ __ \| |   (_)                | | | |             | |
--     | | | \  / | |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | | | |\/| | |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| |_| |  | | |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____|_|  |_|\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                            _/ |
--                           |__/

function Dump:getId()
    return self._id
end

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

function Dump:bestItemSupplier(item, itemDepotLocator, ingredientsItemSupplierLocator, itemSupplierLocator1, itemSupplierLocator2)
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
    if not serviceResults1.success then corelog.Error("Dump:bestItemSupplier: Failed obtaining needs for itemLocator1(="..textutils.serialise(itemLocator1)..")") return nil end

    -- get needs 2
    local itemLocator2 = itemSupplierLocator2:copy()
    itemLocator2:setQuery(item)
    itemServiceData = {
        itemsLocator                    = itemLocator2,
        itemDepotLocator                = itemDepotLocator,
        ingredientsItemSupplierLocator  = ingredientsItemSupplierLocator,
    }
    local serviceResults2 = enterprise_isp.NeedsTo_ProvideItemsTo_SSrv(itemServiceData)
    if not serviceResults2.success then corelog.Error("Dump:bestItemSupplier: Failed obtaining needs for itemLocator2(="..textutils.serialise(itemLocator2)..")") return nil end

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

function Dump:getCanProvideItemSuppliers(item)
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

function Dump:delistAllItemStores()
    -- remove all ItemSupplier's from Dump
    local nLocators = #(self._itemSuppliersLocators)
    for i=nLocators, 1, -1 do
        -- cast
        local itemSupplierLocator = self._itemSuppliersLocators[i]
        -- remove from list
        corelog.WriteToLog(">Delisting ItemSupplier "..itemSupplierLocator:getURI().." from Dump "..self:getId()..".")
        table.remove(self._itemSuppliersLocators, i)
    end

    -- save Dump
    enterprise_dump = require "enterprise_dump"
    local objLocator = enterprise_dump:saveObject(self)
    if not objLocator then corelog.Error("Dump:delistAllItemStores: Failed saving Dump") return {success = false} end
end

--                        _                           _   _               _
--                       (_)                         | | | |             | |
--    ___  ___ _ ____   ___  ___ ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \  __/ |   \ V /| | (_|  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/\___|_|    \_/ |_|\___\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

function Dump:registerItemSupplier_SOSrv(...)
    -- get & check input from description
    local checkSuccess, itemSupplierLocator, suppressWarning = InputChecker.Check([[
        This sync public service registers ("adds") an ItemSupplier in the Dump.

        Note that the ItemSupplier should already be available in the world.

        Return value:
                                    - (table)
                success             - (boolean) whether the service executed successfully

        Parameters:
            serviceData             - (table) data for the service
                itemSupplierLocator + (URL) locating the ItemSupplier
                suppressWarning     + (boolean, false) if Warning should be suppressed
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Dump:registerItemSupplier_SOSrv: Invalid input") return {success = false} end

    -- get ItemSupplier
    local itemSupplier = Host.GetObject(itemSupplierLocator)
    if not itemSupplier then corelog.Error("Dump:registerItemSupplier_SOSrv: Failed obtaining an object from itemSupplierLocator "..itemSupplierLocator:getURI()) return {success = false} end
    if not Class.IsInstanceOf(itemSupplier, IItemSupplier) then if not suppressWarning then corelog.Error("Dump:registerItemSupplier_SOSrv: Obtained object from locator "..itemSupplierLocator:getURI().." is not an IItemSupplier") end return {success = false} end

    -- register the ItemSupplier
    corelog.WriteToLog(">Registering ItemSupplier "..itemSupplierLocator:getURI().." at Dump "..self:getId()..".")
    table.insert(self._itemSuppliersLocators, itemSupplierLocator)

    -- save Dump
    enterprise_dump = require "enterprise_dump"
    local objLocator = enterprise_dump:saveObject(self)
    if not objLocator then corelog.Error("Dump:registerItemSupplier_SOSrv: Failed saving Dump") return {success = false} end

    -- end
    local result = {
        success = true,
    }
    return result
end

function Dump:delistItemSupplier_SOSrv(...)
    -- get & check input from description
    local checkSuccess, itemSupplierLocator = InputChecker.Check([[
        This sync public service delists ("removes") an ItemSupplier from the Dump.

        Note that the ItemSupplier is not removed from the world.

        Return value:
            success                 - (boolean) whether the service executed successfully

        Parameters:
            serviceData             - (table) data for the service
                itemSupplierLocator + (URL) locating the ItemSupplier
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Dump:delistItemSupplier_SOSrv: Invalid input") return {success = false} end

    -- get ItemSuppliers
    local itemSupplierFound = false
--    corelog.WriteToLog("   itemSupplierLocator="..textutils.serialise(itemSupplierLocator))

    for i, registeredItemSupplierLocator in ipairs(self._itemSuppliersLocators) do
        -- check we found it
        if itemSupplierLocator:getURI() == registeredItemSupplierLocator:getURI() then
            -- remove from list
            corelog.WriteToLog(">Delisting ItemSupplier "..itemSupplierLocator:getURI().." from Dump "..self:getId()..".")
            itemSupplierFound = true
            table.remove(self._itemSuppliersLocators, i)

            -- save Dump
            enterprise_dump = require "enterprise_dump"
            local objLocator = enterprise_dump:saveObject(self)
            if not objLocator then corelog.Error("Dump:delistItemSupplier_SOSrv: Failed saving Dump") return {success = false} end
            break
        end
    end

    -- end
    local result = {
        success = itemSupplierFound,
    }
    return result
end

function Dump:getBestItemLocator_SOSrv(...)
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
    if not checkSuccess then corelog.Error("enterprise_dump:getBestItemLocator_SOSrv: Invalid input") return {success = false} end

    -- check input
    if type(item) ~= "table" then corelog.Error("enterprise_dump:getBestItemLocator_SOSrv: Invalid item (type="..type(item)..")") return {success = false} end

    -- select ItemSuppliers than can provide items
    local canProvideItemSupplierLocators = self:getCanProvideItemSuppliers(item)

    -- select best ItemSupplier
    local bestItemSupplierLocator = nil
    for i, itemSupplierLocator in ipairs(canProvideItemSupplierLocators) do
        bestItemSupplierLocator = self:bestItemSupplier(item, itemDepotLocator, ingredientsItemSupplierLocator, bestItemSupplierLocator, itemSupplierLocator)
    end
    if not bestItemSupplierLocator then corelog.Warning("enterprise_dump:getBestItemLocator_SOSrv: No ItemSupplier can provide "..textutils.serialise(item)) return {success = false} end

    -- determine itemLocator
    local itemLocator = bestItemSupplierLocator:copy()
    itemLocator:setQuery(item)

    -- end
    return {
        success             = true,
        itemLocator         = itemLocator,
    }
end

--    _____ _____ _                  _____                   _ _                            _   _               _
--   |_   _|_   _| |                / ____|                 | (_)                          | | | |             | |
--     | |   | | | |_ ___ _ __ ___ | (___  _   _ _ __  _ __ | |_  ___ _ __   _ __ ___   ___| |_| |__   ___   __| |___
--     | |   | | | __/ _ \ '_ ` _ \ \___ \| | | | '_ \| '_ \| | |/ _ \ '__| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| |_ _| |_| ||  __/ | | | | |____) | |_| | |_) | |_) | | |  __/ |    | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____|_____|\__\___|_| |_| |_|_____/ \__,_| .__/| .__/|_|_|\___|_|    |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                                              | |   | |
--                                              |_|   |_|

function Dump:provideItemsTo_AOSrv(...)
    -- get & check input from description
    local checkSuccess, provideItems, itemDepotLocator, ingredientsItemSupplierLocator, wasteItemDepotLocator, assignmentsPriorityKey, callback = InputChecker.Check([[
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
                wasteItemDepotLocator           + (URL) locating where waste material can be delivered
                assignmentsPriorityKey          + (string, "") priorityKey that should be set for all assignments triggered by this service
            callback                            + (Callback) to call once service is ready
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Dump:provideItemsTo_AOSrv: Invalid input") return Callback.ErrorCall(callback) end

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
            { stepType = "SOSrv", stepTypeDef = { className = "Dump", serviceName = "getBestItemLocator_SOSrv", objStep = 0, objKeyDef = "dump" }, stepDataDef = {
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
                { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
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
    projectData.wasteItemDepotLocator = wasteItemDepotLocator
    projectData.assignmentsPriorityKey = assignmentsPriorityKey
    projectData.dump = self:copy() -- ToDo: consider providing locator at some point, to allow for things to change while performing async project

    -- add combining URL's
    iStep = iStep + 1
    table.insert(projectSteps,
        { stepType = "SSrv", stepTypeDef = { moduleName = "enterprise_isp", serviceName = "AddItemsLocators_SSrv" }, stepDataDef = addItemLocatorsStepDataDef}
    )
    local iAddItemsLocatorStep = iStep

    -- create project service data
    local projectDef = {
        steps = projectSteps,
        returnData  = {
            { keyDef = "destinationItemsLocator", sourceStep = iAddItemsLocatorStep, sourceKeyDef = "itemsLocator" },
        }
    }
    local projectServiceData = {
        projectDef  = projectDef,
        projectData = projectData,
        projectMeta = { title = "The dump will provide", description = "Wait and see" },
    }

    -- start project
--    corelog.WriteToLog(">Providing "..itemsLocator:getURI().."")
    return enterprise_projects.StartProject_ASrv(projectServiceData, callback)
end

function Dump:can_ProvideItems_QOSrv(...)
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
    if not checkSuccess then corelog.Error("Dump:can_ProvideItems_QOSrv: Invalid input") return {success = false} end

    -- loop on items
    for itemName, itemCount in pairs(provideItems) do
        -- check
        if type(itemName) ~= "string" then corelog.Error("Dump:can_ProvideItems_QOSrv: itemName of wrong type = "..type(itemName)..".") return {success = false} end
        if type(itemCount) ~= "number" then corelog.Error("Dump:can_ProvideItems_QOSrv: itemCount of wrong type = "..type(itemCount)..".") return {success = false} end
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

function Dump:needsTo_ProvideItemsTo_SOSrv(...)
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
    if not checkSuccess then corelog.Error("Dump:needsTo_ProvideItemsTo_SOSrv: Invalid input") return {success = false} end

    -- loop on items
    local fuelNeed = 0
    local ingredientsNeed = {}
    for itemName, itemCount in pairs(provideItems) do
        -- check item
        if type(itemName) ~= "string" then corelog.Error("Dump:needsTo_ProvideItemsTo_SOSrv: Invalid itemName (type="..type(itemName)..")") return {success = false} end
        if type(itemCount) ~= "number" then corelog.Error("Dump:needsTo_ProvideItemsTo_SOSrv: Invalid itemCount (type="..type(itemCount)..")") return {success = false} end
        local item = { [itemName] = itemCount }

        -- get best itemLocator
        local itemLocator = self:getBestItemLocator_SOSrv({
            item                            = item,
            itemDepotLocator                = itemDepotLocator,
            ingredientsItemSupplierLocator  = ingredientsItemSupplierLocator}
        ).itemLocator
        if not itemLocator then corelog.Error("Dump:needsTo_ProvideItemsTo_SOSrv: No ItemSupplier can provide "..itemCount.." "..itemName.."'s") return {success = false} end

        -- get provide needs
        local itemServiceData = {
            itemsLocator                    = itemLocator,
            itemDepotLocator                = itemDepotLocator,
            ingredientsItemSupplierLocator  = ingredientsItemSupplierLocator,
        }
        local serviceResults = enterprise_isp.NeedsTo_ProvideItemsTo_SSrv(itemServiceData)
        if not serviceResults.success then corelog.Error("Dump:needsTo_ProvideItemsTo_SOSrv: Failed obtaining needs for "..itemCount.." "..itemName.."'s") return {success = false} end

        -- get fuelNeed to provide
        local fuelNeed_Provide = serviceResults.fuelNeed

        -- add fuelNeed
--        corelog.WriteToLog("S  fuelNeed_Provide="..fuelNeed_Provide.." for "..itemCount.." "..itemName.."'s")
        fuelNeed = fuelNeed + fuelNeed_Provide

        -- add ingredientsNeed
        local itemIngredientsNeed = serviceResults.ingredientsNeed
        if not enterprise_isp.AddItemsTo(ingredientsNeed, itemIngredientsNeed).success then corelog.Error("Dump:needsTo_ProvideItemsTo_SOSrv: Failed adding items "..textutils.serialise(itemIngredientsNeed).." to ingredientsNeed.") return {success = false} end
    end

    -- end
    return {
        success         = true,
        fuelNeed        = fuelNeed,
        ingredientsNeed = ingredientsNeed, -- ToDo: consider allowing for non empty list to further generalise Dump into a container of ItemSuppliers
    }
end

return Dump
