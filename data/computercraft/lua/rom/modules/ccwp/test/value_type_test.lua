-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local ITest = require "i_test"
local ValueTypeTest = Class.NewClass(ObjBase, ITest)

--[[
    This module implements the class ValueTypeTest.

    It is a generic test class for testing the type of a value
--]]

local corelog = require "corelog"

local IObj = require "i_obj"

local compact = { compact = true }

function ValueTypeTest:_init(expectedType)
    -- check input
    assert(type(expectedType) == "string", "expectedType not a string")

    -- initialisation
    self._expectedType = expectedType
end

function ValueTypeTest:test(value, valueName, indent, logOk)
    -- check input
    assert(type(valueName) == "string", "valueName not a string")
    assert(type(indent) == "string", "indent not a string")
    assert(type(logOk) == "boolean", "logOk not a boolean")

    -- prepare test
    local valueType = type(value)
    local testContextStr = valueName.." type "..valueType

    -- test
    assert(valueType == self._expectedType, indent..testContextStr.." not equal to expected type "..textutils.serialise(self._expectedType))

    -- complete test
    if logOk then corelog.WriteToLog(indent..testContextStr.." ok") end

    -- cleanup test
end

return ValueTypeTest
