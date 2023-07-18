local Host = require "obj_host"

local MObjHost = Host:new({
    _hostName   = "MObjHost",
})

local corelog = require "corelog"

local InputChecker = require "input_checker"
local Callback = require "obj_callback"
local ObjectFactory = require "object_factory"
local objectFactory = ObjectFactory:getInstance()

local IMObj = require "i_mobj"

local enterprise_projects = require "enterprise_projects"

--[[
    The MObjHost is a Host that hosts MObj objects and provides additional services on and with these MObj's.

    This class typically is used as a base class for enterprise classes.
--]]

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

function MObjHost:getClassName()
    return "MObjHost"
end

--                        _                           _   _               _
--                       (_)                         | | | |             | |
--    ___  ___ _ ____   ___  ___ ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \  __/ |   \ V /| | (_|  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/\___|_|    \_/ |_|\___\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

function MObjHost:addMObj_ASrv(...)
    -- get & check input from description
    local checkSuccess, className, constructParameters, materialsItemSupplierLocator, callback = InputChecker.Check([[
        This async public service add a new MObj and ensures it's ready for use. Adding consist of
            - registering a new MObj
            - building the MObj in the world
            - activating the MObj

        Return value:
                                                - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                                - (table)
                success                         - (boolean) whether the service executed successfully
                mobjLocator                     - (URL) locating the created MObj

        Parameters:
            serviceData                         - (table) data about this site
                className                       + (string, "") with the name of the class of the MObj
                constructParameters             + (table) parameters for constructing the MObj
                materialsItemSupplierLocator    + (URL) locating the host for building materials
            callback                            + (Callback) to call once service is ready
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("MObjHost:addMobj_ASrv: Invalid input") return Callback.ErrorCall(callback) end

    -- register new MObj
    local serviceResult = self:registerMObj_SSrv({ className = className, constructParameters = constructParameters})
    if not serviceResult or not serviceResult.success then corelog.Error("MObjHost:addMobj_ASrv: Failed registering a new "..className..".") return Callback.ErrorCall(callback) end

    -- get MObj
    local mobjLocator = serviceResult.mobjLocator
    local mobj = self:getObject(mobjLocator)
    if not mobj then corelog.Error("MObjHost:addMobj_ASrv: Failed obtaining "..mobjLocator:getURI()..".") return Callback.ErrorCall(callback) end

    -- get blueprint
    local buildLocation, blueprint = mobj:getBuildBlueprint()
    if not buildLocation or not blueprint then corelog.Error("MObjHost:addMobj_ASrv: Failed obtaining build blueprint for "..mobjLocator:getURI()..".") return Callback.ErrorCall(callback) end

    -- create project definition
    local projectData = {
        buildLocation               = buildLocation,
        blueprint                   = blueprint,
        materialsItemSupplierLocator= materialsItemSupplierLocator,

        mobjLocator                 = mobjLocator,
    }
    local projectDef = {
        steps   = {
            -- build MObj in the world
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_construction", serviceName = "BuildBlueprint_ASrv" }, stepDataDef = {
                { keyDef = "blueprintStartpoint"            , sourceStep = 0, sourceKeyDef = "buildLocation" },
                { keyDef = "blueprint"                      , sourceStep = 0, sourceKeyDef = "blueprint" },
                { keyDef = "materialsItemSupplierLocator"   , sourceStep = 0, sourceKeyDef = "materialsItemSupplierLocator" },
            }},
            -- activate MObj (& save)
            { stepType = "LSMtd", stepTypeDef = { methodName = "activate", locatorStep = 0, locatorKeyDef = "mobjLocator" }, stepDataDef = {
            }},
            { stepType = "SSrv", stepTypeDef = { moduleName = "enterprise_projects", serviceName = "AreAllTrue_QSrv" }, stepDataDef = {
                { keyDef = "success1"                       , sourceStep = 1, sourceKeyDef = "success" },
                { keyDef = "success2"                       , sourceStep = 2, sourceKeyDef = "success" },
            }},
        },
        returnData  = {
--            { keyDef = "success"                    , sourceStep = 3, sourceKeyDef = "success" },
            { keyDef = "mobjLocator"                , sourceStep = 0, sourceKeyDef = "mobjLocator" },
        }
    }
    local projectServiceData = {
        projectDef  = projectDef,
        projectData = projectData,
    }

    -- start project
    return enterprise_projects.StartProject_ASrv(projectServiceData, callback)
end

-- ToDo: does this have to be a service?
function MObjHost:registerMObj_SSrv(...)
    -- get & check input from description
    local checkSuccess, className, constructParameters = InputChecker.Check([[
        This sync public service registers a new MObj in the MObjHost. Registration consist of
            - construction of a new inactive MObj instance
            - saving the instance in the MObjHost.

        Note that the MObj is not physically build in the world.

        Return value:
                                    - (table)
                success             - (boolean) whether the service executed successfully
                mobjLocator         - (URL) locating the created MObj

        Parameters:
            serviceData             - (table) data about this service
                className           + (string, "") with the name of the class of the MObj
                constructParameters + (table) parameters for constructing the MObj
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("MObjHost:registerMObj_SSrv: Invalid input") return {success = false} end

    -- log
    corelog.WriteToLog(">Registering new "..className..".")

    -- get class
    local class = objectFactory:getClass(className)
    if not class then corelog.Error("MObjHost:registerMObj_SSrv: Class "..className.." not found in objectFactory") return {success = false} end
    if not IMObj.ImplementsInterface(class) then corelog.Error("MObjHost:registerMObj_SSrv: Class "..className.." does not (fully) implement IMObj interface") return {success = false} end

    -- construct new MObj
    local mobj = class:construct(constructParameters)
    if not mobj then corelog.Error("MObjHost:registerMObj_SSrv: Failed constructing "..className.." from constructParameters(="..textutils.serialise(constructParameters)..")") return {success = false} end

    -- save the MObj
    local mobjLocator = self:saveObject(mobj)
    if not mobjLocator then corelog.Error("MObjHost:registerMObj_SSrv: Failed saving "..className.." "..textutils.serialise(mobj)..")") return {success = false} end

    -- end
    local result = {
        success     = true,
        mobjLocator = mobjLocator,
    }
    return result
end

function MObjHost:removeMObj_ASrv(...)
    -- get & check input from description
    local checkSuccess, mobjLocator, materialsItemSupplierLocator, callback = InputChecker.Check([[
        This async public service removes a MObj. Removing consist of
            - deactivating the MObj (stop accepting new business)
            - waiting for running business to be completed
            - dismantle MObj in the world
            - delisting the MObj

        Return value:
                                                - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                                - (table)
                success                         - (boolean) whether the site was successfully stopped and dismantled.

        Parameters:
            serviceData                         - (table) data about this service
                mobjLocator                     + (URL) locating the MObj
                materialsItemSupplierLocator    + (URL) locating the host for dismantling materials
            callback                            + (Callback) to call once service is ready
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("MObjHost:removeMObj_ASrv: Invalid input") return Callback.ErrorCall(callback) end

    -- get MObj
    local mobj = Host.GetObject(mobjLocator)
    if not mobj or not IMObj.ImplementsInterface(mobj) then corelog.Error("MObjHost:removeMObj_ASrv: Failed obtaing a MObj from mobjLocator "..mobjLocator:getURI()) return Callback.ErrorCall(callback) end

    -- deactivate MObj (stops accepting business)
    local success = mobj:deactivate()
    if not success then corelog.Error("MObjHost:registerMObj_SSrv: Failed deactivating "..mobjLocator:getURI()) return Callback.ErrorCall(callback) end

    -- get blueprint
    local buildLocation, blueprint = mobj:getDismantleBlueprint()
    if not buildLocation or not blueprint then corelog.Error("MObjHost:addMobj_ASrv: Failed obtaining dismantle blueprint for "..mobjLocator:getURI()..".") return Callback.ErrorCall(callback) end

    -- create project definition
    local projectData = {
        buildLocation               = buildLocation,
        blueprint                   = blueprint,
        materialsItemSupplierLocator= materialsItemSupplierLocator,

--        mobjHost                    = self:copy(),
--        OR
        hostLocator                 = self:getHostLocator(),

        mobjLocator                 = mobjLocator,
    }
    local projectDef = {
        steps   = {
            -- complete running business
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "completeRunningBusiness_AOSrv", locatorStep = 0, locatorKeyDef = "mobjLocator" }, stepDataDef = {
            }},
            -- dismantle MObj in the world
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_construction", serviceName = "BuildBlueprint_ASrv" }, stepDataDef = {
                { keyDef = "blueprintStartpoint"            , sourceStep = 0, sourceKeyDef = "buildLocation" },
                { keyDef = "blueprint"                      , sourceStep = 0, sourceKeyDef = "blueprint" },
                { keyDef = "materialsItemSupplierLocator"   , sourceStep = 0, sourceKeyDef = "materialsItemSupplierLocator" },
            }},

            -- delist MObj
            -- ToDo: what is best way to do this?
--            { stepType = "SOSrv", stepTypeDef = { className = "MObjHost", serviceName = "delistMObj_SSrv", objStep = 0, objKeyDef = "mobjHost" }, stepDataDef = {
--                { keyDef = "mobjLocator"                    , sourceStep = 0, sourceKeyDef = "mobjLocator" },
--            }},
--            OR
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "delistMObj_SSrv", locatorStep = 0, locatorKeyDef = "hostLocator" }, stepDataDef = {
                { keyDef = "mobjLocator"                    , sourceStep = 0, sourceKeyDef = "mobjLocator" },
            }},

            { stepType = "SSrv", stepTypeDef = { moduleName = "enterprise_projects", serviceName = "AreAllTrue_QSrv" }, stepDataDef = {
                { keyDef = "success1"                       , sourceStep = 1, sourceKeyDef = "success" },
                { keyDef = "success2"                       , sourceStep = 2, sourceKeyDef = "success" },
            }},
        },
        returnData  = {
--            { keyDef = "success"                            , sourceStep = 3, sourceKeyDef = "success" },
        }
    }
    local projectServiceData = {
        projectDef  = projectDef,
        projectData = projectData,
    }

    -- start project
    return enterprise_projects.StartProject_ASrv(projectServiceData, callback)
end

function MObjHost:delistMObj_SSrv(...)
    -- get & check input from description
    local checkSuccess, mobjLocator = InputChecker.Check([[
        This async public service delists a MObj from the MObjHost. Delisting implies
            - destruction of an MObj instance
            - deleting the instance from the MObjHost.

        Note that the MObj is not physically removed from the world.

        Return value:
                                                - (table)
                success                         - (boolean) whether the service executed successfully

        Parameters:
            serviceData                         + (table) data about this service
                mobjLocator                     + (URL) locating the MObj
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("MObjHost:delistMObj_SSrv: Invalid input") return {success = false} end

    -- log
    corelog.WriteToLog(">Delisting "..mobjLocator:getURI())

    -- get MObj
    local mobj = Host.GetObject(mobjLocator)
    if not mobj or not IMObj.ImplementsInterface(mobj) then corelog.Error("MObjHost:delistMObj_SSrv: Failed obtaing a MObj from mobjLocator "..mobjLocator:getURI()) return {success = false} end

    -- destuct MObj
    local success = mobj:destruct()
    if not success then corelog.Error("MObjHost:registerMObj_SSrv: Failed destructing "..mobjLocator:getURI()) return {success = false} end

    -- remove MObj from MObjHost
    success = self:deleteResource(mobjLocator)
    if not success then corelog.Error("MObjHost:registerMObj_SSrv: Failed deleting "..mobjLocator:getURI()) return {success = false} end

    -- end
    return {success = success}
end

return MObjHost
