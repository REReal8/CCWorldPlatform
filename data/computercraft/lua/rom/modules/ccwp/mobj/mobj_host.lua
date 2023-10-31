-- define class
local Class = require "class"
local ObjHost = require "obj_host"
local MObjHost = Class.NewClass(ObjHost)

--[[
    The MObjHost is a ObjHost that hosts MObj objects and provides additional services on and with these MObj's.

    This class typically is used as a base class for enterprise classes.
--]]

local corelog = require "corelog"

local InputChecker = require "input_checker"
local Callback = require "obj_callback"
local ObjectFactory = require "object_factory"
local objectFactory = ObjectFactory:getInstance()

local IMObj = require "i_mobj"

local enterprise_projects = require "enterprise_projects"
local enterprise_administration = require "enterprise_administration"

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

-- note: currently enterprise is treated like a singleton, but by directly using the name of the module
-- ToDo: consider making changes to enterprise to
--          - explicitly make it a singleton (by construction with :newInstance(hostName) and using the singleton pattern)
--          - properly initialise it (by adding and implementing the _init method)
--          - adopt other classes to these changes
MObjHost._hostName   = "MObjHost"

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function MObjHost:getClassName()
    return "MObjHost"
end

--    __  __  ____  _     _ _    _           _
--   |  \/  |/ __ \| |   (_) |  | |         | |
--   | \  / | |  | | |__  _| |__| | ___  ___| |_
--   | |\/| | |  | | '_ \| |  __  |/ _ \/ __| __|
--   | |  | | |__| | |_) | | |  | | (_) \__ \ |_
--   |_|  |_|\____/|_.__/| |_|  |_|\___/|___/\__|
--                      _/ |
--                     |__/

