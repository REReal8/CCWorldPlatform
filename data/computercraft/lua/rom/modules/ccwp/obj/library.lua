-- define library
local library = {}

function library.Init()
    -- add library to path
    package.path = package.path..";/rom/modules/ccwp/obj/?"..";/rom/modules/ccwp/obj/?.lua"
end

local function ExecuteLibraryTest(t)
	-- forward call with options
	local options	= {
		{key = "m", desc = "ModuleRegistry", 	func = ExecuteLibraryTest, param = {filename = "T_ModuleRegistry"}},
		{key = "1", desc = "Class", 			func = ExecuteLibraryTest, param = {filename = "T_Class"}},
		{key = "f", desc = "ObjectFactory", 	func = ExecuteLibraryTest, param = {filename = "T_ObjectFactory"}},
		{key = "2", desc = "ObjBase", 			func = ExecuteLibraryTest, param = {filename = "T_ObjBase"}},
		{key = "a", desc = "ObjArray", 			func = ExecuteLibraryTest, param = {filename = "T_ObjArray"}},
		{key = "o", desc = "ObjTable", 			func = ExecuteLibraryTest, param = {filename = "T_ObjTable"}},
		{key = "d", desc = "CallDef", 			func = ExecuteLibraryTest, param = {filename = "T_CallDef"}},
		{key = "c", desc = "Callback", 			func = ExecuteLibraryTest, param = {filename = "T_Callback"}},
		{key = "t", desc = "TaskCall", 			func = ExecuteLibraryTest, param = {filename = "T_TaskCall"}},
		{key = "e", desc = "MethodExecutor", 	func = ExecuteLibraryTest, param = {filename = "T_MethodExecutor"}},
		{key = "u", desc = "URL", 				func = ExecuteLibraryTest, param = {filename = "T_URL"}},
		{key = "h", desc = "Host", 				func = ExecuteLibraryTest, param = {filename = "T_Host"}},
		{key = "j", desc = "ObjHost", 			func = ExecuteLibraryTest, param = {filename = "T_ObjHost"}},
		{key = "l", desc = "Location",			func = ExecuteLibraryTest, param = {filename = "T_Location"}},
		{key = "b", desc = "Block",				func = ExecuteLibraryTest, param = {filename = "T_Block"}},
		{key = "p", desc = "CodeMap",			func = ExecuteLibraryTest, param = {filename = "T_CodeMap"}},
		{key = "r", desc = "LayerRectangle",	func = ExecuteLibraryTest, param = {filename = "T_LayerRectangle"}},
		{key = "i", desc = "Inventory",			func = ExecuteLibraryTest, param = {filename = "T_Inventory"}},
		{key = "g", desc = "ItemTable",			func = ExecuteLibraryTest, param = {filename = "T_ItemTable"}},
		{key = "q", desc = "WIPQueue",			func = ExecuteLibraryTest, param = {filename = "T_WIPQueue"}},
		{key = "w", desc = "WIPAdministrator",	func = ExecuteLibraryTest, param = {filename = "T_WIPAdministrator"}},
		{key = "x", desc = "Back to main menu", func = function () return true end }
	}
	return ExecuteXObjTest(t, "obj", options, ExecuteLibraryTest)
end

