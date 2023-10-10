local T_MObjHost = {}

local corelog = require "corelog"

local Class = require "class"
local IObj = require "i_obj"
local ModuleRegistry = require "module_registry"
local moduleRegistry = ModuleRegistry:getInstance()
local MethodExecutor = require "method_executor"
local ObjBase = require "obj_base"

local URL = require "obj_url"
local Location = require "obj_location"
local Host = require "obj_host"

local MObjHost = require "mobj_host"

local TestArrayTest = require "test_array_test"
local FieldValueEqualTest = require "field_value_equal_test"

local T_Class = require "test.t_class"
local T_IObj = require "test.t_i_obj"

local T_TestMObj = require "test.t_mobj_test"

local t_turtle

function T_MObjHost.T_All()
    -- initialisation
    T_MObjHost.T_new()

    -- IObj
    T_MObjHost.T_IObj_All()

    -- MObjHost
    T_MObjHost.T_hostMObj_SSrv_TestMObj()
    T_MObjHost.T_upgradeMObj_SSrv_TestMObj()
    T_MObjHost.T_releaseMObj_SSrv_TestMObj()
end

function T_MObjHost.T_AllPhysical()
    -- IObj

    -- MObjHost
    local mobjLocator = T_MObjHost.T_hostAndBuildMObj_ASrv_TestMObj()
    T_MObjHost.T_extendAndUpgradeMObj_ASrv_TestMObj(mobjLocator)
    T_MObjHost.T_dismantleAndReleaseMObj_ASrv_TestMObj(mobjLocator)
end

local testClassName = "MObjHost"
local testObjName = "host"
local logOk = false

local test_mobjHostName1 = "TestMObjHost"
local test_mobjHost1 = MObjHost:newInstance(test_mobjHostName1)

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
    local testObj = MObjHost:newInstance(hostName)

    -- end
    return testObj
end

function T_MObjHost.CreateInitialisedTest(hostName)
    -- check input

    -- create test
    local test = TestArrayTest:newInstance(
        FieldValueEqualTest:newInstance("_hostName", hostName)
    )

    -- end
    return test
end

function T_MObjHost.T_new()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() tests")

    -- test full
    local obj = MObjHost:new({
        _hostName   = test_mobjHostName1,
    })
    local test = T_MObjHost.CreateInitialisedTest(test_mobjHostName1)
    test:test(obj, testObjName, "", logOk)

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
    T_Class.pt_IsInstanceOf(testClassName, obj, "Host", Host) -- ToDo: consider moving to different section
    T_IObj.pt_all(testClassName, obj, otherObj)
end

--    __  __  ____  _     _ _    _           _                    _   _               _
--   |  \/  |/ __ \| |   (_) |  | |         | |                  | | | |             | |
--   | \  / | |  | | |__  _| |__| | ___  ___| |_   _ __ ___   ___| |_| |__   ___   __| |___
--   | |\/| | |  | | '_ \| |  __  |/ _ \/ __| __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   | |  | | |__| | |_) | | |  | | (_) \__ \ |_  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_|  |_|\____/|_.__/| |_|  |_|\___/|___/\__| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                      _/ |
--                     |__/

-- parameterised service tests
function T_MObjHost.pt_hostMObj_SSrv(mobjHost, className, constructParameters, objName, fieldsTest, logOk)
    -- prepare test
    assert(type(mobjHost) =="table", "no mobjHost provided")
    assert(type(className) == "string", "no className provided")
    assert(type(constructParameters) == "table", "no constructParameters provided")
    assert(type(objName) == "string", "no objName provided")
    assert(type(fieldsTest) == "table", "no fieldsTest provided")
    assert(type(logOk) == "boolean", "no logOk provided")
    corelog.WriteToLog("* "..mobjHost:getHostName()..":hostMObj_SSrv() tests (of "..objName..")")

    -- test
    local serviceResults = mobjHost:hostMObj_SSrv({
        className           = className,
        constructParameters = constructParameters,
    })

    -- check: hosting success
    assert(serviceResults and serviceResults.success, "failed hosting "..className)

    -- check: mobjLocator returned
    local mobjLocator = serviceResults.mobjLocator
    assert(Class.IsInstanceOf(mobjLocator, URL), "incorrect mobjLocator returned")

    -- check: mobj saved
    local mobj = mobjHost:getObject(mobjLocator)
    assert(mobj, className.." not in host")

    -- check: mobj constructed (i.e. fields initialised as expected)
    fieldsTest:test(mobj, objName, "", logOk)

    -- check: child MObj's hosted
    -- ToDo: consider implementing testing this. Or shouldn't we as it's a choice to have/ responsibilty of the MObj to do this?

    -- cleanup test
    mobj:destruct()
    mobjHost:deleteResource(mobjLocator)
    if logOk then corelog.WriteToLog(" ok") end

    -- return results
    return serviceResults
