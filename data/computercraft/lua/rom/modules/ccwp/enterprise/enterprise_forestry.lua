local Host = require "obj_host"

local enterprise_forestry = Host:new({
    _hostName   = "enterprise_forestry",
})

local coreutils = require "coreutils"
local corelog = require "corelog"

local Callback = require "obj_callback"
local TaskCall = require "obj_task_call"
local InputChecker = require "input_checker"

local role_forester = require "role_forester"

local BirchForest = require "mobj_birchforest"

local enterprise_projects = require "enterprise_projects"
local enterprise_turtle
local enterprise_construction = require "enterprise_construction"

--[[
    The forestry enterprise provides services for building and using forest production sites.
--]]

--                        _                           _   _               _
--                       (_)                         | | | |             | |
--    ___  ___ _ ____   ___  ___ ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \  __/ |   \ V /| | (_|  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/\___|_|    \_/ |_|\___\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

function enterprise_forestry.AddNewSite_ASrv(...)
    -- get & check input from description
    local checkSuccess, baseLocation, forestLevel, nTrees, materialsItemSupplierLocator, wasteItemDepotLocator, callback = InputChecker.Check([[
        This async public service builds a new forest site and ensures it's ready for use.

        Return value:
                                                - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                                - (table)
                success                         - (boolean) whether the service executed successfully
                forestLocator                   - (URL) locating the site

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

    -- create new BirchForest
    enterprise_turtle = enterprise_turtle or require "enterprise_turtle"
    local forest = BirchForest:new({
        _id                     = coreutils.NewId(),
        _level                  = forestLevel,

        _baseLocation           = baseLocation:copy(),
        _nTrees                 = 0,

        _localLogsLocator       = enterprise_turtle.GetAnyTurtleLocator(),
        _localSaplingsLocator   = enterprise_turtle.GetAnyTurtleLocator(),
    })

    -- save the BirchForest
    corelog.WriteToLog(">Adding forest "..forest:getId()..".")
    local forestLocator = enterprise_forestry:saveObject(forest)
    if not forestLocator then corelog.Error("enterprise_forestry.AddNewSite_ASrv: Failed adding BirchForest") return Callback.ErrorCall(callback) end

    -- create projectDef and projectData
    local projectData = {
        forestLocator               = forestLocator,
        forestLevel                 = forestLevel,
        nTrees                      = nTrees,
    }

    local projectSteps = { }
    if forestLevel == -1 then
        -- add build tree step
        table.insert(projectSteps,
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_assignmentboard", serviceName = "DoAssignment_ASrv" }, stepDataDef = {
                { keyDef = "metaData"                   , sourceStep = 0, sourceKeyDef = "plantFirstSaplingMetaData" },
                { keyDef = "taskCall"                   , sourceStep = 0, sourceKeyDef = "plantFirstSaplingTaskCall" },
            }}
        )

        -- add step data
        local firstTreeLocation         = baseLocation:getRelativeLocation(3, 2, 0)
        local plantFirstSaplingTaskData =  {
            startLocation               = firstTreeLocation:copy(),
        }
        projectData.plantFirstSaplingMetaData   = role_forester.PlantFirstSapling_MetaData(plantFirstSaplingTaskData)
        projectData.plantFirstSaplingTaskCall   = TaskCall:new({ _moduleName = "role_forester", _methodName = "PlantFirstSapling_Task", _data = plantFirstSaplingTaskData, })
    else
        -- add build tree step
        table.insert(projectSteps,
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_forestry", serviceName = "BuildForestTree_ASrv" }, stepDataDef = {
                { keyDef = "treeBaseLocation"               , sourceStep = 0, sourceKeyDef = "treeBaseLocation" },
                { keyDef = "treeLayer"                      , sourceStep = 0, sourceKeyDef = "treeLayer" },
                { keyDef = "materialsItemSupplierLocator"   , sourceStep = 0, sourceKeyDef = "materialsItemSupplierLocator" },
                { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
            }}
        )

        -- add step data
        local treeBaseLocation  = baseLocation:copy()
        local targetBaseLayer = forest:getBaseLayer(forestLevel)
        projectData.materialsItemSupplierLocator= materialsItemSupplierLocator
        projectData.wasteItemDepotLocator       = wasteItemDepotLocator
        projectData.treeBaseLocation            = treeBaseLocation
        projectData.treeLayer                   = targetBaseLayer
    end

    table.insert(projectSteps,
        { stepType = "SSrv", stepTypeDef = { moduleName = "enterprise_forestry", serviceName = "UpdateForest_SSrv" }, stepDataDef = {
            { keyDef = "forestLocator"              , sourceStep = 0, sourceKeyDef = "forestLocator" },
            { keyDef = "forestLevel"                , sourceStep = 0, sourceKeyDef = "forestLevel" },
            { keyDef = "nTrees"                     , sourceStep = 0, sourceKeyDef = "nTrees" },
        }}
    )
    local projectDef = {
        steps = projectSteps,
        returnData  = {
            { keyDef = "forestLocator"                  , sourceStep = 2, sourceKeyDef = "forestLocator" },
        }
    }
    local projectServiceData = {
        projectDef  = projectDef,
        projectData = projectData,
        projectMeta = { title = "New forest site", description = "More trees == more fun" },
    }

    -- start project
    return enterprise_projects.StartProject_ASrv(projectServiceData, callback)
end

function enterprise_forestry.UpgradeSite_ASrv(...)
    -- get & check input from description
    local checkSuccess, forestLocator, targetLevel, targetNTrees, materialsItemSupplierLocator, wasteItemDepotLocator, callback = InputChecker.Check([[
        This private async service upgrades a forest site from the current configuration (i.e. level, # trees, ...) to a new configuration.

        Note: downgrading a forest is not supported.

        Return value:
                                                - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                                - (table)
                success                         - (boolean) whether the service executed successfully

        Parameters:
            serviceData                         - (table) data about the service
                forestLocator                   + (URL) locating the forest
                targetLevel                     + (number) with forest level to upgrade to
                targetNTrees                    + (number) number of trees to upgrade forest to
                materialsItemSupplierLocator    + (URL) locating the host of the building materials
                wasteItemDepotLocator           + (URL) locating where waste material can be delivered
            callback                            + (Callback) to call once service is ready
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("enterprise_forestry.UpgradeSite_ASrv: Invalid input") return Callback.ErrorCall(callback) end

    -- get forest
    local forest = enterprise_forestry:getObject(forestLocator)
    if type(forest) ~="table" then corelog.Error("enterprise_forestry.UpgradeSite_ASrv: Failed retrieving forest = "..forestLocator:getURI()) return Callback.ErrorCall(callback) end

    -- check not downgrading
    local startingLevel = forest:getLevel()
    if startingLevel > targetLevel then corelog.Error("enterprise_forestry.UpgradeSite_ASrv: Downgrading forest level (from "..startingLevel.." to "..targetLevel..") not supported") return Callback.ErrorCall(callback) end

    -- determine projectSteps and projectData
    local projectSteps = { }
    local areAllTrueStepDataDef = {}
    local targetTreeLayer = forest:getTreeLayer(targetLevel)
    local projectData = {
        forestLocator               = forestLocator,
        targetLevel                 = targetLevel,
        treeLayer                   = targetTreeLayer,
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

        projectData.startingNTrees  = startingNTrees

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
                    { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_forestry", serviceName = "BuildForestTree_ASrv" }, stepDataDef = {
                        { keyDef = "treeBaseLocation"               , sourceStep = 0, sourceKeyDef = treeBaseLocationStr },
                        { keyDef = "treeLayer"                      , sourceStep = 0, sourceKeyDef = layerStr },
                        { keyDef = "materialsItemSupplierLocator"   , sourceStep = 0, sourceKeyDef = "materialsItemSupplierLocator" },
                        { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
                    }}
                )

                -- add step data
                projectData[treeBaseLocationStr] = treeBaseLocation

                -- add success stepDataDef
                table.insert(areAllTrueStepDataDef, { keyDef = "success"..iStepStr, sourceStep = iStep, sourceKeyDef = "success" })
            end
        end

        -- update forest info
        iStep = iStep + 1
        local iStepStr = tostring(iStep)
        table.insert(projectSteps,
            { stepType = "SSrv", stepTypeDef = { moduleName = "enterprise_forestry", serviceName = "UpdateForest_SSrv" }, stepDataDef = {
                { keyDef = "forestLocator"          , sourceStep = 0, sourceKeyDef = "forestLocator" },
                { keyDef = "forestLevel"            , sourceStep = 0, sourceKeyDef = "targetLevel" },
                { keyDef = "nTrees"                 , sourceStep = 0, sourceKeyDef = "startingNTrees" },
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
                { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_forestry", serviceName = "BuildForestTree_ASrv" }, stepDataDef = {
                    { keyDef = "treeBaseLocation"               , sourceStep = 0, sourceKeyDef = treeBaseLocationStr },
                    { keyDef = "treeLayer"                      , sourceStep = 0, sourceKeyDef = "treeLayer" },
                    { keyDef = "materialsItemSupplierLocator"   , sourceStep = 0, sourceKeyDef = "materialsItemSupplierLocator" },
                    { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
                }}
            )

            -- add step data
            projectData[treeBaseLocationStr] = treeBaseLocation

            -- add success stepDataDef
            table.insert(areAllTrueStepDataDef, { keyDef = "success"..iStepStr, sourceStep = iStep, sourceKeyDef = "success" })

            -- update forest info
            iStep = iStep + 1
            iStepStr = tostring(iStep)
            local newNTreesStr = "newNTreeStep"..iStepStr
            table.insert(projectSteps,
                { stepType = "SSrv", stepTypeDef = { moduleName = "enterprise_forestry", serviceName = "UpdateForest_SSrv" }, stepDataDef = {
                    { keyDef = "forestLocator"          , sourceStep = 0, sourceKeyDef = "forestLocator" },
                    { keyDef = "forestLevel"            , sourceStep = 0, sourceKeyDef = "targetLevel" },
                    { keyDef = "nTrees"                 , sourceStep = 0, sourceKeyDef = newNTreesStr },
                }}
            )

            -- add step data
            projectData[newNTreesStr] = iTree

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
        projectMeta = { title = "Adding trees to the forest", description = "More trees == more fun" },
    }

    -- start project
    corelog.WriteToLog(">Upgrading forest "..forestLocator:getURI().." from level "..startingLevel.." to "..targetLevel.." and from "..startingNTrees.." to "..targetNTrees.." trees")
    return enterprise_projects.StartProject_ASrv(projectServiceData, callback)
end

--    _       _                        _                       _                                _   _               _
--   (_)     | |                      | |                     (_)                              | | | |             | |
--    _ _ __ | |_ ___ _ __ _ __   __ _| |  ___  ___ _ ____   ___  ___ ___  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   | | '_ \| __/ _ \ '__| '_ \ / _` | | / __|/ _ \ '__\ \ / / |/ __/ _ \/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   | | | | | ||  __/ |  | | | | (_| | | \__ \  __/ |   \ V /| | (_|  __/\__ \ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_|_| |_|\__\___|_|  |_| |_|\__,_|_| |___/\___|_|    \_/ |_|\___\___||___/ |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

function enterprise_forestry.BuildForestTree_ASrv(...)
    -- get & check input from description
    local checkSuccess, treeBaseLocation, treeLayer, materialsItemSupplierLocator, wasteItemDepotLocator, callback = InputChecker.Check([[
        This private async service extends the forest with 1 tree

        Return value:
                                                - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                                - (table)
                success                         - (boolean) whether the service executed successfully

        Parameters:
            serviceData                         - (table) data about this service
                treeBaseLocation                + (Location) location of the base (lower left corner) of a forest tree (layer)
                treeLayer                       + (LayerRectangle) tree layer to build
                materialsItemSupplierLocator    + (URL) locating the host of the building materials
                wasteItemDepotLocator           + (URL) locating where waste material can be delivered
            callback                            + (Callback) to call once service is ready
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("enterprise_forestry.BuildForestTree_ASrv: Invalid input") return Callback.ErrorCall(callback) end

    -- let construction enterprise build the tree
    local buildData = {
        startpoint                  = treeBaseLocation:copy(),
        buildFromAbove              = true,
        replacePresentObjects       = false,
        layer                       = treeLayer,
        materialsItemSupplierLocator= materialsItemSupplierLocator,
        wasteItemDepotLocator       = wasteItemDepotLocator,
    }
    corelog.WriteToLog(">Building tree (forest layer) at "..textutils.serialise(buildData.startpoint, { compact = true }))
    return enterprise_construction.BuildLayer_ASrv(buildData, callback)
end

function enterprise_forestry.UpdateForest_SSrv(...)
    -- get & check input from description
    local checkSuccess, forestLocator, forestLevel, nTrees = InputChecker.Check([[
        This private sync service updates the forest information.

        Return value:
                                        - (table)
                success                 - (boolean) whether the service executed successfully
                forestLocator           - (URL) locating the forest

        Parameters:
            serviceData                 - (table) data about the service
                forestLocator           + (URL) locating the forest
                forestLevel             + (number) with forest level
                nTrees                  + (number) number of trees in the forest
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("enterprise_forestry.UpdateForest_SSrv: Invalid input") return {success = false} end

    -- get forest
    local forest = enterprise_forestry:getObject(forestLocator)
    if type(forest) ~="table" then corelog.Error("enterprise_forestry.UpdateForest_SSrv: Failed retrieving forest = "..forestLocator:getURI()) return {success = false} end

    -- set forest information
    forest:setLevel(forestLevel)
    forest:setNTrees(nTrees)

    -- save forest data
    forestLocator = enterprise_forestry:saveObject(forest)

    -- end
    corelog.WriteToLog(">Updated forest (level="..forestLevel..", nTrees="..nTrees..")")
    return {
        success         = true,
        forestLocator   = forestLocator,
    }
end

return enterprise_forestry