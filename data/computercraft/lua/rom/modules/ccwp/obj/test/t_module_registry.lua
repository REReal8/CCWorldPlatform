local T_ModuleRegistry = {}
local corelog = require "corelog"

local ModuleRegistry = require "module_registry"

function T_ModuleRegistry.T_All()
    T_ModuleRegistry.T_registerModule_isRegistered()
    T_ModuleRegistry.T_delistModule()
    T_ModuleRegistry.T_getModule()
end

local registry = ModuleRegistry:getInstance()
local module1Name = "module1"
local module1 = {aValue = 1}

function T_ModuleRegistry.T_registerModule_isRegistered()
    -- prepare test
    corelog.WriteToLog("* ModuleRegistry:registerModule() and ModuleRegistry:isRegistered() tests")
    assert(not registry:isRegistered(module1Name), "Module "..module1Name.." already registered")

    -- test
    registry:registerModule(module1Name, module1)
    assert(registry:isRegistered(module1Name), "Module "..module1Name.." not registered")

    -- cleanup test
    registry:delistModule(module1Name)
end

function T_ModuleRegistry.T_delistModule()
    -- prepare test
    corelog.WriteToLog("* ModuleRegistry:delistModule() test")
    registry:registerModule(module1Name, module1)
    assert(registry:isRegistered(module1Name), "Module not registered")

    -- test
    registry:delistModule(module1Name)
    assert(not registry:isRegistered(module1Name), "Module not delisted")

    -- cleanup
end

function T_ModuleRegistry.T_getModule()
    -- prepare test
    corelog.WriteToLog("* ModuleRegistry:getModule() tests")
    assert(not registry:isRegistered(module1Name), "Module "..module1Name.." already registered")
    registry:registerModule(module1Name, module1)
    local module2Name = "module2"
    local module2 = {aValue = 2}
    assert(not registry:isRegistered(module2Name), "Module "..module2Name.." already registered")
    registry:registerModule(module2Name, module2)

    -- test
    local retrievedObject1 = registry:getModule(module1Name)
    assert(retrievedObject1 == module1, "Retrieved module 1 does not match original module 1")
    local retrievedObject2 = registry:getModule(module2Name)
    assert(retrievedObject2 == module2, "Retrieved module 2 does not match original module 2")

    -- cleanup test
    registry:delistModule(module1Name)
    registry:delistModule(module2Name)
end

return T_ModuleRegistry
