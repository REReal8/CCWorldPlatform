local t_storage = {}

local corelog = require "corelog"

local Callback = require "obj_callback"
local InputChecker = require "input_checker"

local Location = require "obj_location"

local enterprise_projects = require "enterprise_projects"

function t_storage.T_All()
    -- IObj methods

    -- service methods
--    t_storage.T_hostMObj_SSrv()
--    t_storage.T_releaseMObj_SSrv()
end

function t_storage.T_AllPhysical()
    -- IObj methods

    -- service methods
    enterprise_projects.StartProject_ASrv({ projectMeta = { title = "enterprise_storage ASrv Tests", description = "ASync enterprise_storage tests in sequence" }, projectData = { }, projectDef  = { steps = {
            { stepType = "ASrv", stepTypeDef = { moduleName = "t_storage", serviceName = "T_hostAndBuildMObj_ASrv_Silo" }, stepDataDef = {}},
            { stepType = "ASrv", stepTypeDef = { moduleName = "t_storage", serviceName = "T_dismantleAndReleaseMObj_ASrv_Silo" }, stepDataDef = {
                { keyDef = "mobjLocator"        , sourceStep = 1, sourceKeyDef = "mobjLocator" },
            }},
        }, returnData  = { }}, }, Callback.GetNewDummyCallBack())
end

