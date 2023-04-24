local library = {}

function library.Init()
    -- add library to path
    package.path = package.path..";/rom/modules/ccwp/core/?"
end

function library.Setup()
    -- register library modules
    local ModuleRegistry = require "module_registry"
    local moduleRegistry = ModuleRegistry:getInstance()

    -- register library modules test modules
    moduleRegistry:requireAndRegisterModule("t_coremove", "test.t_coremove")
    moduleRegistry:requireAndRegisterModule("t_coredht", "test.t_coredht")
    moduleRegistry:requireAndRegisterModule("t_coreinventory", "test.t_coreinventory")

    -- do other stuff
end

return library