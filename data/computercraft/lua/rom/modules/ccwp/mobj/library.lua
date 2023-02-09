local library = {}

function library.Init()
    -- add library to path
    package.path = package.path..";/rom/modules/ccwp/mobj/?"
end

function library.Setup()
    -- register library objects
    local ObjectRegistry = require "object_registry"
    local objectRegistry = ObjectRegistry:getInstance()
    -- ToDo: add

    -- register library object tests
    objectRegistry:requireAndRegisterObject("T_Chest", "test.t_mobj_chest")
    objectRegistry:requireAndRegisterObject("T_BirchForest", "test.t_mobj_birchforest")

    -- do other stuff
end

return library