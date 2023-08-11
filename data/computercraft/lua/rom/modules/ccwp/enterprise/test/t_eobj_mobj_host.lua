local T_MObjHost = {}

local corelog = require "corelog"

local Callback = require "obj_callback"
local ModuleRegistry = require "module_registry"
local moduleRegistry = ModuleRegistry:getInstance()
local InputChecker = require "input_checker"

local URL = require "obj_url"
local Location = require "obj_location"

local MObjHost = require "eobj_mobj_host"
local enterprise_projects = require "enterprise_projects"

local t_turtle = require "test.t_turtle"

function T_MObjHost.T_All()
    -- IObj methods
    T_MObjHost.T_new()

    -- service methods
    T_MObjHost.T_hostMObj_SSrv()
    T_MObjHost.T_releaseMObj_SSrv()
end

function T_MObjHost.T_AllPhysical()
    -- IObj methods

    -- service methods
    enterprise_projects.StartProject_ASrv({ projectMeta = { title = "MObjHost ASrv Tests", description = "ASync MObjHost tests in sequence" }, projectData = { }, projectDef  = { steps = {
            { stepType = "ASrv", stepTypeDef = { moduleName = "T_MObjHost", serviceName = "T_hostAndBuildMObj_ASrv_TestMObj" }, stepDataDef = {}},
            { stepType = "ASrv", stepTypeDef = { moduleName = "T_MObjHost", serviceName = "T_dismantleAndReleaseMObj_ASrv_TestMObj" }, stepDataDef = {
                { keyDef = "mobjLocator"        , sourceStep = 1, sourceKeyDef = "mobjLocator" },
            }},
        }, returnData  = { }}, }, Callback.GetNewDummyCallBack())
end

local test_mobjHostName1 = "TestMObjHost"
local test_mobjHost1 = MObjHost:new({
    _hostName   = test_mobjHostName1,
})

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

function T_MObjHost.T_new()
    -- prepare test
    corelog.WriteToLog("* MObjHost:new() tests")

    -- test full
    local host = MObjHost:new({
        _hostName   = test_mobjHostName1,
    })
    assert(host:getHostName() == test_mobjHostName1, "gotten getHostName(="..host:getHostName()..") not the same as expected(="..test_mobjHostName1..")")

    -- cleanup test
end

