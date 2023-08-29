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

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function ValueEqualTest:_init(expectedValue)
    -- initialisation
    self._expectedValue = expectedValue
end

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

function ValueEqualTest:getClassName()
    return "ValueEqualTest"
end

--    _____ _______        _
--   |_   _|__   __|      | |
--     | |    | | ___  ___| |_
--     | |    | |/ _ \/ __| __|
--    _| |_   | |  __/\__ \ |_
--   |_____|  |_|\___||___/\__|

function ValueEqualTest:test(value, valueName, indent, logOk)
    -- check input
    assert(type(valueName) == "string", "valueName not a string")
    assert(type(indent) == "string", "indent not a string")
    assert(type(logOk) == "boolean", "logOk not a boolean")

    -- prepare test
    local testContextStr = valueName.." value "..textutils.serialise(value, compact)

    -- test
    if Class.IsInstanceOf(self._expectedValue, IObj) then
        assert(value:isEqual(self._expectedValue), indent..testContextStr.." not equal to expected value "..textutils.serialise(self._expectedValue))
    elseif type(self._expectedValue) == "table" then
        assert(type(value) == "table", indent..testContextStr.." not equal to expected type table")
        for key, expTblValue in pairs(self._expectedValue) do
            local tblValue = value[key]
            local testTblContextStr = valueName.." sub field "..key.." value "..textutils.serialise(tblValue, compact)
            assert(tblValue == expTblValue, indent.."  "..testTblContextStr.." not equal to expected value "..textutils.serialise(expTblValue))
            if logOk then corelog.WriteToLog(indent.."  "..testTblContextStr.." ok") end
        end
        -- ToDo: consider testing for additional keys in value (see also ObjBase)
        -- ToDo: consider testing deeper into the table (see also ObjBase)
    else
        assert(value == self._expectedValue, indent..testContextStr.." not equal to expected value "..textutils.serialise(self._expectedValue))
    end

    -- complete test
    if logOk then corelog.WriteToLog(indent..testContextStr.." ok") end

    -- cleanup test
end

return ValueEqualTest
