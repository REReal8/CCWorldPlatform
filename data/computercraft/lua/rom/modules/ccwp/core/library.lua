local library = {}

function library.Init()
    -- add library to path
    package.path = package.path..";/rom/modules/ccwp/core/?"
end

function library.Setup()
    -- register library objects
    local ObjectRegistry = require "object_registry"
    local objectRegistry = ObjectRegistry:getInstance()

    -- register library object tests
    objectRegistry:requireAndRegisterObject("t_coremove", "test.t_coremove")
    objectRegistry:requireAndRegisterObject("t_coredht", "test.t_coredht")

    -- do other stuff
end

return library