function library.Setup()
    -- register library classes
    local ObjectFactory = require "object_factory"
    local objectFactory = ObjectFactory:getInstance()
    objectFactory:registerClass("ObjBase", require "obj_base")
    objectFactory:registerClass("ObjArray", require "obj_array")
    objectFactory:registerClass("ObjTable", require "obj_table")
    objectFactory:registerClass("CallDef", require "obj_call_def")
    objectFactory:registerClass("Callback", require "obj_callback")
    objectFactory:registerClass("TaskCall", require "obj_task_call")
    objectFactory:registerClass("URL", require "obj_url")
    objectFactory:registerClass("Host", require "host")
    objectFactory:registerClass("ObjHost", require "obj_host")
    objectFactory:registerClass("Location", require "obj_location")
    objectFactory:registerClass("Block", require "obj_block")
    objectFactory:registerClass("CodeMap", require "obj_code_map")
    objectFactory:registerClass("LayerRectangle", require "obj_layer_rectangle")
    objectFactory:registerClass("Inventory", require "obj_inventory")
    objectFactory:registerClass("ItemTable", require "obj_item_table")
    objectFactory:registerClass("WIPQueue", require "obj_wip_queue")
    objectFactory:registerClass("WIPAdministrator", require "obj_wip_administrator")

    objectFactory:registerClass("TestObj", require "test.obj_test")

    -- register library modules
    local ModuleRegistry = require "module_registry"
    local moduleRegistry = ModuleRegistry:getInstance()
    moduleRegistry:requireAndRegisterModule("IObj", "i_obj")
    moduleRegistry:requireAndRegisterModule("IItemSupplier", "i_item_supplier")
    moduleRegistry:requireAndRegisterModule("IItemDepot", "i_item_depot")
    moduleRegistry:requireAndRegisterModule("CallDef", "obj_call_def")
    moduleRegistry:requireAndRegisterModule("Callback", "obj_callback")
    moduleRegistry:requireAndRegisterModule("MethodExecutor", "method_executor")

    -- register library modules test modules
    moduleRegistry:requireAndRegisterModule("T_ModuleRegistry", "test.t_module_registry")
    moduleRegistry:requireAndRegisterModule("T_Class", "test.t_class")
    moduleRegistry:requireAndRegisterModule("T_ObjectFactory", "test.t_object_factory")
    moduleRegistry:requireAndRegisterModule("T_ObjBase", "test.t_obj_base")
    moduleRegistry:requireAndRegisterModule("T_ObjArray", "test.t_obj_array")
    moduleRegistry:requireAndRegisterModule("T_ObjTable", "test.t_obj_table")
    moduleRegistry:requireAndRegisterModule("T_CallDef", "test.t_obj_call_def")
    moduleRegistry:requireAndRegisterModule("T_Callback", "test.t_obj_callback")
    moduleRegistry:requireAndRegisterModule("T_TaskCall", "test.t_obj_task_call")
    moduleRegistry:requireAndRegisterModule("T_MethodExecutor", "test.t_method_executor")
    moduleRegistry:requireAndRegisterModule("T_IItemSupplier", "test.t_i_item_supplier")
    moduleRegistry:requireAndRegisterModule("T_IItemDepot", "test.t_i_item_depot")
    moduleRegistry:requireAndRegisterModule("T_URL", "test.t_obj_url")
    moduleRegistry:requireAndRegisterModule("T_Host", "test.t_host")
    moduleRegistry:requireAndRegisterModule("T_ObjHost", "test.t_obj_host")
    moduleRegistry:requireAndRegisterModule("T_Location", "test.t_obj_location")
    moduleRegistry:requireAndRegisterModule("T_Block", "test.t_obj_block")
    moduleRegistry:requireAndRegisterModule("T_CodeMap", "test.t_obj_code_map")
    moduleRegistry:requireAndRegisterModule("T_LayerRectangle", "test.t_obj_layer_rectangle")
    moduleRegistry:requireAndRegisterModule("T_Inventory", "test.t_obj_inventory")
    moduleRegistry:requireAndRegisterModule("T_ItemTable", "test.t_obj_item_table")
    moduleRegistry:requireAndRegisterModule("T_WIPQueue", "test.t_obj_wip_queue")
    moduleRegistry:requireAndRegisterModule("T_WIPAdministrator", "test.t_obj_wip_administrator")

    -- add library test menu
    local coredisplay = require "coredisplay"
    coredisplay.MainMenuAddItem("o", "obj lib tests", ExecuteLibraryTest, {})

    -- do other stuff
end

return library