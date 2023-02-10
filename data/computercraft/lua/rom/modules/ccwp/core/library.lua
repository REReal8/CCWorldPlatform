local library = {}

function library.Init()
    -- add library to path
    package.path = package.path..";/rom/modules/ccwp/core/?"
end

function library.Setup()
    -- register library objects
    local ModuleRegistry = require "module_registry"
    local moduleRegistry = ModuleRegistry:getInstance()

    -- register library object tests
    moduleRegistry:requireAndRegisterObject("t_coremove", "test.t_coremove")
    moduleRegistry:requireAndRegisterObject("t_coredht", "test.t_coredht")

    -- do other stuff
end

return library