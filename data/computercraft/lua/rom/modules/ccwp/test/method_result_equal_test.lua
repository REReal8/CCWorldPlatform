-- define class
local Class = require "class"
local MethodResultTest = require "method_result_test"
local MethodResultEqualTest = Class.NewClass(MethodResultTest)

--[[
    This module implements the class MethodResultEqualTest.

    It is a generic test class for testing the results of a method call on an object be equal to something.
--]]

local ValueEqualTest = require "value_equal_test"
local MultipleValuesTest = require "multiple_values_test"

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function MethodResultEqualTest:_init(methodName, expectedResult, ...)
    -- check input
    local methodNameType = type(methodName)
    assert(methodNameType == "string", "type methodName(="..methodNameType..") not a string")
    local isStaticMethod = false -- ToDo: consider making an argument to allow testing static methods for equality

    -- initialisation
    MethodResultTest._init(self, methodName, isStaticMethod, MultipleValuesTest:newInstance(ValueEqualTest:newInstance(expectedResult)), ...)
end

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

function MethodResultEqualTest:getClassName()
    return "MethodResultEqualTest"
end

--    _____ _______        _
--   |_   _|__   __|      | |
--     | |    | | ___  ___| |_
--     | |    | |/ _ \/ __| __|
--    _| |_   | |  __/\__ \ |_
--   |_____|  |_|\___||___/\__|

return MethodResultEqualTest
