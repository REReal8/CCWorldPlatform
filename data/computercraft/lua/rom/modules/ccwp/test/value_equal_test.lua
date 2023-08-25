-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local ITest = require "i_test"
local ValueEqualTest = Class.NewClass(ObjBase, ITest)

--[[
    This module implements the class ValueEqualTest.

    It is a generic test class for testing the equality of two values
--]]

local corelog = require "corelog"

local IObj = require "i_obj"

local compact = { compact = true }

function ValueEqualTest:_init(expectedValue)
    -- initialisation
    self._expectedValue = expectedValue
end

function ValueEqualTest:test(value, valueName, indent, logOk)
    -- check input
    assert(type(valueName) == "string", "valueName not a string")
    assert(type(indent) == "string", "indent not a string")
    assert(type(logOk) == "boolean", "logOk not a boolean")

    -- prepare test
    local testContextStr = valueName.." value "..textutils.serialise(value, compact)

    -- test
    if Class.IsInstanceOf(value, IObj) then
        assert(value:isEqual(self._expectedValue), indent..testContextStr.." not equal to expected value "..textutils.serialise(self._expectedValue))
    else
        assert(value == self._expectedValue, indent..testContextStr.." not equal to expected value "..textutils.serialise(self._expectedValue))
    end

    -- complete test
    if logOk then corelog.WriteToLog(indent..testContextStr.." ok") end

    -- cleanup test
end

return ValueEqualTest
