local library = {}

function library.Init()
    -- add library to path
    package.path = package.path..";/rom/modules/ccwp/obj/?"
end

function library.Setup()
    -- register library objects
    local ObjectRegistry = require "object_registry"
    local objectRegistry = ObjectRegistry:getInstance()
    -- ToDo: add

    -- register library object tests
    objectRegistry:requireAndRegisterObject("T_URL", "test.t_obj_url")
    objectRegistry:requireAndRegisterObject("T_Block", "test.t_obj_block")
    objectRegistry:requireAndRegisterObject("T_LayerRectangle", "test.t_obj_layer_rectangle")
    objectRegistry:requireAndRegisterObject("T_ItemInventory", "test.t_obj_item_inventory")

    -- do other stuff
end

return library