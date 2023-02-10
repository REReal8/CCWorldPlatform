local library = {}

function library.Init()
    -- add library to path
    package.path = package.path..";/rom/modules/ccwp/mobj/?"
end

function library.Setup()
    -- register library classes
    local ObjectFactory = require "object_factory"
    local objectFactory = ObjectFactory:getInstance()
    objectFactory:registerClass("Chest", require "mobj_chest")

    -- register library modules
    local ModuleRegistry = require "module_registry"
    local moduleRegistry = ModuleRegistry:getInstance()
    moduleRegistry:requireAndRegisterModule("Chest", "mobj_chest") -- ToDo: refactor Chest to no longer need to register it also as a module

    -- register library modules test modules
    moduleRegistry:requireAndRegisterModule("T_Chest", "test.t_mobj_chest")
    moduleRegistry:requireAndRegisterModule("T_BirchForest", "test.t_mobj_birchforest")

    -- do other stuff
end

return library