local library = {}

function library.Init()
    -- add library to path
    package.path = package.path..";/rom/modules/ccwp/mobj/?"
end

function library.Setup()
    -- register library modules
    local ModuleRegistry = require "module_registry"
    local moduleRegistry = ModuleRegistry:getInstance()
    moduleRegistry:requireAndRegisterObject("Chest", "mobj_chest")
    -- ToDo: consider adding & using object_factory

    -- register library modules test modules
    moduleRegistry:requireAndRegisterObject("T_Chest", "test.t_mobj_chest")
    moduleRegistry:requireAndRegisterObject("T_BirchForest", "test.t_mobj_birchforest")

    -- do other stuff
end

return library