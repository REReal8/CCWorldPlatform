-- define class
local Class = require "class"
local ValueTypeTest = require "value_type_test"
local FieldValueTypeTest = Class.NewClass(ValueTypeTest)

--[[
    This module implements the class FieldValueTypeTest.

    It is a generic test class for testing the type of a field of an object.
--]]

local corelog = require "corelog"

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function FieldValueTypeTest:_init(fieldName, expectedType)
    -- check input
    assert(type(fieldName) == "string", "fieldName not a string")

    -- initialisation
    ValueTypeTest._init(self, expectedType)
    self._fieldName     = fieldName
end

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

function FieldValueTypeTest:getClassName()
    return "FieldValueTypeTest"
end

--    _____ _______        _
--   |_   _|__   __|      | |
--     | |    | | ___  ___| |_
--     | |    | |/ _ \/ __| __|
--    _| |_   | |  __/\__ \ |_
--   |_____|  |_|\___||___/\__|

function FieldValueTypeTest:test(testObj, testObjName, indent, logOk)
    -- check input
    assert(type(testObjName) == "string", "testObjName not a string")
    assert(type(indent) == "string", "indent not a string")
    assert(type(logOk) == "boolean", "logOk not a boolean")

    -- prepare test
    local testFieldStr = testObjName.."."..self._fieldName.." field"

    local fieldValue = testObj[self._fieldName]
    if self._expectedType ~= "nil" then
        assert(fieldValue, indent..testFieldStr..": test "..testObjName.."(="..textutils.serialise(testObj, compact)..") does not have field")
    end

    -- test (via ValueTypeTest base)
    ValueTypeTest.test(self, fieldValue, testFieldStr, indent.."  ", logOk)

    -- complete test
    if logOk then corelog.WriteToLog(indent..testFieldStr.." ok") end

    -- cleanup test
end

return FieldValueTypeTest
