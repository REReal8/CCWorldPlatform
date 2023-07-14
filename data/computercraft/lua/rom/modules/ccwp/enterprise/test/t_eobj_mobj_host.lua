local T_MObjHost = {}

local coreutils = require "coreutils"
local corelog = require "corelog"

local ModuleRegistry = require "module_registry"
local moduleRegistry = ModuleRegistry:getInstance()
local URL = require "obj_url"
local MObjHost = require "eobj_mobj_host"

local TestMObj = require "test.mobj_test"

function T_MObjHost.T_All()
    -- IObj methods
    T_MObjHost.T_new()

    -- service methods
    T_MObjHost.T_registerMObj_SSrv()
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
function T_MObjHost.T_IsOfType()
    -- prepare test
    corelog.WriteToLog("* MObjHost.IsOfType() tests")
    local host2 = MObjHost:new({
        _hostName   = hostName,
    })

    -- test valid
    local isOfType = MObjHost.IsOfType(host2)
    local expectedIsOfType = true
    assert(isOfType == expectedIsOfType, "gotten IsOfType(="..tostring(isOfType)..") not the same as expected(="..tostring(expectedIsOfType)..")")

    -- test different object
    isOfType = MObjHost.IsOfType("a atring")
    expectedIsOfType = false
    assert(isOfType == expectedIsOfType, "gotten IsOfType(="..tostring(isOfType)..") not the same as expected(="..tostring(expectedIsOfType)..")")

    -- test invalid hostName
    host2._hostName = 1000
    isOfType = MObjHost.IsOfType(host2)
    expectedIsOfType = false
    assert(isOfType == expectedIsOfType, "gotten IsOfType(="..tostring(isOfType)..") not the same as expected(="..tostring(expectedIsOfType)..")")
    host2._hostName = hostName

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

function T_MObjHost.T_registerMObj_SSrv()
    -- prepare test
    corelog.WriteToLog("* MObjHost:registerMObj_SSrv() tests")
    local mobj_className = "TestMObj"
    local field1SetValue = "value field1"
    local constructParameters = {
        field1Value = field1SetValue
    }

    -- test
    local serviceResult = host1:registerMObj_SSrv({
        className           = mobj_className,
        constructParameters = constructParameters,
    })

    -- check registration success
    assert(serviceResult and serviceResult.success, "failed registering MObj")

    -- check mobjLocator returned
    local mobjLocator = serviceResult.mobjLocator
    assert(URL.IsOfType(mobjLocator), "incorrect mobjLocator returned")

    -- check mobj saved
    local mobj = host1:getObject(mobjLocator)
    assert(mobj, "MObj not in host")

    -- check mobj constructed
    local field1Value = mobj:getField1()
    assert(field1Value == field1SetValue, "construct did not set _field1")
    local isActive = mobj:isActive()
    assert(type(isActive) == "boolean", "isActive does not(="..type(isActive)..") return a boolean")
    assert(not isActive, "MObj is active")

    -- cleanup test
    host1:deleteObjects("TestMObj")
end

return T_MObjHost
