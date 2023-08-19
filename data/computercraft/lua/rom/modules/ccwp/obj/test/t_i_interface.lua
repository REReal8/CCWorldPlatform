local T_IInterface = {}
local corelog = require "corelog"

local ModuleRegistry = require "module_registry"
local moduleRegistry = ModuleRegistry:getInstance()

function T_IInterface.pt_ImplementsInterface(interfaceName, className, obj)
    -- prepare test
    assert(interfaceName, "no interfaceName provided")
    assert(className, "no className provided")
    assert(obj, "no obj provided")
    corelog.WriteToLog("* "..className.." "..interfaceName.." interface test")
    local Interface = moduleRegistry:getModule(interfaceName)

    -- test
    local implementsInterface = Interface.ImplementsInterface(obj)
    assert(implementsInterface, ""..className.." class does not (fully) implement "..interfaceName.." interface")

    -- cleanup test
end

return T_IInterface
