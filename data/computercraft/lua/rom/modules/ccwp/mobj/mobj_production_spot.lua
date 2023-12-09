-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local ILObj = require "i_lobj"
local ProductionSpot = Class.NewClass(ObjBase, ILObj)

--[[
    The ProductionSpot mobj represents a production spot in the minecraft world and provides production services to operate on that ProductionSpot.

    There are (currently) two production techniques for producing items.
        The crafting technique uses a crafting table to produce an output item from a set of input items (ingredients).
        The smelting technique uses a furnace to produce an output item from an input item (ingredient).
--]]

local corelog = require "corelog"
local coreutils = require "coreutils"

local InputChecker = require "input_checker"

local Callback = require "obj_callback"
local TaskCall = require "obj_task_call"
local ObjHost = require "obj_host"

local role_alchemist = require "role_alchemist"

local enterprise_projects = require "enterprise_projects"
local enterprise_employment = require "enterprise_employment"
local enterprise_assignmentboard = require "enterprise_assignmentboard"
local enterprise_energy = require "enterprise_energy"

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function ProductionSpot:_init(...)
    -- get & check input from description
    local checkSuccess, id, baseLocation, isCraftingSpot = InputChecker.Check([[
        Initialise a ProductionSpot.

        Parameters:
            id                      + (string) id of the ProductionSpot
            baseLocation            + (Location) base location of the ProductionSpot
            isCraftingSpot          + (boolean) if it is a crafting spot
    ]], ...)
    if not checkSuccess then corelog.Error("ProductionSpot:_init: Invalid input") return nil end

    -- initialisation
    ObjBase._init(self)
    self._id                = id
    self._baseLocation      = baseLocation
    self._isCraftingSpot    = isCraftingSpot
end

-- ToDo: should be renamed to newFromTable at some point
function ProductionSpot:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a ProductionSpot.

        Parameters:
            o                       + (table, {}) with object fields
                _id                 - (string, "unknown") id of the ProductionSpot
                _baseLocation       - (Location) base location of the ProductionSpot
                _isCraftingSpot     - (boolean) if it is a crafting spot
    ]], ...)
    if not checkSuccess then corelog.Error("ProductionSpot:new: Invalid input") return {} end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- end
    return o
end

function ProductionSpot:isCraftingSpot()
    return self._isCraftingSpot
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function ProductionSpot:getClassName()
    return "ProductionSpot"
end

--    _____ _      ____  _     _
--   |_   _| |    / __ \| |   (_)
--     | | | |   | |  | | |__  _
--     | | | |   | |  | | '_ \| |
--    _| |_| |___| |__| | |_) | |
--   |_____|______\____/|_.__/| |
--                           _/ |
--                          |__/

function ProductionSpot:construct(...)
    -- get & check input from description
    local checkSuccess, baseLocation, isCraftingSpot = InputChecker.Check([[
        This method constructs a ProductionSpot instance from a table of parameters with all necessary fields (in an objectTable) and methods (by setmetatable) as defined in the class.

        The constructed ProductionSpot is not yet saved in the LObjHost.

        Return value:
                                        - (ProductionSpot) the constructed ProductionSpot

        Parameters:
            constructParameters         - (table) parameters for constructing the ProductionSpot
                baseLocation            + (Location) base location of the ProductionSpot
                isCraftingSpot          + (boolean) if it is a crafting spot
    ]], ...)
    if not checkSuccess then corelog.Error("ProductionSpot:construct: Invalid input") return nil end

    -- determine ProductionSpot fields
    local id = coreutils.NewId()

    -- construct new ProductionSpot
    local obj = ProductionSpot:newInstance(id, baseLocation:copy(), isCraftingSpot)

    -- end
    return obj
end

function ProductionSpot:destruct()
    --[[
        This method destructs a ProductionSpot instance.

        The ProductionSpot is not yet deleted from the MObjHost.

        Return value:
                                        - (boolean) whether the ProductionSpot was succesfully destructed.

        Parameters:
    ]]

    -- end
    local destructSuccess = true
    return destructSuccess
end

function ProductionSpot:getId()
    return self._id
end

function ProductionSpot:getWIPId()
    return self:getClassName().." "..self:getId()
