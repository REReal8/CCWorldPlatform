local t_alchemist = {}

local corelog = require "corelog"

local Location = require "obj_location"

local role_alchemist = require "role_alchemist"

function t_alchemist.T_All()
end

local baseLocationV1 = Location:new({_x=12, _y= 0, _z= 1, _dx=0, _dy=1})

function t_alchemist.T_Craft_Task()
    local craftData = {
        recipe = {
            [6]         = { itemName = "minecraft:birch_log", itemCount = 1 },
           yield        = 4
        },
        productItemName = "minecraft:birch_planks",
        productItemCount= 4,
        workingLocation = baseLocationV1:getRelativeLocation(3, 3, -4),
    }

    local result = role_alchemist.Craft_Task(craftData)
    corelog.WriteToLog("  result="..textutils.serialize(result))
end

function t_alchemist.T_Smelt_Task()
    local smeltData = {
        recipe = {
            itemName    = "minecraft:birch_log",
            yield       = 1
        },
        productItemCount= 3,
        workingLocation = baseLocationV1:getRelativeLocation(3, 3, -3),
        fuelItemName    = "minecraft:birch_planks",
        fuelItemCount   = 3,
    }

    local result = role_alchemist.Smelt_Task(smeltData)
    corelog.WriteToLog("  result="..textutils.serialize(result))
end

function t_alchemist.T_Pickup_Task()
    local pickupData = {
        productItemName = "minecraft:charcoal",
        productItemCount= 3,
        workingLocation = baseLocationV1:getRelativeLocation(3, 3, -3),
    }

    local result = role_alchemist.Pickup_Task(pickupData)
    corelog.WriteToLog("  result="..textutils.serialize(result))
end

return t_alchemist
