local T_IMObj = {}
local corelog = require "corelog"

local IMObj = require "i_mobj"

local T_IInterface = require "test.t_i_interface"
local T_Class = require "test.t_class"

local MethodResultTest = require "method_result_test"
local MethodResultEqualTest = require "method_result_equal_test"

--    _____ __  __  ____  _     _                  _   _               _
--   |_   _|  \/  |/ __ \| |   (_)                | | | |             | |
--     | | | \  / | |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | | | |\/| | |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| |_| |  | | |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____|_|  |_|\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                            _/ |
--                           |__/

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

function T_IMObj.pt_destruct(className, class, constructParameters)
    -- prepare test
    assert(className, "no className provided")
    assert(class, "no class provided")
    assert(constructParameters, "no constructParameters provided")
    corelog.WriteToLog("* "..className..":destruct() tests")
    local obj = class:construct(constructParameters) assert(obj, "Failed obtaining "..className)

    -- test
    local destructSuccess = obj:destruct()
    assert(destructSuccess, className..":destruct() not a success")
end

function T_IMObj.pt_construct(className, class, constructParameters, objName, constructInitialisedTest, logOk)
    -- prepare test
    assert(className, "no className provided")
    assert(class, "no class provided")
    assert(constructParameters, "no constructParameters provided")
    assert(objName, "no objName provided")
    assert(constructInitialisedTest, "no constructInitialisedTest provided")
    assert(type(logOk) == "boolean", "no logOk provided")
    corelog.WriteToLog("* "..className..":construct() tests")

    -- test
    local obj = class:construct(constructParameters) assert(obj, "Failed obtaining "..className)
    local test = constructInitialisedTest
    test:test(obj, objName, "", logOk)

    -- cleanup test
    obj:destruct()
end

function T_IMObj.pt_getId(className, obj, objName, logOk)
    -- prepare test
    assert(className, "no className provided")
    assert(obj, "no obj provided")
    assert(objName, "no objName provided")
    assert(type(logOk) == "boolean", "no logOk provided")
    corelog.WriteToLog("* "..className..":getId() tests")

    -- test
    local test = MethodResultEqualTest:newInstance("getId", obj._id)
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

function T_IMObj.pt_getBuildBlueprint(className, obj, objName, isBlueprintTest, logOk)
    -- prepare test
    assert(className, "no className provided")
    assert(obj, "no obj provided")
    assert(objName, "no objName provided")
    assert(isBlueprintTest, "no isBlueprintTest provided")
    assert(type(logOk) == "boolean", "no logOk provided")
    corelog.WriteToLog("* "..className..":getBuildBlueprint() tests")

    -- test
    local test = MethodResultTest:newInstance("getBuildBlueprint", isBlueprintTest)
    test:test(obj, objName, "", logOk)
end

function T_IMObj.pt_getDismantleBlueprint(className, obj, objName, isBlueprintTest, logOk)
    -- prepare test
    assert(className, "no className provided")
    assert(obj, "no obj provided")
    assert(objName, "no objName provided")
    assert(isBlueprintTest, "no isBlueprintTest provided")
    assert(type(logOk) == "boolean", "no logOk provided")
    corelog.WriteToLog("* "..className..":getDismantleBlueprint() tests")

    -- test
    local test = MethodResultTest:newInstance("getDismantleBlueprint", isBlueprintTest)
    test:test(obj, objName, "", logOk)
end

return T_IMObj
