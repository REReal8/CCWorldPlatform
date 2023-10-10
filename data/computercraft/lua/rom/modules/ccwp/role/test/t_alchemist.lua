local t_alchemist = {}

local corelog = require "corelog"

local Location = require "obj_location"

local role_alchemist = require "role_alchemist"

local t_turtle

function t_alchemist.T_All()
end

function t_alchemist.T_AllPhysical()
    -- role_alchemist
    t_alchemist.T_Craft_Task()
    t_alchemist.T_Smelt_Task()
    t_alchemist.T_Pickup_Task()
end

local baseLocationV1 = Location:newInstance(12, 0, 1, 0, 1)

function t_alchemist.T_Craft_Task()
    -- prepare test
    corelog.WriteToLog("* role_alchemist.Craft_Task() tests")
    t_turtle = t_turtle or require "test.t_turtle"
    local craftData = {
        recipe = {
            [6]         = { itemName = "minecraft:birch_log", itemCount = 1 },
           yield        = 4
        },
        productItemName = "minecraft:birch_planks",
        productItemCount= 4,
        workingLocation = baseLocationV1:getRelativeLocation(3, 3, -4),
        workerLocator   = t_turtle.GetCurrentTurtleLocator()
    }

    -- test
    local result = role_alchemist.Craft_Task(craftData)
    corelog.WriteToLog("  result="..textutils.serialize(result))

    -- cleanup test
end

function t_alchemist.T_Smelt_Task()
    -- prepare test
    corelog.WriteToLog("* role_alchemist.Smelt_Task() tests")
    t_turtle = t_turtle or require "test.t_turtle"
    local smeltData = {
        recipe = {
            itemName    = "minecraft:birch_log",
            yield       = 1
        },
        productItemCount= 3,
        workingLocation = baseLocationV1:getRelativeLocation(3, 3, -3),
        fuelItemName    = "minecraft:birch_planks",
        fuelItemCount   = 3,
        workerLocator   = t_turtle.GetCurrentTurtleLocator()
    }

    -- test
    local result = role_alchemist.Smelt_Task(smeltData)
    corelog.WriteToLog("  result="..textutils.serialize(result))

    -- cleanup test
end

function t_alchemist.T_Pickup_Task()
    -- prepare test
    corelog.WriteToLog("* role_alchemist.Pickup_Task() tests")
    t_turtle = t_turtle or require "test.t_turtle"
    local pickupData = {
        productItemName = "minecraft:charcoal",
        productItemCount= 3,
        workingLocation = baseLocationV1:getRelativeLocation(3, 3, -3),
        workerLocator   = t_turtle.GetCurrentTurtleLocator()
    }

    -- test
    local result = role_alchemist.Pickup_Task(pickupData)
    corelog.WriteToLog("  result="..textutils.serialize(result))

    -- cleanup test
end

return t_alchemist
