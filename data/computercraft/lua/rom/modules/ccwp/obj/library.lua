local library = {}

function library.Init()
    -- add library to path
    package.path = package.path..";/rom/modules/ccwp/obj/?"
end

function library.Setup()
    -- register library objects
    local ModuleRegistry = require "module_registry"
    local moduleRegistry = ModuleRegistry:getInstance()
    -- ToDo: add

    -- register library object tests
    moduleRegistry:requireAndRegisterObject("T_URL", "test.t_obj_url")
    moduleRegistry:requireAndRegisterObject("T_Block", "test.t_obj_block")
    moduleRegistry:requireAndRegisterObject("T_LayerRectangle", "test.t_obj_layer_rectangle")
    moduleRegistry:requireAndRegisterObject("T_ItemInventory", "test.t_obj_item_inventory")

    -- do other stuff
end

return library