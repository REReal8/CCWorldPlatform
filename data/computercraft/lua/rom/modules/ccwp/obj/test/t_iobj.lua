local T_IObj = {}
local corelog = require "corelog"

local ModuleRegistry = require "module_registry"
local moduleRegistry = ModuleRegistry:getInstance()
local ObjectFactory = require "object_factory"
local objectFactory = ObjectFactory:getInstance()

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

function T_IObj.pt_getClassName(className, obj)
    -- prepare test
    assert(className, "no className provided")
    assert(obj, "no obj provided")
    corelog.WriteToLog("* "..className..":getClassName() tests")

    -- test
    assert(obj:getClassName() == className, "gotten className(="..obj:getClassName()..") not the same as expected(="..className..")")

    -- cleanup test
end

function T_IObj.pt_isTypeOf(className, obj)
    -- prepare test
    assert(className, "no className provided")
    assert(obj, "no obj provided")
    corelog.WriteToLog("* "..className..":isTypeOf() tests")

    local class = objectFactory:getClass(className)
    assert (class, "Class "..className.." not found in objectFactory")

    -- test valid
    local isTypeOf = class:isTypeOf(obj)
    local expectedIsTypeOf = true
    assert(isTypeOf == expectedIsTypeOf, "gotten "..className..":isTypeOf(="..tostring(isTypeOf)..") not the same as expected(="..tostring(expectedIsTypeOf)..")")

    -- test different object
    isTypeOf = class:isTypeOf("a atring")
    expectedIsTypeOf = false
    assert(isTypeOf == expectedIsTypeOf, "gotten "..className..":isTypeOf(="..tostring(isTypeOf)..") not the same as expected(="..tostring(expectedIsTypeOf)..")")

    -- cleanup test
end

function T_IObj.pt_isEqual(className, obj, otherObj) -- note: obj and otherObj are assumed to be the same at the start of the test
    -- prepare test
    assert(className, "no className provided")
    assert(obj, "no obj provided")
    assert(otherObj, "no otherObj provided")
    corelog.WriteToLog("* "..className..":isEqual() tests")

    -- test identical obj equal
    corelog.WriteToLog("->test identical obj")
    local isEqual = obj:isEqual(obj)
    local expectedIsEqual = true
    assert(isEqual == expectedIsEqual, "gotten isEqual(="..tostring(isEqual)..") not the same as expected(="..tostring(expectedIsEqual)..")")

    -- test equal obj equal
    corelog.WriteToLog("->test equal obj")
    isEqual = obj:isEqual(otherObj)
    expectedIsEqual = true
    assert(isEqual == expectedIsEqual, "gotten isEqual(="..tostring(isEqual)..") not the same as expected(="..tostring(expectedIsEqual)..")")

    -- test fields
    for fieldName, fieldValue in pairs(otherObj) do
        corelog.WriteToLog("->test field "..fieldName.." type="..type(fieldValue))
        -- figure out anotherFieldValue
        local anotherFieldValue = nil
        if type(fieldValue) == "nil" then anotherFieldValue = "not nil" -- will probably never occur because key wouldn't be present
        elseif type(fieldValue) == "number" then anotherFieldValue = fieldValue + 1
        elseif type(fieldValue) == "string" then anotherFieldValue = fieldValue.."_extra"
        elseif type(fieldValue) == "boolean" then anotherFieldValue = not fieldValue
        else
            assert(false, "testing field of type "..type(fieldValue).." not supported (yet)")
        end

        -- change value
        obj[fieldName] = anotherFieldValue

        -- test not equal
        isEqual = obj:isEqual(otherObj)
        expectedIsEqual = false
        assert(isEqual == expectedIsEqual, "gotten isEqual(="..tostring(isEqual)..") not the same as expected(="..tostring(expectedIsEqual)..") for field "..fieldName)

        -- restore original value (for follow up tests)
        obj[fieldName] = fieldValue
    end

    -- cleanup test
end

function T_IObj.pt_copy(className, obj)
    -- prepare test
    assert(className, "no className provided")
    assert(obj, "no obj provided")
    corelog.WriteToLog("* "..className..":copy() tests")

    -- test
    local copy = obj:copy()
    assert(copy:isEqual(obj), "gotten copy(="..textutils.serialize(copy, compact)..") not the same as expected(="..textutils.serialize(obj, compact)..")")

    -- cleanup test
end

return T_IObj
