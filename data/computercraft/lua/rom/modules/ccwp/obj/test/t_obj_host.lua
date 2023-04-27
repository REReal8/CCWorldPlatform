local T_Host = {}

local corelog = require "corelog"

local Host = require "obj_host"

function T_Host.T_All()
    -- base methods
    T_Host.T_new()
    T_Host.T_IsOfType()
    T_Host.T_isSame()
    T_Host.T_copy()

    -- specific methods

    -- helper functions
end

local hostName = "TestHost"
local hostName2 = "TestHost2"

local host1 = Host:new({
    _hostName   = hostName,
})

local compact = { compact = true }

--    _                                     _   _               _
--   | |                                   | | | |             | |
--   | |__   __ _ ___  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   | '_ \ / _` / __|/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   | |_) | (_| \__ \  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_.__/ \__,_|___/\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

function T_Host.T_new()
    -- prepare test
    corelog.WriteToLog("* Host:new() tests")

    -- test full
    local host = Host:new({
        _hostName   = hostName,
    })
    assert(host:getHostName() == hostName, "gotten getHostName(="..host:getHostName()..") not the same as expected(="..hostName..")")

    -- cleanup test
end

function T_Host.T_IsOfType()
    -- prepare test
    corelog.WriteToLog("* Host.IsOfType() tests")
    local host2 = Host:new({
        _hostName   = hostName,
    })

    -- test valid
    local isOfType = Host.IsOfType(host2)
    local expectedIsOfType = true
    assert(isOfType == expectedIsOfType, "gotten IsOfType(="..tostring(isOfType)..") not the same as expected(="..tostring(expectedIsOfType)..")")

    -- test different object
    isOfType = Host.IsOfType("a atring")
    expectedIsOfType = false
    assert(isOfType == expectedIsOfType, "gotten IsOfType(="..tostring(isOfType)..") not the same as expected(="..tostring(expectedIsOfType)..")")

    -- test invalid hostName
    host2._hostName = 1000
    isOfType = Host.IsOfType(host2)
    expectedIsOfType = false
    assert(isOfType == expectedIsOfType, "gotten IsOfType(="..tostring(isOfType)..") not the same as expected(="..tostring(expectedIsOfType)..")")
    host2._hostName = hostName

    -- cleanup test
end

function T_Host.T_isSame()
    -- prepare test
    corelog.WriteToLog("* Host:isSame() tests")
    local host2 = Host:new({
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

function T_Host.T_copy()
    -- prepare test
    corelog.WriteToLog("* Host:copy() tests")

    -- test
    local copy = host1:copy()
    assert(copy:isSame(host1), "gotten copy(="..textutils.serialize(copy, compact)..") not the same as expected(="..textutils.serialize(host1, compact)..")")

    -- cleanup test
end

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

return T_Host
