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
