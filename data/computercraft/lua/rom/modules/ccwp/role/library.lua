local library = {}

function library.Init()
    -- add library to path
    package.path = package.path..";/rom/modules/ccwp/role/?"
end

function library.Setup()
    -- register library objects
    local ModuleRegistry = require "module_registry"
    local moduleRegistry = ModuleRegistry:getInstance()
    moduleRegistry:requireAndRegisterObject("role_alchemist")
    moduleRegistry:requireAndRegisterObject("role_builder")
    moduleRegistry:requireAndRegisterObject("role_chests_worker")
    moduleRegistry:requireAndRegisterObject("role_forester")
    moduleRegistry:requireAndRegisterObject("role_fuel_worker")
    moduleRegistry:requireAndRegisterObject("role_settler")
    moduleRegistry:requireAndRegisterObject("role_storage_silo_worker")

    -- register library object tests
    moduleRegistry:requireAndRegisterObject("t_alchemist", "test.t_alchemist")
    moduleRegistry:requireAndRegisterObject("t_builder", "test.t_builder")
    moduleRegistry:requireAndRegisterObject("t_foresting", "test.t_foresting")

    -- do other stuff
end

return library