end

--    _____ __  __  ____  _     _
--   |_   _|  \/  |/ __ \| |   (_)
--     | | | \  / | |  | | |__  _
--     | | | |\/| | |  | | '_ \| |
--    _| |_| |  | | |__| | |_) | |
--   |_____|_|  |_|\____/|_.__/| |
--                            _/ |
--                           |__/

function ProductionSpot:getBaseLocation()
    return self._baseLocation
end

-- ToDo: make ProductionSpot a full IMObj (i.e. inherit + add other methods)

--    _____               _            _   _              _____             _
--   |  __ \             | |          | | (_)            / ____|           | |
--   | |__) | __ ___   __| |_   _  ___| |_ _  ___  _ __ | (___  _ __   ___ | |_
--   |  ___/ '__/ _ \ / _` | | | |/ __| __| |/ _ \| '_ \ \___ \| '_ \ / _ \| __|
--   | |   | | | (_) | (_| | |_| | (__| |_| | (_) | | | |____) | |_) | (_) | |_
--   |_|   |_|  \___/ \__,_|\__,_|\___|\__|_|\___/|_| |_|_____/| .__/ \___/ \__|
--                                                             | |
--                                                             |_|

function ProductionSpot:getFuelNeed_Production_Att(...)
    -- get & check input from description
    local checkSuccess, items = InputChecker.Check([[
        ProductionSpot attribute for the current fuelNeed for producing items.

        It returns the fuelNeed for producing the items assuming the ingredients (incl possible production fuel) are available (in a Turtle located) at the ProductionSpot baseLocation
        and the results are to be delivered to that Location. In other worths we ignore fuel needs to and from the ProductionSpot.

        Return value:
            fuelNeed        - (number) amount of fuel needed to produce items

        Parameters:
            items           + (table) items to produce
    --]], ...)
    if not checkSuccess then corelog.Error("ProductionSpot:getFuelNeed_Production_Att: Invalid input") return enterprise_energy.GetLargeFuelAmount_Att() end

    -- fuelNeed for production of items
    local fuelNeed_Production = 0
    for _, _ in pairs(items) do
        if self:isCraftingSpot() then
            fuelNeed_Production = fuelNeed_Production + 0 -- craft
        else
            fuelNeed_Production = fuelNeed_Production + 4 + 4 -- smelt + pickup
        end
    end

    -- end
    return fuelNeed_Production
end

function ProductionSpot:produceIngredientsNeeded(...)
    -- get & check input from description
    local checkSuccess, productionRecipe, productItemCount = InputChecker.Check([[
        This method determines the ingredients needed to produce 'productItemCount' items with the 'productionRecipe'.

        Return value:
            ingredientsNeeded           - (table) ingredientsNeeded to produce items
            productSurplus              - (number) number of surplus requested products

        Parameters:
            productionRecipe            + (table) production recipe
            productItemCount            + (number) amount of items to produce
    ]], ...)
    if not checkSuccess then corelog.Error("ProductionSpot:itemsNeeded: Invalid input") return nil end

    -- determine ingredientsNeeded
    local ingredientsNeeded = nil
    local productSurplus = nil
    if self:isCraftingSpot() then
        ingredientsNeeded, productSurplus = role_alchemist.Craft_ItemsNeeded(productionRecipe, productItemCount)
        ingredientsNeeded = coreutils.DeepCopy(ingredientsNeeded)
    else
        -- determine production fuel
        -- ToDo: do this differently
        local fuelItemName  = "minecraft:birch_planks"
        local fuelItemCount = productItemCount

        ingredientsNeeded, productSurplus = role_alchemist.Smelt_ItemsNeeded(productionRecipe, productItemCount, fuelItemName, fuelItemCount)
        ingredientsNeeded = coreutils.DeepCopy(ingredientsNeeded)
    end

    -- end
    return ingredientsNeeded, productSurplus
end

--    _____ _____ _                  _____                   _ _
--   |_   _|_   _| |                / ____|                 | (_)
--     | |   | | | |_ ___ _ __ ___ | (___  _   _ _ __  _ __ | |_  ___ _ __
--     | |   | | | __/ _ \ '_ ` _ \ \___ \| | | | '_ \| '_ \| | |/ _ \ '__|
--    _| |_ _| |_| ||  __/ | | | | |____) | |_| | |_) | |_) | | |  __/ |
--   |_____|_____|\__\___|_| |_| |_|_____/ \__,_| .__/| .__/|_|_|\___|_|
--                                              | |   | |
--                                              |_|   |_|

