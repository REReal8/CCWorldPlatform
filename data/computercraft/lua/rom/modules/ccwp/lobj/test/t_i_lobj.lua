local T_ILObj = {}
local corelog = require "corelog"

local ILObj = require "i_lobj"

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

function T_ILObj.pt_IsInstanceOf_ILObj(className, obj)
    -- prepare test
    assert(className, "no className provided")
    assert(obj, "no obj provided")

    -- test
    T_Class.pt_IsInstanceOf(className, obj, "ILObj", ILObj)
end

function T_ILObj.pt_Implements_ILObj(className, obj)
    -- prepare test
    assert(className, "no className provided")
    assert(obj, "no obj provided")

    -- test
    T_IInterface.pt_ImplementsInterface("ILObj", ILObj, className, obj)
end

--    _____ _      ____  _     _
--   |_   _| |    / __ \| |   (_)
--     | | | |   | |  | | |__  _
--     | | | |   | |  | | '_ \| |
--    _| |_| |___| |__| | |_) | |
--   |_____|______\____/|_.__/| |
--                           _/ |
--                          |__/

function T_ILObj.pt_destruct(className, class, constructParameters, objName, destructFieldsTest, logOk)
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

    -- ToDo: add tests if child LObj's have been released
end

function T_ILObj.pt_construct(className, class, constructParameters, objName, constructFieldsTest, logOk)
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

function T_ILObj.pt_upgrade(className, class, constructParameters, objName, upgradeParameters, upgradeFieldsTest, logOk)
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

function T_ILObj.pt_getId(className, obj, objName, logOk, expectedId)
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

function T_ILObj.pt_getWIPId(className, obj, objName, logOk)
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

return T_ILObj
