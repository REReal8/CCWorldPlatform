local library = {}

function library.Init()
    -- add library to path
    package.path = package.path..";/rom/modules/ccwp/obj/?"
end

function library.Setup()
    -- register library modules
    local ModuleRegistry = require "module_registry"
    local moduleRegistry = ModuleRegistry:getInstance()
    -- ToDo: add

    -- register library modules test modules
    moduleRegistry:requireAndRegisterModule("T_ModuleRegistry", "test.t_module_registry")
    moduleRegistry:requireAndRegisterModule("T_ObjectFactory", "test.t_object_factory")
    moduleRegistry:requireAndRegisterModule("T_URL", "test.t_obj_url")
    moduleRegistry:requireAndRegisterModule("T_Block", "test.t_obj_block")
    moduleRegistry:requireAndRegisterModule("T_LayerRectangle", "test.t_obj_layer_rectangle")
    moduleRegistry:requireAndRegisterModule("T_ItemInventory", "test.t_obj_item_inventory")

    -- do other stuff
end

return library