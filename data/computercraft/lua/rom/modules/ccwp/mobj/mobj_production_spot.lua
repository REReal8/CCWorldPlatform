-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local ProductionSpot = Class.NewClass(ObjBase)

local corelog = require "corelog"
local coreutils = require "coreutils"

local InputChecker = require "input_checker"

local role_alchemist = require "role_alchemist"

--[[
    The ProductionSpot mobj represents a production spot in the minecraft world and provides production services to operate on that ProductionSpot.

    There are (currently) two production techniques for producing items.
        The crafting technique uses a crafting table to produce an output item from a set of input items (ingredients).
        The smelting technique uses a furnace to produce an output item from an input item (ingredient).
--]]

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function ProductionSpot:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a ProductionSpot.

        Parameters:
            o                       + (table, {}) with object fields
                _baseLocation       - (Location) base location of the ProductionSpot
                _isCraftingSpot     - (boolean) if it is a crafting spot
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("ProductionSpot:new: Invalid input") return {} end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- end
    return o
end

function ProductionSpot:getBaseLocation()
    return self._baseLocation
end

function ProductionSpot:isCraftingSpot()
    return self._isCraftingSpot
end

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

function ProductionSpot:getClassName()
    return "ProductionSpot"
end

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

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
    ]], table.unpack(arg))
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
