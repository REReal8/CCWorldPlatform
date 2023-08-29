-- define class
local Class = require "class"
local ValueEqualTest = require "value_equal_test"
local MethodResultEqualTest = Class.NewClass(ValueEqualTest)

--[[
    This module implements the class MethodResultEqualTest.

    It is a generic test class for testing the results of a method call on an object.
--]]

local corelog = require "corelog"

local compact = { compact = true }

function MethodResultEqualTest:_init(methodName, expectedResult)
    -- check input
    local methodNameType = type(methodName)
    assert(methodNameType == "string", "type methodName(="..methodNameType..") not a string")

    -- initialisation
    ValueEqualTest._init(self, expectedResult)
    self._methodName     = methodName
end

function MethodResultEqualTest:test(testObj, testObjName, indent, logOk)
    -- check input
    assert(type(testObjName) == "string", "testObjName not a string")
    assert(type(indent) == "string", "indent not a string")
    assert(type(logOk) == "boolean", "logOk not a boolean")

    -- prepare test
    local testFieldStr = testObjName..":"..self._methodName.."() result"

    local method = testObj[self._methodName]
    assert(method, indent..testFieldStr..": test "..testObjName.."(="..textutils.serialise(testObj, compact)..") does not have method")

    -- test (via ValueEqualTest)
    local methodResult = method(testObj)
    -- ToDo: consider allowing methods which additional arguments
    ValueEqualTest.test(self, methodResult, testFieldStr, indent.."  ", logOk)

    -- complete test
    if logOk then corelog.WriteToLog(indent..testFieldStr.." ok") end

    -- cleanup test
end

return MethodResultEqualTest
