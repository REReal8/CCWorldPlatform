local t_turtle = {}

local corelog = require "corelog"

local Callback = require "obj_callback"
local Location = require "obj_location"

local enterprise_turtle = require "enterprise_turtle"
local enterprise_energy = require "enterprise_energy"
local enterprise_forestry = require "enterprise_forestry"
local enterprise_manufacturing = require "enterprise_manufacturing"

local T_BirchForest = require "test.t_mobj_birchforest"
local TestObj = require "test.obj_test"
local T_MObjHost = require "test.t_mobj_host"
local T_Turtle

function t_turtle.T_All()
--    t_turtle.T_GetFuelLevels_Att()

    -- specific methods
    t_turtle.T_GetAnyTurtleLocator()
    t_turtle.T_getObject()

    -- MObjHost methods
    t_turtle.T_hostMObj_SSrv_Turtle()
    t_turtle.T_releaseMObj_SSrv_Turtle()
end

function t_turtle.T_AllPhysical()
    -- IObj methods

    -- MObjHost methods
    local mobjLocator = t_turtle.T_hostAndBuildMObj_ASrv_Turtle()
    t_turtle.T_dismantleAndReleaseMObj_ASrv_Turtle(mobjLocator)
end

local logOk = false
local testMObjClassName = "Turtle"
local testMObjName = "turtle"
local level0 = 0
local turtleId = 999999
local location1  = Location:newInstance(-6, 6, 1, 0, 1)
local fuelPriorityKey = ""

local constructParameters = {
    turtleId        = turtleId,
    location        = location1,
}

-- print("GetFuelLevels_Att="..textutils.serialize(enterprise_turtle.GetFuelLevels_Att()))
function t_turtle.T_GetFuelLevels_Att()
    -- prepare test
    corelog.WriteToLog("# Test GetFuelLevels_Att")
    local forest = T_BirchForest.CreateTestObj() assert(forest, "Failed obtaining BirchForest")
    local forestLocator = enterprise_forestry:saveObject(forest)
    T_Turtle = T_Turtle or require "test.t_mobj_turtle"
    local turtleObj = T_Turtle.CreateTestObj() assert (turtleObj, "Failed obtaining Turtle")
    local location = turtleObj:getLocation()
    local factoryClassName = "Factory"
    local factoryConstructParameters = {
        level           = 0,

        baseLocation    = location,
    }

    local result = enterprise_manufacturing:hostMObj_SSrv({ className = factoryClassName, constructParameters = factoryConstructParameters}) assert(result.success, "Failed hosting Factory")
    local factoryLocator = result.mobjLocator

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

    result = enterprise_manufacturing:releaseMObj_SSrv({ mobjLocator = factoryLocator}) assert(result, "Failed releasing Factory")

    enterprise_forestry:deleteResource(forestLocator)
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

-- ToDo: consider replacing with direct calls to enterprise_turtle:GetCurrentTurtleLocator()
function t_turtle.GetCurrentTurtleLocator()
    --[[
        This method provides the locator of the current turtle (in enterprise_turtle).

        Return value:
            turtleLocator       - (URL) locating the current turtle

        Parameters:
    --]]

    -- check turtle
    assert(turtle, "Current computer(ID="..os.getComputerID()..") not a Turtle")

    -- construct URL
    local currentTurtleLocator = enterprise_turtle:GetCurrentTurtleLocator()

    -- end
    return currentTurtleLocator
end

function t_turtle.T_getObject()
    -- prepare test
    corelog.WriteToLog("* enterprise_turtle:getObject() tests")
    local testObject = TestObj:newInstance("field1", 4)
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

--    __  __  ____  _     _ _    _           _                    _   _               _
--   |  \/  |/ __ \| |   (_) |  | |         | |                  | | | |             | |
--   | \  / | |  | | |__  _| |__| | ___  ___| |_   _ __ ___   ___| |_| |__   ___   __| |___
--   | |\/| | |  | | '_ \| |  __  |/ _ \/ __| __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   | |  | | |__| | |_) | | |  | | (_) \__ \ |_  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_|  |_|\____/|_.__/| |_|  |_|\___/|___/\__| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                      _/ |
--                     |__/

function t_turtle.T_hostMObj_SSrv_Turtle()
    -- prepare test
    local id = tostring(turtleId)
    T_Turtle = T_Turtle or require "test.t_mobj_turtle"
    local fieldsTest0 = T_Turtle.CreateInitialisedTest(id, location1, fuelPriorityKey)

    -- test
    local serviceResults = T_MObjHost.pt_hostMObj_SSrv(enterprise_forestry, testMObjClassName, constructParameters, testMObjName, fieldsTest0, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

local mobjLocator_Turtle = nil

function t_turtle.T_hostAndBuildMObj_ASrv_Turtle()
    -- prepare test

    -- test
    local serviceResults = T_MObjHost.pt_hostAndBuildMObj_ASrv(enterprise_forestry, testMObjClassName, constructParameters, testMObjName, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    mobjLocator_Turtle = serviceResults.mobjLocator

    -- return mobjLocator
    return serviceResults.mobjLocator
end

function t_turtle.T_releaseMObj_SSrv_Turtle()
    -- prepare test

    -- test
    local serviceResults = T_MObjHost.pt_releaseMObj_SSrv(enterprise_forestry, testMObjClassName, constructParameters, testMObjName, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

function t_turtle.T_dismantleAndReleaseMObj_ASrv_Turtle(mobjLocator)
    -- prepare test
    if not mobjLocator then
        -- see if we locally remembered a mobjLocator
        assert(mobjLocator_Turtle, "no mobjLocator to operate on")
        mobjLocator = mobjLocator_Turtle
    end

    -- test
    local serviceResults = T_MObjHost.pt_dismantleAndReleaseMObj_ASrv(enterprise_forestry, mobjLocator, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    mobjLocator_Turtle = nil
end

return t_turtle
