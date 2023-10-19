local t_employment = {}

local corelog = require "corelog"

local Callback = require "obj_callback"
local MethodExecutor = require "method_executor"
local Location = require "obj_location"

local enterprise_employment = require "enterprise_employment"
local enterprise_energy = require "enterprise_energy"
local enterprise_forestry = require "enterprise_forestry"
local enterprise_manufacturing = require "enterprise_manufacturing"

local T_BirchForest = require "test.t_mobj_birchforest"
local TestObj = require "test.obj_test"
local T_MObjHost = require "test.t_mobj_host"
local T_IRegistry = require "test.t_i_registry"
local T_Turtle

function t_employment.T_All()
--    t_employment.T_GetFuelLevels_Att()

    -- specific
    t_employment.T_GetAnyTurtleLocator()
    t_employment.T_getObject()

    -- MObjHost
    t_employment.T_hostMObj_SSrv_Turtle()
    t_employment.T_releaseMObj_SSrv_Turtle()

    -- workerLocator
    t_employment.T_IRegistry_All()
end

function t_employment.T_AllPhysical()
    -- IObj

    -- MObjHost
    local mobjLocator = t_employment.T_buildAndHostMObj_ASrv_Turtle()
    t_employment.T_dismantleAndReleaseMObj_ASrv_Turtle(mobjLocator)
end

local logOk = false
local testClassName = "enterprise_employment"
local testMObjClassName = "Turtle"
local testMObjName = "turtle"
local level0 = 0
local workerId1 = 111111
local location1  = Location:newInstance(-6, 6, 1, 0, 1)
local fuelPriorityKey = ""

local constructParameters = {
    workerId        = workerId1,
    location        = location1,
}

-- print("GetFuelLevels_Att="..textutils.serialize(enterprise_employment.GetFuelLevels_Att()))
function t_employment.T_GetFuelLevels_Att()
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
    local fuelLevels = enterprise_employment.GetFuelLevels_Att()
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

function t_employment.T_GetAnyTurtleLocator()
    -- prepare test
    corelog.WriteToLog("* enterprise_employment.GetAnyTurtleLocator() tests")

    -- test
    local turtleLocator = enterprise_employment.GetAnyTurtleLocator() assert(turtleLocator, "t_employment.T_GetAnyTurtleLocator: Failed obtaining turtleLocator")
    local expectedLocator = enterprise_employment.GetAnyTurtleLocator()

    assert(turtleLocator:isEqual(expectedLocator), "gotten locator(="..textutils.serialise(turtleLocator, compact)..") not the same as expected(="..textutils.serialise(expectedLocator, compact)..")")

    -- cleanup test
end

-- ToDo: consider replacing with direct calls to enterprise_employment:getCurrentTurtleLocator()
function t_employment.GetCurrentTurtleLocator()
    --[[
        This method provides the locator of the current turtle (in enterprise_employment).

        Return value:
            turtleLocator       - (URL) locating the current turtle

        Parameters:
    --]]

    -- check turtle
    assert(turtle, "Current computer(ID="..os.getComputerID()..") not a Turtle")

    -- construct URL
    local currentTurtleLocator = enterprise_employment:getCurrentWorkerLocator()

    -- end
    return currentTurtleLocator
end

function t_employment.T_getObject()
    -- prepare test
    corelog.WriteToLog("* enterprise_employment:getObject() tests")
    local testObject = TestObj:newInstance("field1", 4)
    local objectLocator = enterprise_employment:saveObject(testObject)
    local currentTurtleLocator = t_employment.GetCurrentTurtleLocator()
    local currentTurtle = enterprise_employment:getObject(currentTurtleLocator)

    -- test normal object works (similair to T_Host.T_getObject())
    local object = enterprise_employment:getObject(objectLocator) assert(object, "t_employment.T_getObject: Failed obtaining object")
    assert(object:isEqual(testObject), "object(="..textutils.serialise(object, compact)..") not the same as expected(="..textutils.serialise(testObject, compact)..")")

    -- test "any turtle" provides current turtle
    local getAnyTurtleLocator = enterprise_employment.GetAnyTurtleLocator()
    object = enterprise_employment:getObject(getAnyTurtleLocator) assert(object, "t_employment.T_getObject: Failed obtaining object")
    assert(object:isEqual(currentTurtle), "object(="..textutils.serialise(object, compact)..") not the same as expected(="..textutils.serialise(currentTurtle, compact)..")")

    -- cleanup test
    enterprise_employment:deleteResource(objectLocator)
    assert(not enterprise_employment:getResource(objectLocator), "resource not deleted")
end

