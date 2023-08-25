-- define class
local Class = require "class"
local ValueTypeTest = require "value_type_test"
local FieldValueTypeTest = Class.NewClass(ValueTypeTest)

--[[
    This module implements the class FieldValueTypeTest.

    It is a generic test class for testing the type of a field of an object.
--]]

local corelog = require "corelog"

function FieldValueTypeTest:_init(fieldName, expectedType)
    -- check input
    assert(type(fieldName) == "string", "fieldName not a string")

    -- initialisation
    ValueTypeTest._init(self, expectedType)
    self._fieldName     = fieldName
end

function FieldValueTypeTest:test(testObj, testObjName, indent, logOk)
    -- check input
    assert(type(testObjName) == "string", "testObjClassName not a string")
    assert(type(indent) == "string", "indent not a string")
    assert(type(logOk) == "boolean", "logOk not a boolean")

    -- prepare test
    local testFieldStr = testObjName.."."..self._fieldName.." field"

    local fieldValue = testObj[self._fieldName]
    assert(fieldValue, indent..testFieldStr.." testObj does not have field")

    -- test (via ValueTypeTest base)
    ValueTypeTest.test(self, fieldValue, testFieldStr, indent.."  ", logOk)

    -- complete test
    if logOk then corelog.WriteToLog(indent..testFieldStr.." ok") end

    -- cleanup test
end

return FieldValueTypeTest