function ProductionSpot:produceItem_AOSrv(...)
    -- get & check input from description
    local checkSuccess, localInputItemsLocator, localOutputLocator, productItemName, productItemCount, productionRecipe, assignmentsPriorityKey, callback = InputChecker.Check([[
        This async public service produces multiple instances of a specific item in a factory site. It does so by producing
        the requested amount of items with the supplied production method (i.e. crafting or smelting).

        Return value:
                                        - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                        - (table)
                success                 - (boolean) whether the service executed correctly
                localOutputItemsLocator - (ObjLocator) locating the items that where produced
                                            (upon service succes the "host" component of this ObjLocator should be equal to localOutputLocator, and
                                            the "query" should be equal to the "query" component of the localInputItemLocator)
                wasteItemsLocator       - (ObjLocator) locating waste items produced during production

        Parameters:
            serviceData                 - (table) data for the service
                localInputItemsLocator  + (ObjLocator) locating where the production ingredients can be retrieved locally "within" the site (e.g. an input Chest)
                localOutputLocator      + (ObjLocator) locating where the produced items need to be delivered locally "within" the site (e.g. an output Chest)
                productItemName         + (string) name of item to produce
                productItemCount        + (number) amount of items to produce
                productionRecipe        + (table) production recipe
                assignmentsPriorityKey  + (string, "") priorityKey that should be set for all assignments triggered by this service
            callback                    + (Callback) to call once service is ready
    ]], ...)
    if not checkSuccess then corelog.Error("ProductionSpot:produceItem_AOSrv: Invalid input") return Callback.ErrorCall(callback) end

    -- determine turtleInputLocator
    local turtleInputLocator = enterprise_employment.GetAnyTurtleLocator()

    -- create project data
    local projectData = {
        localInputItemsLocator      = localInputItemsLocator,
        localOutputLocator          = localOutputLocator,

        turtleInputLocator          = turtleInputLocator,

        assignmentsPriorityKey      = assignmentsPriorityKey,
    }

    -- determine production steps
    local projectSteps = {
        -- get items into Turtle
        -- ToDo: consider using provideItemsTo_AOSrv here...
        { stepType = "LAOSrv", stepTypeDef = { serviceName = "storeItemsFrom_AOSrv", locatorStep = 0, locatorKeyDef = "turtleInputLocator" }, stepDataDef = {
            { keyDef = "itemsLocator"               , sourceStep = 0, sourceKeyDef = "localInputItemsLocator" },
            { keyDef = "assignmentsPriorityKey"     , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
        }, description = "Getting items "..localInputItemsLocator:getURI().." (local input) into Turtle"},
    }

    -- add production steps
    local extraStep = 0
    if self:isCraftingSpot() then
        -- craftData
        local craftData = {
            productItemName = productItemName,
            productItemCount= productItemCount,

            recipe          = productionRecipe,
            workingLocation = self:getBaseLocation():copy(),

            priorityKey     = assignmentsPriorityKey,
        }
        projectData.craftMetaData = role_alchemist.Craft_MetaData(craftData)
        projectData.craftTaskCall = TaskCall:newInstance("role_alchemist", "Craft_Task", craftData)

        -- add crafting steps
        table.insert(projectSteps,
            -- obtain workerId
            { stepType = "LSOMtd", stepTypeDef = { methodName = "getWorkerId", locatorStep = 1, locatorKeyDef = "destinationItemsLocator" }, stepDataDef = {
            }}
        )
        extraStep = 1
        table.insert(projectSteps,
            -- Craft_Task
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_assignmentboard", serviceName = "DoAssignment_ASrv" }, stepDataDef = {
                { keyDef = "metaData"               , sourceStep = 0, sourceKeyDef = "craftMetaData" },
                { keyDef = "metaData.needWorkerId"  , sourceStep = 2, sourceKeyDef = "methodResults" },
                { keyDef = "taskCall"               , sourceStep = 0, sourceKeyDef = "craftTaskCall" },
            }, description = "Crafting "..productItemCount.." "..productItemName}
        )
    else
        -- smeltData
        local smeltData = {
            productItemCount= productItemCount,
            recipe          = productionRecipe,

            workingLocation = self:getBaseLocation():copy(),

            -- ToDo: do this more efficient/ different (determine beste type, calculate etc)
            fuelItemName    = "minecraft:birch_planks",
            fuelItemCount   = productItemCount,

            priorityKey     = assignmentsPriorityKey,
        }
        projectData.smeltMetaData = role_alchemist.Smelt_MetaData(smeltData)
        projectData.smeltTaskCall = TaskCall:newInstance("role_alchemist", "Smelt_Task", smeltData)

        -- add smelting steps
        table.insert(projectSteps,
            -- obtain workerId
            { stepType = "LSOMtd", stepTypeDef = { methodName = "getWorkerId", locatorStep = 1, locatorKeyDef = "destinationItemsLocator" }, stepDataDef = {
            }}
        )
        table.insert(projectSteps,
            -- Smelt_Task
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_assignmentboard", serviceName = "DoAssignment_ASrv" }, stepDataDef = {
                { keyDef = "metaData"               , sourceStep = 0, sourceKeyDef = "smeltMetaData" },
                { keyDef = "metaData.needWorkerId"  , sourceStep = 2, sourceKeyDef = "methodResults" },
                { keyDef = "taskCall"               , sourceStep = 0, sourceKeyDef = "smeltTaskCall" },
            }, description = "Smelting "..productItemCount.." "..productItemName}
        )

        -- pickupData
        local pickupData = {
            productItemName = productItemName,
            productItemCount= productItemCount,

            workingLocation = self:getBaseLocation():copy(),

            priorityKey     = assignmentsPriorityKey,
        }
        projectData.pickupMetaData = role_alchemist.Pickup_MetaData(pickupData)
        projectData.pickupTaskCall = TaskCall:newInstance("role_alchemist", "Pickup_Task", pickupData)

        -- add pickup step
        table.insert(projectSteps,
            -- Pickup_Task
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_assignmentboard", serviceName = "DoAssignment_ASrv" }, stepDataDef = {
                { keyDef = "metaData"               , sourceStep = 0, sourceKeyDef = "pickupMetaData" },
                { keyDef = "metaData.startTime"     , sourceStep = 3, sourceKeyDef = "smeltReadyTime" },
                { keyDef = "taskCall"               , sourceStep = 0, sourceKeyDef = "pickupTaskCall" },
            }, description = "Pickup "..productItemCount.." "..productItemName}
        )

        extraStep = 2
    end

    -- add remaining steps
    table.insert(projectSteps,
        { stepType = "LAOSrv", stepTypeDef = { serviceName = "storeItemsFrom_AOSrv", locatorStep = 0, locatorKeyDef = "localOutputLocator" }, stepDataDef = {
            { keyDef = "itemsLocator"               , sourceStep = 2 + extraStep, sourceKeyDef = "turtleOutputItemsLocator" },
            { keyDef = "assignmentsPriorityKey"     , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
        }, description = "Storing items into "..localOutputLocator:getURI().." (local output)" }
    )

    -- create (remaining) project definition
    local projectDef = {
        steps = projectSteps,
        returnData  = {
            { keyDef = "wasteItemsLocator"          , sourceStep = 2 + extraStep, sourceKeyDef = "turtleWasteItemsLocator" },
            { keyDef = "localOutputItemsLocator"    , sourceStep = 3 + extraStep, sourceKeyDef = "destinationItemsLocator" },
        }
    }
    local projectServiceData = {
        projectDef  = projectDef,
        projectData = projectData,
        projectMeta = { title = "ProductionSpot:produceItem_AOSrv", description = "Time to make "..productItemCount.." "..productItemName}, -- add wipId here. likely once we have ProductionSpot's that are IItemSupplier's
    }

    -- start project
    return enterprise_projects.StartProject_ASrv(projectServiceData, callback)
end

return ProductionSpot
