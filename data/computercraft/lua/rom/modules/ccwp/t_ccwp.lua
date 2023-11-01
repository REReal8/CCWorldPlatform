local t_ccwp = {}

local corelog = require "corelog"
local coreinventory = require "coreinventory"
local coreassignment = require "coreassignment"

local t_coremove = require "test.t_coremove"

local T_CoreLibrary = require "core.library"
local T_BaseLibrary = require "base.library"
local T_ObjLibrary = require "obj.library"
local T_RoleLibrary = require "role.library"
local T_MObjLibrary = require "mobj.library"

local enterprise_assignmentboard = require "enterprise_assignmentboard"
local enterprise_administration = require "enterprise_administration"
local enterprise_projects = require "enterprise_projects"
local enterprise_energy = require "enterprise_energy"
local enterprise_manufacturing = require "enterprise_manufacturing"
local enterprise_employment = require "enterprise_employment"
local enterprise_chests = require "enterprise_chests"
local enterprise_shop = require "enterprise_shop"
local enterprise_forestry = require "enterprise_forestry"
local enterprise_storage = require "enterprise_storage"

local T_EnterpriseLibrary = require "enterprise.library"

function t_ccwp.T_dummy()
    corelog.WriteToLog("Running T_()")
    print("!")
end

function t_ccwp.T_All()
    -- libraries
    T_CoreLibrary.T_All()
    T_BaseLibrary.T_All()
    T_ObjLibrary.T_All()
    T_RoleLibrary.T_All()
    T_MObjLibrary.T_All()
    T_EnterpriseLibrary.T_All()
end

function t_ccwp.T_ResetWorld()
    -- core resets
    coreinventory.ResetAllItems()
    coreassignment.Reset()

    -- enterprise resets
    enterprise_assignmentboard.Reset()
    enterprise_administration:reset()
    enterprise_projects.DeleteProjects()
    enterprise_energy.ResetParameters()
    enterprise_manufacturing:deleteObjects("Factory")
    enterprise_employment:reset()
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

function t_ccwp.T_ClearLogfile()
    corelog.ClearLog()
end

function t_ccwp.Func1_Callback(callbackData, taskResult)
--    corelog.WriteToLog("  doing t_ccwp.Func1_Callback("..textutils.serialise(callbackData)..", "..textutils.serialise(taskResult)..")")
    return true
end

function t_ccwp.GoHomeCallBack(callbackData, taskResult)
    corelog.WriteToLog("  doing t_ccwp.GoHomeCallBack("..textutils.serialise(callbackData)..", "..textutils.serialise(taskResult)..")")

    t_coremove.T_GoHome()

    return true
end

return t_ccwp
