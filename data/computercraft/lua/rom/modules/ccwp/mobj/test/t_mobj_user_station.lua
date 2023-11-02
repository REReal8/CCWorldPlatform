local T_UserStation = {}

local corelog = require "corelog"

local IObj = require "i_obj"
local MethodExecutor = require "method_executor"
local ObjBase = require "obj_base"
local IItemDepot = require "i_item_depot"

local Location = require "obj_location"
local URL = require "obj_url"

local UserStation = require "mobj_user_station"

local enterprise_employment = require "enterprise_employment"

local TestArrayTest = require "test_array_test"
local FieldTest = require "field_test"
local FieldValueEqualTest = require "field_value_equal_test"
local ValueTypeTest = require "value_type_test"
local FieldValueTypeTest = require "field_value_type_test"
local MethodResultEqualTest = require "method_result_equal_test"
local IsBlueprintTest = require "test.is_blueprint_test"

local T_Class = require "test.t_class"
local T_IInterface = require "test.t_i_interface"
local T_IObj = require "test.t_i_obj"
local T_ILObj = require "test.t_i_lobj"
local T_IMObj = require "test.t_i_mobj"
local T_IWorker = require "test.t_i_worker"

function T_UserStation.T_All()
    -- initialisation
    T_UserStation.T__init()
    T_UserStation.T_new()
    T_UserStation.T_Getters()

    -- IObj
    T_UserStation.T_IObj_All()

    -- ILObj
    T_UserStation.T_ILObj_All()

    -- IMObj
    T_UserStation.T_IMObj_All()

    -- IWorker
    T_UserStation.T_IWorker_All()

    -- IItemDepot
    T_UserStation.T_IItemDepot_All()
end

function T_UserStation.T_AllPhysical()
    -- IItemDepot
    T_UserStation.T_storeItemsFrom_AOSrv_Turtle()
end

local testClassName = "UserStation"
local testObjName = "utilStation"
local testObjName0 = testObjName.."0"

local logOk = false

local workerId1 = 111111
local baseLocation0 = Location:newInstance(-6, -12, 1, 0, 1)

local inputLocator0 = enterprise_employment.GetAnyTurtleLocator() assert(inputLocator0, "Failed obtaining inputLocator0")
local outputLocator0 = enterprise_employment.GetAnyTurtleLocator() assert(outputLocator0, "Failed obtaining outputLocator0")

local constructParameters0 = {
    workerId        = workerId1,
    baseLocation    = baseLocation0,
}

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_UserStation.CreateTestObj(workerId, baseLocation, inputLocator, outputLocator)
    -- check input
    workerId = workerId or workerId1
    baseLocation = baseLocation or baseLocation0
    inputLocator = inputLocator or inputLocator0
    outputLocator = outputLocator or outputLocator0

    -- create testObj
    local testObj = UserStation:newInstance(workerId, baseLocation:copy(), inputLocator, outputLocator)

    -- end
    return testObj
end

function T_UserStation.CreateInitialisedTest(workerId, baseLocation, inputLocatorTest, outputLocatorTest)
    -- check input

    -- create test
    local test = TestArrayTest:newInstance(
        FieldValueEqualTest:newInstance("_workerId", workerId),
        FieldValueEqualTest:newInstance("_baseLocation", baseLocation),
        inputLocatorTest,
        outputLocatorTest
    )

    -- end
    return test
end

function T_UserStation.T__init()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":_init() tests")

    -- test
    local obj = T_UserStation.CreateTestObj(workerId1, baseLocation0, inputLocator0, outputLocator0) assert(obj, "Failed obtaining "..testClassName)
    local inputLocatorTest = FieldValueEqualTest:newInstance("_inputLocator", inputLocator0)
    local outputLocatorTest = FieldValueEqualTest:newInstance("_outputLocator", outputLocator0)
    local test = T_UserStation.CreateInitialisedTest(workerId1, baseLocation0, inputLocatorTest, outputLocatorTest)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_UserStation.T_new()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() tests")

    -- test
    local obj = UserStation:new({
        _workerId       = workerId1,
        _baseLocation   = baseLocation0:copy(),
        _inputLocator   = inputLocator0:copy(),
        _outputLocator  = outputLocator0:copy(),
    })
    local inputLocatorTest = FieldValueEqualTest:newInstance("_inputLocator", inputLocator0)
    local outputLocatorTest = FieldValueEqualTest:newInstance("_outputLocator", outputLocator0)
    local test = T_UserStation.CreateInitialisedTest(workerId1, baseLocation0, inputLocatorTest, outputLocatorTest)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_UserStation.T_Getters()
    -- prepare test
    corelog.WriteToLog("* "..testClassName.." base getter tests")
    local obj = T_UserStation.CreateTestObj(workerId1, baseLocation0) assert(obj, "Failed obtaining "..testClassName)

    -- test
    local test = TestArrayTest:newInstance(
        MethodResultEqualTest:newInstance("getBaseLocation", baseLocation0)
    )
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function T_UserStation.T_IObj_All()
    -- prepare test
    local obj = T_UserStation.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_UserStation.CreateTestObj() assert(otherObj, "Failed obtaining "..testClassName)

    -- testing type
    T_Class.pt_IsInstanceOf(testClassName, obj, "IObj", IObj)
    T_Class.pt_IsInstanceOf(testClassName, obj, "ObjBase", ObjBase)

    -- test
    T_IObj.pt_all(testClassName, obj, otherObj)
