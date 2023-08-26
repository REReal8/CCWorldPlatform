local t_isp = {}

local corelog = require "corelog"

local Callback = require "obj_callback"

local Location = require "obj_location"

local enterprise_turtle = require "enterprise_turtle"
local enterprise_projects = require "enterprise_projects"
local enterprise_isp = require "enterprise_isp"

local t_chests = require "test.t_chests"

function t_isp.T_All()
    t_isp.T_AddItemsLocators()
end

local testStartLocation  = Location:newInstance(-6, 0, 1, 0, 1)
local testStartLocation2  = Location:newInstance(-6, 6, 1, 0, 1)
local itemsQuery = {
    ["minecraft:birch_log"] = 1,
    ["minecraft:torch"]     = 5,
}

local callback = Callback:new({
    _moduleName     = "t_main",
    _methodName     = "Func1_Callback",
    _data           = {"some callback data"},
})

function t_isp.T_AddItemsLocators()
    -- create testData
    local itemsQuery1 = {
        ["minecraft:birch_log"] = 1,
        ["minecraft:torch"]     = 5,
    }
    local itemsQuery2 = {
        ["minecraft:birch_log"] = 1,
        ["minecraft:torch"]     = 5,
    }
    local itemsQuery3 = {
        ["minecraft:birch_log"] = 1,
        ["minecraft:charcoal"]  = 100,
    }
    local turtleId = os.getComputerID()
    local testData = {
        itemsLocator1 = enterprise_turtle.GetItemsLocator_SSrv({ turtleId = turtleId, itemsQuery = itemsQuery1 }).itemsLocator,
        itemsLocator2 = enterprise_turtle.GetItemsLocator_SSrv({ turtleId = turtleId, itemsQuery = itemsQuery2 }).itemsLocator,
        itemsLocator3 = enterprise_turtle.GetItemsLocator_SSrv({ turtleId = turtleId, itemsQuery = itemsQuery3 }).itemsLocator,
    }

    -- call test method
    local result = enterprise_isp.AddItemsLocators_SSrv(testData)
--    corelog.WriteToLog("  result="..textutils.serialize(result))

    -- check result
    local expectedItemsQuery = {
        ["minecraft:charcoal"]  = 100,
        ["minecraft:birch_log"] = 3,
        ["minecraft:torch"]     = 10,
    }
    local expectedItemsLocator = enterprise_turtle.GetItemsLocator_SSrv({ turtleId = turtleId, itemsQuery = expectedItemsQuery }).itemsLocator
    assert(expectedItemsLocator:sameBase(result.itemsLocator), "result itemsLocator (="..result.itemsLocator:getURI()..") different base from expected (="..expectedItemsLocator:getURI()..")")
    assert(expectedItemsLocator:sameQuery(result.itemsLocator), "result itemsLocator (="..result.itemsLocator:getURI()..") different query from expected (="..expectedItemsLocator:getURI()..")")
end

return t_isp
