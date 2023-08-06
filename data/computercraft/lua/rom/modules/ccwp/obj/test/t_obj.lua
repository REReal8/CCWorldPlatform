local T_Obj = {}
local corelog = require "corelog"

local ModuleRegistry = require "module_registry"
local moduleRegistry = ModuleRegistry:getInstance()
local ObjectFactory = require "object_factory"
local objectFactory = ObjectFactory:getInstance()

local compact = { compact = true }

--    _       _             __
--   (_)     | |           / _|
--    _ _ __ | |_ ___ _ __| |_ __ _  ___ ___  ___
--   | | '_ \| __/ _ \ '__|  _/ _` |/ __/ _ \/ __|
--   | | | | | ||  __/ |  | || (_| | (_|  __/\__ \
--   |_|_| |_|\__\___|_|  |_| \__,_|\___\___||___/

-- ToDo: consider moving to more generic place (i.e. not coupled to IObj)
function T_Obj.ImplementsInterface(interfaceName, className, oTable)
    -- prepare test
    assert(className, "no className provided")
    corelog.WriteToLog("* "..className.." "..interfaceName.." interface test")
    local Interface = moduleRegistry:getModule(interfaceName)

    local obj = T_Obj.newObj(className, oTable) assert(obj, "failed obtaining "..className.." Obj from oTable "..textutils.serialise(oTable, compact))

    -- test
    local implementsInterface = Interface.ImplementsInterface(obj)
    assert(implementsInterface, ""..className.." class does not (fully) implement "..interfaceName.." interface")

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

function T_Obj.newObj(className, oTable)
    -- check input
    assert(className, "no className provided")
    assert(oTable, "no oTable for "..className.." provided")

    -- get class
    local class = objectFactory:getClass(className)
    assert (class, "Class "..className.." not found in objectFactory")

    -- create Obj from oTable
    local obj = objectFactory:create(className, oTable)

    -- end
    return obj
end

function T_Obj.T_new(className, oTable)
    -- prepare test
    assert(className, "no className provided")
    corelog.WriteToLog("* "..className..":new() tests")

    -- test
    local obj = T_Obj.newObj(className, oTable)
    assert(obj, "failed creating "..className.." Obj from oTable "..textutils.serialise(oTable, compact))

    -- cleanup test
end

function T_Obj.T_ImplementsInterface(className, oTable)
    assert(className, "no className provided")
    T_Obj.ImplementsInterface("IObj", className, oTable)
end

function T_Obj.T_getClassName(className, oTable)
    -- prepare test
    assert(className, "no className provided")
    corelog.WriteToLog("* "..className..":getClassName() tests")

    local obj = T_Obj.newObj(className, oTable) assert(obj, "failed obtaining "..className.." Obj from oTable "..textutils.serialise(oTable, compact))

    -- test
    assert(obj:getClassName() == className, "gotten className(="..obj:getClassName()..") not the same as expected(="..className..")")

    -- cleanup test
end

function T_Obj.T_isTypeOf(className, oTable)
    -- prepare test
    assert(className, "no className provided")
    corelog.WriteToLog("* "..className..":isTypeOf() tests")

    local obj = T_Obj.newObj(className, oTable) assert(obj, "failed obtaining "..className.." Obj from oTable "..textutils.serialise(oTable, compact))

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

    local obj = T_Obj.newObj(className, oTable) assert(obj, "failed obtaining "..className.." Obj from oTable "..textutils.serialise(oTable, compact))

    -- test
    local copy = obj:copy()
    assert(copy:isSame(obj), "gotten copy(="..textutils.serialize(copy, compact)..") not the same as expected(="..textutils.serialize(obj, compact)..")")

    -- cleanup test
end

return T_Obj