end

--    _____ _      ____  _     _
--   |_   _| |    / __ \| |   (_)
--     | | | |   | |  | | |__  _
--     | | | |   | |  | | '_ \| |
--    _| |_| |___| |__| | |_) | |
--   |_____|______\____/|_.__/| |
--                           _/ |
--                          |__/

function T_UserStation.T_ILObj_All()
    -- prepare tests
    local obj0 = T_UserStation.CreateTestObj(workerId1, baseLocation0) assert(obj0, "Failed obtaining "..testClassName)

    local destructFieldsTest = TestArrayTest:newInstance(
    )
    local inputLocatorTest = FieldTest:newInstance("_inputLocator", TestArrayTest:newInstance(
        ValueTypeTest:newInstance("URL")
    ))
    local outputLocatorTest = FieldTest:newInstance("_outputLocator", TestArrayTest:newInstance(
        ValueTypeTest:newInstance("URL")
    ))
    local fieldsTest0 = T_UserStation.CreateInitialisedTest(workerId1, baseLocation0, inputLocatorTest, outputLocatorTest)

    -- testing type
    T_ILObj.pt_IsInstanceOf_ILObj(testClassName, obj0)
    T_ILObj.pt_Implements_ILObj(testClassName, obj0)

    -- test construct/ upgrade/ destruct
    T_ILObj.pt_destruct(testClassName, UserStation, constructParameters0, testObjName0, destructFieldsTest, logOk)
    T_ILObj.pt_construct(testClassName, UserStation, constructParameters0, testObjName0, fieldsTest0, logOk)

    -- test getters
    local expectedId = tostring(workerId1)
    T_ILObj.pt_getId(testClassName, obj0, testObjName0, logOk, expectedId)
    T_ILObj.pt_getWIPId(testClassName, obj0, testObjName0, logOk)

    -- cleanup test
end

--    _____ __  __  ____  _     _
--   |_   _|  \/  |/ __ \| |   (_)
--     | | | \  / | |  | | |__  _
--     | | | |\/| | |  | | '_ \| |
--    _| |_| |  | | |__| | |_) | |
--   |_____|_|  |_|\____/|_.__/| |
--                            _/ |
--                           |__/

function T_UserStation.T_IMObj_All()
    -- prepare tests
    local obj0 = T_UserStation.CreateTestObj(workerId1, baseLocation0) assert(obj0, "Failed obtaining "..testClassName)

    local isBlueprintTest = IsBlueprintTest:newInstance(baseLocation0)

    -- testing type
    T_IMObj.pt_IsInstanceOf_IMObj(testClassName, obj0)
    T_IMObj.pt_Implements_IMObj(testClassName, obj0)

    -- test blueprints
    T_IMObj.pt_GetBuildBlueprint(testClassName, obj0, testObjName0, constructParameters0, isBlueprintTest, logOk)
    T_IMObj.pt_getDismantleBlueprint(testClassName, obj0, testObjName0, isBlueprintTest, logOk)

    -- cleanup test
end

--    _______          __        _
--   |_   _\ \        / /       | |
--     | |  \ \  /\  / /__  _ __| | _____ _ __
--     | |   \ \/  \/ / _ \| '__| |/ / _ \ '__|
--    _| |_   \  /\  / (_) | |  |   <  __/ |
--   |_____|   \/  \/ \___/|_|  |_|\_\___|_|

