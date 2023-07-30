local library = {}

function library.Init()
    -- add library to path
    package.path = package.path..";/rom/modules/ccwp/mobj/?;/rom/modules/ccwp/mobj/?.lua"
end

function library.Setup()
    -- register library classes
    local ObjectFactory = require "object_factory"
    local objectFactory = ObjectFactory:getInstance()
    objectFactory:registerClass("Chest",        require "mobj_chest")
    objectFactory:registerClass("BirchForest",  require "mobj_birchforest")
    objectFactory:registerClass("Factory",      require "mobj_factory")
    objectFactory:registerClass("ProductionSpot",   require "mobj_production_spot")
    objectFactory:registerClass("Silo",         require "mobj_silo")
    objectFactory:registerClass("Mine",         require "mobj_mine")
    objectFactory:registerClass("Shop",         require "mobj_shop")
    objectFactory:registerClass("Turtle",       require "mobj_turtle")

    objectFactory:registerClass("TestMObj",     require "test.mobj_test")

    -- register library modules
    local ModuleRegistry = require "module_registry"
    local moduleRegistry = ModuleRegistry:getInstance()
    moduleRegistry:requireAndRegisterModule("Factory", "mobj_factory") -- ToDo: refactor Factory to no longer need to register it also as a module
    moduleRegistry:requireAndRegisterModule("IMObj", "i_mobj")

    -- register library modules test modules
    moduleRegistry:requireAndRegisterModule("T_BirchForest", "test.t_mobj_birchforest")
    moduleRegistry:requireAndRegisterModule("T_Chest", "test.t_mobj_chest")
    moduleRegistry:requireAndRegisterModule("T_ProductionSpot", "test.t_mobj_production_spot")
    moduleRegistry:requireAndRegisterModule("T_Factory", "test.t_mobj_factory")
    moduleRegistry:requireAndRegisterModule("T_Silo", "test.t_mobj_silo")
    moduleRegistry:requireAndRegisterModule("T_Mine", "test.t_mobj_mine")
    moduleRegistry:requireAndRegisterModule("T_Shop", "test.t_mobj_shop")
    moduleRegistry:requireAndRegisterModule("T_Turtle", "test.t_mobj_turtle")

    -- do other stuff
end

return library