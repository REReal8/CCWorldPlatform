local library = {}

function library.Init()
    -- add library to path
    package.path = package.path..";/rom/modules/ccwp/mobj/?"
end

function library.Setup()
    -- register library classes
    local ObjectFactory = require "object_factory"
    local objectFactory = ObjectFactory:getInstance()
    objectFactory:registerClass("Test",         require "mobj_turtle")
    objectFactory:registerClass("Chest",        require "mobj_chest")
    objectFactory:registerClass("BirchForest",  require "mobj_birchforest")
    objectFactory:registerClass("ProductionSpot",   require "mobj_production_spot")
    objectFactory:registerClass("Silo",         require "mobj_silo")

    -- register library modules
    local ModuleRegistry = require "module_registry"
    local moduleRegistry = ModuleRegistry:getInstance()
    moduleRegistry:requireAndRegisterModule("Chest", "mobj_chest") -- ToDo: refactor Chest to no longer need to register it also as a module
    moduleRegistry:requireAndRegisterModule("mobj_factory")

    -- register library modules test modules
    moduleRegistry:requireAndRegisterModule("T_BirchForest", "test.t_mobj_birchforest")
    moduleRegistry:requireAndRegisterModule("T_Chest", "test.t_mobj_chest")
    moduleRegistry:requireAndRegisterModule("T_ProductionSpot", "test.t_mobj_production_spot")
    moduleRegistry:requireAndRegisterModule("T_Silo", "test.t_mobj_silo")
    moduleRegistry:requireAndRegisterModule("T_Turtle", "test.t_mobj_turtle")

    -- do other stuff
end

return library