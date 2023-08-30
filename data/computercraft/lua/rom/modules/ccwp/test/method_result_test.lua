-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local ITest = require "i_test"
local MethodResultTest = Class.NewClass(ObjBase, ITest)

--[[
    This module implements the class MethodResultTest.

    It is a generic test class for testing the results of a method call on an object.
--]]

local corelog = require "corelog"

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function MethodResultTest:_init(methodName, resultTest)
    -- check input
    local methodNameType = type(methodName)
    assert(methodNameType == "string", "type methodName(="..methodNameType..") not a string")
    assert(Class.IsInstanceOf(resultTest, ITest), "Provided resultTest argument not an ITest")

    -- initialisation
    self._resultTest    = resultTest
    self._methodName    = methodName
end

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

function MethodResultTest:getClassName()
    return "MethodResultTest"
end

--    _____ _______        _
--   |_   _|__   __|      | |
--     | |    | | ___  ___| |_
--     | |    | |/ _ \/ __| __|
--    _| |_   | |  __/\__ \ |_
--   |_____|  |_|\___||___/\__|

function MethodResultTest:test(testObj, testObjName, indent, logOk)
    -- check input
    assert(type(testObjName) == "string", "testObjName not a string")
    assert(type(indent) == "string", "indent not a string")
    assert(type(logOk) == "boolean", "logOk not a boolean")

    -- prepare test
    local testFieldStr = testObjName..":"..self._methodName.."() result"

    local method = testObj[self._methodName]
    assert(method, indent..testFieldStr..": test "..testObjName.."(="..textutils.serialise(testObj, compact)..") does not have method")

    -- test (via ValueEqualTest)
    local methodResults = {method(testObj)} -- note: collect possible multiple results
    -- ToDo: consider allowing methods which additional arguments
    self._resultTest:test(methodResults, testFieldStr, indent.."  ", logOk)

    -- complete test
    if logOk then corelog.WriteToLog(indent..testFieldStr.." ok") end

    -- cleanup test
end

return MethodResultTest