function MObjHost:buildAndHostMObj_ASrv(...)
    -- get & check input from description
    local checkSuccess, className, constructParameters, materialsItemSupplierLocator, wasteItemDepotLocator, callback = InputChecker.Check([[
        This async public service builds and hosts a new MObj. It consist of
            - building a MObj in the world
            - hosting the new MObj

        Return value:
                                                - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                                - (table)
                success                         - (boolean) whether the service executed successfully
                mobjLocator                     - (URL) locating the build and hosted MObj

        Parameters:
            serviceData                         - (table) data about this service
                className                       + (string, "") with the name of the class of the MObj
                constructParameters             + (table) parameters for constructing the MObj
                materialsItemSupplierLocator    + (URL) locating the host for building materials
                wasteItemDepotLocator           + (URL) locating where waste material can be delivered
            callback                            + (Callback) to call once service is ready
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("MObjHost:buildAndHostMObj_ASrv: Invalid input") return Callback.ErrorCall(callback) end

    -- get class
    local class = objectFactory:getClass(className)
    if not class then corelog.Error("MObjHost:buildAndHostMObj_ASrv: Class "..className.." not found in objectFactory") return Callback.ErrorCall(callback) end
    if not Class.IsInstanceOf(class, IMObj) then corelog.Error("MObjHost:buildAndHostMObj_ASrv: Class "..className.." is not an IMObj") return Callback.ErrorCall(callback) end

    -- get blueprint
    local buildLocation, blueprint = class.GetBuildBlueprint(constructParameters)
    if not buildLocation or not blueprint then corelog.Error("MObjHost:buildAndHostMObj_ASrv: Failed obtaining build blueprint for a new "..className..".") return Callback.ErrorCall(callback) end

    -- create project definition
    local projectData = {
        buildLocation               = buildLocation,
        blueprint                   = blueprint,
        materialsItemSupplierLocator= materialsItemSupplierLocator,
        wasteItemDepotLocator       = wasteItemDepotLocator,

        hostLocator                 = self:getHostLocator(),

        className                   = className,
        constructParameters         = constructParameters,
    }
    local projectDef = {
        steps   = {
            -- build MObj in the world
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_construction", serviceName = "BuildBlueprint_ASrv" }, stepDataDef = {
                { keyDef = "blueprintStartpoint"            , sourceStep = 0, sourceKeyDef = "buildLocation" },
                { keyDef = "blueprint"                      , sourceStep = 0, sourceKeyDef = "blueprint" },
                { keyDef = "materialsItemSupplierLocator"   , sourceStep = 0, sourceKeyDef = "materialsItemSupplierLocator" },
                { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
            }, description = "Building "..className},
            -- host MObj
            { stepType = "LSOSrv", stepTypeDef = { serviceName = "hostMObj_SSrv", locatorStep = 0, locatorKeyDef = "hostLocator" }, stepDataDef = {
                { keyDef = "className"                      , sourceStep = 0, sourceKeyDef = "className" },
                { keyDef = "constructParameters"            , sourceStep = 0, sourceKeyDef = "constructParameters" },
            }, description = "Hosting "..className},
        },
        returnData  = {
            { keyDef = "mobjLocator"                        , sourceStep = 2, sourceKeyDef = "mobjLocator" },
        }
    }
    local projectServiceData = {
        projectDef  = projectDef,
        projectData = projectData,
        projectMeta = { title = "Adding a new mobj", description = "Just wondering which one, aren't you?" },
    }

    -- start project
    return enterprise_projects.StartProject_ASrv(projectServiceData, callback)
end

function MObjHost:hostMObj_SSrv(...)
    -- get & check input from description
    local checkSuccess, className, constructParameters = InputChecker.Check([[
        This sync public service hosts a new MObj in the MObjHost. Hosting consist of
            - construction of a new MObj instance
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
    if not checkSuccess then corelog.Error("MObjHost:hostMObj_SSrv: Invalid input") return {success = false} end

    -- get class
    local class = objectFactory:getClass(className)
    if not class then corelog.Error("MObjHost:hostMObj_SSrv: Class "..className.." not found in objectFactory") return {success = false} end
    if not Class.IsInstanceOf(class, IMObj) then corelog.Error("MObjHost:hostMObj_SSrv: Class "..className.." is not an IMObj") return {success = false} end

    -- construct new MObj
    local mobj = class:construct(constructParameters)
    if not mobj then corelog.Error("MObjHost:hostMObj_SSrv: Failed constructing "..className.." from constructParameters(="..textutils.serialise(constructParameters)..")") return {success = false} end

    -- save the MObj
    local mobjLocator = self:saveObject(mobj)
    if not mobjLocator then corelog.Error("MObjHost:hostMObj_SSrv: Failed saving "..className.." "..textutils.serialise(mobj)..")") return {success = false} end

    -- log
    corelog.WriteToLog(">Hosting new "..className.." "..mobj:getId()..".")

    -- end
    local result = {
        success     = true,
        mobjLocator = mobjLocator,
    }
    return result
end

function MObjHost:upgradeMObj_SSrv(...)
    -- get & check input from description
    local checkSuccess, mobjLocator, upgradeParameters = InputChecker.Check([[
        This async public service upgrades a MObj in the MObjHost.

        Note that downgrading is not supported as it implies stopping running businesss etc.

        Note that the MObj is not physically extended in the world. If this is also required extendAndUpgradeMObj_ASrv should be called.

        Return value:
                                                - (table)
                success                         - (boolean) whether the service executed successfully

        Parameters:
            serviceData                         - (table) data about this service
                mobjLocator                     + (URL) locating the MObj
                upgradeParameters               + (table) parameters for upgrading the MObj
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("MObjHost:upgradeMObj_SSrv: Invalid input") return {success = false} end

    -- log
    corelog.WriteToLog(">Upgrading "..mobjLocator:getURI().." with "..textutils.serialise(upgradeParameters, {compact = true}))

    -- get MObj
    local mobj = ObjHost.GetObject(mobjLocator)
    if not mobj or not Class.IsInstanceOf(mobj, IMObj) then corelog.Error("MObjHost:upgradeMObj_SSrv: Failed obtaining an IMObj from mobjLocator "..mobjLocator:getURI()) return {success = false} end
    if not mobj.upgrade then corelog.Error("MObjHost:upgradeMObj_SSrv: MObj "..mobjLocator:getURI().." does not have upgrade method (yet)") return {success = false} end
    -- ToDo: consider if we want to make upgrade a mandatory method of IMObj

    -- upgrade MObj
    local success = mobj:upgrade(upgradeParameters)
    if not success then corelog.Error("MObjHost:upgradeMObj_SSrv: Failed upgrading "..mobjLocator:getURI().." from upgradeParameters(="..textutils.serialise(upgradeParameters)..")") return {success = false} end

    -- save the MObj
    mobjLocator = self:saveObject(mobj)
    if not mobjLocator then corelog.Error("MObjHost:upgradeMObj_SSrv: Failed saving "..textutils.serialise(mobj)..")") return {success = false} end

    -- end
    return {success = success}
end

function MObjHost:extendAndUpgradeMObj_ASrv(...)
    -- get & check input from description
    local checkSuccess, mobjLocator, upgradeParameters, materialsItemSupplierLocator, wasteItemDepotLocator, callback = InputChecker.Check([[
        This async public service extends and upgrades a MObj. It consists of
            - extending the MObj in the world
            - upgrading the MObj

        This service assumes extending the MObj will not interfere with any running business in the MObj.

        Return value:
                                                - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                                - (table)
                success                         - (boolean) whether the service executed successfully

        Parameters:
            serviceData                         - (table) data about this service
                mobjLocator                     + (URL) locating the MObj
                upgradeParameters               + (table) parameters for upgrading the MObj
                materialsItemSupplierLocator    + (URL) locating the host for dismantling materials
                wasteItemDepotLocator           + (URL) locating where waste material can be delivered
            callback                            + (Callback) to call once service is ready
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("MObjHost:extendAndUpgradeMObj_ASrv: Invalid input") return Callback.ErrorCall(callback) end

    -- get MObj
    local mobj = ObjHost.GetObject(mobjLocator)
    if not mobj or not Class.IsInstanceOf(mobj, IMObj) then corelog.Error("MObjHost:extendAndUpgradeMObj_ASrv: Failed obtaining an IMObj from mobjLocator "..mobjLocator:getURI()) return Callback.ErrorCall(callback) end
    if not mobj.getExtendBlueprint then corelog.Error("MObjHost:extendAndUpgradeMObj_ASrv: MObj "..mobjLocator:getURI().." does not have getExtendBlueprint method (yet)") return {success = false} end
    -- ToDo: consider if we want to make getExtendBlueprint a mandatory method of IMObj

    -- get blueprint
    local buildLocation, blueprint = mobj:getExtendBlueprint(upgradeParameters)
    if not buildLocation or not blueprint then corelog.Error("MObjHost:extendAndUpgradeMObj_ASrv: Failed obtaining extend blueprint for "..mobjLocator:getURI().." with upgradeParameters(="..textutils.serialise(upgradeParameters)..")") return Callback.ErrorCall(callback) end

    -- create project definition
    local projectData = {
        buildLocation               = buildLocation,
        blueprint                   = blueprint,
        materialsItemSupplierLocator= materialsItemSupplierLocator,
        wasteItemDepotLocator       = wasteItemDepotLocator,

        hostLocator                 = self:getHostLocator(),

        mobjLocator                 = mobjLocator,
        upgradeParameters           = upgradeParameters,
    }
    local projectDef = {
        steps   = {
            -- extend MObj in the world
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_construction", serviceName = "BuildBlueprint_ASrv" }, stepDataDef = {
                { keyDef = "blueprintStartpoint"            , sourceStep = 0, sourceKeyDef = "buildLocation" },
                { keyDef = "blueprint"                      , sourceStep = 0, sourceKeyDef = "blueprint" },
                { keyDef = "materialsItemSupplierLocator"   , sourceStep = 0, sourceKeyDef = "materialsItemSupplierLocator" },
                { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
            }},
            -- upgrade MObj
            { stepType = "LSOSrv", stepTypeDef = { serviceName = "upgradeMObj_SSrv", locatorStep = 0, locatorKeyDef = "hostLocator" }, stepDataDef = {
                { keyDef = "mobjLocator"                    , sourceStep = 0, sourceKeyDef = "mobjLocator" },
                { keyDef = "upgradeParameters"              , sourceStep = 0, sourceKeyDef = "upgradeParameters" },
            }},
        },
        returnData  = {
        }
    }
    local projectServiceData = {
        projectDef  = projectDef,
        projectData = projectData,
        projectMeta = { title = "extend and upgrade MObj", description = "extend and upgrade "..mobjLocator:getURI().." with upgradeParameters(="..textutils.serialise(upgradeParameters)..")"},
    }

    -- start project
    return enterprise_projects.StartProject_ASrv(projectServiceData, callback)
end

function MObjHost:dismantleAndReleaseMObj_ASrv(...)
    -- get & check input from description
    local checkSuccess, mobjLocator, materialsItemSupplierLocator, wasteItemDepotLocator, callback = InputChecker.Check([[
        This async public service dismantles and releases a MObj. It consists of
            - waiting for running business to be completed
            - dismantling the MObj in the world
            - releasing the MObj

        This service assumes the MObj will not get any new business, i.e. it was already delisted for users of the MObj.

        Return value:
                                                - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                                - (table)
                success                         - (boolean) whether the service executed successfully

        Parameters:
            serviceData                         - (table) data about this service
                mobjLocator                     + (URL) locating the MObj
                materialsItemSupplierLocator    + (URL) locating the host for dismantling materials
                wasteItemDepotLocator           + (URL) locating where waste material can be delivered
            callback                            + (Callback) to call once service is ready
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("MObjHost:dismantleAndReleaseMObj_ASrv: Invalid input") return Callback.ErrorCall(callback) end

    -- get MObj
    local mobj = ObjHost.GetObject(mobjLocator)
    if not mobj or not Class.IsInstanceOf(mobj, IMObj) then corelog.Error("MObjHost:dismantleAndReleaseMObj_ASrv: Failed obtaining an IMObj from mobjLocator "..mobjLocator:getURI()) return Callback.ErrorCall(callback) end

    -- get blueprint
    local buildLocation, blueprint = mobj:getDismantleBlueprint()
    if not buildLocation or not blueprint then corelog.Error("MObjHost:dismantleAndReleaseMObj_ASrv: Failed obtaining dismantle blueprint for "..mobjLocator:getURI()..".") return Callback.ErrorCall(callback) end

    -- create project definition
    local projectData = {
        buildLocation               = buildLocation,
        blueprint                   = blueprint,
        materialsItemSupplierLocator= materialsItemSupplierLocator,
        wasteItemDepotLocator       = wasteItemDepotLocator,

        hostLocator                 = self:getHostLocator(),

        mobjLocator                 = mobjLocator,
        mobjWIPId                   = mobj:getWIPId(),

        wipAdministratorLocator     = enterprise_administration:getWIPAdministratorLocator(),
    }
    local projectDef = {
        steps   = {
            -- complete running business
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "waitForNoWIPOnQueue_AOSrv", locatorStep = 0, locatorKeyDef = "wipAdministratorLocator" }, stepDataDef = {
                { keyDef = "queueId"                        , sourceStep = 0, sourceKeyDef = "mobjWIPId" },
            }},
            -- dismantle MObj in the world
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_construction", serviceName = "BuildBlueprint_ASrv" }, stepDataDef = {
                { keyDef = "blueprintStartpoint"            , sourceStep = 0, sourceKeyDef = "buildLocation" },
                { keyDef = "blueprint"                      , sourceStep = 0, sourceKeyDef = "blueprint" },
                { keyDef = "materialsItemSupplierLocator"   , sourceStep = 0, sourceKeyDef = "materialsItemSupplierLocator" },
                { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
            }},
            -- release MObj
            { stepType = "LSOSrv", stepTypeDef = { serviceName = "releaseMObj_SSrv", locatorStep = 0, locatorKeyDef = "hostLocator" }, stepDataDef = {
                { keyDef = "mobjLocator"                    , sourceStep = 0, sourceKeyDef = "mobjLocator" },
            }},
        },
        returnData  = {
        }
    }
    local projectServiceData = {
        projectDef  = projectDef,
        projectData = projectData,
        projectMeta = { title = "dismantle and release MObj", description = "Word goes we fully want to remove it" },
    }

    -- start project
    return enterprise_projects.StartProject_ASrv(projectServiceData, callback)
end

function MObjHost:releaseMObj_SSrv(...)
    -- get & check input from description
    local checkSuccess, mobjLocator = InputChecker.Check([[
        This async public service releases a MObj from the MObjHost. Releasing implies
            - destruction of an MObj instance
            - deleting the instance from the MObjHost.

        Note that the MObj is not physically removed from the world.

        Return value:
                                                - (table)
                success                         - (boolean) whether the service executed successfully

        Parameters:
            serviceData                         - (table) data about this service
                mobjLocator                     + (URL) locating the MObj
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("MObjHost:releaseMObj_SSrv: Invalid input") return {success = false} end

    -- log
    corelog.WriteToLog(">Releasing "..mobjLocator:getURI())

    -- get MObj
    local mobj = ObjHost.GetObject(mobjLocator)
    if not mobj or not Class.IsInstanceOf(mobj, IMObj) then corelog.Error("MObjHost:releaseMObj_SSrv: Failed obtaining an IMObj from mobjLocator "..mobjLocator:getURI()) return {success = false} end

    -- destuct MObj
    local success = mobj:destruct()
    if not success then corelog.Error("MObjHost:releaseMObj_SSrv: Failed destructing "..mobjLocator:getURI()) return {success = false} end

    -- remove MObj from MObjHost
    success = self:deleteResource(mobjLocator)
    if not success then corelog.Error("MObjHost:releaseMObj_SSrv: Failed deleting "..mobjLocator:getURI()) return {success = false} end

    -- end
    return {success = success}
end

return MObjHost
