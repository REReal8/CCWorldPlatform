-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local ITest = require "i_test"
local FieldsTest = Class.NewClass(ObjBase, ITest)

--[[
    This module implements the class FieldsTest.

    It is a generic test class for testing the equality of fields in an object.
--]]

local corelog = require "corelog"

function FieldsTest:_init(...)
    -- check input
    local tests = {...}
    for i, test in ipairs(tests) do
        assert(Class.IsInstanceOf(test, ITest), "Provided argument "..i.." (="..textutils.serialise(test)..") not an ITest")
    end

    -- initialisation
    self._tests = tests
end

function FieldsTest:test(testObj, testObjName, indent, logOk)
    -- check input
    assert(type(testObj) ~= "nil", "testObj shouldn't be nil")
    assert(type(testObjName) == "string", "testObjName not a string")
    assert(type(indent) == "string", "indent not a string")
    assert(type(logOk) == "boolean", "logOk not a boolean")

    -- prepare test
    local testFieldsStr = testObjName.." fields"

    -- test all tests
    assert(self._tests, indent..testFieldsStr..": no tests provided")
    for i, fieldTest in ipairs(self._tests) do
        -- test
        fieldTest:test(testObj, testObjName, indent.."  ", logOk)
    end

    -- complete test
    if logOk then corelog.WriteToLog(indent..testFieldsStr.." ok") end

    -- cleanup test
end

return FieldsTest
