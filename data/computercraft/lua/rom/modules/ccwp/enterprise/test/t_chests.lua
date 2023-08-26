local t_chests = {}

local corelog = require "corelog"

local Callback = require "obj_callback"

local Location = require "obj_location"

local enterprise_projects = require "enterprise_projects"
local enterprise_chests = require "enterprise_chests"

function t_chests.T_All()
    -- service methods
    t_chests.T_hostMObj_SSrv_Chest()
    t_chests.T_releaseMObj_SSrv_Chest()
end

local testStartLocation  = Location:newInstance(-6, 0, 1, 0, 1)
local testStartLocation2  = Location:newInstance(-6, 6, 1, 0, 1)

local callback = Callback:new({
    _moduleName     = "t_main",
    _methodName     = "Func1_Callback",
    _data           = { },
})

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

function t_chests.T_hostMObj_SSrv_Chest()
    -- prepare test
    local className = "Chest"
    corelog.WriteToLog("* enterprise_chests:hostMObj_SSrv() ("..className..") tests")
    local constructParameters = {
        baseLocation    = testStartLocation:getRelativeLocation(2, 5, 0),
        accessDirection = "top"
    }

    -- test
    local result = enterprise_chests:hostMObj_SSrv({className = className, constructParameters = constructParameters,})
    assert(result.success, "failed hosting "..className)
    local mobjLocator = result.mobjLocator
    assert(mobjLocator, "Failed obtaining mobjLocator")
    local mobj = enterprise_chests:getObject(mobjLocator)
    assert(mobj, "Failed obtaining mobj")

    -- cleanup test
    mobj:destruct()
    enterprise_chests:deleteResource(mobjLocator)
end

function t_chests.T_releaseMObj_SSrv_Chest()
    -- prepare test
    local className = "Chest"
    corelog.WriteToLog("* enterprise_chests:releaseMObj_SSrv() tests")
    local constructParameters = {
        baseLocation    = testStartLocation:getRelativeLocation(2, 5, 0),
        accessDirection = "top"
    }
    local objLocator = enterprise_chests:hostMObj_SSrv({className = className, constructParameters = constructParameters}).mobjLocator if not objLocator then corelog.Error("failed registering Obj") return end

    -- test
    local serviceResults = enterprise_chests:releaseMObj_SSrv({ mobjLocator = objLocator})
    assert(serviceResults.success, "failed executing sync service")

    local objResourceTable = enterprise_chests:getResource(objLocator)
    assert(not objResourceTable, "Obj wasn't deleted")

    -- cleanup test
end

return t_chests
