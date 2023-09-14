local t_chests = {}

local corelog = require "corelog"

local Callback = require "obj_callback"

local Location = require "obj_location"
local Inventory = require "obj_inventory"

local enterprise_projects = require "enterprise_projects"
local enterprise_chests = require "enterprise_chests"

local T_Chest = require "test.t_mobj_chest"
local T_MObjHost = require "test.t_eobj_mobj_host"

function t_chests.T_All()
    -- service methods
    t_chests.T_hostMObj_SSrv_Chest()
    t_chests.T_releaseMObj_SSrv_Chest()
end

local testStartLocation  = Location:newInstance(-6, 0, 1, 0, 1)
local testStartLocation2  = Location:newInstance(-6, 6, 1, 0, 1)

local callback = Callback:newInstance("t_main", "Func1_Callback", { } )

--                        _                           _   _               _
--                       (_)                         | | | |             | |
--    ___  ___ _ ____   ___  ___ ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \  __/ |   \ V /| | (_|  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/\___|_|    \_/ |_|\___\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

function t_chests.T_hostAndUpdateChest()
    corelog.WriteToLog("* Test host and update chest")

    -- create project
    local projectData = {
        hostLocator         = enterprise_chests:getHostLocator(),
        className           = "Chest",
        constructParameters = {
            baseLocation    = testStartLocation2:getRelativeLocation(2, 5, 0),
            accessDirection = "back",
        }
    }
    local projectServiceData = {
        projectDef  = t_chests.GetHostAndUpdateChestProjectDef(),
        projectData = projectData,
        projectMeta = { title = "Testing", description = "Register and update chest" },
    }

    -- start project
    return enterprise_projects.StartProject_ASrv(projectServiceData, callback)
end

function t_chests.GetHostAndUpdateChestProjectDef()
    return {
        steps = {
            -- host Chest
            { stepType = "LSOSrv", stepTypeDef = { serviceName = "hostMObj_SSrv", locatorStep = 0, locatorKeyDef = "hostLocator" }, stepDataDef = {
                { keyDef = "className"          , sourceStep = 0, sourceKeyDef = "className" },
                { keyDef = "constructParameters", sourceStep = 0, sourceKeyDef = "constructParameters" },
            }},
            -- update Chest
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_chests", serviceName = "UpdateChestRecord_ASrv" }, stepDataDef = {
                { keyDef = "chestLocator"       , sourceStep = 1, sourceKeyDef = "mobjLocator" },
            }},
        },
        returnData = {
            { keyDef = "chestLocator"           , sourceStep = 1, sourceKeyDef = "mobjLocator" },
        }
    }
end

local testMObjClassName = "Chest"
local testMObjName = "chest"
local logOk = false
local baseLocation1 = testStartLocation:getRelativeLocation(2, 5, 0)
local accessDirection1 = "top"
local inventory1 = Inventory:new() -- optionally add elements

local constructParameters1 = {
    baseLocation    = baseLocation1,
    accessDirection = "top"
}

function t_chests.T_hostMObj_SSrv_Chest()
    -- prepare test
    local constructFieldsTest = T_Chest.CreateInitialisedTest(nil, baseLocation1, accessDirection1, inventory1)

    -- test
    local serviceResults = T_MObjHost.pt_hostMObj_SSrv(enterprise_chests, testMObjClassName, constructParameters1, testMObjName, constructFieldsTest, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

function t_chests.T_releaseMObj_SSrv_Chest()
    -- prepare test
    local mobjLocator = enterprise_chests:hostMObj_SSrv({className = testMObjClassName, constructParameters = constructParameters1}).mobjLocator if not mobjLocator then corelog.Error("failed registering Obj") return end

    -- test
    local serviceResults = T_MObjHost.pt_releaseMObj_SSrv(enterprise_chests, mobjLocator, testMObjClassName, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

return t_chests
