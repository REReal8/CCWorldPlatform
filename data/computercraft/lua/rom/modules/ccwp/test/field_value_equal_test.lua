-- define class
local Class = require "class"
local ValueEqualTest = require "value_equal_test"
local FieldValueEqualTest = Class.NewClass(ValueEqualTest)

--[[
    This module implements the class FieldValueEqualTest.

    It is a generic test class for testing the equality of a field of an object.
--]]

local corelog = require "corelog"

function FieldValueEqualTest:_init(fieldName, expectedValue)
    -- check input
    assert(type(fieldName) == "string", "fieldName not a string")

    -- initialisation
    ValueEqualTest._init(self, expectedValue)
    self._fieldName     = fieldName
end

function FieldValueEqualTest:test(testObj, testObjName, indent, logOk)
    -- check input
    assert(type(testObjName) == "string", "testObjClassName not a string")
    assert(type(indent) == "string", "indent not a string")
    assert(type(logOk) == "boolean", "logOk not a boolean")

    -- prepare test
    local testFieldStr = testObjName.."."..self._fieldName.." field"

    local fieldValue = testObj[self._fieldName]
    assert(fieldValue, indent..testFieldStr.." testObj does not have field")

    -- test (via ValueEqualTest)
    ValueEqualTest.test(self, fieldValue, testFieldStr, indent.."  ", logOk)

    -- complete test
    if logOk then corelog.WriteToLog(indent..testFieldStr.." ok") end

    -- cleanup test
end

return FieldValueEqualTest
