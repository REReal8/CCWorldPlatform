local T_Obj = {}
local corelog = require "corelog"

local ModuleRegistry = require "module_registry"
local moduleRegistry = ModuleRegistry:getInstance()
local ObjectFactory = require "object_factory"
local objectFactory = ObjectFactory:getInstance()

local IObj = require "i_obj"

local compact = { compact = true }

-- ToDo: consider moving to more generic place (i.e. not coupled to IObj)
function T_Obj.ImplementsInterface(interfaceName, className, oTable)
    -- prepare test
    assert(className, "no className provided")
    corelog.WriteToLog("* "..className.." "..interfaceName.." interface test")
    local Interface = moduleRegistry:getModule(interfaceName)

    local obj = T_Obj.createObj(className, oTable) assert(obj, "failed obtaining "..className.." Obj from oTable "..textutils.serialise(oTable, compact))

    -- test
    local implementsInterface = Interface.ImplementsInterface(obj)
    assert(implementsInterface, ""..className.." class does not (fully) implement "..interfaceName.." interface")

    -- cleanup test
end

function T_Obj.CheckOTableFieldsSame(oTableA, oTableB)
    --[[

    ]]

    -- check both arguments are tables
    assert(type(oTableA) == "table", "oTableA not a table: oTableA="..textutils.serialise(oTableA))
    assert(type(oTableB) == "table", "oTableB not a table: oTableB="..textutils.serialise(oTableB))

    -- loop over fields oTable1
    for fieldKeyA, fieldValueA in pairs(oTableA) do
        -- check fieldKeyA is in oTableB
        assert(oTableB.fieldKeyA, "field "..fieldKeyA.." not found (in oTableB)")

        -- check fieldValue types are equal
        local fieldValueB = oTableB.fieldKeyA
        assert(type(fieldValueB) == type(fieldValueA), "field "..fieldKeyA.." type(="..type(fieldValueB)..") not same as expected(="..type(fieldValueA)..")")

        -- check supported fieldValue type
        assert(type(fieldValueA) ~= "function", "field "..fieldKeyA.." type(="..type(fieldValueA)..") not supported")
        assert(type(fieldValueA) ~= "thread", "field "..fieldKeyA.." type(="..type(fieldValueA)..") not supported")
        assert(type(fieldValueA) ~= "userdata", "field "..fieldKeyA.." type(="..type(fieldValueA)..") not supported")

        -- check fieldValue values are equal
        if type(fieldValueA) ~= "table" then
            -- check build in values equal
            assert(fieldValueB == fieldValueA, "field "..fieldKeyA.." value(="..fieldValueB..") not the same as expected(="..fieldValueA..")")
        else
            -- check table values equal
            if fieldValueA == fieldValueB then -- identical so also equal
            else -- not identical
                -- check IObj's
                assert(IObj.ImplementsInterface(fieldValueB), "field "..fieldKeyA.." not an IObj, checking plane table fields not supported")

                -- check fieldValue isEqual
                assert(fieldValueB:isEqual(fieldValueA), "field "..fieldKeyA.." value(="..textutils.serialise(fieldValueB)..") not the same as expected(="..textutils.serialise(fieldValueA)..")")
            end
        end
    end

    -- end
    return true
end

function T_Obj.createObj(className, oTable)
    --[[
        This test helper method creates and returns an Obj of class 'className' from an object table 'oTable'.
    ]]

    -- check input
    assert(className, "no className provided")
    assert(oTable, "no oTable for "..className.." provided")

    -- get class
    local class = objectFactory:getClass(className)
    assert (class, "Class "..className.." not found in objectFactory")

    -- create Obj from oTable
    local obj = objectFactory:create(className, oTable)
    if not obj then corelog.Warning("failed creating "..className.." Obj from oTable "..textutils.serialise(oTable, compact)) end

    -- end
    return obj
end

function T_Obj.T_new(className, oTable)
    -- prepare test
    assert(className, "no className provided")
    corelog.WriteToLog("* "..className..":new() tests")

    -- test
    local obj = T_Obj.createObj(className, oTable)
    assert(obj, "failed creating "..className.." Obj from oTable "..textutils.serialise(oTable, compact))

    -- cleanup test
end

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

function T_Obj.T_ImplementsInterface(className, oTable)
    assert(className, "no className provided")
    T_Obj.ImplementsInterface("IObj", className, oTable)
end

function T_Obj.T_getClassName(className, oTable)
    -- prepare test
    assert(className, "no className provided")
    corelog.WriteToLog("* "..className..":getClassName() tests")

    local obj = T_Obj.createObj(className, oTable) assert(obj, "failed obtaining "..className.." Obj from oTable "..textutils.serialise(oTable, compact))

    -- test
    assert(obj:getClassName() == className, "gotten className(="..obj:getClassName()..") not the same as expected(="..className..")")

    -- cleanup test
end

function T_Obj.T_isTypeOf(className, oTable)
    -- prepare test
    assert(className, "no className provided")
    corelog.WriteToLog("* "..className..":isTypeOf() tests")

    local obj = T_Obj.createObj(className, oTable) assert(obj, "failed obtaining "..className.." Obj from oTable "..textutils.serialise(oTable, compact))

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

function T_Obj.T_copy(className, oTable)
    -- prepare test
    assert(className, "no className provided")
    corelog.WriteToLog("* "..className..":copy() tests")

    local obj = T_Obj.createObj(className, oTable) assert(obj, "failed obtaining "..className.." Obj from oTable "..textutils.serialise(oTable, compact))

    -- test
    local copy = obj:copy()
    assert(copy:isEqual(obj), "gotten copy(="..textutils.serialize(copy, compact)..") not the same as expected(="..textutils.serialize(obj, compact)..")")

    -- cleanup test
end

return T_Obj
