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

function enterprise_forestry:hostAndBuildMObj_ASrv(...)
    -- get & check input from description
    local checkSuccess, className, constructParameters, materialsItemSupplierLocator, wasteItemDepotLocator, callback = InputChecker.Check([[
        This async public service hosts and builds a new MObj. It consist of
            - hosting a new MObj
            - building the MObj in the world

        This method extends MObjHost:hostAndBuildMObj_ASrv by allowing building a -1 level BirchForest

        Return value:
                                                - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                                - (table)
                success                         - (boolean) whether the service executed successfully
                mobjLocator                     - (URL) locating the hosted and build MObj

        Parameters:
            serviceData                         - (table) data about this site
                className                       + (string, "") with the name of the class of the MObj
                constructParameters             + (table) parameters for constructing the MObj
                materialsItemSupplierLocator    + (URL) locating the host for building materials
                wasteItemDepotLocator           + (URL) locating where waste material can be delivered
            callback                            + (Callback) to call once service is ready
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("enterprise_forestry:hostAndBuildMObj_ASrv: Invalid input") return Callback.ErrorCall(callback) end

    -- check for special case: BirchForest level -1
    if className == "BirchForest" and constructParameters.level == -1 then
        -- special case
        corelog.WriteToLog("special case ...")

        -- construct new MObj
        local mobj = BirchForest:construct(constructParameters)
        if not mobj then corelog.Error("enterprise_forestry:hostAndBuildMObj_ASrv: Failed constructing "..className.." from constructParameters(="..textutils.serialise(constructParameters)..")") return Callback.ErrorCall(callback) end

        -- save the MObj
        local mobjLocator = enterprise_forestry:saveObject(mobj)
        if not mobjLocator then corelog.Error("enterprise_forestry:hostAndBuildMObj_ASrv: Failed saving "..className.." "..textutils.serialise(mobj)..")") return Callback.ErrorCall(callback) end

        -- create project
        local plantFirstSaplingTaskData =  {
            startLocation               = constructParameters.baseLocation:getRelativeLocation(3, 2, 0),
        }
        local projectData = {
            hostLocator                 = enterprise_forestry:getHostLocator(),

            mobjLocator                 = mobjLocator,

            plantFirstSaplingMetaData   = role_forester.PlantFirstSapling_MetaData(plantFirstSaplingTaskData),
            plantFirstSaplingTaskCall   = TaskCall:newInstance("role_forester", "PlantFirstSapling_Task", plantFirstSaplingTaskData),
        }
        local projectDef = {
            steps = {
                -- planting sapling
                { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_assignmentboard", serviceName = "DoAssignment_ASrv" }, stepDataDef = {
                    { keyDef = "metaData"                   , sourceStep = 0, sourceKeyDef = "plantFirstSaplingMetaData" },
                    { keyDef = "taskCall"                   , sourceStep = 0, sourceKeyDef = "plantFirstSaplingTaskCall" },
                }, description = "Planting sapling"}
            },
            returnData  = {
                { keyDef = "mobjLocator"                    , sourceStep = 0, sourceKeyDef = "mobjLocator" },
            }
        }
        local projectServiceData = {
            projectDef  = projectDef,
            projectData = projectData,
            projectMeta = { title = "New BirchForest level -1", description = "More trees == more fun" },
        }

        -- end
        return enterprise_projects.StartProject_ASrv(projectServiceData, callback)
    else
        -- normal case
        return MObjHost.hostAndBuildMObj_ASrv(self, table.unpack(arg))
    end
end

return enterprise_forestry
