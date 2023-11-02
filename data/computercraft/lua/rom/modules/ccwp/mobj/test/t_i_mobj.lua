local T_IMObj = {}
local corelog = require "corelog"

local IMObj = require "i_mobj"

local T_IInterface = require "test.t_i_interface"
local T_Class = require "test.t_class"

local MethodResultTest = require "method_result_test"
local MethodResultEqualTest = require "method_result_equal_test"

local compact = { compact = true }

--    _
--   | |
--   | |_ _   _ _ __   ___
--   | __| | | | '_ \ / _ \
--   | |_| |_| | |_) |  __/
--    \__|\__, | .__/ \___|
--         __/ | |
--        |___/|_|

function T_IMObj.pt_IsInstanceOf_IMObj(className, obj)
    -- prepare test
    assert(className, "no className provided")
    assert(obj, "no obj provided")

    -- test
    T_Class.pt_IsInstanceOf(className, obj, "IMObj", IMObj)
end

function T_IMObj.pt_Implements_IMObj(className, obj)
    -- prepare test
    assert(className, "no className provided")
    assert(obj, "no obj provided")

    -- test
    T_IInterface.pt_ImplementsInterface("IMObj", IMObj, className, obj)
end

--    _____ __  __  ____  _     _
--   |_   _|  \/  |/ __ \| |   (_)
--     | | | \  / | |  | | |__  _
--     | | | |\/| | |  | | '_ \| |
--    _| |_| |  | | |__| | |_) | |
--   |_____|_|  |_|\____/|_.__/| |
--                            _/ |
--                           |__/

function T_IMObj.pt_destruct(className, class, constructParameters, objName, destructFieldsTest, logOk)
    -- prepare test
    assert(className, "no className provided")
    assert(class, "no class provided")
    assert(constructParameters, "no constructParameters provided")
    assert(objName, "no objName provided")
    assert(destructFieldsTest, "no destructFieldsTest provided")
    assert(type(logOk) == "boolean", "no logOk provided")
    corelog.WriteToLog("* "..className..":destruct() tests (with "..objName..")")
    local obj = class:construct(constructParameters) assert(obj, "Failed obtaining "..className)

    -- test
    local destructSuccess = obj:destruct()
    assert(destructSuccess, className..":destruct() not a success")
    local test = destructFieldsTest
    test:test(obj, objName, "", logOk)

    -- ToDo: add tests if child MObj's have been released
end

function T_IMObj.pt_construct(className, class, constructParameters, objName, constructFieldsTest, logOk)
    -- prepare test
    assert(className, "no className provided")
    assert(class, "no class provided")
    assert(constructParameters, "no constructParameters provided")
    assert(objName, "no objName provided")
    assert(constructFieldsTest, "no constructFieldsTest provided")
    assert(type(logOk) == "boolean", "no logOk provided")
    corelog.WriteToLog("* "..className..":construct() tests (with "..objName..")")

    -- test
    local obj = class:construct(constructParameters) assert(obj, "Failed obtaining "..className)
    local test = constructFieldsTest
    test:test(obj, objName, "", logOk)

    -- cleanup test
    obj:destruct()
end

function T_IMObj.pt_upgrade(className, class, constructParameters, objName, upgradeParameters, upgradeFieldsTest, logOk)
    -- prepare test
    assert(className, "no className provided")
    assert(class, "no class provided")
    assert(constructParameters, "no constructParameters provided")
    assert(objName, "no objName provided")
    assert(upgradeParameters, "no upgradeParameters provided")
    assert(upgradeFieldsTest, "no upgradeFieldsTest provided")
    assert(type(logOk) == "boolean", "no logOk provided")
    corelog.WriteToLog("* "..className..":upgrade() tests (with "..objName..")")
    local obj = class:construct(constructParameters) assert(obj, "Failed obtaining "..className)

    -- test
    local upgradeSuccess = obj:upgrade(upgradeParameters)
    assert(upgradeSuccess, className..":upgrade() not a success")
    local test = upgradeFieldsTest
    test:test(obj, objName, "", logOk)

    -- cleanup test
    obj:destruct()
end

function T_IMObj.pt_getId(className, obj, objName, logOk, expectedId)
    -- prepare test
    assert(className, "no className provided")
    assert(obj, "no obj provided")
    assert(objName, "no objName provided")
    assert(type(logOk) == "boolean", "no logOk provided")
    expectedId = expectedId or obj._id
    corelog.WriteToLog("* "..className..":getId() tests")

    -- test
    local test = MethodResultEqualTest:newInstance("getId", expectedId)
    test:test(obj, objName, "", logOk)
end

function T_IMObj.pt_getWIPId(className, obj, objName, logOk)
    -- prepare test
    assert(className, "no className provided")
    assert(obj, "no obj provided")
    assert(objName, "no objName provided")
    assert(type(logOk) == "boolean", "no logOk provided")
    corelog.WriteToLog("* "..className..":getWIPId() tests")

    -- test
    local expectedWIPId = className.." "..obj:getId()
    local test = MethodResultEqualTest:newInstance("getWIPId", expectedWIPId)
    test:test(obj, objName, "", logOk)
end

function T_IMObj.pt_getBaseLocation(className, obj, objName, expectedBaseLocation, logOk)
    -- prepare test
    assert(className, "no className provided")
    assert(obj, "no obj provided")
    assert(objName, "no objName provided")
    assert(expectedBaseLocation, "no expectedBaseLocation provided")
    assert(type(logOk) == "boolean", "no logOk provided")
    corelog.WriteToLog("* "..className..":getBaseLocation() tests")

    -- test
    local test = MethodResultEqualTest:newInstance("getBaseLocation", expectedBaseLocation)
    test:test(obj, objName, "", logOk)
end

function T_IMObj.pt_getBlueprint(className, methodName, isStaticMethod, obj, objName, isBlueprintTest, logOk, ...)
    -- prepare test
    assert(className, "no className provided")
    local methodNameType = type(methodName)
    assert(methodNameType == "string", "type methodName(="..methodNameType..") not a string")
    local isStaticMethodType = type(isStaticMethod)
    assert(isStaticMethodType == "boolean", "type methodName(="..isStaticMethodType..") not a boolean")
    assert(obj, "no obj provided")
    assert(objName, "no objName provided")
    assert(isBlueprintTest, "no isBlueprintTest provided")
    assert(type(logOk) == "boolean", "no logOk provided")
    local methodOperator = ":" if isStaticMethod then methodOperator = "." end
    corelog.WriteToLog("* "..className..methodOperator..methodName.."() tests (with "..objName..")")

    -- test
    local test = MethodResultTest:newInstance(methodName, isStaticMethod, isBlueprintTest, ...)
    test:test(obj, objName, "", logOk)
end

function T_IMObj.pt_GetBuildBlueprint(className, obj, objName, constructParameters, isBlueprintTest, logOk)
    -- test
    T_IMObj.pt_getBlueprint(className, "GetBuildBlueprint", true, obj, objName, isBlueprintTest, logOk, constructParameters)
end

function T_IMObj.pt_getDismantleBlueprint(className, obj, objName, isBlueprintTest, logOk)
    -- test
    T_IMObj.pt_getBlueprint(className, "getDismantleBlueprint", false, obj, objName, isBlueprintTest, logOk)
end

function T_IMObj.pt_getExtendBlueprint(className, obj, objName, upgradeParameters, isBlueprintTest, logOk)
    -- test
    T_IMObj.pt_getBlueprint(className, "getExtendBlueprint", false, obj, objName, isBlueprintTest, logOk, upgradeParameters)
end

return T_IMObj
