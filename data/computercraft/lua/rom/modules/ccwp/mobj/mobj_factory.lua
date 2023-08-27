-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local IItemSupplier = require "i_item_supplier"
local Factory = Class.NewClass(ObjBase, IItemSupplier)

--[[
    The Factory mobj represents a factory in the minecraft world and provides (production) services to operate on that Factory.

    There are (currently) two production techniques for producing items.
        The crafting technique uses a crafting table to produce an output item from a set of input items (ingredients).
        The smelting technique uses a furnace to produce an output item from an input item (ingredient).

    A Factory is comprised out of one or more crafting and/ or smelting spots. Furthermore a Factory specifies one or more item input and
    one or more item output "spots". These input/ output spots locally locate the input and output of items by the site.
    The most simple version of these input/ output "spots" are the inventory of a turtle. They however could in principle
    also be a full fledged local ItemDepot site.
--]]

local corelog = require "corelog"
local coreutils = require "coreutils"

local ObjArray = require "obj_array"
local InputChecker = require "input_checker"
local Callback = require "obj_callback"
local TaskCall = require "obj_task_call"
local ObjTable = require "obj_table"
local Location = require "obj_location"
local Block = require "obj_block"
local LayerRectangle = require "obj_layer_rectangle"

local ProductionSpot = require "mobj_production_spot"

local role_alchemist = require "role_alchemist"
local role_fuel_worker = require "role_fuel_worker"

local enterprise_projects = require "enterprise_projects"
local enterprise_isp = require "enterprise_isp"
local enterprise_turtle = require "enterprise_turtle"
local enterprise_assignmentboard = require "enterprise_assignmentboard"
local enterprise_chests = require "enterprise_chests"
local enterprise_energy = require "enterprise_energy"
local enterprise_manufacturing

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function Factory:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a Factory.

        Parameters:
            o                           + (table, {}) with object fields
                _id                     - (string) id of the Factory
                _baseLocation           - (Location) location of the Factory
                _inputLocators          - (ObjArray) with input locators
                _outputLocators         - (ObjArray) with output locators
                _craftingSpots          - (ObjArray) with crafting spots
                _smeltingSpots          - (ObjArray) with smelting spots
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Factory:new: Invalid input") return nil end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- end
    return o
end

function Factory:getId()
    return self._id
end

function Factory:getBaseLocation()
    return self._baseLocation
end

function Factory:getInputLocators()
    return self._inputLocators
end

function Factory:getOutputLocators()
    return self._outputLocators
end

function Factory:getCraftingSpots()
    return self._craftingSpots
end

function Factory:getSmeltingSpots()
    return self._smeltingSpots
end

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

function Factory:getClassName()
    return "Factory"
end

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

function Factory:getAvailableInputLocator()
    -- find first available locator
    for i, locator in ipairs(self:getInputLocators()) do
        -- ToDo: check actual availability

        -- take first
        return locator
    end

    -- end
    return nil
end

function Factory:getAvailableOutputLocator()
    -- find first available locator
    for i, locator in ipairs(self:getOutputLocators()) do
        -- ToDo: check actual availability

        -- take first
        return locator
    end

    -- end
    return nil
end

function Factory:getAvailableCraftSpot()
    -- find first available spot
    for i, spot in ipairs(self:getCraftingSpots()) do
        -- ToDo: check actual availability (make method of ProductionSpot?)

        -- take first
        return spot
    end

    -- end
    return nil
end

function Factory:getAvailableSmeltSpot()
    -- find first available spot
    for i, spot in ipairs(self:getSmeltingSpots()) do
        -- ToDo: check actual availability (make method of ProductionSpot?)

        -- take first
        return spot
    end

    -- end
    return nil
end

function Factory:getAvailableProductionSpot(recipe)
    --[[
        This method finds and selects a ProductionSpot for producing items from a recipe.

        Return value:
            productionSpot          - (ProductionSpot) available ProductionSpot for recipe
            productionRecipe        - (table) production recipe

        Parameters:
            recipe                  + (table) item base recipe (including possibly both a crafting as smelting recipe)
    ]]

    -- check it can craft or smelt recipe
    local productionSpot = nil
    local productionRecipe = nil
    if recipe.crafting then
        productionRecipe = recipe.crafting
        productionSpot = self:getAvailableCraftSpot()
    elseif recipe.smelting then
        productionRecipe = recipe.smelting
        productionSpot = self:getAvailableSmeltSpot()
    else
        corelog.Error("Factory:getAvailableProductionSpot: no valid production recipe provided.")
    end

    -- end
    return productionSpot, productionRecipe
end