end

function T_MObjHost.pt_hostAndBuildMObj_ASrv(mobjHost, className, constructParameters, objName, logOk)
    -- prepare test
    assert(type(mobjHost) =="table", "no mobjHost provided")
    assert(type(className) == "string", "no className provided")
    assert(type(constructParameters) == "table", "no constructParameters provided")
    assert(type(objName) == "string", "no objName provided")
    assert(type(logOk) == "boolean", "no logOk provided")
    corelog.WriteToLog("* "..mobjHost:getHostName()..":hostAndBuildMObj_ASrv() tests (of "..objName..")")
    t_turtle = t_turtle or require "test.t_turtle"

    -- test
    local serviceResults = MethodExecutor.DoASyncObjService_Sync(mobjHost, "hostAndBuildMObj_ASrv", {
        className                   = className,
        constructParameters         = constructParameters,
        materialsItemSupplierLocator= t_turtle.GetCurrentTurtleLocator(),
        wasteItemDepotLocator       = t_turtle.GetCurrentTurtleLocator(),
    })

    -- check: service success
    assert(serviceResults, "no serviceResults returned")
    assert(serviceResults.success, "failed executing service")

    -- check: mobj hosted on MObjHost (full check done in pt_hostMObj_SSrv)
    local mobjLocator = serviceResults.mobjLocator assert(mobjLocator, "no mobjLocator returned")
    local mobj = mobjHost:getObject(mobjLocator)
    assert(mobj, "MObj(="..mobjLocator:getURI()..") not hosted by "..mobjHost:getHostName())

    -- check: build blueprint build
    -- ToDo: add mock test

    -- cleanup test
    if logOk then corelog.WriteToLog(" ok") end

    -- return results
    return serviceResults
end

function T_MObjHost.pt_upgradeMObj_SSrv(mobjHost, className, constructParameters, upgradeParameters, objName, fieldsTest, logOk)
    -- prepare test
    assert(type(mobjHost) =="table", "no mobjHost provided")
    assert(type(className) == "string", "no className provided")
    assert(type(constructParameters) == "table", "no constructParameters provided")
    assert(type(upgradeParameters) == "table", "no upgradeParameters provided")
    assert(type(logOk) == "boolean", "no logOk provided")
    assert(type(objName) == "string", "no objName provided")
    assert(type(fieldsTest) == "table", "no fieldsTest provided")
    corelog.WriteToLog("* "..mobjHost:getHostName()..":upgradeMObj_SSrv() tests (of "..objName..")")

    local serviceResults = mobjHost:hostMObj_SSrv({
        className           = className,
        constructParameters = constructParameters,
    }) assert(serviceResults, "failed hosting "..className)
    local mobjLocator = serviceResults.mobjLocator

    -- test
    serviceResults = mobjHost:upgradeMObj_SSrv({
        mobjLocator         = mobjLocator,
        upgradeParameters   = upgradeParameters,
    })

    -- check: service success
    assert(serviceResults and serviceResults.success, "failed upgrading "..mobjLocator:getURI())

    -- check: mobj saved
    local mobj = mobjHost:getObject(mobjLocator)
    assert(mobj, mobjLocator:getURI().." not in host")

    -- check: mobj upgraded (i.e. fields values as expected)
    fieldsTest:test(mobj, objName, "", logOk)

    -- cleanup test
    mobj:destruct()
    mobjHost:deleteResource(mobjLocator)
    if logOk then corelog.WriteToLog(" ok") end

    -- return results
    return serviceResults
end

