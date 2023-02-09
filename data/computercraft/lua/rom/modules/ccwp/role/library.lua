local library = {}

function library.Init()
    -- add library to path
    package.path = package.path..";/rom/modules/ccwp/role/?"
end

function library.Setup()
    -- register library objects
    local ObjectRegistry = require "object_registry"
    local objectRegistry = ObjectRegistry:getInstance()
    objectRegistry:requireAndRegisterObject("role_alchemist")
    objectRegistry:requireAndRegisterObject("role_builder")
    objectRegistry:requireAndRegisterObject("role_chests_worker")
    objectRegistry:requireAndRegisterObject("role_forester")
    objectRegistry:requireAndRegisterObject("role_fuel_worker")
    objectRegistry:requireAndRegisterObject("role_settler")
    objectRegistry:requireAndRegisterObject("role_storage_silo_worker")

    -- register library object tests
    objectRegistry:requireAndRegisterObject("t_alchemist", "test.t_alchemist")
    objectRegistry:requireAndRegisterObject("t_builder", "test.t_builder")
    objectRegistry:requireAndRegisterObject("t_foresting", "test.t_foresting")

    -- do other stuff
end

return library