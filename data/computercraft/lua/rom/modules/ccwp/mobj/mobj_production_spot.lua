-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local ProductionSpot = Class.NewClass(ObjBase)

--[[
    The ProductionSpot mobj represents a production spot in the minecraft world and provides production services to operate on that ProductionSpot.

    There are (currently) two production techniques for producing items.
        The crafting technique uses a crafting table to produce an output item from a set of input items (ingredients).
        The smelting technique uses a furnace to produce an output item from an input item (ingredient).
--]]

local corelog = require "corelog"
local coreutils = require "coreutils"

local InputChecker = require "input_checker"

local role_alchemist = require "role_alchemist"

local enterprise_energy = require "enterprise_energy"

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function ProductionSpot:_init(...)
    -- get & check input from description
    local checkSuccess, baseLocation, isCraftingSpot = InputChecker.Check([[
        Initialise a ProductionSpot.

        Parameters:
            baseLocation            + (Location) base location of the ProductionSpot
            isCraftingSpot          + (boolean) if it is a crafting spot
    ]], ...)
    if not checkSuccess then corelog.Error("ProductionSpot:_init: Invalid input") return nil end

    -- initialisation
    ObjBase._init(self)
    self._baseLocation      = baseLocation
    self._isCraftingSpot   = isCraftingSpot
end

-- ToDo: should be renamed to newFromTable at some point
function ProductionSpot:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a ProductionSpot.

        Parameters:
            o                       + (table, {}) with object fields
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

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

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

return ProductionSpot
