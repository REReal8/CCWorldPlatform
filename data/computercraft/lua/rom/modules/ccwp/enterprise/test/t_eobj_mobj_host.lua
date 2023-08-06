local T_MObjHost = {}

local corelog = require "corelog"

local Callback = require "obj_callback"
local ModuleRegistry = require "module_registry"
local moduleRegistry = ModuleRegistry:getInstance()

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
            { stepType = "ASrv", stepTypeDef = { moduleName = "T_MObjHost", serviceName = "T_hostAndBuildMObj_ASrv" }, stepDataDef = {} },
            { stepType = "ASrv", stepTypeDef = { moduleName = "T_MObjHost", serviceName = "T_dismantleAndReleaseMObj_ASrv" }, stepDataDef = {} },
        }, returnData  = { } }, }, Callback.GetNewDummyCallBack())
end

local hostName = "TestMObjHost"

local host1 = MObjHost:new({
    _hostName   = hostName,
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
        _hostName   = hostName,
    })
    assert(host:getHostName() == hostName, "gotten getHostName(="..host:getHostName()..") not the same as expected(="..hostName..")")

    -- cleanup test
end

--[[
function T_MObjHost.T_isTypeOf()
    -- prepare test
    corelog.WriteToLog("* MObjHost:isTypeOf() tests")
    local host2 = MObjHost:new({
        _hostName   = hostName,
    })

    -- test valid
    local isTypeOf = MObjHost:isTypeOf(host2)
    local expectedIsTypeOf = true
    assert(isTypeOf == expectedIsTypeOf, "gotten isTypeOf(="..tostring(isTypeOf)..") not the same as expected(="..tostring(expectedIsTypeOf)..")")

    -- test different object
    isTypeOf = MObjHost:isTypeOf("a atring")
    expectedIsTypeOf = false
    assert(isTypeOf == expectedIsTypeOf, "gotten isTypeOf(="..tostring(isTypeOf)..") not the same as expected(="..tostring(expectedIsTypeOf)..")")

    -- cleanup test
end

function T_MObjHost.T_isSame()
    -- prepare test
    corelog.WriteToLog("* MObjHost:isSame() tests")
    local host2 = MObjHost:new({
        _hostName   = hostName,
    })

    -- test same
    local isSame = host1:isSame(host2)
    local expectedIsSame = true
    assert(isSame == expectedIsSame, "gotten isSame(="..tostring(isSame)..") not the same as expected(="..tostring(expectedIsSame)..")")

    -- test different hostName
    host2._hostName = hostName2
    isSame = host1:isSame(host2)
    expectedIsSame = false
    assert(isSame == expectedIsSame, "gotten isSame(="..tostring(isSame)..") not the same as expected(="..tostring(expectedIsSame)..")")
    host2._hostName = hostName

    -- cleanup test
end

function T_MObjHost.T_copy()
    -- prepare test
    corelog.WriteToLog("* MObjHost:copy() tests")

    -- test
    local copy = host1:copy()
    assert(copy:isSame(host1), "gotten copy(="..textutils.serialize(copy, compact)..") not the same as expected(="..textutils.serialize(host1, compact)..")")

    -- cleanup test
end
]]

