local t_turtle = {}

local corelog = require "corelog"

local Callback = require "obj_callback"

local enterprise_turtle = require "enterprise_turtle"
local enterprise_energy = require "enterprise_energy"
local enterprise_forestry = require "enterprise_forestry"
local enterprise_isp = require "enterprise_isp"

local t_manufacturing = require "test.t_manufacturing"
local T_BirchForest = require "test.t_mobj_birchforest"
local TestObj = require "test.obj_test"

function t_turtle.T_All()
--    t_turtle.T_GetFuelLevels_Att()

    -- specific methods
    t_turtle.T_GetAnyTurtleLocator()
    t_turtle.T_getObject()

    -- service methods
    t_turtle.T_RegisterTurtle_SSrv()
    t_turtle.T_DelistTurtle_ASrv()
end

local itemsQuery = {
    ["minecraft:birch_log"] = 1,
    ["minecraft:torch"]     = 5,
}

local level0 = 0
local turtleId1 = 999999

function t_turtle.T_Can_ProvideItems()
    corelog.WriteToLog("* Test Can_ProvideItems_QSrv for turtles:")
    -- create transferData
    local itemsLocator = enterprise_turtle.GetItemsLocator_SSrv({ turtleId = turtleId1, itemsQuery = itemsQuery }).itemsLocator
    local queryData = {
        itemsLocator = itemsLocator,
    }

    -- call test method
    corelog.WriteToLog("  calling enterprise_isp.Can_ProvideItems_QSrv("..textutils.serialize(queryData)..")")
    local result = enterprise_isp.Can_ProvideItems_QSrv(queryData)
    corelog.WriteToLog("  result="..textutils.serialize(result))
end

-- print("GetFuelLevels_Att="..textutils.serialize(enterprise_turtle.GetFuelLevels_Att()))
function t_turtle.T_GetFuelLevels_Att()
    -- prepare test
    corelog.WriteToLog("# Test GetFuelLevels_Att")
    local forest = T_BirchForest.CreateTestObj() assert(forest, "Failed obtaining BirchForest")
    local forestLocator = enterprise_forestry:saveObject(forest)
    local T_Turtle = require "test.t_mobj_turtle"
    local turtleObj = T_Turtle.CreateTestObj() assert (turtleObj, "Failed obtaining Turtle")
    local location = turtleObj:getLocation()
    local result = t_manufacturing.StartNewSite(location) if not result.success then corelog.Error("failed starting Site") return end
    local factoryLocator = result.siteLocator

    local energyParameters = enterprise_energy.GetParameters()
    local originalLevel = energyParameters.enterpriseLevel
    local originalForestLocator = energyParameters.forestLocator
    local originalFactoryLocator = energyParameters.factoryLocator

    -- test
    enterprise_energy.UpdateEnterprise_SSrv({ enterpriseLevel = level0, forestLocator = forestLocator, factoryLocator = factoryLocator })
    local fuelLevels = enterprise_turtle.GetFuelLevels_Att()
    local expectedFuelLevel_Priority = 41
    assert(fuelLevels.fuelLevel_Priority == expectedFuelLevel_Priority, "gotten fuelLevel_Priority(="..fuelLevels.fuelLevel_Priority..") for energy enterpriseLevel "..level0.." not the same as expected(="..expectedFuelLevel_Priority..")")
    local expectedFuelLevel_Assignment = 41 -- ToDo: consider taking enterprise_assignmentboard maxFuelNeed_Assignment into account as well
    assert(fuelLevels.fuelLevel_Assignment == expectedFuelLevel_Assignment, "gotten fuelLevel_Assignment(="..fuelLevels.fuelLevel_Assignment..") for energy enterpriseLevel "..level0.." not the same as expected(="..expectedFuelLevel_Assignment..")")

    -- cleanup test
    enterprise_energy.UpdateEnterprise_SSrv({ enterpriseLevel = originalLevel, forestLocator = originalForestLocator, factoryLocator = originalFactoryLocator })

    t_manufacturing.StopSite(factoryLocator)

    enterprise_forestry:deleteResource(forestLocator)
end

