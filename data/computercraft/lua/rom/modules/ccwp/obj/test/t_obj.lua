local T_Obj = {}
local corelog = require "corelog"

local ModuleRegistry = require "module_registry"
local moduleRegistry = ModuleRegistry:getInstance()
local Object = require "object"
local IObj = require "i_obj"

-- ToDo: consider moving to more generic place for interfaces
function T_Obj.pt_ImplementsInterface(interfaceName, className, obj)
    -- prepare test
    assert(className, "no className provided")
    assert(obj, "no obj provided")
    corelog.WriteToLog("* "..className.." "..interfaceName.." interface test")
    local Interface = moduleRegistry:getModule(interfaceName)

    -- test
    local implementsInterface = Interface.ImplementsInterface(obj)
    assert(implementsInterface, ""..className.." class does not (fully) implement "..interfaceName.." interface")

    -- cleanup test
end

-- ToDo: consider moving to a new tests module for initialisation/ construction of objects, e.g. t_i_initialisation
function T_Obj.pt_new(testClassName, obj, expectedFieldValues)
    -- prepare test
    assert(testClassName, "no className provided")
    corelog.WriteToLog("* "..testClassName..":new() tests")

    -- test initialised
    assert(obj, "Failed obtaining "..testClassName)

    -- test fields initialised
    assert(expectedFieldValues, "no expectedFieldValues provided")
    for fieldName, expectedValue in pairs(expectedFieldValues) do
        local fieldValue = obj[fieldName]
        if Object.IsInstanceOf(fieldValue, IObj) then
            assert(fieldValue:isEqual(expectedValue), "Failed initialising "..testClassName.." field "..fieldName.." to "..textutils.serialise(expectedValue).." (obtained ="..textutils.serialise(fieldValue) ..")")
        else
            assert(fieldValue == expectedValue, "Failed initialising "..testClassName.." field "..fieldName.." to "..textutils.serialise(expectedValue).." (obtained ="..textutils.serialise(fieldValue) ..")")
        end
    end

    -- cleanup test
end

return T_Obj