function T_MObjHost.pt_extendAndUpgradeMObj_ASrv(mobjHost, mobjLocator, upgradeParameters, objName, fieldsTest, logOk)
    -- prepare test
    assert(type(mobjHost) =="table", "no mobjHost provided")
    assert(type(mobjLocator) == "table", "no mobjLocator provided")
    assert(type(upgradeParameters) == "table", "no upgradeParameters provided")
    assert(type(objName) == "string", "no objName provided")
    assert(type(fieldsTest) == "table", "no fieldsTest provided")
    assert(type(logOk) == "boolean", "no logOk provided")
    corelog.WriteToLog("* "..mobjHost:getHostName()..":extendAndUpgradeMObj_ASrv() tests (of "..objName..")")
    t_turtle = t_turtle or require "test.t_turtle"

    -- test
    local serviceResults = MethodExecutor.DoASyncObjService_Sync(mobjHost, "extendAndUpgradeMObj_ASrv", {
        mobjLocator                 = mobjLocator,
        upgradeParameters           = upgradeParameters,
        materialsItemSupplierLocator= t_turtle.GetCurrentTurtleLocator(),
        wasteItemDepotLocator       = t_turtle.GetCurrentTurtleLocator(),
    })

    -- check: service success
    assert(serviceResults, "no serviceResults returned")
    assert(serviceResults.success, "failed executing service")

    -- check: extend blueprint build
    -- ToDo: add mock test

    -- check: mobj upgraded (i.e. fields values as expected)
    local mobj = mobjHost:getObject(mobjLocator) assert(mobj, "MObj(="..mobjLocator:getURI()..") not hosted by "..mobjHost:getHostName())
    fieldsTest:test(mobj, objName, "", logOk)

    -- cleanup test
    if logOk then corelog.WriteToLog(" ok") end

    -- return results
    return serviceResults
end

function T_MObjHost.pt_releaseMObj_SSrv(mobjHost, className, constructParameters, objName, logOk)
    -- prepare test
    assert(type(mobjHost) =="table", "no mobjHost provided")
    assert(type(className) == "string", "no className provided")
    assert(type(constructParameters) == "table", "no constructParameters provided")
    assert(type(objName) == "string", "no objName provided")
    assert(type(logOk) == "boolean", "no logOk provided")
    corelog.WriteToLog("* "..mobjHost:getHostName()..":releaseMObj_SSrv() tests (of "..objName..")")

    local serviceResults = mobjHost:hostMObj_SSrv({
        className           = className,
        constructParameters = constructParameters,
    }) assert(serviceResults, "failed hosting "..className)
    local mobjLocator = serviceResults.mobjLocator

    -- test
    serviceResults = mobjHost:releaseMObj_SSrv({
        mobjLocator         = mobjLocator,
    })

    -- check: releasing success
    assert(serviceResults and serviceResults.success, "failed releasing "..mobjLocator:getURI())

    -- check: mobj deleted
    local mobjResourceTable = mobjHost:getResource(mobjLocator)
    assert(not mobjResourceTable, mobjLocator:getURI().." not deleted")

    -- check child MObj's released
    -- ToDo: consider implementing testing this. Or shouldn't we as it's a responsibilty of the MObj to do this?

    -- cleanup test
    if logOk then corelog.WriteToLog(" ok") end

    -- return results
    return serviceResults
end

function T_MObjHost.pt_dismantleAndReleaseMObj_ASrv(mobjHost, mobjLocator, logOk)
    -- prepare test
    assert(type(mobjHost) =="table", "no mobjHost provided")
    assert(type(mobjLocator) == "table", "no mobjLocator provided")
    assert(type(logOk) == "boolean", "no logOk provided")
    corelog.WriteToLog("* "..mobjHost:getHostName()..":dismantleAndReleaseMObj_ASrv() tests (of "..mobjLocator:getURI()..")")
    t_turtle = t_turtle or require "test.t_turtle"

    -- test
    local serviceResults = MethodExecutor.DoASyncObjService_Sync(mobjHost, "dismantleAndReleaseMObj_ASrv", {
        mobjLocator                 = mobjLocator,
        materialsItemSupplierLocator= t_turtle.GetCurrentTurtleLocator(),
        wasteItemDepotLocator       = t_turtle.GetCurrentTurtleLocator(),
    })

    -- check: service success
    assert(serviceResults, "no serviceResults returned")
    assert(serviceResults.success, "failed executing service")

    -- check: mobj released
    local mobjResourceTable = mobjHost:getResource(mobjLocator)
    assert(not mobjResourceTable, "MObj(="..mobjLocator:getURI()..") not released from MObjHost "..mobjHost:getHostName())

    -- check: dismantle blueprint "build"
    -- ToDo: add mock test

    -- cleanup test
    if logOk then corelog.WriteToLog(" ok") end

    -- return results
    return serviceResults
