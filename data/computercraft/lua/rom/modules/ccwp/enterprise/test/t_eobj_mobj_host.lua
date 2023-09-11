local T_MObjHost = {}

local corelog = require "corelog"

local Class = require "class"
local IObj = require "i_obj"
local Callback = require "obj_callback"
local ModuleRegistry = require "module_registry"
local moduleRegistry = ModuleRegistry:getInstance()
local InputChecker = require "input_checker"
local MethodExecutor = require "method_executor"
local ObjBase = require "obj_base"

local URL = require "obj_url"
local Location = require "obj_location"
local Host = require "obj_host"

local MObjHost = require "eobj_mobj_host"

local T_Class = require "test.t_class"
local T_IObj = require "test.t_i_obj"

local t_turtle = require "test.t_turtle"

function T_MObjHost.T_All()
    -- initialisation
    T_MObjHost.T_new()

    -- IObj methods
    T_MObjHost.T_IObj_All()

    -- service methods
    T_MObjHost.T_hostMObj_SSrv_TestMObj()
    T_MObjHost.T_releaseMObj_SSrv_TestMObj()
end

function T_MObjHost.T_AllPhysical()
    -- IObj methods

    -- service methods
    local mobjLocator = T_MObjHost.T_hostAndBuildMObj_ASrv_TestMObj()
    T_MObjHost.T_dismantleAndReleaseMObj_ASrv_TestMObj(mobjLocator)
end

local testClassName = "MObjHost"
local test_mobjHostName1 = "TestMObjHost"
local test_mobjHost1 = MObjHost:new({
    _hostName   = test_mobjHostName1,
})

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_MObjHost.CreateTestObj(hostName)
    -- check input
    hostName = test_mobjHostName1 or hostName

    -- create testObj
    local testObj = MObjHost:new({
        _hostName   = hostName,
    })

    return testObj
end

function T_MObjHost.T_new()
    -- prepare test
    corelog.WriteToLog("* MObjHost:new() tests")

    -- test full
    local host = MObjHost:new({
        _hostName   = test_mobjHostName1,
    })
    assert(host:getHostName() == test_mobjHostName1, "gotten getHostName(="..host:getHostName()..") not the same as expected(="..test_mobjHostName1..")")

    -- cleanup test
end

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

function T_MObjHost.T_IObj_All()
    -- prepare test
    local obj = T_MObjHost.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_MObjHost.CreateTestObj() assert(otherObj, "Failed obtaining "..testClassName)

    -- test
    T_Class.pt_IsInstanceOf(testClassName, obj, "IObj", IObj)
    T_Class.pt_IsInstanceOf(testClassName, obj, "ObjBase", ObjBase)
    T_Class.pt_IsInstanceOf(testClassName, obj, "Host", Host)
    T_IObj.pt_all(testClassName, obj, otherObj)
end

