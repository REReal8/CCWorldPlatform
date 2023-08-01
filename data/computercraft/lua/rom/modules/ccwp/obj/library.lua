local library = {}

function library.Init()
    -- add library to path
    package.path = package.path..";/rom/modules/ccwp/obj/?"..";/rom/modules/ccwp/obj/?.lua"
end

function library.Setup()
    -- register library classes
    local ObjectFactory = require "object_factory"
    local objectFactory = ObjectFactory:getInstance()
    objectFactory:registerClass("ObjArray", require "obj_array")
    objectFactory:registerClass("ObjTable", require "obj_table")
    objectFactory:registerClass("Callback", require "obj_callback")
    objectFactory:registerClass("TaskCall", require "obj_task_call")
    objectFactory:registerClass("URL", require "obj_url")
    objectFactory:registerClass("Host", require "obj_host")
    objectFactory:registerClass("Location", require "obj_location")
    objectFactory:registerClass("Block", require "obj_block")
    objectFactory:registerClass("LayerRectangle", require "obj_layer_rectangle")
    objectFactory:registerClass("Inventory", require "obj_inventory")
    objectFactory:registerClass("WIPQueue", require "obj_wip_queue")

    objectFactory:registerClass("TestObj", require "test.obj_test")

    -- register library modules
    local ModuleRegistry = require "module_registry"
    local moduleRegistry = ModuleRegistry:getInstance()
    moduleRegistry:requireAndRegisterModule("IObj", "i_obj")
    moduleRegistry:requireAndRegisterModule("IItemSupplier", "i_item_supplier")
    moduleRegistry:requireAndRegisterModule("IItemDepot", "i_item_depot")

    -- register library modules test modules
    moduleRegistry:requireAndRegisterModule("T_ModuleRegistry", "test.t_module_registry")
    moduleRegistry:requireAndRegisterModule("T_ObjectFactory", "test.t_object_factory")
    moduleRegistry:requireAndRegisterModule("T_ObjArray", "test.t_obj_array")
    moduleRegistry:requireAndRegisterModule("T_ObjTable", "test.t_obj_table")
    moduleRegistry:requireAndRegisterModule("T_CallDef", "test.t_obj_call_def")
    moduleRegistry:requireAndRegisterModule("T_Callback", "test.t_obj_callback")
    moduleRegistry:requireAndRegisterModule("T_TaskCall", "test.t_obj_task_call")
    moduleRegistry:requireAndRegisterModule("T_MethodExecutor", "test.t_method_executor")
    moduleRegistry:requireAndRegisterModule("T_URL", "test.t_obj_url")
    moduleRegistry:requireAndRegisterModule("T_Host", "test.t_obj_host")
    moduleRegistry:requireAndRegisterModule("T_Location", "test.t_obj_location")
    moduleRegistry:requireAndRegisterModule("T_Block", "test.t_obj_block")
    moduleRegistry:requireAndRegisterModule("T_LayerRectangle", "test.t_obj_layer_rectangle")
    moduleRegistry:requireAndRegisterModule("T_Inventory", "test.t_obj_inventory")
    moduleRegistry:requireAndRegisterModule("T_WIPQueue", "test.t_obj_wip_queue")

    -- do other stuff
end

return library