--                        _                           _   _               _
--                       (_)                         | | | |             | |
--    ___  ___ _ ____   ___  ___ ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \  __/ |   \ V /| | (_|  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/\___|_|    \_/ |_|\___\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

local mobj_className = "TestMObj"
local location = Location:new({_x= -12, _y= 0, _z= 1, _dx=0, _dy=1})
local field1SetValue = "value field1"
local constructParameters = {
    location        = location,
    field1Value     = field1SetValue,
}

function T_MObjHost.T_hostMObj_SSrv()
    -- prepare test
    corelog.WriteToLog("* MObjHost:hostMObj_SSrv() tests")

    -- test
    local serviceResults = host1:hostMObj_SSrv({
        className           = mobj_className,
        constructParameters = constructParameters,
    })

    -- check hosting success
    assert(serviceResults and serviceResults.success, "failed hosting MObj")

    -- check mobjLocator returned
    local mobjLocator = serviceResults.mobjLocator
    assert(URL:isTypeOf(mobjLocator), "incorrect mobjLocator returned")

    -- check mobj saved
    local mobj = host1:getObject(mobjLocator)
    assert(mobj, "MObj not in host")

    -- check mobj constructed
    local field1Value = mobj:getField1()
    assert(field1Value == field1SetValue, "construct did not set _field1")

    -- check child MObj's hosted
    -- ToDo: consider implementing testing this. Or shouldn't we as it's a choice to have and responsibilty of the MObj to do this?

    -- cleanup test
    host1:deleteObjects("TestMObj")
end

function T_MObjHost.T_hostAndBuildMObj_ASrv(serviceData, testsCallback)
    -- prepare test
    corelog.WriteToLog("* MObjHost:hostAndBuildMObj_ASrv() tests")
    moduleRegistry:registerModule(hostName, host1)
    local host = moduleRegistry:getModule(hostName) if not host then corelog.Warning("host "..hostName.." not registered") return nil end

    local materialsItemSupplierLocator = t_turtle.GetCurrentTurtleLocator()

    local callback = Callback:new({
        _moduleName     = "T_MObjHost",
        _methodName     = "hostAndBuildMObj_ASrv_Callback",
        _data           = {
            ["testsCallback"]   = testsCallback,
        },
    })

    -- test
    local scheduleResult = host1:hostAndBuildMObj_ASrv({
        className                   = mobj_className,
        constructParameters         = constructParameters,
        materialsItemSupplierLocator= materialsItemSupplierLocator,
        wasteItemDepotLocator       = t_turtle.GetCurrentTurtleLocator(),
    }, callback)
    assert(scheduleResult == true, "failed to schedule async service")

    -- end
    return true
end

function T_MObjHost.hostAndBuildMObj_ASrv_Callback(callbackData, serviceResults)
    -- test (cont)
    -- check hostAndBuildMObj_ASrv success
    assert(serviceResults and serviceResults.success, "failed building and hosting MObj")

    -- check mobjLocator returned
    local mobjLocator = URL:new(serviceResults.mobjLocator)
    assert(URL:isTypeOf(mobjLocator), "incorrect mobjLocator returned")

    -- check mobj hosted (full check done in T_hostMObj_SSrv)
    local mobj = host1:getObject(mobjLocator)
    assert(mobj, "MObj not hosted")

    -- check build blueprint build
    -- ToDo: add mock test

    -- cleanup test
    host1:deleteResource(mobjLocator)
    moduleRegistry:delistModule(hostName)

    -- end
    local testsCallback = callbackData["testsCallback"]
    if testsCallback then
        -- report we are done with testing
        testsCallback = Callback:new(testsCallback)
        return testsCallback:call({success = true})
    else
        return true
    end
end

function T_MObjHost.T_releaseMObj_SSrv()
    -- prepare test
    corelog.WriteToLog("* MObjHost:releaseMObj_SSrv() tests")
    moduleRegistry:registerModule(hostName, host1)
    local serviceResults = host1:hostMObj_SSrv({
        className           = mobj_className,
        constructParameters = constructParameters,
    })
    local mobjLocator = URL:new(serviceResults.mobjLocator)

    -- test
    serviceResults = host1:releaseMObj_SSrv({
        mobjLocator         = mobjLocator,
    })

    -- check releasing success
    assert(serviceResults and serviceResults.success, "failed releasing MObj")

    -- check mobj deleted
    local mobjResourceTable = host1:getResource(mobjLocator)
    assert(not mobjResourceTable, "MObj not deleted")

    -- check child MObj's released
    -- ToDo: consider implementing testing this. Or shouldn't we as it's a responsibilty of the MObj to do this?

    -- cleanup test
    moduleRegistry:delistModule(hostName)
end

function T_MObjHost.T_dismantleAndReleaseMObj_ASrv(serviceData, testsCallback)
    -- prepare test
    corelog.WriteToLog("* MObjHost:dismantleAndReleaseMObj_ASrv() tests")
    moduleRegistry:registerModule(hostName, host1)
    local host = moduleRegistry:getModule(hostName) if not host then corelog.Warning("host "..hostName.." not registered") return nil end

    local serviceResults = host1:hostMObj_SSrv({
        className           = mobj_className,
        constructParameters = constructParameters,
    })
    local mobjLocator = URL:new(serviceResults.mobjLocator)

    local callback = Callback:new({
        _moduleName     = "T_MObjHost",
        _methodName     = "dismantleAndReleaseMObj_ASrv_Callback",
        _data           = {
            ["mobjLocator"]     = mobjLocator,
            ["testsCallback"]   = testsCallback,
        },
    })

    -- test
    local scheduleResult = host1:dismantleAndReleaseMObj_ASrv({
        mobjLocator                 = mobjLocator,
        materialsItemSupplierLocator= t_turtle.GetCurrentTurtleLocator(),
        wasteItemDepotLocator       = t_turtle.GetCurrentTurtleLocator(),
    }, callback)
    assert(scheduleResult == true, "failed to schedule async service")

    -- end
    return true
end

function T_MObjHost.dismantleAndReleaseMObj_ASrv_Callback(callbackData, serviceResults)
    -- test (cont)
    -- check dismantleAndReleaseMObj_ASrv success
    assert(serviceResults and serviceResults.success, "failed releasing and dismantling MObj")

    -- check mobj deleted
    local mobjLocator = callbackData["mobjLocator"]
    local mobjResourceTable = host1:getResource(mobjLocator)
    assert(not mobjResourceTable, "MObj not deleted")

    -- check dismantle blueprint "build"
    -- ToDo: add mock test

    -- cleanup test
    moduleRegistry:delistModule(hostName)

    -- end
    local testsCallback = callbackData["testsCallback"]
    if testsCallback then
        -- report we are done with testing
        testsCallback = Callback:new(testsCallback)
        return testsCallback:call({success = true})
    else
        return true
    end
end

return T_MObjHost