end

-- test MObjHost with TestMObj
local testMObjClassName = "TestMObj"
local testMObjName = "testMObj"
local baseLocation1 = Location:newInstance(-12, 0, 1, 0, 1)
local field1_1 = "field1 1"
local field1_2 = "field1 2"
local constructParameters1 = {
    baseLocation    = baseLocation1,
    field1Value     = field1_1,
}
local upgradeParameters2 = {
    field1 = field1_2
}

function T_MObjHost.T_hostMObj_SSrv_TestMObj()
    -- prepare test
    local constructFieldsTest = T_TestMObj.CreateInitialisedTest(nil, baseLocation1, field1_1)

    -- test
    local serviceResults = T_MObjHost.pt_hostMObj_SSrv(test_mobjHost1, testMObjClassName, constructParameters1, testMObjName, constructFieldsTest, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

local mobjLocator_TestMObj = nil

function T_MObjHost.T_hostAndBuildMObj_ASrv_TestMObj()
    -- prepare test
    moduleRegistry:registerModule(test_mobjHostName1, test_mobjHost1)

    -- test
    local serviceResults = T_MObjHost.pt_hostAndBuildMObj_ASrv(test_mobjHost1, testMObjClassName, constructParameters1, testMObjName, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    moduleRegistry:delistModule(test_mobjHostName1)
    mobjLocator_TestMObj = serviceResults.mobjLocator

    -- return mobjLocator
    return serviceResults.mobjLocator
end

function T_MObjHost.T_upgradeMObj_SSrv_TestMObj()
    -- prepare test
    moduleRegistry:registerModule(test_mobjHostName1, test_mobjHost1)
    local upgradeFieldsTest = T_TestMObj.CreateInitialisedTest(nil, baseLocation1, field1_2)

    -- test
    local serviceResults = T_MObjHost.pt_upgradeMObj_SSrv(test_mobjHost1, testMObjClassName, constructParameters1, upgradeParameters2, testMObjName, upgradeFieldsTest, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    moduleRegistry:delistModule(test_mobjHostName1)
end

function T_MObjHost.T_extendAndUpgradeMObj_ASrv_TestMObj(mobjLocator)
    -- prepare test
    moduleRegistry:registerModule(test_mobjHostName1, test_mobjHost1)
    local upgradeFieldsTest = T_TestMObj.CreateInitialisedTest(nil, baseLocation1, field1_2)

    if not mobjLocator then
        -- check if we locally remembered a mobjLocator
        assert(mobjLocator_TestMObj, "no mobjLocator to operate on")
        mobjLocator = mobjLocator_TestMObj
    end

    -- test
    local serviceResults = T_MObjHost.pt_extendAndUpgradeMObj_ASrv(test_mobjHost1, mobjLocator, upgradeParameters2, testMObjName, upgradeFieldsTest, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    moduleRegistry:delistModule(test_mobjHostName1)
end

function T_MObjHost.T_releaseMObj_SSrv_TestMObj()
    -- prepare test
    moduleRegistry:registerModule(test_mobjHostName1, test_mobjHost1)

    -- test
    local serviceResults = T_MObjHost.pt_releaseMObj_SSrv(test_mobjHost1, testMObjClassName, constructParameters1, testMObjName, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    moduleRegistry:delistModule(test_mobjHostName1)
end

function T_MObjHost.T_dismantleAndReleaseMObj_ASrv_TestMObj(mobjLocator)
    -- prepare test
    moduleRegistry:registerModule(test_mobjHostName1, test_mobjHost1)

    if not mobjLocator then
        -- check if we locally remembered a mobjLocator
        assert(mobjLocator_TestMObj, "no mobjLocator to operate on")
        mobjLocator = mobjLocator_TestMObj
    end

    -- test
    local serviceResults = T_MObjHost.pt_dismantleAndReleaseMObj_ASrv(test_mobjHost1, mobjLocator, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    mobjLocator_TestMObj = nil
    moduleRegistry:delistModule(test_mobjHostName1)
end

return T_MObjHost
