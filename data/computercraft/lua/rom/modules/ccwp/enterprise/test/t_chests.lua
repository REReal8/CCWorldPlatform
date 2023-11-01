local t_chests = {}

local corelog = require "corelog"

local Callback = require "obj_callback"

local Location = require "obj_location"
local Inventory = require "obj_inventory"

local enterprise_projects = require "enterprise_projects"
local enterprise_chests = require "enterprise_chests"

local T_Chest = require "test.t_mobj_chest"
local T_MObjHost = require "test.t_mobj_host"

function t_chests.T_All()
    -- MObjHost
    t_chests.T_hostMObj_SSrv_Chest()
    t_chests.T_releaseMObj_SSrv_Chest()
end

function t_chests.T_AllPhysical()
    -- IObj

    -- MObjHost
    local mobjLocator = t_chests.T_buildAndHostMObj_ASrv_Chest()
    t_chests.T_dismantleAndReleaseMObj_ASrv_Chest(mobjLocator)
end

local testMObjClassName = "Chest"
local testMObjName = "chest"
local logOk = false

local testStartLocation  = Location:newInstance(-6, 0, 1, 0, 1)
local testStartLocation2  = Location:newInstance(-6, 6, 1, 0, 1)
local baseLocation1 = testStartLocation:getRelativeLocation(2, 5, 0)
local accessDirection1 = "top"
local inventory1 = Inventory:newInstance() -- optionally add elements

local constructParameters1 = {
    baseLocation    = baseLocation1,
    accessDirection = "top"
}

--                        _
--                       (_)
--    ___  ___ _ ____   ___  ___ ___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \
--   \__ \  __/ |   \ V /| | (_|  __/
--   |___/\___|_|    \_/ |_|\___\___|

function t_chests.T_hostAndUpdateChest()
    corelog.WriteToLog("* Test host and update Chest")
    local callback = Callback:newInstance("t_ccwp", "Func1_Callback", { } )

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
        projectMeta = { title = "Testing", description = "Register and update Chest" },
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
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "updateChestRecord_AOSrv", locatorStep = 1, locatorKeyDef = "mobjLocator" }, stepDataDef = {
            }, description = "Updating Chest record"},
        },
        returnData = {
            { keyDef = "chestLocator"           , sourceStep = 1, sourceKeyDef = "mobjLocator" },
        }
    }
end

--    __  __  ____  _     _ _    _           _                    _   _               _
--   |  \/  |/ __ \| |   (_) |  | |         | |                  | | | |             | |
--   | \  / | |  | | |__  _| |__| | ___  ___| |_   _ __ ___   ___| |_| |__   ___   __| |___
--   | |\/| | |  | | '_ \| |  __  |/ _ \/ __| __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   | |  | | |__| | |_) | | |  | | (_) \__ \ |_  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_|  |_|\____/|_.__/| |_|  |_|\___/|___/\__| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                      _/ |
--                     |__/

function t_chests.T_hostMObj_SSrv_Chest()
    -- prepare test
    local constructFieldsTest = T_Chest.CreateInitialisedTest(nil, baseLocation1, accessDirection1, inventory1)

    -- test
    local serviceResults = T_MObjHost.pt_hostMObj_SSrv(enterprise_chests, testMObjClassName, constructParameters1, testMObjName, constructFieldsTest, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

local mobjLocator_Chest = nil

function t_chests.T_buildAndHostMObj_ASrv_Chest()
    -- prepare test

    -- test
    local serviceResults = T_MObjHost.pt_buildAndHostMObj_ASrv(enterprise_chests, testMObjClassName, constructParameters1, testMObjName, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    mobjLocator_Chest = serviceResults.mobjLocator

    -- return mobjLocator
    return serviceResults.mobjLocator
end

function t_chests.T_releaseMObj_SSrv_Chest()
    -- prepare test

    -- test
    local serviceResults = T_MObjHost.pt_releaseMObj_SSrv(enterprise_chests, testMObjClassName, constructParameters1, testMObjName, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

function t_chests.T_dismantleAndReleaseMObj_ASrv_Chest(mobjLocator)
    -- prepare test
    if not mobjLocator then
        -- see if we locally remembered a mobjLocator
        assert(mobjLocator_Chest, "no mobjLocator to operate on")
        mobjLocator = mobjLocator_Chest
    end

    -- test
    local serviceResults = T_MObjHost.pt_dismantleAndReleaseMObj_ASrv(enterprise_chests, mobjLocator, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    mobjLocator_Chest = nil
end

return t_chests