--                        _                           _   _               _
--                       (_)                         | | | |             | |
--    ___  ___ _ ____   ___  ___ ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \  __/ |   \ V /| | (_|  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/\___|_|    \_/ |_|\___\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

-- parameterised service tests
function T_MObjHost.pt_hostAndBuildMObj_ASrv(mobjHost, className, constructParameters, logOk)
    -- prepare test
    assert(type(mobjHost) =="table", "no mobjHost provided")
    assert(type(className) == "string", "no className provided")
    assert(type(constructParameters) == "table", "no constructParameters provided")
    assert(type(logOk) == "boolean", "no logOk provided")
    corelog.WriteToLog("* "..mobjHost:getHostName()..":hostAndBuildMObj_ASrv() tests (with a "..className..")")

    -- test: service success
    local serviceResults = MethodExecutor.DoASyncObjService_Sync(mobjHost, "hostAndBuildMObj_ASrv", {
        className                   = className,
        constructParameters         = constructParameters,
        materialsItemSupplierLocator= t_turtle.GetCurrentTurtleLocator(),
        wasteItemDepotLocator       = t_turtle.GetCurrentTurtleLocator(),
    })
    assert(serviceResults, "no serviceResults returned")
    assert(serviceResults.success, "failed executing service")

    -- test: mobj hosted on MObjHost (full check done in pt_hostMObj_SSrv)
    local mobjLocator = serviceResults.mobjLocator assert(mobjLocator, "no mobjLocator returned")
    local mobj = mobjHost:getObject(mobjLocator)
    assert(mobj, "MObj(="..mobjLocator:getURI()..") not hosted by "..mobjHost:getHostName())

    -- test: build blueprint build
    -- ToDo: add mock test

    -- complete test
    if logOk then corelog.WriteToLog(" ok") end

    -- cleanup test

    -- return results
    return serviceResults
end

function T_MObjHost.pt_dismantleAndReleaseMObj_ASrv(mobjHost, mobjLocator, logOk)
    -- prepare test
    assert(type(mobjHost) =="table", "no mobjHost provided")
    assert(type(mobjLocator) == "table", "no mobjLocator provided")
    assert(type(logOk) == "boolean", "no logOk provided")
    corelog.WriteToLog("* "..mobjHost:getHostName()..":dismantleAndReleaseMObj_ASrv() tests (with "..mobjLocator:getURI()..")")

    -- test: service success
    local serviceResults = MethodExecutor.DoASyncObjService_Sync(mobjHost, "dismantleAndReleaseMObj_ASrv", {
        mobjLocator                 = mobjLocator,
        materialsItemSupplierLocator= t_turtle.GetCurrentTurtleLocator(),
        wasteItemDepotLocator       = t_turtle.GetCurrentTurtleLocator(),
    })
    assert(serviceResults, "no serviceResults returned")
    assert(serviceResults.success, "failed executing service")

    -- test: mobj released
    local mobjResourceTable = mobjHost:getResource(mobjLocator)
    assert(not mobjResourceTable, "MObj(="..mobjLocator:getURI()..") not released from MObjHost "..mobjHost:getHostName())

    -- test: dismantle blueprint "build"
    -- ToDo: add mock test

    -- complete test
    if logOk then corelog.WriteToLog(" ok") end

    -- cleanup test

    -- return results
    return serviceResults
end

-- test MObjHost with TestMObj
local test_mobjClassName1 = "TestMObj"
local location1 = Location:newInstance(-12, 0, 1, 0, 1)
local field1SetValue = "value field1"
local test_mobjConstructParameters1 = {
    baseLocation    = location1,
    field1Value     = field1SetValue,
}

function T_MObjHost.T_hostMObj_SSrv_TestMObj()
    -- prepare test
    corelog.WriteToLog("* MObjHost:hostMObj_SSrv() tests")

    -- test
    local serviceResults = test_mobjHost1:hostMObj_SSrv({
        className           = test_mobjClassName1,
        constructParameters = test_mobjConstructParameters1,
    })

    -- check hosting success
    assert(serviceResults and serviceResults.success, "failed hosting MObj")

    -- check mobjLocator returned
    local mobjLocator = serviceResults.mobjLocator
    assert(Class.IsInstanceOf(mobjLocator, URL), "incorrect mobjLocator returned")

    -- check mobj saved
    local mobj = test_mobjHost1:getObject(mobjLocator)
    assert(mobj, "MObj not in host")

    -- check mobj constructed
    local field1Value = mobj:getField1()
    assert(field1Value == field1SetValue, "construct did not set _field1")

    -- check child MObj's hosted
    -- ToDo: consider implementing testing this. Or shouldn't we as it's a choice to have and responsibilty of the MObj to do this?

    -- cleanup test
    test_mobjHost1:deleteObjects("TestMObj")
end

local mobjLocator_TestMObj = nil

local logOk = false

function T_MObjHost.T_hostAndBuildMObj_ASrv_TestMObj()
    -- prepare test
    moduleRegistry:registerModule(test_mobjHostName1, test_mobjHost1)

    -- test
    local serviceResults = T_MObjHost.pt_hostAndBuildMObj_ASrv(test_mobjHost1, test_mobjClassName1, test_mobjConstructParameters1, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    moduleRegistry:delistModule(test_mobjHostName1)
    mobjLocator_TestMObj = serviceResults.mobjLocator

    -- return mobjLocator
    return serviceResults.mobjLocator
end

function T_MObjHost.T_releaseMObj_SSrv_TestMObj()
    -- prepare test
    corelog.WriteToLog("* MObjHost:releaseMObj_SSrv() tests")
    moduleRegistry:registerModule(test_mobjHostName1, test_mobjHost1)
    local serviceResults = test_mobjHost1:hostMObj_SSrv({
        className           = test_mobjClassName1,
        constructParameters = test_mobjConstructParameters1,
    })
    local mobjLocator = URL:new(serviceResults.mobjLocator)

    -- test
    serviceResults = test_mobjHost1:releaseMObj_SSrv({
        mobjLocator         = mobjLocator,
    })

    -- check releasing success
    assert(serviceResults and serviceResults.success, "failed releasing MObj")

    -- check mobj deleted
    local mobjResourceTable = test_mobjHost1:getResource(mobjLocator)
    assert(not mobjResourceTable, "MObj not deleted")

    -- check child MObj's released
    -- ToDo: consider implementing testing this. Or shouldn't we as it's a responsibilty of the MObj to do this?

    -- cleanup test
    moduleRegistry:delistModule(test_mobjHostName1)
end

function T_MObjHost.T_dismantleAndReleaseMObj_ASrv_TestMObj(mobjLocator)
    -- prepare test
    moduleRegistry:registerModule(test_mobjHostName1, test_mobjHost1)

    if not mobjLocator then
        -- check if we locally remembered a mobjLocator from the T_hostAndBuildMObj_ASrv_TestMObj test
        assert(mobjLocator_TestMObj, "no mobjLocator for the TestMObj to operate on")
        mobjLocator = mobjLocator_TestMObj
    end

    -- test
    local serviceResults = T_MObjHost.pt_dismantleAndReleaseMObj_ASrv(test_mobjHost1, mobjLocator, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    mobjLocator_TestMObj = nil
    -- ToDo: remove test host data
    moduleRegistry:delistModule(test_mobjHostName1)
end

return T_MObjHost