function T_UserStation.T_IWorker_All()
    -- prepare test
    local obj = T_UserStation.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)
    local workerResumeTest = TestArrayTest:newInstance(
        FieldValueTypeTest:newInstance("workerId", "number"),
        FieldValueTypeTest:newInstance("location", "Location")
    )
    local isMainUIMenuTest = TestArrayTest:newInstance(
        FieldValueTypeTest:newInstance("clear", "boolean"),
        FieldValueTypeTest:newInstance("intro", "string"),
        FieldValueTypeTest:newInstance("param", "table"),
        FieldValueTypeTest:newInstance("question", "nil")
    )
    local assignmentFilterTest = TestArrayTest:newInstance(
    )

    -- test
    local expectedWorkerLocation = obj:getBaseLocation():getRelativeLocation(3, 3, 0)
    T_IWorker.pt_all(testClassName, obj, testObjName, expectedWorkerLocation, workerResumeTest, isMainUIMenuTest, assignmentFilterTest, logOk)
end

--    _____ _____ _                 _____                   _
--   |_   _|_   _| |               |  __ \                 | |
--     | |   | | | |_ ___ _ __ ___ | |  | | ___ _ __   ___ | |_
--     | |   | | | __/ _ \ '_ ` _ \| |  | |/ _ \ '_ \ / _ \| __|
--    _| |_ _| |_| ||  __/ | | | | | |__| |  __/ |_) | (_) | |_
--   |_____|_____|\__\___|_| |_| |_|_____/ \___| .__/ \___/ \__|
--                                             | |
--                                             |_|

function T_UserStation.T_IItemDepot_All()
    -- prepare test
    local obj = T_UserStation.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

    -- test type
    T_Class.pt_IsInstanceOf(testClassName, obj, "IItemDepot", IItemDepot)
    T_IInterface.pt_ImplementsInterface("IItemDepot", IItemDepot, testClassName, obj)
end

local function storeItemsFrom_AOSrv_Test(itemsLocator, provideItems, fromStr)
    -- prepare test (cont)
    assert(itemsLocator, "no className provided")
    assert(provideItems, "no provideItems provided")
    assert(fromStr, "no fromStr provided")
    corelog.WriteToLog("* "..testClassName..":storeItemsFrom_AOSrv() test (from "..fromStr..")")
    local obj = UserStation:construct(constructParameters0) assert(obj, "Failed obtaining "..testClassName)
    local itemDepotLocator = obj:getOutputLocator() assert(itemDepotLocator, "Failed obtaining outputLocator")

    itemsLocator:setQuery(provideItems)

    local expectedDestinationItemsLocator = itemDepotLocator:copy()
    expectedDestinationItemsLocator:setQuery(provideItems)

    -- test
    local serviceResults = MethodExecutor.DoASyncObjService_Sync(obj, "storeItemsFrom_AOSrv", {
        itemsLocator    = itemsLocator,
    })

    -- check: service success
    assert(serviceResults, "no serviceResults returned")
    assert(serviceResults.success, "failed executing service")

    -- check: destinationItemsLocator
    local destinationItemsLocator = URL:new(serviceResults.destinationItemsLocator)
    assert(destinationItemsLocator:isEqual(expectedDestinationItemsLocator), "gotten destinationItemsLocator(="..textutils.serialize(destinationItemsLocator, compact)..") not the same as expected(="..textutils.serialize(expectedDestinationItemsLocator, compact)..")")

    -- cleanup test
    obj:destruct()
end

function T_UserStation.T_storeItemsFrom_AOSrv_Turtle()
    -- prepare test
    local itemsLocator = enterprise_employment.GetAnyTurtleLocator() assert(itemsLocator, "Failed obtaining Turtle locator")

    local provideItems = {
        ["minecraft:birch_log"]  = 3,
    }

    -- test
    storeItemsFrom_AOSrv_Test(itemsLocator, provideItems, "Turtle")
end

function T_UserStation.T_shop_storeItemsFrom_AOSrv_Shop()
    -- prepare test
    local enterprise_shop = require "enterprise_shop"
    local itemsLocator = enterprise_shop.GetShopLocator() assert(itemsLocator, "Failed obtaining Shop locator")
    local provideItems = {
        ["minecraft:birch_log"]  = 3,
        ["minecraft:birch_planks"]  = 20,
        ["minecraft:coal_block"]  = 2,
    }

    -- test
    storeItemsFrom_AOSrv_Test(itemsLocator, provideItems, "Shop")
end

return T_UserStation
