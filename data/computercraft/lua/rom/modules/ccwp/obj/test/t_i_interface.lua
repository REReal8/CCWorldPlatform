local T_IInterface = {}
local corelog = require "corelog"

local ModuleRegistry = require "module_registry"
local moduleRegistry = ModuleRegistry:getInstance()

local function pt_ImplementsInterface(interfaceName, interface, className, class)
    --[[
        This function checks if a(n) (instance of) class inplements an interface.

        To check if the class implements the interface it is checked if all functions in the interface are
        implemented in the class.

        A functions is assumed to be implemented if the functions in the interface is not identical (i.e. an identical
        address) to the functions with the same key in the class.
    ]]

    -- check
    assert(interfaceName, "no interfaceName provided")
    assert(interface, "no interface provided")
    assert(className, "no className provided")
    assert(class, "no class provided")

    -- loop on all functions in the interface
    for key, interface_func in pairs(interface) do
        -- check interface_func is a function
        assert(type(interface_func) == "function", "key "..key.." of interface "..interfaceName.." not a function (type="..type(interface_func)..")")

        -- check interface_func is present in class
        local classFunc = class[key] -- rawget(class, key)
        assert(classFunc, "key "..key.." of interface "..interfaceName.." not present in class "..className)

        -- check classFunc is a function
        assert(type(classFunc) == "function", "key "..key.." of class "..className.." not a function (type="..type(classFunc)..")")

        -- check functions are not identical (as that implies classFunc is not overridden in class)
        assert(classFunc ~= interface_func, "key "..key.." of interface "..interfaceName.." not implemented in in class "..className)
    end
end

function T_IInterface.pt_ImplementsInterface(interfaceName, className, obj)
    -- prepare test
    assert(interfaceName, "no interfaceName provided")
    assert(className, "no className provided")
    assert(obj, "no obj provided")
    corelog.WriteToLog("* "..className.." "..interfaceName.." interface test")
    local interface = moduleRegistry:getModule(interfaceName)

    -- test
    pt_ImplementsInterface(interfaceName, interface, className, obj)

    -- cleanup test
end

return T_IInterface
