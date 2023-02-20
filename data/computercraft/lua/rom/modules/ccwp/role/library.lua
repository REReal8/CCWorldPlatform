local library = {}

function library.Init()
    -- add library to path
    package.path = package.path..";/rom/modules/ccwp/role/?"
end

function library.Setup()
    -- register library modules
    local ModuleRegistry = require "module_registry"
    local moduleRegistry = ModuleRegistry:getInstance()
    moduleRegistry:requireAndRegisterModule("role_alchemist")
    moduleRegistry:requireAndRegisterModule("role_builder")
    moduleRegistry:requireAndRegisterModule("role_chests_worker")
    moduleRegistry:requireAndRegisterModule("role_forester")
    moduleRegistry:requireAndRegisterModule("role_fuel_worker")
    moduleRegistry:requireAndRegisterModule("role_settler")
    moduleRegistry:requireAndRegisterModule("role_storage_silo_worker")

    -- register library modules test modules
    moduleRegistry:requireAndRegisterModule("role_test", "test.role_test")
    moduleRegistry:requireAndRegisterModule("t_alchemist", "test.t_alchemist")
    moduleRegistry:requireAndRegisterModule("t_builder", "test.t_builder")
    moduleRegistry:requireAndRegisterModule("t_foresting", "test.t_foresting")

    -- do other stuff
end

return library