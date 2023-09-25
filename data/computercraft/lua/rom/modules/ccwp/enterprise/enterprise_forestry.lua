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
local enterprise_construction = require "enterprise_construction"

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
                { keyDef = "startpoint"                     , sourceStep = 0, sourceKeyDef = "treeBaseLocation" },
                { keyDef = "buildFromAbove"                 , sourceStep = 0, sourceKeyDef = "buildFromAbove" },
                { keyDef = "replacePresentObjects"          , sourceStep = 0, sourceKeyDef = "replacePresentObjects" },
                { keyDef = "layer"                          , sourceStep = 0, sourceKeyDef = "treeLayer" },
                { keyDef = "materialsItemSupplierLocator"   , sourceStep = 0, sourceKeyDef = "materialsItemSupplierLocator" },
                { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
            }, description = "Building tree (Forest layer) at "..textutils.serialise(baseLocation, { compact = true })}
        )

        -- add step data
        local targetBaseLayer = mobj:getBaseLayer(forestLevel)
        projectData.treeBaseLocation            = baseLocation:copy()
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

function enterprise_forestry.UpgradeSite_ASrv(...)
    -- get & check input from description
    local checkSuccess, mobjLocator, targetLevel, targetNTrees, materialsItemSupplierLocator, wasteItemDepotLocator, callback = InputChecker.Check([[
        This private async service upgrades a Forest from the current configuration (i.e. level, # trees, ...) to a new configuration.

        Note: downgrading a Forest is not supported.

        Return value:
                                                - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                                - (table)
                success                         - (boolean) whether the service executed successfully

        Parameters:
            serviceData                         - (table) data about the service
                mobjLocator                     + (URL) locating the Forest
                targetLevel                     + (number) with Forest level to upgrade to
                targetNTrees                    + (number) number of trees to upgrade Forest to
                materialsItemSupplierLocator    + (URL) locating the host of the building materials
                wasteItemDepotLocator           + (URL) locating where waste material can be delivered
            callback                            + (Callback) to call once service is ready
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("enterprise_forestry.UpgradeSite_ASrv: Invalid input") return Callback.ErrorCall(callback) end

    -- get Forest
    local forest = enterprise_forestry:getObject(mobjLocator)
    if type(forest) ~="table" then corelog.Error("enterprise_forestry.UpgradeSite_ASrv: Failed retrieving Forest = "..mobjLocator:getURI()) return Callback.ErrorCall(callback) end

    -- check not downgrading
    local startingLevel = forest:getLevel()
    if startingLevel > targetLevel then corelog.Error("enterprise_forestry.UpgradeSite_ASrv: Downgrading Forest level (from "..startingLevel.." to "..targetLevel..") not supported") return Callback.ErrorCall(callback) end

    -- determine projectSteps and projectData
    local projectSteps = { }
    local areAllTrueStepDataDef = {}
    local targetTreeLayer = forest:getTreeLayer(targetLevel)
    local projectData = {
        hostLocator                 = enterprise_forestry:getHostLocator(),

        mobjLocator                 = mobjLocator,

        treeLayer                   = targetTreeLayer,

        buildFromAbove              = true,
        replacePresentObjects       = false,

        materialsItemSupplierLocator= materialsItemSupplierLocator,
        wasteItemDepotLocator       = wasteItemDepotLocator,
    }

    -- add project steps for upgrading level
    local iStep = 0
    local startingTreeLayer = forest:getTreeLayer(startingLevel)
    local startingNTrees = forest:getNTrees()
    if startingLevel < targetLevel and startingNTrees > 0 then
        -- upgrade level data
        local targetBaseLayer = forest:getBaseLayer(targetLevel)
        local startingBaseLayer = forest:getBaseLayer(startingLevel)
        local transformLayer = startingBaseLayer:transformToLayer(targetBaseLayer)
        if not transformLayer then corelog.Error("enterprise_forestry.UpgradeSite_ASrv: No base transformLayer") return Callback.ErrorCall(callback) end
        local baseColOffset, baseRowOffset, baseBuildLayer = transformLayer:buildData()
        projectData.baseBuildLayer = baseBuildLayer

        transformLayer = startingTreeLayer:transformToLayer(targetTreeLayer)
        if not transformLayer then corelog.Error("enterprise_forestry.UpgradeSite_ASrv: No tree transformLayer") return Callback.ErrorCall(callback) end
        local treeColOffset, treeRowOffset, treeBuildLayer = transformLayer:buildData()
        projectData.treeBuildLayer = treeBuildLayer

        projectData.upgradeLevelParameters = {
            level   = targetLevel,

            nTrees  = startingNTrees,
        }

        -- loop on current trees
        for iTree = 1, startingNTrees do
            -- get layer
            local buildLayer = treeBuildLayer
            local layerStr = "treeBuildLayer"
            local colOffset = treeColOffset
            local rowOffset = treeRowOffset
            if iTree == 1 then
                buildLayer = baseBuildLayer
                layerStr = "baseBuildLayer"
                colOffset = baseColOffset
                rowOffset = baseRowOffset
            end

            -- check layer needs update
            if buildLayer:getNRows() > 0 then
                -- add build tree step
                iStep = iStep + 1
                local iStepStr = tostring(iStep)
                local treeBaseLocation = forest:getBaseLocation():getRelativeLocation(colOffset + 0, rowOffset + 6 * (iTree - 1), 0)
                local treeBaseLocationStr = "treeBaseLocation"..iStepStr
                table.insert(projectSteps,
                    { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_construction", serviceName = "BuildLayer_ASrv" }, stepDataDef = {
                        { keyDef = "startpoint"                     , sourceStep = 0, sourceKeyDef = treeBaseLocationStr },
                        { keyDef = "buildFromAbove"                 , sourceStep = 0, sourceKeyDef = "buildFromAbove" },
                        { keyDef = "replacePresentObjects"          , sourceStep = 0, sourceKeyDef = "replacePresentObjects" },
                        { keyDef = "layer"                          , sourceStep = 0, sourceKeyDef = layerStr },
                        { keyDef = "materialsItemSupplierLocator"   , sourceStep = 0, sourceKeyDef = "materialsItemSupplierLocator" },
                        { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
                    }, description = "Building tree (Forest layer) at "..textutils.serialise(treeBaseLocation, { compact = true })}
                )

                -- add step data
                projectData[treeBaseLocationStr] = treeBaseLocation

                -- add success stepDataDef
                table.insert(areAllTrueStepDataDef, { keyDef = "success"..iStepStr, sourceStep = iStep, sourceKeyDef = "success" })
            end
        end

        -- update Forest info
        iStep = iStep + 1
        local iStepStr = tostring(iStep)
        table.insert(projectSteps,
            -- upgrade MObj
            { stepType = "LSOSrv", stepTypeDef = { serviceName = "upgradeMObj_SSrv", locatorStep = 0, locatorKeyDef = "hostLocator" }, stepDataDef = {
                { keyDef = "mobjLocator"                    , sourceStep = 0, sourceKeyDef = "mobjLocator" },
                { keyDef = "upgradeParameters"              , sourceStep = 0, sourceKeyDef = "upgradeLevelParameters" },
            }}
        )

        -- add success stepDataDef
        table.insert(areAllTrueStepDataDef, { keyDef = "success"..iStepStr, sourceStep = iStep, sourceKeyDef = "success" })
    end

    -- add project step for trees to add
    if startingNTrees < targetNTrees then
        -- loop on trees to add
        for iTree = startingNTrees + 1, targetNTrees do
            -- add build tree step
            iStep = iStep + 1
            local iStepStr = tostring(iStep)
            local treeBaseLocation = forest:getBaseLocation():getRelativeLocation(0, 6 * (iTree - 1), 0)
            local treeBaseLocationStr = "treeBaseLocation"..iStepStr
            table.insert(projectSteps,
                { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_construction", serviceName = "BuildLayer_ASrv" }, stepDataDef = {
                    { keyDef = "startpoint"                     , sourceStep = 0, sourceKeyDef = treeBaseLocationStr },
                    { keyDef = "buildFromAbove"                 , sourceStep = 0, sourceKeyDef = "buildFromAbove" },
                    { keyDef = "replacePresentObjects"          , sourceStep = 0, sourceKeyDef = "replacePresentObjects" },
                    { keyDef = "layer"                          , sourceStep = 0, sourceKeyDef = "treeLayer" },
                    { keyDef = "materialsItemSupplierLocator"   , sourceStep = 0, sourceKeyDef = "materialsItemSupplierLocator" },
                    { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
                }, description = "Building tree (Forest layer) at "..textutils.serialise(treeBaseLocation, { compact = true })}
            )

            -- add step data
            projectData[treeBaseLocationStr] = treeBaseLocation

            -- add success stepDataDef
            table.insert(areAllTrueStepDataDef, { keyDef = "success"..iStepStr, sourceStep = iStep, sourceKeyDef = "success" })

            -- update Forest info
            iStep = iStep + 1
            iStepStr = tostring(iStep)
            local upgradeLevelParametersStr = "upgradeLevelParametersStep"..iStepStr
            table.insert(projectSteps,
                -- upgrade MObj
                { stepType = "LSOSrv", stepTypeDef = { serviceName = "upgradeMObj_SSrv", locatorStep = 0, locatorKeyDef = "hostLocator" }, stepDataDef = {
                    { keyDef = "mobjLocator"                    , sourceStep = 0, sourceKeyDef = "mobjLocator" },
                    { keyDef = "upgradeParameters"              , sourceStep = 0, sourceKeyDef = upgradeLevelParametersStr },
                }}
            )

            -- add step data
            projectData[upgradeLevelParametersStr] = {
                level   = targetLevel,

                nTrees  = iTree,
            }

            -- add success stepDataDef
            table.insert(areAllTrueStepDataDef, { keyDef = "success"..iStepStr, sourceStep = iStep, sourceKeyDef = "success" })
        end
    end

    -- create project service data
    local projectDef = {
        steps = projectSteps,
        returnData  = {
        }
    }
    local projectServiceData = {
        projectDef  = projectDef,
        projectData = projectData,
        projectMeta = { title = "Adding trees to the Forest", description = "More trees == more fun" },
    }

    -- start project
    corelog.WriteToLog(">Upgrading Forest "..mobjLocator:getURI().." from level "..startingLevel.." to "..targetLevel.." and from "..startingNTrees.." to "..targetNTrees.." trees")
    return enterprise_projects.StartProject_ASrv(projectServiceData, callback)
end

return enterprise_forestry
