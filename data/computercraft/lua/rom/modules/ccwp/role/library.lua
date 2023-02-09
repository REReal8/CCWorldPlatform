local library = {}

function library.Init()
    -- add library to path
    package.path = package.path..";/rom/modules/ccwp/role/?"
end

function library.Setup()
    -- register library objects
    local ObjectRegistry = require "object_registry"
    local objectRegistry = ObjectRegistry:getInstance()
    objectRegistry:requireAndRegisterObject("role_settler")
    -- ToDo: add others

    -- register library object tests
    objectRegistry:requireAndRegisterObject("t_alchemist", "test.t_alchemist")
    objectRegistry:requireAndRegisterObject("t_builder", "test.t_builder")

    -- do other stuff
end

return library