--                        _                           _   _               _
--                       (_)                         | | | |             | |
--    ___  ___ _ ____   ___  ___ ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \  __/ |   \ V /| | (_|  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/\___|_|    \_/ |_|\___\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

local test_mobjClassName1 = "TestMObj"
local location1 = Location:new({_x= -12, _y= 0, _z= 1, _dx=0, _dy=1})
local field1SetValue = "value field1"
local test_mobjConstructParameters1 = {
    baseLocation    = location1,
    field1Value     = field1SetValue,
}

-- hostMObj_SSrv
function T_MObjHost.T_hostMObj_SSrv()
    -- prepare test
    corelog.WriteToLog("* MObjHost:hostMObj_SSrv() tests")

    -- test
    local serviceResults = test_mobjHost1:hostMObj_SSrv({
        className           = test_mobjClassName1,
        constructParameters = test_mobjConstructParameters1,
    })

    -- check hosting success
    assert(serviceResults and serviceResults.success, "failed hosting MObj")

    -- check mobjLocator returned
    local mobjLocator = serviceResults.mobjLocator
    assert(URL:isTypeOf(mobjLocator), "incorrect mobjLocator returned")

    -- check mobj saved
    local mobj = test_mobjHost1:getObject(mobjLocator)
    assert(mobj, "MObj not in host")

    -- check mobj constructed
    local field1Value = mobj:getField1()
    assert(field1Value == field1SetValue, "construct did not set _field1")

    -- check child MObj's hosted
    -- ToDo: consider implementing testing this. Or shouldn't we as it's a choice to have and responsibilty of the MObj to do this?

    -- cleanup test
    test_mobjHost1:deleteObjects("TestMObj")
end

-- hostAndBuildMObj_ASrv
function T_MObjHost.hostAndBuildMObj_ASrv_test_ASrv(...)
    -- get & check input from description
    local checkSuccess, mobjHostName, className, constructParameters, callback = InputChecker.Check([[
        This async method tests the hostAndBuildMObj_ASrv service of a specific MObjHost for hosting and building a specific MObj.

        Return value:
                                                - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                                - (table)
                success                         - (boolean) whether the service executed successfully
                mobjLocator                     - (URL) locating the hosted and build MObj

        Parameters:
            serviceData                         - (table) data about this site
                mobjHostName                    + (string) with the name of the MObjHost of the MObj
                className                       + (string) with the name of the class of the MObj
                constructParameters             + (table) parameters for constructing the MObj
            callback                            + (Callback) to call once service is ready
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("T_MObjHost.hostAndBuildMObj_ASrv_test_ASrv: Invalid input") return Callback.ErrorCall(callback) end

    -- prepare test
    corelog.WriteToLog("* "..mobjHostName..":hostAndBuildMObj_ASrv() tests (with a "..className..")")
    local mobjHost = moduleRegistry:getModule(mobjHostName)
    if not mobjHost then corelog.Error("host "..mobjHostName.." not registered") return Callback.ErrorCall(callback) end

    -- test
    return enterprise_projects.StartProject_ASrv({ projectMeta = { title = "Test hostAndBuildMObj_ASrv", description = "Testing "..mobjHostName..":hostAndBuildMObj_ASrv for a "..className },
        projectData = {
            mobjHostName                = mobjHostName,
            mobjHostLocator             = mobjHost:getHostLocator(),

            className                   = className,
            constructParameters         = constructParameters,
            materialsItemSupplierLocator= t_turtle.GetCurrentTurtleLocator(),
            wasteItemDepotLocator       = t_turtle.GetCurrentTurtleLocator(),
        },
        projectDef  = {
            steps = {
                -- test: call method to test
                { stepType = "LAOSrv", stepTypeDef = { serviceName = "hostAndBuildMObj_ASrv", locatorStep = 0, locatorKeyDef = "mobjHostLocator" }, stepDataDef = {
                    { keyDef = "className"                      , sourceStep = 0, sourceKeyDef = "className" },
                    { keyDef = "constructParameters"            , sourceStep = 0, sourceKeyDef = "constructParameters" },
                    { keyDef = "materialsItemSupplierLocator"   , sourceStep = 0, sourceKeyDef = "materialsItemSupplierLocator" },
                    { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
                }},
                -- test: check results
                { stepType = "SSrv", stepTypeDef = { moduleName = "T_MObjHost", serviceName = "hostAndBuildMObj_ASrv_checkResults_SSrv" }, stepDataDef = {
                    { keyDef = "mobjHostName"                   , sourceStep = 0, sourceKeyDef = "mobjHostName" },
                    { keyDef = "mobjLocator"                    , sourceStep = 1, sourceKeyDef = "mobjLocator" },
                }},
            },
            returnData  = {
                { keyDef = "mobjLocator"                        , sourceStep = 1, sourceKeyDef = "mobjLocator" },
            }
        },
    }, callback)
end

function T_MObjHost.hostAndBuildMObj_ASrv_checkResults_SSrv(...)
    -- get & check input from description
    local checkSuccess, mobjHostName, mobjLocator = InputChecker.Check([[
        This method checks the results of a hostAndBuildMObj_ASrv service test call for a specific MObjHost, MObj combination.

        Return value:
                success                         - (boolean) whether the service executed successfully

        Parameters:
            serviceData                         - (table) data about this site
                mobjHostName                    + (string) with the name of the MObjHost of the MObj
                mobjLocator                     + (URL) locating the hosted and build MObj
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("T_MObjHost.hostAndBuildMObj_ASrv_checkResults_SSrv: Invalid input") return { success = false } end

    -- check expected MObjHost
    local mobjHost = MObjHost.GetHost(mobjLocator:getHost()) if not mobjHost then corelog.Error("MObjHost of mobjLocator(="..mobjLocator:getURI()..") not present") return { success = false } end
    if mobjHost:getHostName() ~= mobjHostName then corelog.Error("MObjHost name(="..mobjHost:getHostName()..") not the same as expected(="..mobjHostName..")") return { success = false } end

    -- check mobj hosted on MObjHost (full check done in T_hostMObj_SSrv)
    local mobj = mobjHost:getObject(mobjLocator)
    if not mobj then corelog.Error("MObj(="..mobjLocator:getURI()..") not hosted by "..mobjHost:getHostName()) return { success = false } end

    -- check build blueprint build
    -- ToDo: add mock test

    -- cleanup test

    -- end
    return {success = true}
end

function T_MObjHost.T_hostAndBuildMObj_ASrv_TestMObj(...)
    -- get & check input from description
    local checkSuccess, callback = InputChecker.Check([[
        This async method tests MObjHost:hostAndBuildMObj_ASrv service with a TestMObj.

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
    if not checkSuccess then corelog.Error("T_MObjHost.T_hostAndBuildMObj_ASrv_TestMObj: Invalid input") return Callback.ErrorCall(callback) end

    -- prepare test: register test host
    moduleRegistry:registerModule(test_mobjHostName1, test_mobjHost1)

    -- prepare test: ensure callback (needed when called directly)
    if not callback then callback = Callback:GetNewDummyCallBack() end

    -- test & cleanup
    return enterprise_projects.StartProject_ASrv({ projectMeta = { title = "Test MObjHost:hostAndBuildMObj_ASrv", description = "Testing MObjHost:hostAndBuildMObj_ASrv for a "..test_mobjClassName1 },
        projectData = {
            mobjHostName                = test_mobjHostName1,
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
                { stepType = "SSrv", stepTypeDef = { moduleName = "T_MObjHost", serviceName = "hostAndBuildMObj_ASrv_TestMObj_cleanupTest_SSrv" }, stepDataDef = {
                    { keyDef = "mobjLocator"                        , sourceStep = 1, sourceKeyDef = "mobjLocator" },
                }},
            },
            returnData  = {
                { keyDef = "mobjLocator"                        , sourceStep = 1, sourceKeyDef = "mobjLocator" },
            }
        },
    }, callback)
end

local mobjLocator_TestMObj = nil

function T_MObjHost.hostAndBuildMObj_ASrv_TestMObj_cleanupTest_SSrv(...)
    -- get & check input from description
    local checkSuccess, mobjLocator = InputChecker.Check([[
        This method does test cleanup actions.

        Return value:
                success                         - (boolean) whether the service executed successfully

        Parameters:
            serviceData                         - (table, {}) data about this site
                mobjLocator                     + (URL, nil) locating the MObj
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("T_MObjHost.hostAndBuildMObj_ASrv_TestMObj_cleanupTest_SSrv: Invalid input") return {success = true} end

--    corelog.WriteToLog("hostAndBuildMObj_ASrv_TestMObj_cleanupTest_SSrv")

    -- cleanup test: delist test host
    moduleRegistry:delistModule(test_mobjHostName1)

    -- cleanup test: remembering mobjLocator (for possible usage by T_dismantleAndReleaseMObj_ASrv_TestMObj)
    mobjLocator_TestMObj = mobjLocator

    -- end
    return {success = true}
end

-- releaseMObj_SSrv
function T_MObjHost.T_releaseMObj_SSrv()
    -- prepare test
    corelog.WriteToLog("* MObjHost:releaseMObj_SSrv() tests")
    moduleRegistry:registerModule(test_mobjHostName1, test_mobjHost1)
    local serviceResults = test_mobjHost1:hostMObj_SSrv({
        className           = test_mobjClassName1,
        constructParameters = test_mobjConstructParameters1,
    })
    local mobjLocator = URL:new(serviceResults.mobjLocator)

    -- test
    serviceResults = test_mobjHost1:releaseMObj_SSrv({
        mobjLocator         = mobjLocator,
    })

    -- check releasing success
    assert(serviceResults and serviceResults.success, "failed releasing MObj")

    -- check mobj deleted
    local mobjResourceTable = test_mobjHost1:getResource(mobjLocator)
    assert(not mobjResourceTable, "MObj not deleted")

    -- check child MObj's released
    -- ToDo: consider implementing testing this. Or shouldn't we as it's a responsibilty of the MObj to do this?

    -- cleanup test
    moduleRegistry:delistModule(test_mobjHostName1)
end

-- dismantleAndReleaseMObj_ASrv
function T_MObjHost.dismantleAndReleaseMObj_ASrv_test_ASrv(...)
    -- get & check input from description
    local checkSuccess, mobjHostName, mobjLocator, callback = InputChecker.Check([[
        This async method tests the dismantleAndReleaseMObj_ASrv service of a specific MObjHost for dismantling and releasing a specific MObj.

        Return value:
                                                - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                                - (table)
                success                         - (boolean) whether the service executed successfully

        Parameters:
            serviceData                         - (table) data about this site
                mobjHostName                    + (string) with the name of the MObjHost of the MObj
                mobjLocator                     + (URL) locating the MObj
            callback                            + (Callback) to call once service is ready
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("T_MObjHost.dismantleAndReleaseMObj_ASrv_test_ASrv: Invalid input") return Callback.ErrorCall(callback) end

    -- prepare test
    corelog.WriteToLog("* "..mobjHostName..":dismantleAndReleaseMObj_ASrv() tests (with "..mobjLocator:getURI()..")")
    local mobjHost = moduleRegistry:getModule(mobjHostName)
    if not mobjHost then corelog.Error("host "..mobjHostName.." not registered") return Callback.ErrorCall(callback) end

    -- test
    return enterprise_projects.StartProject_ASrv({ projectMeta = { title = "Test dismantleAndReleaseMObj_ASrv", description = "Testing "..mobjHostName..":dismantleAndReleaseMObj_ASrv with "..mobjLocator:getURI() },
        projectData = {
            mobjHostName                = mobjHostName,
            mobjHostLocator             = mobjHost:getHostLocator(),

            mobjLocator                 = mobjLocator,
            materialsItemSupplierLocator= t_turtle.GetCurrentTurtleLocator(),
            wasteItemDepotLocator       = t_turtle.GetCurrentTurtleLocator(),
        },
        projectDef  = {
            steps = {
                -- test: call method to test
                { stepType = "LAOSrv", stepTypeDef = { serviceName = "dismantleAndReleaseMObj_ASrv", locatorStep = 0, locatorKeyDef = "mobjHostLocator" }, stepDataDef = {
                    { keyDef = "mobjLocator"                    , sourceStep = 0, sourceKeyDef = "mobjLocator" },
                    { keyDef = "materialsItemSupplierLocator"   , sourceStep = 0, sourceKeyDef = "materialsItemSupplierLocator" },
                    { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
                }},
                -- test: check results
                { stepType = "SSrv", stepTypeDef = { moduleName = "T_MObjHost", serviceName = "dismantleAndReleaseMObj_ASrv_checkResults_SSrv" }, stepDataDef = {
                    { keyDef = "mobjHostName"                   , sourceStep = 0, sourceKeyDef = "mobjHostName" },
                    { keyDef = "mobjLocator"                    , sourceStep = 0, sourceKeyDef = "mobjLocator" },
                }},
            },
            returnData  = {
            }
        },
    }, callback)
end

function T_MObjHost.dismantleAndReleaseMObj_ASrv_checkResults_SSrv(...)
    -- get & check input from description
    local checkSuccess, mobjHostName, mobjLocator = InputChecker.Check([[
        This method checks the results of a dismantleAndReleaseMObj_ASrv service test call for a specific MObjHost, MObj combination.

        Return value:
                success                         - (boolean) whether the service executed successfully

        Parameters:
            serviceData                         - (table) data about this site
                mobjHostName                    + (string) with the name of the MObjHost of the MObj
                mobjLocator                     + (URL) locating the hosted and build MObj
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("T_MObjHost.dismantleAndReleaseMObj_ASrv_checkResults_SSrv: Invalid input") return { success = false } end

    -- check expected MObjHost
    local mobjHost = MObjHost.GetHost(mobjLocator:getHost()) if not mobjHost then corelog.Error("MObjHost of mobjLocator(="..mobjLocator:getURI()..") not present") return { success = false } end
    if mobjHost:getHostName() ~= mobjHostName then corelog.Error("MObjHost name(="..mobjHost:getHostName()..") not the same as expected(="..mobjHostName..")") return { success = false } end

    -- check mobj deleted
    local mobjResourceTable = mobjHost:getResource(mobjLocator)
    if mobjResourceTable ~= nil then corelog.Error("MObj(="..mobjLocator:getURI()..") not deleted from MObjHost "..mobjHost:getHostName()) return { success = false } end

    -- check dismantle blueprint "build"
    -- ToDo: add mock test

    -- end
    return {success = true}
end

function T_MObjHost.T_dismantleAndReleaseMObj_ASrv_TestMObj(...)
    -- get & check input from description
    local checkSuccess, mobjLocator, callback = InputChecker.Check([[
        This async method tests MObjHost:dismantleAndReleaseMObj_ASrv service with a TestMObj.

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
    if not checkSuccess then corelog.Error("T_MObjHost.T_dismantleAndReleaseMObj_ASrv_TestMObj: Invalid input") return Callback.ErrorCall(callback) end

    -- prepare test: register test host
    moduleRegistry:registerModule(test_mobjHostName1, test_mobjHost1)

    -- prepare test: ensure/ check mobjLocator
    if not mobjLocator then
        -- see if we locally remembered a mobjLocator from the T_hostAndBuildMObj_ASrv_TestMObj test
        if mobjLocator_TestMObj then
--            corelog.WriteToLog("Using previously stored "..mobjLocator:getURI())
            mobjLocator = mobjLocator_TestMObj
        else
            corelog.Error("T_MObjHost.T_dismantleAndReleaseMObj_ASrv_TestMObj: No mobjLocator for the TestMObj to operate on") return Callback.ErrorCall(callback)
        end
    end

    -- prepare test: ensure callback (needed when called directly)
    if not callback then callback = Callback:GetNewDummyCallBack() end

    -- test & cleanup
    return enterprise_projects.StartProject_ASrv({ projectMeta = { title = "Test MObjHost:dismantleAndReleaseMObj_ASrv", description = "Testing MObjHost:dismantleAndReleaseMObj_ASrv for a "..test_mobjClassName1 },
        projectData = {
            mobjHostName                = test_mobjHostName1,

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
                { stepType = "SSrv", stepTypeDef = { moduleName = "T_MObjHost", serviceName = "dismantleAndReleaseMObj_ASrv_TestMObj_cleanupTest_SSrv" }, stepDataDef = {
                }},
            },
            returnData  = {
            }
        },
    }, callback)
end

function T_MObjHost.dismantleAndReleaseMObj_ASrv_TestMObj_cleanupTest_SSrv(...)
--    corelog.WriteToLog("dismantleAndReleaseMObj_ASrv_TestMObj_cleanupTest_SSrv")

    -- cleanup test: stop remembering mobjLocator_TestMObj
    mobjLocator_TestMObj = nil

    -- cleanup test: remove test host data
    -- ToDo: remove data

    -- cleanup test: delist test host
    moduleRegistry:delistModule(test_mobjHostName1)

    -- end
    return {success = true}
end

return T_MObjHost