--    __  __  ____  _     _ _    _           _
--   |  \/  |/ __ \| |   (_) |  | |         | |
--   | \  / | |  | | |__  _| |__| | ___  ___| |_
--   | |\/| | |  | | '_ \| |  __  |/ _ \/ __| __|
--   | |  | | |__| | |_) | | |  | | (_) \__ \ |_
--   |_|  |_|\____/|_.__/| |_|  |_|\___/|___/\__|
--                      _/ |
--                     |__/

function t_employment.T_hostMObj_SSrv_Turtle()
    -- prepare test
    T_Turtle = T_Turtle or require "test.t_mobj_turtle"
    local fieldsTest0 = T_Turtle.CreateInitialisedTest(workerId1, location1, fuelPriorityKey)

    -- test
    local serviceResults = T_MObjHost.pt_hostMObj_SSrv(enterprise_employment, testMObjClassName, constructParameters, testMObjName, fieldsTest0, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

local mobjLocator_Turtle = nil

function t_employment.T_buildAndHostMObj_ASrv_Turtle()
    -- prepare test

    -- test
    local serviceResults = T_MObjHost.pt_buildAndHostMObj_ASrv(enterprise_employment, testMObjClassName, constructParameters, testMObjName, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    mobjLocator_Turtle = serviceResults.mobjLocator

    -- return mobjLocator
    return serviceResults.mobjLocator
end

function t_employment.T_releaseMObj_SSrv_Turtle()
    -- prepare test

    -- test
    local serviceResults = T_MObjHost.pt_releaseMObj_SSrv(enterprise_employment, testMObjClassName, constructParameters, testMObjName, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

function t_employment.T_dismantleAndReleaseMObj_ASrv_Turtle(mobjLocator)
    -- prepare test
    if not mobjLocator then
        -- see if we locally remembered a mobjLocator
        assert(mobjLocator_Turtle, "no mobjLocator to operate on")
        mobjLocator = mobjLocator_Turtle
    end

    -- test
    local serviceResults = T_MObjHost.pt_dismantleAndReleaseMObj_ASrv(enterprise_employment, mobjLocator, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    mobjLocator_Turtle = nil
end

--                       _             _                     _
--                      | |           | |                   | |
--   __      _____  _ __| | _____ _ __| |     ___   ___ __ _| |_ ___  _ __
--   \ \ /\ / / _ \| '__| |/ / _ \ '__| |    / _ \ / __/ _` | __/ _ \| '__|
--    \ V  V / (_) | |  |   <  __/ |  | |___| (_) | (_| (_| | || (_) | |
--     \_/\_/ \___/|_|  |_|\_\___|_|  |______\___/ \___\__,_|\__\___/|_|

function t_employment.T_IRegistry_All()
    -- prepare test
    local thingName = "Worker"
    local workerLocator1 = enterprise_employment:getResourceLocator(enterprise_employment.GetObjectPath("AWorkerClass", "worker1")) assert(workerLocator1, "Failed obtaining workerLocator1")
    local workerId2 = 222222
    local workerLocator2 = enterprise_employment:getResourceLocator(enterprise_employment.GetObjectPath("AWorkerClass", "worker2")) assert(workerLocator2, "Failed obtaining workerLocator2")

    -- test
    T_IRegistry.pt_all(testClassName, enterprise_employment, workerId1, workerLocator1, workerId2, workerLocator2, thingName)
end

function t_employment.T_buildHostRegisterAndBootWorker_ASrv_Turtle()
    -- prepare test
    corelog.WriteToLog("* enterprise_employment:buildHostRegisterAndBootWorker_ASrv() tests (of Turtle)")
    t_employment = t_employment or require "test.t_employment"

    -- test
    local serviceResults = MethodExecutor.DoASyncObjService_Sync(enterprise_employment, "buildHostRegisterAndBootWorker_ASrv", {
        className                   = testMObjClassName,
        constructParameters         = constructParameters,
        materialsItemSupplierLocator= t_employment.GetCurrentTurtleLocator(),
        wasteItemDepotLocator       = t_employment.GetCurrentTurtleLocator(),
    })

    -- check: service success
    assert(serviceResults, "no serviceResults returned")
    assert(serviceResults.success, "failed executing service")

    -- check: Worker hosted on MObjHost (full check done in pt_buildAndHostMObj_ASrv)
    local mobjLocator = serviceResults.mobjLocator assert(mobjLocator, "no mobjLocator returned")
    local mobj = enterprise_employment:getObject(mobjLocator)
    assert(mobj, "Worker(="..mobjLocator:getURI()..") not hosted by "..enterprise_employment:getHostName())

    -- cleanup test
    if logOk then corelog.WriteToLog(" ok") end
    mobjLocator_Turtle = serviceResults.mobjLocator

    -- return mobjLocator
    return serviceResults.mobjLocator
end


return t_employment
