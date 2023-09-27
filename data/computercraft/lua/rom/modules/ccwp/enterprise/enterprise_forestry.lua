-- define class
local Class = require "class"
local MObjHost = require "eobj_mobj_host"
local enterprise_forestry = Class.NewClass(MObjHost)

--[[
    The enterprise_forestry is a MObjHost. It hosts ItemSupplier's (i.e. BirchForest's) that can produce wood.
--]]

local corelog = require "corelog"

local Callback = require "obj_callback"
local TaskCall = require "obj_task_call"
local InputChecker = require "input_checker"

local role_forester = require "role_forester"

local BirchForest = require "mobj_birchforest"

local enterprise_projects = require "enterprise_projects"

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

-- note: currently enterprise is treated like a singleton, but by directly using the name of the module
-- ToDo: consider making changes to enteprise to
--          - explicitly make it a singleton (by construction with :newInstance(hostName) and using the singleton pattern)
--          - properly initialise it (by adding and implementing the _init method)
--          - adopt other classes to these changes
enterprise_forestry._hostName   = "enterprise_forestry"

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

function enterprise_forestry:getClassName()
    return "enterprise_forestry"
end

--                        _                           _   _               _
--                       (_)                         | | | |             | |
--    ___  ___ _ ____   ___  ___ ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \  __/ |   \ V /| | (_|  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/\___|_|    \_/ |_|\___\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

function enterprise_forestry.AddNewSite_ASrv(...)
    -- get & check input from description
    local checkSuccess, baseLocation, forestLevel, nTrees, materialsItemSupplierLocator, wasteItemDepotLocator, callback = InputChecker.Check([[
        This async public service builds a new Forest site and ensures it's ready for use.

        Return value:
                                                - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                                - (table)
                success                         - (boolean) whether the service executed successfully
                mobjLocator                     - (URL) locating the created MObj

        Parameters:
            serviceData                         - (table) data about this site
                baseLocation                    + (Location) world location of the base (lower left corner) of this site
                forestLevel                     + (number) level of the site
                nTrees                          + (number) number of initial trees
                materialsItemSupplierLocator    + (URL) locating the host of the building materials
                wasteItemDepotLocator           + (URL) locating where waste material can be delivered
            callback                            + (Callback) to call once service is ready
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("enterprise_forestry.AddNewSite_ASrv: Invalid input") return Callback.ErrorCall(callback) end

    -- check nTrees == 1  -- ToDo: remove this restriction
    if nTrees ~=1 then corelog.Warning("enterprise_forestry.AddNewSite_ASrv: not yet implemented for nTrees="..nTrees) return Callback.ErrorCall(callback) end

    -- create constructParameters
    local className = "BirchForest"
    local constructParameters = {
        level           = forestLevel,

        baseLocation    = baseLocation,
        nTrees          = 0,
    }

    -- construct new MObj
    local mobj = BirchForest:construct(constructParameters)
    if not mobj then corelog.Error("enterprise_forestry.AddNewSite_ASrv: Failed constructing "..className.." from constructParameters(="..textutils.serialise(constructParameters)..")") return Callback.ErrorCall(callback) end

    -- save the MObj
    local mobjLocator = enterprise_forestry:saveObject(mobj)
    if not mobjLocator then corelog.Error("enterprise_forestry.AddNewSite_ASrv: Failed saving "..className.." "..textutils.serialise(mobj)..")") return Callback.ErrorCall(callback) end

    -- log
    corelog.WriteToLog(">Hosting new "..className.." "..mobj:getId()..".")

    -- create projectDef and projectData
    local projectData = {
        hostLocator                 = enterprise_forestry:getHostLocator(),

        mobjLocator                 = mobjLocator,
        upgradeParameters           = {
            level                   = forestLevel,

            nTrees                  = nTrees,
        }
    }

    local projectSteps = { }
    if forestLevel == -1 then
        -- add build tree step
        table.insert(projectSteps,
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_assignmentboard", serviceName = "DoAssignment_ASrv" }, stepDataDef = {
                { keyDef = "metaData"                   , sourceStep = 0, sourceKeyDef = "plantFirstSaplingMetaData" },
                { keyDef = "taskCall"                   , sourceStep = 0, sourceKeyDef = "plantFirstSaplingTaskCall" },
            }, description = "Planting sapling"}
        )

        -- add step data
        local firstTreeLocation         = baseLocation:getRelativeLocation(3, 2, 0)
        local plantFirstSaplingTaskData =  {
            startLocation               = firstTreeLocation:copy(),
        }
        projectData.plantFirstSaplingMetaData   = role_forester.PlantFirstSapling_MetaData(plantFirstSaplingTaskData)
        projectData.plantFirstSaplingTaskCall   = TaskCall:newInstance("role_forester", "PlantFirstSapling_Task", plantFirstSaplingTaskData)
    else
        -- add build tree step
        table.insert(projectSteps,
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_construction", serviceName = "BuildLayer_ASrv" }, stepDataDef = {
                { keyDef = "startpoint"                     , sourceStep = 0, sourceKeyDef = "buildLayerLocation" },
                { keyDef = "buildFromAbove"                 , sourceStep = 0, sourceKeyDef = "buildFromAbove" },
                { keyDef = "replacePresentObjects"          , sourceStep = 0, sourceKeyDef = "replacePresentObjects" },
                { keyDef = "layer"                          , sourceStep = 0, sourceKeyDef = "treeLayer" },
                { keyDef = "materialsItemSupplierLocator"   , sourceStep = 0, sourceKeyDef = "materialsItemSupplierLocator" },
                { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
            }, description = "Building tree (Forest layer) at "..textutils.serialise(baseLocation, { compact = true })}
        )

        -- add step data
        local targetBaseLayer = mobj:getBaseLayer(forestLevel)
        projectData.buildLayerLocation          = baseLocation:copy()
        projectData.buildFromAbove              = true
        projectData.replacePresentObjects       = false
        projectData.treeLayer                   = targetBaseLayer
        projectData.materialsItemSupplierLocator= materialsItemSupplierLocator
        projectData.wasteItemDepotLocator       = wasteItemDepotLocator
    end

    table.insert(projectSteps,
        -- upgrade MObj
        { stepType = "LSOSrv", stepTypeDef = { serviceName = "upgradeMObj_SSrv", locatorStep = 0, locatorKeyDef = "hostLocator" }, stepDataDef = {
            { keyDef = "mobjLocator"                    , sourceStep = 0, sourceKeyDef = "mobjLocator" },
            { keyDef = "upgradeParameters"              , sourceStep = 0, sourceKeyDef = "upgradeParameters" },
        }}
    )
    local projectDef = {
        steps = projectSteps,
        returnData  = {
            { keyDef = "mobjLocator"                    , sourceStep = 0, sourceKeyDef = "mobjLocator" },
        }
    }
    local projectServiceData = {
        projectDef  = projectDef,
        projectData = projectData,
        projectMeta = { title = "New Forest", description = "More trees == more fun" },
    }

    -- start project
    return enterprise_projects.StartProject_ASrv(projectServiceData, callback)
end

return enterprise_forestry
