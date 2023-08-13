local T_IObj = {}
local corelog = require "corelog"

local ObjectFactory = require "object_factory"
local objectFactory = ObjectFactory:getInstance()

local Object = require "object"
local IObj = require "i_obj"

function T_IObj.pt_all(className, obj, otherObj)
    T_IObj.pt_getClassName(className, obj)
    T_IObj.pt_isTypeOf(className, obj)
    T_IObj.pt_isEqual(className, obj, otherObj)
    T_IObj.pt_copy(className, obj)
end

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

local compact = { compact = true }

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

    -- test class isTypeOf obj
    local isTypeOf = class:isTypeOf(obj)
    local expectedIsTypeOf = true
    assert(isTypeOf == expectedIsTypeOf, "gotten "..className..":isTypeOf(="..tostring(isTypeOf)..") not the same as expected(="..tostring(expectedIsTypeOf)..")")

    -- test class is not type of a different object
    isTypeOf = class:isTypeOf("a atring")
    expectedIsTypeOf = false
    assert(isTypeOf == expectedIsTypeOf, "gotten "..className..":isTypeOf(="..tostring(isTypeOf)..") not the same as expected(="..tostring(expectedIsTypeOf)..")")

    -- cleanup test
end

local function pt_isNotEqual_anotherValue(obj, otherObj, otherTable, fieldName, fieldValue, anotherFieldValue)
    -- change value
    otherTable[fieldName] = anotherFieldValue

    -- test not equal
    local isEqual = obj:isEqual(otherObj)
    local expectedIsEqual = false
    assert(isEqual == expectedIsEqual, "isEqual not "..tostring(expectedIsEqual).." for field "..fieldName.." of type "..type(fieldValue).." with original value "..textutils.serialise(fieldValue).." and anotherFieldValue "..textutils.serialise(anotherFieldValue))

    -- restore original value (for follow up tests)
    otherTable[fieldName] = fieldValue
end

local function pt_isNotEqual_tableField(obj, otherObj, otherTable, indent)
    --[[
        This function tests obj and otherObj are not the same if a field in otherTable is changed w.r.t. the input.
    ]]

    -- test fields
    for fieldName, fieldValue in pairs(otherTable) do
        corelog.WriteToLog(indent.."->test different field "..fieldName)
        -- check for table
        if type(fieldValue) == "table" then
            if Object.IsInstanceOf(fieldValue, IObj) then -- or IObj.ImplementsInterface(fieldValue) then
--                corelog.WriteToLog("type=IObj")
                local anotherFieldValue = "a string instead of an IObj"
                -- note: the actual class of the IObj field should have it's own isEqual test so we only need to test here it's inequality with something else (a string in this case)

                -- test anotherValue
                pt_isNotEqual_anotherValue(obj, otherObj, otherTable, fieldName, fieldValue, anotherFieldValue)
            else
--                corelog.WriteToLog("type=plain table")
                -- trigger test of equality of plane table fields
                pt_isNotEqual_tableField(obj, otherObj, fieldValue, indent.."  ")
            end
        else
--            corelog.WriteToLog("type="..type(fieldValue)..", value="..textutils.serialise(fieldValue))
            -- figure out anotherFieldValue
            local anotherFieldValue = nil
            if type(fieldValue) == "nil" then anotherFieldValue = "not nil" -- will probably never occur because key wouldn't be present
            elseif type(fieldValue) == "number" then anotherFieldValue = fieldValue + 1
            elseif type(fieldValue) == "string" then anotherFieldValue = fieldValue..", a longer string"
            elseif type(fieldValue) == "boolean" then anotherFieldValue = not fieldValue
            else
                assert(false, "testing field of type "..type(fieldValue).." not supported (yet)")
            end

            -- test anotherValue
            pt_isNotEqual_anotherValue(obj, otherObj, otherTable, fieldName, fieldValue, anotherFieldValue)
        end
    end
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

    -- test different fields not equal
    pt_isNotEqual_tableField(obj, otherObj, otherObj, "")

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
