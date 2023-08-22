local t_main = {}

local corelog = require "corelog"
local coreinventory = require "coreinventory"
local coreassignment = require "coreassignment"

local t_coredht = require "test.t_coredht"
local t_coremove = require "test.t_coremove"

local t_alchemist = require "test.t_alchemist"
local t_builder = require "test.t_builder"
local t_foresting = require "test.t_foresting"

local T_ModuleRegistry = require "test.t_module_registry"
local T_Class = require "test.t_object"
local T_ObjectFactory = require "test.t_object_factory"
local T_ObjBase = require "test.t_obj_base"
local T_ObjArray = require "test.t_obj_array"
local T_ObjTable = require "test.t_obj_table"
local T_MethodExecutor = require "test.t_method_executor"
local T_CallDef = require "test.t_obj_call_def"
local T_Callback = require "test.t_obj_callback"
local T_TaskCall = require "test.t_obj_task_call"
local T_URL = require "test.t_obj_url"
local T_Host = require "test.t_obj_host"
local T_Location = require "test.t_obj_location"
local T_Block = require "test.t_obj_block"
local T_LayerRectangle = require "test.t_obj_layer_rectangle"
local T_Inventory = require "test.t_obj_inventory"
local T_WIPQueue = require "test.t_obj_wip_queue"
local T_WIPAdministrator = require "test.t_obj_wip_administrator"

local T_BirchForest = require "test.t_mobj_birchforest"
local T_Chest = require "test.t_mobj_chest"
local T_ProductionSpot = require "test.t_mobj_production_spot"
local T_Factory = require "test.t_mobj_factory"
local T_Silo = require "test.t_mobj_silo"
local T_Mine = require "test.t_mobj_mine"
local T_Shop = require "test.t_mobj_shop"
local T_Turtle = require "test.t_mobj_turtle"

local enterprise_assignmentboard = require "enterprise_assignmentboard"
local enterprise_administration = require "enterprise_administration"
local enterprise_projects = require "enterprise_projects"
local enterprise_energy = require "enterprise_energy"
local enterprise_manufacturing = require "enterprise_manufacturing"
local enterprise_turtle = require "enterprise_turtle"
local enterprise_chests = require "enterprise_chests"
local enterprise_shop = require "enterprise_shop"
local enterprise_forestry = require "enterprise_forestry"
local enterprise_storage = require "enterprise_storage"

local t_test = require "test.t_test"
local t_assignmentboard = require "test.t_assignmentboard"
local t_projects = require "test.t_projects"
local t_eobj_mobj_host = require "test.t_eobj_mobj_host"
local t_isp = require "test.t_isp"
local t_energy = require "test.t_energy"
local t_chests = require "test.t_chests"
local t_manufacturing = require "test.t_manufacturing"
local t_forestry = require "test.t_forestry"
local t_shop = require "test.t_shop"
local t_turtle = require "test.t_turtle"

function t_main.T_dummy()
    corelog.WriteToLog("Running T_()")
    print("!")
end

function t_main.T_All()
    -- core tests
    t_coredht.T_All()

    -- role tests
    t_alchemist.T_All()
    t_builder.T_All()
    t_foresting.T_All()

    -- obj tests
    T_ModuleRegistry.T_All()
    T_Class.T_All()
    T_ObjectFactory.T_All()
    T_ObjBase.T_All()
    T_ObjArray.T_All()
    T_ObjTable.T_All()
    T_CallDef.T_All()
    T_Callback.T_All()
    T_TaskCall.T_All()
    T_MethodExecutor.T_All()
    T_URL.T_All()
    T_Host.T_All()
    T_Location.T_All()
    T_Block.T_All()
    T_LayerRectangle.T_All()
    T_Inventory.T_All()
    T_WIPQueue.T_All()
    T_WIPAdministrator.T_All()

    -- mobj tests
    T_BirchForest.T_All()
    T_Chest.T_All()
    T_Factory.T_All()
    T_ProductionSpot.T_All()
    T_Silo.T_All()
    T_Mine.T_All()
    T_Shop.T_All()
    T_Turtle.T_All()

    -- enterprise tests
    t_test.T_All()
    t_assignmentboard.T_All()
    t_projects.T_All()
    t_eobj_mobj_host.T_All()
    t_isp.T_All()
    t_forestry.T_All()
    t_manufacturing.T_All()
    t_energy.T_All()
    t_chests.T_All()
    t_shop.T_All()
    t_turtle.T_All()
end

function t_main.T_ResetWorld()
    coreinventory.ResetAllItems()
    coreassignment.Reset()
    enterprise_assignmentboard.Reset()
    enterprise_administration:reset()
    enterprise_projects.DeleteProjects()
    enterprise_energy.ResetParameters()
    enterprise_manufacturing:deleteObjects("Factory")
    enterprise_turtle:reset()
    enterprise_chests:deleteObjects("Chest")
    enterprise_shop:reset()
    enterprise_forestry:deleteObjects("BirchForest")
    enterprise_storage:deleteObjects("Silo")

    -- give the system some time to save changes to disk
    os.sleep(0.25)

    -- time to reboot
    -- ToDo: figure out why changes are often still not saved to disk
--    os.reboot()
end

function t_main.Func1_Callback(callbackData, taskResult)
--    corelog.WriteToLog("  doing t_main.Func1_Callback("..textutils.serialise(callbackData)..", "..textutils.serialise(taskResult)..")")
    return true
end

function t_main.GoHomeCallBack(callbackData, taskResult)
    corelog.WriteToLog("  doing t_main.GoHomeCallBack("..textutils.serialise(callbackData)..", "..textutils.serialise(taskResult)..")")

    t_coremove.T_GoHome()

    return true
end

return t_main