--                        _                           _   _               _
--                       (_)                         | | | |             | |
--    ___  ___ _ ____   ___  ___ ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \  __/ |   \ V /| | (_|  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/\___|_|    \_/ |_|\___\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

local test_mobjHostName = "enterprise_storage"
local test_mobjClassName1 = "Silo"
local location1  = Location:new({_x= 12, _y= 12, _z= 1, _dx=0, _dy=1})
local test_mobjConstructParameters1 = {
    baseLocation    = location1,
    topChests       = 2,
    layers          = 2,
}

-- hostAndBuildMObj_ASrv
function t_storage.T_hostAndBuildMObj_ASrv_Silo(...)
    -- get & check input from description
    local checkSuccess, callback = InputChecker.Check([[
        This async method tests enterprise_storage:hostAndBuildMObj_ASrv service with a Silo.

        Return value:
                                                - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                                - (table)
                success                         - (boolean) whether the service executed successfully
                mobjLocator                     - (URL) locating the hosted and build MObj

        Parameters:
            serviceData                         - (table, {}) data about this site
            callback                            + (Callback, nil) to call once service is ready
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("t_storage.T_hostAndBuildMObj_ASrv_Silo: Invalid input") return Callback.ErrorCall(callback) end

    -- prepare test: ensure callback (needed when called directly)
    if not callback then callback = Callback:GetNewDummyCallBack() end

    -- test & cleanup
    return enterprise_projects.StartProject_ASrv({ projectMeta = { title = "Test enterprise_storage:hostAndBuildMObj_ASrv", description = "Testing enterprise_storage:hostAndBuildMObj_ASrv for a "..test_mobjClassName1 },
        projectData = {
            mobjHostName                = test_mobjHostName,
            className                   = test_mobjClassName1,
            constructParameters         = test_mobjConstructParameters1,
        },
        projectDef  = {
            steps = {
                -- test
                { stepType = "ASrv", stepTypeDef = { moduleName = "T_MObjHost", serviceName = "hostAndBuildMObj_ASrv_test_ASrv" }, stepDataDef = {
                    { keyDef = "mobjHostName"                   , sourceStep = 0, sourceKeyDef = "mobjHostName" },
                    { keyDef = "className"                      , sourceStep = 0, sourceKeyDef = "className" },
                    { keyDef = "constructParameters"            , sourceStep = 0, sourceKeyDef = "constructParameters" },
                }},
                -- cleanup test
                { stepType = "SSrv", stepTypeDef = { moduleName = "t_storage", serviceName = "hostAndBuildMObj_ASrv_Silo_cleanupTest_SSrv" }, stepDataDef = {
                    { keyDef = "mobjLocator"                        , sourceStep = 1, sourceKeyDef = "mobjLocator" },
                }},
            },
            returnData  = {
                { keyDef = "mobjLocator"                        , sourceStep = 1, sourceKeyDef = "mobjLocator" },
            }
        },
    }, callback)
end

local mobjLocator_Silo = nil

function t_storage.hostAndBuildMObj_ASrv_Silo_cleanupTest_SSrv(...)
    -- get & check input from description
    local checkSuccess, mobjLocator = InputChecker.Check([[
        This method does test cleanup actions.

        Return value:
                success                         - (boolean) whether the service executed successfully

        Parameters:
            serviceData                         - (table, {}) data about this site
                mobjLocator                     + (URL, nil) locating the MObj
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("t_storage.hostAndBuildMObj_ASrv_Silo_cleanupTest_SSrv: Invalid input") return {success = true} end

--    corelog.WriteToLog("hostAndBuildMObj_ASrv_Silo_cleanupTest_SSrv")

    -- cleanup test: remembering mobjLocator (for possible usage by T_dismantleAndReleaseMObj_ASrv_Silo)
    mobjLocator_Silo = mobjLocator

    -- end
    return {success = true}
end

-- dismantleAndReleaseMObj_ASrv
function t_storage.T_dismantleAndReleaseMObj_ASrv_Silo(...)
    -- get & check input from description
    local checkSuccess, mobjLocator, callback = InputChecker.Check([[
        This async method tests enterprise_storage:dismantleAndReleaseMObj_ASrv service with a Silo.

        Return value:
                                                - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                                - (table)
                success                         - (boolean) whether the service executed successfully

        Parameters:
            serviceData                         - (table, {}) data about this site
                mobjLocator                     + (URL, nil) locating the MObj
            callback                            + (Callback, nil) to call once service is ready
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("t_storage.T_dismantleAndReleaseMObj_ASrv_Silo: Invalid input") return Callback.ErrorCall(callback) end

    -- prepare test: ensure/ check mobjLocator
    if not mobjLocator then
        -- see if we locally remembered a mobjLocator from the T_hostAndBuildMObj_ASrv_Silo test
        if mobjLocator_Silo then
--            corelog.WriteToLog("Using previously stored "..mobjLocator:getURI())
            mobjLocator = mobjLocator_Silo
        else
            corelog.Error("t_storage.T_dismantleAndReleaseMObj_ASrv_Silo: No mobjLocator for the Silo to operate on") return Callback.ErrorCall(callback)
        end
    end

    -- prepare test: ensure callback (needed when called directly)
    if not callback then callback = Callback:GetNewDummyCallBack() end

    -- test & cleanup
    return enterprise_projects.StartProject_ASrv({ projectMeta = { title = "Test enterprise_storage:dismantleAndReleaseMObj_ASrv", description = "Testing enterprise_storage:dismantleAndReleaseMObj_ASrv for a "..test_mobjClassName1 },
        projectData = {
            mobjHostName                = test_mobjHostName,

            mobjLocator                 = mobjLocator,
        },
        projectDef  = {
            steps = {
                -- test
                { stepType = "ASrv", stepTypeDef = { moduleName = "T_MObjHost", serviceName = "dismantleAndReleaseMObj_ASrv_test_ASrv" }, stepDataDef = {
                    { keyDef = "mobjHostName"                   , sourceStep = 0, sourceKeyDef = "mobjHostName" },
                    { keyDef = "mobjLocator"                    , sourceStep = 0, sourceKeyDef = "mobjLocator" },
                }},
                -- cleanup test
                { stepType = "SSrv", stepTypeDef = { moduleName = "t_storage", serviceName = "dismantleAndReleaseMObj_ASrv_Silo_cleanupTest_SSrv" }, stepDataDef = {
                }},
            },
            returnData  = {
            }
        },
    }, callback)
end

function t_storage.dismantleAndReleaseMObj_ASrv_Silo_cleanupTest_SSrv(...)
--    corelog.WriteToLog("dismantleAndReleaseMObj_ASrv_Silo_cleanupTest_SSrv")

    -- cleanup test: stop remembering mobjLocator_Silo
    mobjLocator_Silo = nil

    -- end
    return {success = true}
end

return t_storage
