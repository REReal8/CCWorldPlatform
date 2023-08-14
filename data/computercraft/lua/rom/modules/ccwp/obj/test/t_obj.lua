local T_Obj = {}
local corelog = require "corelog"

local ModuleRegistry = require "module_registry"
local moduleRegistry = ModuleRegistry:getInstance()
local ObjectFactory = require "object_factory"
local objectFactory = ObjectFactory:getInstance()

local compact = { compact = true }

-- ToDo: consider moving to more generic place (i.e. not coupled to IObj)
function T_Obj.pt_ImplementsInterface(interfaceName, className, oTable)
    -- prepare test
    assert(className, "no className provided")
    corelog.WriteToLog("* "..className.." "..interfaceName.." interface test")
    local Interface = moduleRegistry:getModule(interfaceName)

    local obj = T_Obj.createObjFromTable(className, oTable) assert(obj, "failed obtaining "..className.." Obj from oTable "..textutils.serialise(oTable, compact))

    -- test
    local implementsInterface = Interface.ImplementsInterface(obj)
    assert(implementsInterface, ""..className.." class does not (fully) implement "..interfaceName.." interface")

    -- cleanup test
end

function T_Obj.createObjFromTable(className, oTable)
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

function T_Obj.pt_new(className, oTable)
    -- prepare test
    assert(className, "no className provided")
    corelog.WriteToLog("* "..className..":new() tests")

    -- test
    local obj = T_Obj.createObjFromTable(className, oTable)
    assert(obj, "failed creating "..className.." Obj from oTable "..textutils.serialise(oTable, compact))

    -- cleanup test
end

return T_Obj