function t_turtle.T_RegisterTurtle_SSrv()
    -- prepare test
    corelog.WriteToLog("* enterprise_turtle.RegisterTurtle_SSrv() tests")
    local objParameters = {
        turtleId    = turtleId1
    }

    -- test
    local result = enterprise_turtle.RegisterTurtle_SSrv(objParameters)
    assert(result.success, "failed registering Obj")
    local objLocator = result.turtleLocator
    assert(objLocator, "Failed obtaining objLocator")
    local obj = enterprise_turtle:getObject(objLocator)
    assert(obj, "Failed obtaining obj")

    -- cleanup test
    enterprise_turtle:deleteResource(objLocator)
end

function t_turtle.T_DelistTurtle_ASrv()
    -- prepare test
    corelog.WriteToLog("* enterprise_turtle.DelistTurtle_ASrv() tests")
    local objParameters = {
        turtleId        = turtleId1
    }
    local objLocator = enterprise_turtle.RegisterTurtle_SSrv(objParameters).turtleLocator if not objLocator then corelog.Error("failed registering Obj") return end
    local callback = Callback:new({
        _moduleName     = "t_turtle",
        _methodName     = "DelistTurtle_ASrv_callback",
        _data           = {
            ["objLocator"]                      = objLocator,
        },
    })

    -- test
    return enterprise_turtle.DelistTurtle_ASrv({ turtleLocator = objLocator}, callback)
end

function t_turtle.DelistTurtle_ASrv_callback(callbackData, serviceResults)
    -- test (cont)
    assert(serviceResults.success, "failed executing async service")

    local objLocator = callbackData["objLocator"]
    local objResourceTable = enterprise_turtle:getResource(objLocator)
    assert(not objResourceTable, "Obj wasn't deleted")

    -- cleanup test

    -- end
    return true
end

local compact = { compact = true }

function t_turtle.T_GetAnyTurtleLocator()
    -- prepare test
    corelog.WriteToLog("* enterprise_turtle.GetAnyTurtleLocator() tests")

    -- test
    local turtleLocator = enterprise_turtle.GetAnyTurtleLocator() assert(turtleLocator, "t_turtle.T_GetAnyTurtleLocator: Failed obtaining turtleLocator")
    local expectedLocator = enterprise_turtle:getTurtleLocator("any")
    assert(turtleLocator:isEqual(expectedLocator), "gotten locator(="..textutils.serialise(turtleLocator, compact)..") not the same as expected(="..textutils.serialise(expectedLocator, compact)..")")

    -- cleanup test
end

function t_turtle.GetCurrentTurtleLocator()
    --[[
        This method provides the locator of the current turtle (in enterprise_turtle).

        Return value:
            turtleLocator       - (URL) locating the current turtle

        Parameters:
    --]]

    -- construct URL
    local currentTurtleId = os.getComputerID()
    local currentTurtleLocator = enterprise_turtle:getTurtleLocator(tostring(currentTurtleId))

    -- end
    return currentTurtleLocator
end

function t_turtle.T_getObject()
    -- prepare test
    corelog.WriteToLog("* enterprise_turtle:getObject() tests")
    local testObject = TestObj:new({
        _field1 = "field1",
        _field2 = 4,
    })
    local className = "TestObj"
    local objectLocator = enterprise_turtle:saveObject(testObject, className)
    local currentTurtleLocator = t_turtle.GetCurrentTurtleLocator()
    local currentTurtle = enterprise_turtle:getObject(currentTurtleLocator)

    -- test normal object works (similair to T_Host.T_getObject())
    local object = enterprise_turtle:getObject(objectLocator) assert(object, "t_turtle.T_getObject: Failed obtaining object")
    assert(object:isEqual(testObject), "object(="..textutils.serialise(object, compact)..") not the same as expected(="..textutils.serialise(testObject, compact)..")")

    -- test "any turtle" provides current turtle
    local getAnyTurtleLocator = enterprise_turtle.GetAnyTurtleLocator()
    object = enterprise_turtle:getObject(getAnyTurtleLocator) assert(object, "t_turtle.T_getObject: Failed obtaining object")
    assert(object:isEqual(currentTurtle), "object(="..textutils.serialise(object, compact)..") not the same as expected(="..textutils.serialise(currentTurtle, compact)..")")

    -- cleanup test
    enterprise_turtle:deleteResource(objectLocator)
    assert(not enterprise_turtle:getResource(objectLocator), "resource not deleted")
end

return t_turtle
