local T_MObjHost = {}

local coreutils = require "coreutils"
local corelog = require "corelog"

local Callback = require "obj_callback"
local ModuleRegistry = require "module_registry"
local moduleRegistry = ModuleRegistry:getInstance()

local URL = require "obj_url"
local Location = require "obj_location"

local MObjHost = require "eobj_mobj_host"

local t_turtle = require "test.t_turtle"

function T_MObjHost.T_All()
    -- IObj methods
    T_MObjHost.T_new()

    -- service methods
    T_MObjHost.T_registerMObj_SSrv()
    T_MObjHost.T_addMObj_ASrv()
end

local hostName = "TestMObjHost"

local host1 = MObjHost:new({
    _hostName   = hostName,
})

local compact = { compact = true }

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
local field1SetValue = "value field1"
local baseLocation = Location:new({_x= -12, _y= 0, _z= 1, _dx=0, _dy=1})
local constructParameters = {
    baseLocation    = baseLocation,
    field1Value     = field1SetValue,
}

function T_MObjHost.T_registerMObj_SSrv()
    -- prepare test
    corelog.WriteToLog("* MObjHost:registerMObj_SSrv() tests")

    -- test
    local serviceResults = host1:registerMObj_SSrv({
        className           = mobj_className,
        constructParameters = constructParameters,
    })

    -- check registration success
    assert(serviceResults and serviceResults.success, "failed registering MObj")

    -- check mobjLocator returned
    local mobjLocator = serviceResults.mobjLocator
    assert(URL:isTypeOf(mobjLocator), "incorrect mobjLocator returned")

    -- check mobj saved
    local mobj = host1:getObject(mobjLocator)
    assert(mobj, "MObj not in host")

    -- check mobj constructed
    local field1Value = mobj:getField1()
    assert(field1Value == field1SetValue, "construct did not set _field1")


    -- cleanup test
    host1:deleteObjects("TestMObj")
end

function T_MObjHost.T_addMObj_ASrv()
    -- prepare test
    corelog.WriteToLog("* MObjHost:addMObj_ASrv() tests")
    moduleRegistry:registerModule(hostName, host1)
    local host = moduleRegistry:getModule(hostName) if not host then corelog.Warning("host "..hostName.." not registered") return nil end

    local materialsItemSupplierLocator = t_turtle.GetCurrentTurtleLocator()

    local callback = Callback:new({
        _moduleName     = "T_MObjHost",
        _methodName     = "addMObj_ASrv_Callback",
        _data           = {
--            ["field1SetValue"]  = field1SetValue,
        },
    })

    -- test
    local scheduleResult = host1:addMObj_ASrv({
        className                   = mobj_className,
        constructParameters         = constructParameters,
        materialsItemSupplierLocator= materialsItemSupplierLocator,
    }, callback)
    assert(scheduleResult == true, "failed to schedule async service")
end

function T_MObjHost.addMObj_ASrv_Callback(callbackData, serviceResults)
    -- test (cont)
    assert(serviceResults.success, "failed adding MObj")

    -- check addition success
    assert(serviceResults and serviceResults.success, "failed adding MObj")

    -- check mobjLocator returned
    local mobjLocator = URL:new(serviceResults.mobjLocator)
    assert(URL:isTypeOf(mobjLocator), "incorrect mobjLocator returned")

    -- check mobj registered (full check done in T_registerMObj_SSrv)
    local mobj = host1:getObject(mobjLocator)
    assert(mobj, "MObj not registered")


    -- cleanup test
    host1:deleteObjects("TestMObj")
    moduleRegistry:delistModule(hostName)

    -- end
    return true
end

return T_MObjHost
