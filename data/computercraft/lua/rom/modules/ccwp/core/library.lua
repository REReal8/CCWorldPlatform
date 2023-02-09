local library = {}

function library.Init()
    -- add library to path
    package.path = package.path..";/rom/modules/ccwp/core/?"
end

function library.Setup()
    -- register library objects
    local ObjectRegistry = require "object_registry"
    local objectRegistry = ObjectRegistry:getInstance()
    -- ToDo: add

    -- register library object tests
    objectRegistry:requireAndRegisterObject("t_move", "test.t_move")
    objectRegistry:requireAndRegisterObject("t_coredht", "test.t_coredht")

    -- do other stuff
end

return library