--                        _                           _   _               _
--                       (_)                         | | | |             | |
--    ___  ___ _ ____   ___  ___ ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \  __/ |   \ V /| | (_|  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/\___|_|    \_/ |_|\___\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

function Factory:getFuelNeed_Production_Att(...)
    -- get & check input from description
    local checkSuccess, items = InputChecker.Check([[
        Factory attribute for the current fuelNeed for producing items. (i.e. it returns the fuelNeed for producing the items
        assuming the ingredients are available in a turtle and the results are to be delivered to the turtle)

        Parameters:
            items   + (table) items to produce
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Factory:getFuelNeed_Production_Att: Invalid input") return enterprise_energy.GetLargeFuelAmount_Att() end

    -- create locator
    enterprise_turtle = enterprise_turtle or require "enterprise_turtle"
    local turtleLocator = enterprise_turtle.GetAnyTurtleLocator() if not turtleLocator then corelog.Error("Factory:getFuelNeed_Production_Att: Failed obtaining turtleLocator") return enterprise_energy.GetLargeFuelAmount_Att() end

    -- determine fuelNeed
    local serviceResults = self:needsTo_ProvideItemsTo_SOSrv({
        provideItems                    = items,
        itemDepotLocator                = turtleLocator:copy(),
        ingredientsItemSupplierLocator  = turtleLocator:copy(),
    })
    if not serviceResults.success then corelog.Error("Factory:getFuelNeed_Production_Att: failed obtaining fuel need for production.") return enterprise_energy.GetLargeFuelAmount_Att() end
    local fuelNeed = serviceResults.fuelNeed

    -- end
    return fuelNeed
end

function Factory:getProductionLocation_Att(...)
    -- get & check input from description
    local checkSuccess, items = InputChecker.Check([[
        Factory attribute for the location of the current available ProductionSpot for producing items.

        Parameters:
            items   + (table) items to produce
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Factory:getSiteLocation_Att: Invalid input") return {_x=9999, _y=9999, _z= 9999, _dx=0, _dy=1} end

    -- check for recipe to provide items
    local itemName, itemCount = next(items, nil)
    enterprise_manufacturing = enterprise_manufacturing or require "enterprise_manufacturing"
    local recipe = enterprise_manufacturing.GetRecipes()[ itemName ]
    if type(recipe) ~= "table" then corelog.Error("Factory:getSiteLocation_Att: Factory does not provide "..itemName.."'s") return {_x=9999, _y=9999, _z= 9999, _dx=0, _dy=1} end

    -- get location
    local productionSpot = self:getAvailableProductionSpot(recipe)
    if not productionSpot then corelog.Error("Factory:getSiteLocation_Att: No ProductionSpot available.") return {_x=9999, _y=9999, _z= 9999, _dx=0, _dy=1} end
    local location = productionSpot:getBaseLocation()

    -- end
    return location
end

--    _____ _____ _                  _____                   _ _                            _   _               _
--   |_   _|_   _| |                / ____|                 | (_)                          | | | |             | |
--     | |   | | | |_ ___ _ __ ___ | (___  _   _ _ __  _ __ | |_  ___ _ __   _ __ ___   ___| |_| |__   ___   __| |___
--     | |   | | | __/ _ \ '_ ` _ \ \___ \| | | | '_ \| '_ \| | |/ _ \ '__| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| |_ _| |_| ||  __/ | | | | |____) | |_| | |_) | |_) | | |  __/ |    | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____|_____|\__\___|_| |_| |_|_____/ \__,_| .__/| .__/|_|_|\___|_|    |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                                              | |   | |
--                                              |_|   |_|

function Factory:provideItemsTo_AOSrv(...)
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
    if not checkSuccess then corelog.Error("Factory:provideItemsTo_AOSrv: Invalid input") return Callback.ErrorCall(callback) end

    -- loop on items
    local scheduleResult = true
    for itemName, itemCount in pairs(provideItems) do
        -- check
        if type(itemName) ~= "string" then corelog.Error("Factory:provideItemsTo_AOSrv: Invalid itemName (type="..type(itemName)..")") return Callback.ErrorCall(callback) end
        if type(itemCount) ~= "number" then corelog.Error("Factory:provideItemsTo_AOSrv: Invalid itemCount (type="..type(itemCount)..")") return Callback.ErrorCall(callback) end

        -- select recipe to produce item
        enterprise_manufacturing = enterprise_manufacturing or require "enterprise_manufacturing"
        local recipe = enterprise_manufacturing.GetRecipes()[ itemName ]
        if type(recipe) ~= "table" then corelog.Error("Factory:provideItemsTo_AOSrv: No recipe for item "..itemName) return Callback.ErrorCall(callback) end

        -- determine ingredientsItemsLocator (by updating ingredientsItemSupplierLocator with ingredientsNeeded)
        local productionSpot, productionRecipe = self:getAvailableProductionSpot(recipe)
        if not productionSpot then corelog.Error("Factory:provideItemsTo_AOSrv: Failed obtaining available ProductionSpot to produce "..itemName) return Callback.ErrorCall(callback) end
        local ingredientsNeeded, productSurplus = productionSpot:produceIngredientsNeeded(productionRecipe, itemCount)
        local ingredientsItemsLocator = ingredientsItemSupplierLocator:copy()
        ingredientsItemsLocator:setQuery(coreutils.DeepCopy(ingredientsNeeded))

        -- determine wasteItemsLocator
        -- ToDo: consider fixing: we assume the current turtle will eventually have the waste. Remove this hack.
        local currentTurtleId = os.getComputerID()
        local wasteItemsLocator = enterprise_turtle:getTurtleLocator(tostring(currentTurtleId)):copy()
        wasteItemsLocator:setQuery({ [itemName] = productSurplus })

        -- retrieve site input & output locator's
        local localInputLocator = self:getAvailableInputLocator():copy()
        local localOutputLocator = self:getAvailableOutputLocator():copy()

        -- mark productionSpot as unavailable
        -- ToDo: implement (not yet needed in current settle scenario where there is only one turtle)
        -- ToDo: consider to what extend this is also needed for localInputLocator and localOutputLocator

        -- create project service data
        local projectDef = {
            steps = {
                -- get ingredients
                { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_isp", serviceName = "ProvideItemsTo_ASrv" }, stepDataDef = {
                    { keyDef = "itemsLocator"                   , sourceStep = 0, sourceKeyDef = "ingredientsItemsLocator" },
                    { keyDef = "itemDepotLocator"               , sourceStep = 0, sourceKeyDef = "localInputLocator" },
                    { keyDef = "ingredientsItemSupplierLocator" , sourceStep = 0, sourceKeyDef = "ingredientsItemSupplierLocator" },
                    { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
                    { keyDef = "assignmentsPriorityKey"         , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
                }},
                -- produce items
                { stepType = "ASrv", stepTypeDef = { moduleName = "Factory", serviceName = "ProduceItem_ASrv" }, stepDataDef = {
                    { keyDef = "localInputItemsLocator"         , sourceStep = 1, sourceKeyDef = "destinationItemsLocator" },
                    { keyDef = "localOutputLocator"             , sourceStep = 0, sourceKeyDef = "localOutputLocator" },
                    { keyDef = "productionSpot"                 , sourceStep = 0, sourceKeyDef = "productionSpot" },
                    { keyDef = "productItemName"                , sourceStep = 0, sourceKeyDef = "itemName" },
                    { keyDef = "productItemCount"               , sourceStep = 0, sourceKeyDef = "itemCount" },
                    { keyDef = "productionRecipe"               , sourceStep = 0, sourceKeyDef = "productionRecipe" },
                    { keyDef = "assignmentsPriorityKey"         , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
                }},
                -- deliver items
                { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_isp", serviceName = "StoreItemsFrom_ASrv" }, stepDataDef = {
                    { keyDef = "itemsLocator"                   , sourceStep = 2, sourceKeyDef = "localOutputItemsLocator" },
                    { keyDef = "itemDepotLocator"               , sourceStep = 0, sourceKeyDef = "itemDepotLocator" },
                    { keyDef = "assignmentsPriorityKey"         , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
                }},
                -- store waste items
                { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_isp", serviceName = "StoreItemsFrom_ASrv" }, stepDataDef = {
                    { keyDef = "itemsLocator"                   , sourceStep = 0, sourceKeyDef = "wasteItemsLocator" },
                    { keyDef = "itemDepotLocator"               , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
                    { keyDef = "assignmentsPriorityKey"         , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
                }},
            },
            returnData  = {
                { keyDef = "destinationItemsLocator"            , sourceStep = 3, sourceKeyDef = "destinationItemsLocator" },
            }
        }
        local projectData = {
            ingredientsItemSupplierLocator  = ingredientsItemSupplierLocator:copy(),

            ingredientsItemsLocator         = ingredientsItemsLocator,
            itemDepotLocator                = itemDepotLocator,

            localInputLocator               = localInputLocator,
            localOutputLocator              = localOutputLocator,

            productionSpot                  = productionSpot,
            itemName                        = itemName,
            itemCount                       = itemCount,
            productionRecipe                = productionRecipe,

            wasteItemsLocator               = wasteItemsLocator,
            wasteItemDepotLocator           = wasteItemDepotLocator,

            assignmentsPriorityKey          = assignmentsPriorityKey,
        }
        local projectServiceData = {
            projectDef  = projectDef,
            projectData = projectData,
            projectMeta = { title = "Factory:provideItemsTo", description = "We provide "..itemCount.." "..itemName.."'s" },
        }

        -- start project
--        corelog.WriteToLog(">Producing "..itemCount.." "..itemName.."'s in Factory")
        scheduleResult = scheduleResult and enterprise_projects.StartProject_ASrv(projectServiceData, callback)
    end

    -- end
    return scheduleResult
end

function Factory:can_ProvideItems_QOSrv(...)
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
    if not checkSuccess then corelog.Error("Factory:can_ProvideItems_QOSrv: Invalid input") return {success = false} end

    -- loop on items
    for itemName, itemCount in pairs(provideItems) do
        -- check
        if type(itemName) ~= "string" then corelog.Error("Factory:can_ProvideItems_QSrv: itemName of wrong type = "..type(itemName)..".") return {success = false} end

        -- check available inputLocator
        local inputLocator = self:getAvailableInputLocator()
        if not inputLocator then return {success = false} end

        -- check for recipe to produce itemName
        enterprise_manufacturing = enterprise_manufacturing or require "enterprise_manufacturing"
        local recipe = enterprise_manufacturing.GetRecipes()[ itemName ]
        if type(recipe) ~= "table" then return {success = false} end

        -- check it can produce recipe
        local productionSpot = self:getAvailableProductionSpot(recipe)
        if not productionSpot then return {success = false} end

        -- ToDo: consider how to handle production of more items than fitting a single spot

        -- check available inputLocator
        local outputLocator = self:getAvailableOutputLocator()
        if not outputLocator then return {success = false} end
    end

    -- end
    return {
        success = true,
    }
end

function Factory:needsTo_ProvideItemsTo_SOSrv(...)
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
                ingredientsItemSupplierLocator  + (URL, nil) locating where ingredients can be retrieved
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Factory:needsTo_ProvideItemsTo_SOSrv: Invalid input") return {success = false} end

    -- loop on items
    local fuelNeed = 0
    local ingredientsNeed = {}
    for itemName, itemCount in pairs(provideItems) do
        -- check
        if type(itemName) ~= "string" then corelog.Error("Factory:needsTo_ProvideItemsTo_SOSrv: Invalid itemName (type="..type(itemName)..")") return {success = false} end
        if type(itemCount) ~= "number" then corelog.Error("Factory:needsTo_ProvideItemsTo_SOSrv: Invalid itemCount (type="..type(itemCount)..")") return {success = false} end

        -- check for recipe to provide itemName
        enterprise_manufacturing = enterprise_manufacturing or require "enterprise_manufacturing"
        local recipe = enterprise_manufacturing.GetRecipes()[ itemName ]
        if type(recipe) ~= "table" then corelog.Error("Factory:needsTo_ProvideItemsTo_SOSrv: Provider does not provide "..itemName.."'s") return {success = false} end

        -- add ingredientsNeed
        local productionSpot, productionRecipe = self:getAvailableProductionSpot(recipe)
        if not productionSpot then corelog.Error("Factory:needsTo_ProvideItemsTo_SOSrv: Failed obtaining available ProductionSpot to produce "..itemName) return {success = false} end
        local itemIngredientsNeed = productionSpot:produceIngredientsNeeded(productionRecipe, itemCount)
        if not enterprise_isp.AddItemsTo(ingredientsNeed, itemIngredientsNeed).success then corelog.Error("Factory:needsTo_ProvideItemsTo_SOSrv: Failed adding items "..textutils.serialise(itemIngredientsNeed).." to ingredientsNeed.") return {success = false} end

        -- fuelNeed ingredients
        local ingredientsItemsLocator = ingredientsItemSupplierLocator:copy()
        ingredientsItemsLocator:setQuery(coreutils.DeepCopy(itemIngredientsNeed))
        local localInputLocator = self:getAvailableInputLocator():copy()
        local serviceData = {
            itemsLocator                    = ingredientsItemsLocator,
            itemDepotLocator                = localInputLocator,
            ingredientsItemSupplierLocator  = ingredientsItemSupplierLocator:copy(),
        }
        local serviceResults = enterprise_isp.NeedsTo_ProvideItemsTo_SSrv(serviceData)
        if not serviceResults.success then corelog.Error("Factory:needsTo_ProvideItemsTo_SOSrv: Failed obtaining needs for "..ingredientsItemsLocator:getURI().." ingredients") return {success = false} end
        local fuelNeed_IngredientsSupply = serviceResults.fuelNeed

        -- fuelNeed production
        local localInputItemsLocator = localInputLocator:copy()
        localInputItemsLocator:setQuery(coreutils.DeepCopy(itemIngredientsNeed))
        local localOutputLocator = self:getAvailableOutputLocator():copy()
        serviceData = {
            localInputItemsLocator  = localInputItemsLocator,
            localOutputLocator      = localOutputLocator,
            productionSpot          = productionSpot:copy(),
        }
        serviceResults = Factory.NeedsTo_ProvideItemsTo_SSrv(serviceData)
        if not serviceResults.success then corelog.Error("Factory:needsTo_ProvideItemsTo_SOSrv: Failed obtaining needs for production at site") return {success = false} end
        local fuelNeed_SiteProduction = serviceResults.fuelNeed

        -- fuelNeed output transfer
        local localOutputItemsLocator = localOutputLocator:copy()
        local items = { [itemName] = itemCount }
        localOutputItemsLocator:setQuery(items)
        serviceData = {
            sourceItemsLocator          = localOutputItemsLocator,
            destinationItemDepotLocator = itemDepotLocator,
        }
        serviceResults = enterprise_isp.NeedsTo_TransferItems_SSrv(serviceData)
        if not serviceResults.success then corelog.Error("Factory:needsTo_ProvideItemsTo_SOSrv: Failed obtaining transfer needs for "..itemCount.." "..itemName.."'s") return {success = false} end
        local fuelNeed_ProductsSupply = serviceResults.fuelNeed

        -- add fuelNeed
--        corelog.WriteToLog("F  fuelNeed_IngredientsSupply="..fuelNeed_IngredientsSupply..", fuelNeed_SiteProduction="..fuelNeed_SiteProduction..", fuelNeed_ProductsSupply="..fuelNeed_ProductsSupply)
        fuelNeed = fuelNeed + fuelNeed_IngredientsSupply + fuelNeed_SiteProduction + fuelNeed_ProductsSupply
    end

    -- end
    return {
        success         = true,
        fuelNeed        = fuelNeed,
        ingredientsNeed = ingredientsNeed,
    }
end

function Factory.NeedsTo_ProvideItemsTo_SSrv(...)
    -- get & check input from description
    local checkSuccess, localInputItemsLocator, localOutputLocator, productionSpot = InputChecker.Check([[
        This sync public service returns the needs for the site to produce specific items to an ItemDepot.

        Return value:
                                        - (table)
                success                 - (boolean) whether the service executed correctly
                fuelNeed                - (number) amount of fuel needed to supply items

        Parameters:
            serviceData                 - (table) data to the query
                localInputItemsLocator  + (URL) locating where the production ingredients can be retrieved locally "within" the site (e.g. an input chest)
                localOutputLocator      + (URL) locating where the produced items need to be delivered locally "within" the site (e.g. an output chest)
                productionSpot          + (ProductionSpot) production spot
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Factory.NeedsTo_ProvideItemsTo_SSrv: Invalid input") return {success = false} end

    -- fuelNeed from localInputItemsLocator to productionSpot
    local serviceResults = enterprise_isp.GetItemsLocations_SSrv({ itemsLocator = localInputItemsLocator })
    if not serviceResults.success then corelog.Error("Factory.NeedsTo_ProvideItemsTo_SSrv: failed obtaining locations for items "..localInputItemsLocator:getURI()..".") return {success = false} end
    local fuelNeed_ToProductionlocation = 0
    for i, location in ipairs(serviceResults.locations) do
        fuelNeed_ToProductionlocation = fuelNeed_ToProductionlocation + role_fuel_worker.NeededFuelToFrom(productionSpot:getBaseLocation(), location)
    end

    -- fuelNeed for production
    local fuelNeed_Production = 0
    if productionSpot:isCraftingSpot() then fuelNeed_Production = 0 -- craft
    else fuelNeed_Production = 4 + 4 -- smelt + pickup
    end

    -- fuelNeed from productionSpot to localOutputLocator
    serviceResults =  enterprise_isp.GetItemDepotLocation_SSrv({ itemDepotLocator = localOutputLocator })
    if not serviceResults.success then corelog.Error("Factory.NeedsTo_ProvideItemsTo_SSrv: failed obtaining location for ItemDepot "..localOutputLocator:getURI()..".") return {success = false} end
    local fuelNeed_FromProductionLocation = role_fuel_worker.NeededFuelToFrom(serviceResults.location, productionSpot:getBaseLocation())

    -- end
--    corelog.WriteToLog("FS fuelNeed_ToProductionlocation="..fuelNeed_ToProductionlocation..", fuelNeed_Production="..fuelNeed_Production..", fuelNeed_FromProductionLocation="..fuelNeed_FromProductionLocation)
    local fuelNeed = fuelNeed_ToProductionlocation + fuelNeed_Production + fuelNeed_FromProductionLocation
    return {
        success         = true,
        fuelNeed        = fuelNeed,
    }
end

function Factory.ProduceItem_ASrv(...)
    -- get & check input from description
    local checkSuccess, localInputItemsLocator, localOutputLocator, productionSpot, productItemName, productItemCount, productionRecipe, assignmentsPriorityKey, callback = InputChecker.Check([[
        This async public service produces multiple instances of a specific item in a factory site. It does so by producing
        the requested amount of items with the supplied production method (i.e. crafting or smelting).

        Return value:
                                        - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                        - (table)
                success                 - (boolean) whether the service executed correctly
                localOutputItemsLocator - (URL) locating the items that where produced
                                            (upon service succes the "host" component of this URL should be equal to localOutputLocator, and
                                            the "query" should be equal to the "query" component of the localInputItemLocator)

        Parameters:
            serviceData                 - (table) data for the service
                localInputItemsLocator  + (URL) locating where the production ingredients can be retrieved locally "within" the site (e.g. an input chest)
                localOutputLocator      + (URL) locating where the produced items need to be delivered locally "within" the site (e.g. an output chest)
                productionSpot          + (ProductionSpot) production spot
                productItemName         + (string) name of item to produce
                productItemCount        + (number) amount of items to produce
                productionRecipe        + (table) production recipe
                assignmentsPriorityKey  + (string, "") priorityKey that should be set for all assignments triggered by this service
            callback                    + (Callback) to call once service is ready
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Factory.ProduceItem_ASrv: Invalid input") return Callback.ErrorCall(callback) end

    -- determine turtleInputLocator
    local turtleInputLocator = enterprise_turtle.GetAnyTurtleLocator()

    -- determine production steps
    local projectSteps = {
        { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_isp", serviceName = "StoreItemsFrom_ASrv" }, stepDataDef = {
            { keyDef = "itemsLocator"               , sourceStep = 0, sourceKeyDef = "localInputItemsLocator" },
            { keyDef = "itemDepotLocator"           , sourceStep = 0, sourceKeyDef = "turtleInputLocator" },
            { keyDef = "assignmentsPriorityKey"     , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
        }, description = "Getting items into turtle"},
    }

    -- add production steps
    local extraStep = 0
    if productionSpot:isCraftingSpot() then
        -- add crafting step
        table.insert(projectSteps,
            { stepType = "ASrv", stepTypeDef = { moduleName = "Factory", serviceName = "CraftItem_ASrv" }, stepDataDef = {
                { keyDef = "turtleInputItemsLocator", sourceStep = 1, sourceKeyDef = "destinationItemsLocator" },
                { keyDef = "productionSpot"         , sourceStep = 0, sourceKeyDef = "productionSpot" },
                { keyDef = "productItemName"        , sourceStep = 0, sourceKeyDef = "productItemName" },
                { keyDef = "productItemCount"       , sourceStep = 0, sourceKeyDef = "productItemCount" },
                { keyDef = "productionRecipe"       , sourceStep = 0, sourceKeyDef = "productionRecipe" },
                { keyDef = "assignmentsPriorityKey" , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
            }, description = "Crafting items"}
        )
    else
        -- add smelting step
        table.insert(projectSteps,
            { stepType = "ASrv", stepTypeDef = { moduleName = "Factory", serviceName = "SmeltItem_ASrv" }, stepDataDef = {
                { keyDef = "turtleInputItemsLocator", sourceStep = 1, sourceKeyDef = "destinationItemsLocator" },
                { keyDef = "productionSpot"         , sourceStep = 0, sourceKeyDef = "productionSpot" },
                { keyDef = "productItemCount"       , sourceStep = 0, sourceKeyDef = "productItemCount" },
                { keyDef = "productionRecipe"       , sourceStep = 0, sourceKeyDef = "productionRecipe" },
                { keyDef = "assignmentsPriorityKey" , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
            }, description = "Smelting items"}
        )

        -- add pickup step
        table.insert(projectSteps,
            { stepType = "ASrv", stepTypeDef = { moduleName = "Factory", serviceName = "Pickup_ASrv" }, stepDataDef = {
                { keyDef = "pickUpTime"             , sourceStep = 2, sourceKeyDef = "smeltReadyTime" },
                { keyDef = "productionSpot"         , sourceStep = 0, sourceKeyDef = "productionSpot" },
                { keyDef = "productItemName"        , sourceStep = 0, sourceKeyDef = "productItemName" },
                { keyDef = "productItemCount"       , sourceStep = 0, sourceKeyDef = "productItemCount" },
                { keyDef = "assignmentsPriorityKey" , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
            }, description = "Pickup items"}
        )

        extraStep = 1
    end

    -- add remaining steps
    table.insert(projectSteps,
        { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_isp", serviceName = "StoreItemsFrom_ASrv" }, stepDataDef = {
            { keyDef = "itemsLocator"               , sourceStep = 2 + extraStep, sourceKeyDef = "turtleOutputItemsLocator" },
            { keyDef = "itemDepotLocator"           , sourceStep = 0, sourceKeyDef = "localOutputLocator" },
            { keyDef = "assignmentsPriorityKey"     , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
        }, description = "Storing items into local output"}
    )

    -- create project service data
    local projectDef = {
        steps = projectSteps,
        returnData  = {
            { keyDef = "localOutputItemsLocator"    , sourceStep = 3 + extraStep, sourceKeyDef = "destinationItemsLocator" },
        }
    }
    local projectData = {
        localInputItemsLocator      = localInputItemsLocator,
        localOutputLocator          = localOutputLocator,

        turtleInputLocator          = turtleInputLocator,

        productionSpot              = productionSpot,
        productItemName             = productItemName,
        productItemCount            = productItemCount,
        productionRecipe            = productionRecipe,

        assignmentsPriorityKey      = assignmentsPriorityKey,
    }
    local projectServiceData = {
        projectDef  = projectDef,
        projectData = projectData,
        projectMeta = { title = "Factory.ProduceItem_ASrv", description = "Time to make stuff" },
    }

    -- start project
    return enterprise_projects.StartProject_ASrv(projectServiceData, callback)
end

--    _                 _    __                  _   _
--   | |               | |  / _|                | | (_)
--   | | ___   ___ __ _| | | |_ _   _ _ __   ___| |_ _  ___  _ __  ___
--   | |/ _ \ / __/ _` | | |  _| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
--   | | (_) | (_| (_| | | | | | |_| | | | | (__| |_| | (_) | | | \__ \
--   |_|\___/ \___\__,_|_| |_|  \__,_|_| |_|\___|\__|_|\___/|_| |_|___/

--[[
    A v0 site is comprised of
    - one crafting spot. Below the crafting spot is a hole in the ground as a temporary ItemDepot for items not needed
    - no smelting spot
--]]

local blockClassName = "Block"
local function Shaft_layer()
    return LayerRectangle:new({
        _codeTable  = ObjTable:newInstance(blockClassName, {
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        _codeMap    = {
            [1] = " ",
        },
    })
end

local function ShaftRestore_layer()
    return LayerRectangle:new({
        _codeTable  = ObjTable:newInstance(blockClassName, {
            ["D"]   = Block:newInstance("minecraft:dirt"),
        }),
        _codeMap    = {
            [1] = "D",
        },
    })
end

function Factory.GetV0SiteBuildData(serviceData)
    -- construct layer list
    local layerList = {
        { startpoint = Location:newInstance(0, 0, -1), buildFromAbove = true, layer = Shaft_layer()},
    }

    -- construct blueprint
    local blueprint = {
        layerList = layerList,
        escapeSequence = {
        }
    }

    -- construct build data
    local siteBuildData = {
        blueprintStartpoint = serviceData.baseLocation:copy(),
        blueprint = blueprint
    }

    return siteBuildData
end

function Factory.GetV0SiteDismantleBuildData(serviceData)
    -- construct layer list
    local layerList = {
        { startpoint = Location:newInstance(0, 0, -1), buildFromAbove = true, layer = ShaftRestore_layer()},
    }

    -- construct blueprint
    local blueprint = {
        layerList = layerList,
        escapeSequence = {
        }
    }

    -- construct build data
    local siteDismantleBuildData = {
        blueprintStartpoint = serviceData.baseLocation:copy(),
        blueprint = blueprint
    }

    return siteDismantleBuildData
end

local locatorClassName = "URL"
local productionSpotClassName = "ProductionSpot"

function Factory.GetV0SiteStartData(serviceData)
    --
    local baseLocation = serviceData.baseLocation

    -- construct start data
    local startData = {
        version = serviceData.siteVersion,

        baseLocation = baseLocation:copy(),

        inputLocators = ObjArray:newInstance(locatorClassName, {
            enterprise_turtle.GetAnyTurtleLocator(),
        }),
        outputLocators = ObjArray:newInstance(locatorClassName, {
            enterprise_turtle.GetAnyTurtleLocator(),
        }),

        craftingSpots = ObjArray:newInstance(productionSpotClassName, {
            ProductionSpot:new({ _baseLocation = baseLocation:getRelativeLocation(0, 0, 0), _isCraftingSpot = true }),
        }),
        smeltingSpots = ObjArray:newInstance(productionSpotClassName),
    }

    return startData
end

--[[
    A v1 site is comprised of
    - one crafting spot. Below the crafting spot is a hole in the ground as a temporary ItemDepot for items not needed.
    - one smelting spot. In front of the smelting spot is a furnace that can be accessed from the front, the top and below.
--]]

local function AboveOrBelowFurnanceL1_layer()
    return LayerRectangle:new({
        _codeTable  = ObjTable:newInstance(blockClassName, {
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        _codeMap    = {
            [2] = " ",
            [1] = " ",
        },
    })
end

local function FurnanceL1_layer()
    return LayerRectangle:new({
        _codeTable  = ObjTable:newInstance(blockClassName, {
            ["F"]   = Block:newInstance("minecraft:furnace"),
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        _codeMap    = {
            [2] = "F",
            [1] = " ",
        },
    })
end

function Factory.GetV1SiteBuildData(serviceData)
    -- construct layer list
    local layerList = {
        { startpoint = Location:newInstance(3, 3, -1), buildFromAbove = true, layer = Shaft_layer()},
        { startpoint = Location:newInstance(3, 3, -2), buildFromAbove = false, layer = AboveOrBelowFurnanceL1_layer()},
        { startpoint = Location:newInstance(3, 3, -3), buildFromAbove = false, layer = FurnanceL1_layer()},
        { startpoint = Location:newInstance(3, 3, -5), buildFromAbove = true, layer = Shaft_layer()},
    }

    -- construct blueprint
    local blueprint = {
        layerList = layerList,
        escapeSequence = {
            Location:newInstance(3, 3, 1),
        }
    }

    -- construct build data
    local siteBuildData = {
        blueprintStartpoint = serviceData.baseLocation:copy(),
        blueprint = blueprint
    }

    return siteBuildData
end

function Factory.GetV1SiteStartData(serviceData)
    --
    local baseLocation = serviceData.baseLocation

    -- construct start data
    local startData = {
        version = serviceData.siteVersion,

        baseLocation = baseLocation:copy(),

        inputLocators = ObjArray:newInstance(locatorClassName, {
            enterprise_turtle.GetAnyTurtleLocator(),
        }),
        outputLocators = ObjArray:newInstance(locatorClassName, {
            enterprise_turtle.GetAnyTurtleLocator(),
        }),

        craftingSpots = ObjArray:newInstance(productionSpotClassName, {
            ProductionSpot:new({ _baseLocation = baseLocation:getRelativeLocation(3, 3, -4), _isCraftingSpot = true }),
        }),
        smeltingSpots = ObjArray:newInstance(productionSpotClassName, {
            ProductionSpot:new({ _baseLocation = baseLocation:getRelativeLocation(3, 3, -3), _isCraftingSpot = false }),
        }),
    }

    return startData
end

--[[
    A v2 site is comprised of
    - one crafting spot. Below the crafting spot should is a chest as a temporary ItemDepot for items not needed.
    - one smelting spot. In front of the smelting spot is a furnace that can be accessed from the front, the top and below.

    - ToDo and some additional chests of which we need to define what their exact purpose is.
--]]

local function ItemDepotChestL2_layer()
    return LayerRectangle:new({
        _codeTable  = ObjTable:newInstance(blockClassName, {
            ["C"]   = Block:newInstance("minecraft:chest"),
        }),
        _codeMap    = {
            [1] = "C",
        },
    })
end

local function TopLayerL2_layer()
    return LayerRectangle:new({
        _codeTable  = ObjTable:newInstance(blockClassName, {
            ["T"]   = Block:newInstance("minecraft:torch"),
            ["C"]   = Block:newInstance("minecraft:chest"),
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        _codeMap    = {
            [6] = "  C C ",
            [5] = "      ",
            [4] = "T     ",
            [3] = "      ",
            [2] = "      ",
            [1] = "   T  ",
        },
    })
end

function Factory.GetV2SiteBuildData(serviceData)
    local onlyUpgrade = serviceData.upgrade

    -- construct layer list
    local layerList = {
        { startpoint = Location:newInstance(0, 0, 0), buildFromAbove = true, layer = TopLayerL2_layer()},
    }
    if not onlyUpgrade then
        table.insert(layerList, { startpoint = Location:newInstance( 3, 3, -1), buildFromAbove = true, layer = Shaft_layer()})
        table.insert(layerList, { startpoint = Location:newInstance( 3, 3, -2), buildFromAbove = false, layer = AboveOrBelowFurnanceL1_layer()})
        table.insert(layerList, { startpoint = Location:newInstance( 3, 3, -3), buildFromAbove = false, layer = FurnanceL1_layer()})
    end
    table.insert(layerList, { startpoint = Location:newInstance( 3, 3, -5), buildFromAbove = true, layer = ItemDepotChestL2_layer()})

    -- construct blueprint
    local blueprint = {
        layerList = layerList,
        escapeSequence = {
            Location:newInstance(3, 3, 1),
        }
    }

    -- construct build data
    local siteBuildData = {
        blueprintStartpoint = serviceData.baseLocation:copy(),
        blueprint = blueprint
    }

    return siteBuildData
end

function Factory.GetV2SiteStartData(serviceData)
    --
    local baseLocation = serviceData.baseLocation

    -- register input chest
    local inputChestLocator = enterprise_chests:hostMObj_SSrv({ className = "Chest", constructParameters = {
        baseLocation    = baseLocation:getRelativeLocation(2, 5, 0),
        accessDirection = "top",
    }}).mobjLocator

    -- register output chest
    local outputChestLocator = enterprise_chests:hostMObj_SSrv({ className = "Chest", constructParameters = {
        baseLocation    = baseLocation:getRelativeLocation(4, 5, 0),
        accessDirection = "top",
    }}).mobjLocator

    -- construct start data
    local startData = {
        version = serviceData.siteVersion,

        baseLocation = baseLocation,

        inputLocators = ObjArray:newInstance(locatorClassName, {
            inputChestLocator,
        }),
        outputLocators = ObjArray:newInstance(locatorClassName, {
            outputChestLocator,
        }),

        craftingSpots = ObjArray:newInstance(productionSpotClassName, {
            ProductionSpot:new({ _baseLocation = baseLocation:getRelativeLocation(3, 3, -4), _isCraftingSpot = true }),
        }),
        smeltingSpots = ObjArray:newInstance(productionSpotClassName, {
            ProductionSpot:new({ _baseLocation = baseLocation:getRelativeLocation(3, 3, -3), _isCraftingSpot = false }),
        }),
    }

    return startData
end

function Factory.CraftItem_ASrv(...)
    -- get & check input from description
    local checkSuccess, turtleInputItemsLocator, productionSpot, productItemName, productItemCount, productionRecipe, assignmentsPriorityKey, callback = InputChecker.Check([[
        This async service should craft items at the ProductionSpot.

        Return value:
                                        - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                        - (table)
                success                 - (boolean) whether the service executed correctly
                turtleOutputItemsLocator- (URL) locating the items that where produced (in a turtle)

        Parameters:
            serviceData                 - (table) data for the service
                turtleInputItemsLocator + (URL) locating the production ingredients in the turtle that should do the crafting
                productionSpot          + (ProductionSpot) production spot
                productItemName         + (string) name of item to produce
                productItemCount        + (number) amount of items to produce
                productionRecipe        + (table) crafting recipe
                assignmentsPriorityKey  + (string, "") priorityKey that should be set for all assignments triggered by this service
            callback                    + (Callback) to call once service is ready
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Factory.CraftItem_ASrv: Invalid input") return Callback.ErrorCall(callback) end

    -- gather assignment data
    local craftData = {
        productItemName = productItemName,
        productItemCount= productItemCount,

        recipe          = productionRecipe,
        workingLocation = productionSpot:getBaseLocation():copy(),

        priorityKey     = assignmentsPriorityKey,
    }
    local metaData = role_alchemist.Craft_MetaData(craftData)
    metaData.needTurtleId = enterprise_turtle.GetTurtleId_SSrv({ turtleLocator = turtleInputItemsLocator }).turtleId

    -- ToDo: consider setting metaData.itemList from turtleInputItemsLocator path (as we already have it)

    -- do assignment
--    corelog.WriteToLog("   >Crafting with recipe "..textutils.serialise(productionRecipe).."'s")
    local assignmentServiceData = {
        metaData    = metaData,
        taskCall    = TaskCall:new({ _moduleName = "role_alchemist", _methodName = "Craft_Task", _data = craftData, }),
    }
    return enterprise_assignmentboard.DoAssignment_ASrv(assignmentServiceData, callback)
end

function Factory.SmeltItem_ASrv(...)
    -- get & check input from description
    local checkSuccess, turtleInputItemsLocator, productionSpot, productItemCount, productionRecipe, assignmentsPriorityKey, callback = InputChecker.Check([[
        This async service should smelt items at the ProductionSpot.

        Return value:
                                        - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                        - (table)
                success                 - (boolean) whether the service executed correctly
                smeltReadyTime          - (number) the time when the smelting is supposed to be ready

        Parameters:
            serviceData                 - (table) data for the service
                turtleInputItemsLocator + (URL) locating the production ingredients in the turtle that should do the crafting
                productionSpot          + (ProductionSpot) production spot
                productItemCount        + (number) amount of items to produce
                productionRecipe        + (table) smelting recipe
                assignmentsPriorityKey  + (string, "") priorityKey that should be set for all assignments triggered by this service
            callback                    + (Callback) to call once service is ready
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Factory.SmeltItem_ASrv: Invalid input") return Callback.ErrorCall(callback) end

    -- gather assignment data
    local smeltData = {
        productItemCount= productItemCount,
        recipe          = productionRecipe,

        workingLocation = productionSpot:getBaseLocation():copy(),

        -- ToDo: do this more efficient/ different (determine beste type, calculate etc)
        fuelItemName    = "minecraft:birch_planks",
        fuelItemCount   = productItemCount,

        priorityKey     = assignmentsPriorityKey,
    }
    local metaData = role_alchemist.Smelt_MetaData(smeltData)
    metaData.needTurtleId = enterprise_turtle.GetTurtleId_SSrv({ turtleLocator = turtleInputItemsLocator }).turtleId
    -- ToDo: consider setting metaData.itemList from turtleInputItemsLocator path (as we already have it)

    -- do assignment
--    corelog.WriteToLog("   >Smelting with recipe "..textutils.serialise(productionRecipe).."'s")
    local assignmentServiceData = {
        metaData    = metaData,
        taskCall    = TaskCall:new({ _moduleName = "role_alchemist", _methodName = "Smelt_Task", _data = smeltData, }),
    }
    return enterprise_assignmentboard.DoAssignment_ASrv(assignmentServiceData, callback)
end

function Factory.Pickup_ASrv(...)
    -- get & check input from description
    local checkSuccess, pickUpTime, productionSpot, productItemName, productItemCount, assignmentsPriorityKey, callback = InputChecker.Check([[
        This async service should pickup the results from a previous smelt step.

        Return value:
                                        - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                        - (table)
                success                 - (boolean) whether the service executed correctly
                turtleOutputItemsLocator- (URL) locating the items that where pickedup (in a turtle)

        Parameters:
            serviceData                 - (table) data for the service
                pickUpTime              + (number) the time after which the pickup should be done
                productionSpot          + (ProductionSpot) production spot
                productItemName         + (string) name of item to produce
                productItemCount        + (number) amount of items to produce
                assignmentsPriorityKey  + (string, "") priorityKey that should be set for all assignments triggered by this service
            callback                    + (Callback) to call once service is ready
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Factory.Pickup_ASrv: Invalid input") return Callback.ErrorCall(callback) end

    -- gather assignment data
    local pickupData = {
        productItemName = productItemName,
        productItemCount= productItemCount,

        workingLocation = productionSpot:getBaseLocation():copy(),

        priorityKey     = assignmentsPriorityKey,
    }
    local metaData = role_alchemist.Pickup_MetaData(pickupData)
    metaData.startTime = pickUpTime

    -- do assignment
--    corelog.WriteToLog("   >Pickup at spot "..textutils.serialise(spotLocation).."")
    local assignmentServiceData = {
        metaData    = metaData,
        taskCall    = TaskCall:new({ _moduleName = "role_alchemist", _methodName = "Pickup_Task", _data = pickupData, }),
    }
    return enterprise_assignmentboard.DoAssignment_ASrv(assignmentServiceData, callback)
end

return Factory
