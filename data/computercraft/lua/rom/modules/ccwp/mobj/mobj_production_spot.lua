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

function ProductionSpot:craftItem_AOSrv(...)
    -- get & check input from description
    local checkSuccess, turtleInputItemsLocator, productItemName, productItemCount, productionRecipe, assignmentsPriorityKey, callback = InputChecker.Check([[
        This async service should craft items at the ProductionSpot.

        Return value:
                                        - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                        - (table)
                success                 - (boolean) whether the service executed correctly
                turtleOutputItemsLocator- (ObjLocator) locating the items that where produced (in a turtle)
                turtleWasteItemsLocator - (ObjLocator) locating waste items produced during production

        Parameters:
            serviceData                 - (table) data for the service
                turtleInputItemsLocator + (ObjLocator) locating the production ingredients in the turtle that should do the crafting
                productItemName         + (string) name of item to produce
                productItemCount        + (number) amount of items to produce
                productionRecipe        + (table) crafting recipe
                assignmentsPriorityKey  + (string, "") priorityKey that should be set for all assignments triggered by this service
            callback                    + (Callback) to call once service is ready
    ]], ...)
    if not checkSuccess then corelog.Error("ProductionSpot:craftItem_AOSrv: Invalid input") return Callback.ErrorCall(callback) end

    -- gather assignment data
    local craftData = {
        productItemName = productItemName,
        productItemCount= productItemCount,

        recipe          = productionRecipe,
        workingLocation = self:getBaseLocation():copy(),

        priorityKey     = assignmentsPriorityKey,
    }
    local metaData = role_alchemist.Craft_MetaData(craftData)
    local turtleObj = ObjHost.GetObj(turtleInputItemsLocator) if not turtleObj then corelog.Error("ProductionSpot:craftItem_AOSrv: Failed obtaining turtle "..turtleInputItemsLocator:getURI()) return Callback.ErrorCall(callback) end
    metaData.needWorkerId = turtleObj:getWorkerId()
    -- ToDo: consider setting metaData.itemList from turtleInputItemsLocator path (as we already have it)

    -- do assignment
--    corelog.WriteToLog("   >Crafting with recipe "..textutils.serialise(productionRecipe).."'s")
    local assignmentServiceData = {
        metaData    = metaData,
        taskCall    = TaskCall:newInstance("role_alchemist", "Craft_Task", craftData),
    }
    return enterprise_assignmentboard.DoAssignment_ASrv(assignmentServiceData, callback)
end

function ProductionSpot:smeltItem_AOSrv(...)
    -- get & check input from description
    local checkSuccess, turtleInputItemsLocator, productItemCount, productionRecipe, assignmentsPriorityKey, callback = InputChecker.Check([[
        This async service should smelt items at the ProductionSpot.

        Return value:
                                        - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                        - (table)
                success                 - (boolean) whether the service executed correctly
                smeltReadyTime          - (number) the time when the smelting is supposed to be ready

        Parameters:
            serviceData                 - (table) data for the service
                turtleInputItemsLocator + (ObjLocator) locating the production ingredients in the turtle that should do the crafting
                productItemCount        + (number) amount of items to produce
                productionRecipe        + (table) smelting recipe
                assignmentsPriorityKey  + (string, "") priorityKey that should be set for all assignments triggered by this service
            callback                    + (Callback) to call once service is ready
    ]], ...)
    if not checkSuccess then corelog.Error("ProductionSpot:smeltItem_AOSrv: Invalid input") return Callback.ErrorCall(callback) end

    -- gather assignment data
    local smeltData = {
        productItemCount= productItemCount,
        recipe          = productionRecipe,

        workingLocation = self:getBaseLocation():copy(),

        -- ToDo: do this more efficient/ different (determine beste type, calculate etc)
        fuelItemName    = "minecraft:birch_planks",
        fuelItemCount   = productItemCount,

        priorityKey     = assignmentsPriorityKey,
    }
    local metaData = role_alchemist.Smelt_MetaData(smeltData)
    local turtleObj = ObjHost.GetObj(turtleInputItemsLocator) if not turtleObj then corelog.Error("ProductionSpot:smeltItem_AOSrv: Failed obtaining turtle "..turtleInputItemsLocator:getURI()) return Callback.ErrorCall(callback) end
    metaData.needWorkerId = turtleObj:getWorkerId()
    -- ToDo: consider setting metaData.itemList from turtleInputItemsLocator path (as we already have it)

    -- do assignment
--    corelog.WriteToLog("   >Smelting with recipe "..textutils.serialise(productionRecipe).."'s")
    local assignmentServiceData = {
        metaData    = metaData,
        taskCall    = TaskCall:newInstance("role_alchemist", "Smelt_Task", smeltData),
    }
    return enterprise_assignmentboard.DoAssignment_ASrv(assignmentServiceData, callback)
end

function ProductionSpot:pickup_AOSrv(...)
    -- get & check input from description
    local checkSuccess, pickUpTime, productItemName, productItemCount, assignmentsPriorityKey, callback = InputChecker.Check([[
        This async service should pickup the results from a previous smelt step.

        Return value:
                                        - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                        - (table)
                success                 - (boolean) whether the service executed correctly
                turtleOutputItemsLocator- (ObjLocator) locating the items that where pickedup (in a turtle)
                turtleWasteItemsLocator - (ObjLocator) locating waste items produced during production

        Parameters:
            serviceData                 - (table) data for the service
                pickUpTime              + (number) the time after which the pickup should be done
                productItemName         + (string) name of item to produce
                productItemCount        + (number) amount of items to produce
                assignmentsPriorityKey  + (string, "") priorityKey that should be set for all assignments triggered by this service
            callback                    + (Callback) to call once service is ready
    ]], ...)
    if not checkSuccess then corelog.Error("ProductionSpot:pickup_AOSrv: Invalid input") return Callback.ErrorCall(callback) end

    -- gather assignment data
    local pickupData = {
        productItemName = productItemName,
        productItemCount= productItemCount,

        workingLocation = self:getBaseLocation():copy(),

        priorityKey     = assignmentsPriorityKey,
    }
    local metaData = role_alchemist.Pickup_MetaData(pickupData)
    metaData.startTime = pickUpTime

    -- do assignment
--    corelog.WriteToLog("   >Pickup at spot "..textutils.serialise(spotLocation).."")
    local assignmentServiceData = {
        metaData    = metaData,
        taskCall    = TaskCall:newInstance("role_alchemist", "Pickup_Task", pickupData),
    }
    return enterprise_assignmentboard.DoAssignment_ASrv(assignmentServiceData, callback)
end

--    _____ _____ _                  _____                   _ _
--   |_   _|_   _| |                / ____|                 | (_)
--     | |   | | | |_ ___ _ __ ___ | (___  _   _ _ __  _ __ | |_  ___ _ __
--     | |   | | | __/ _ \ '_ ` _ \ \___ \| | | | '_ \| '_ \| | |/ _ \ '__|
--    _| |_ _| |_| ||  __/ | | | | |____) | |_| | |_) | |_) | | |  __/ |
--   |_____|_____|\__\___|_| |_| |_|_____/ \__,_| .__/| .__/|_|_|\___|_|
--                                              | |   | |
--                                              |_|   |_|

return ProductionSpot
