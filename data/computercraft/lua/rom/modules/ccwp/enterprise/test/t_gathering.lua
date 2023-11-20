local t_gathering = {}

local Location = require "obj_location"

local enterprise_gathering = require "enterprise_gathering"

local T_MineShaft = require "test.t_mine_shaft"
local T_MObjHost = require "test.t_mobj_host"

function t_gathering.T_All()
    -- MObjHost
    t_gathering.T_hostMObj_SSrv_MineShaft()
    t_gathering.T_upgradeMObj_SSrv_MineShaft()
    t_gathering.T_releaseMObj_SSrv_MineShaft()
end

function t_gathering.T_AllPhysical()
    -- IObj

    -- MObjHost
    local mobjLocator = t_gathering.T_buildAndHostMObj_ASrv_MineShaft()
    t_gathering.T_extendAndUpgradeMObj_ASrv_MineShaft(mobjLocator)
    t_gathering.T_dismantleAndReleaseMObj_ASrv_MineShaft(mobjLocator)
end

local testMObjClassName = "MineShaft"
local testMObjName = "mineShaft"
local testMObjName0 = testMObjName.."0"

local baseLocation0 = Location:newInstance(0, -12, 1, 0, 1):getRelativeLocation(3, 3, 0)
local currentDepth0 = 0
local maxDepth0 = 32
local maxDepth1 = 48

local constructParameters0 = {
    baseLocation    = baseLocation0,
    maxDepth        = maxDepth0,
}

local upgradeParameters0 = {
    maxDepth        = maxDepth1,
}

local logOk = false

--    __  __  ____  _     _ _    _           _                    _   _               _
--   |  \/  |/ __ \| |   (_) |  | |         | |                  | | | |             | |
--   | \  / | |  | | |__  _| |__| | ___  ___| |_   _ __ ___   ___| |_| |__   ___   __| |___
--   | |\/| | |  | | '_ \| |  __  |/ _ \/ __| __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   | |  | | |__| | |_) | | |  | | (_) \__ \ |_  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_|  |_|\____/|_.__/| |_|  |_|\___/|___/\__| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                      _/ |
--                     |__/

function t_gathering.T_hostMObj_SSrv_MineShaft()
    -- prepare test
    local constructFieldsTest = T_MineShaft.CreateInitialisedTest(nil, baseLocation0, currentDepth0, maxDepth0)

    -- test
    local serviceResults = T_MObjHost.pt_hostMObj_SSrv(enterprise_gathering, testMObjClassName, constructParameters0, testMObjName0, constructFieldsTest, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

local mobjLocator_MineShaft = nil

function t_gathering.T_buildAndHostMObj_ASrv_MineShaft()
    -- prepare test

    -- test
    local serviceResults = T_MObjHost.pt_buildAndHostMObj_ASrv(enterprise_gathering, testMObjClassName, constructParameters0, testMObjName0, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    mobjLocator_MineShaft = serviceResults.mobjLocator

    -- return mobjLocator
    return serviceResults.mobjLocator
end

function t_gathering.T_upgradeMObj_SSrv_MineShaft()
    -- prepare test
    local upgradeFieldsTest = T_MineShaft.CreateInitialisedTest(nil, baseLocation0, currentDepth0, maxDepth1)

    -- test
    local serviceResults = T_MObjHost.pt_upgradeMObj_SSrv(enterprise_gathering, testMObjClassName, constructParameters0, upgradeParameters0, testMObjName0, upgradeFieldsTest, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

function t_gathering.T_extendAndUpgradeMObj_ASrv_MineShaft(mobjLocator)
    -- prepare test
    local upgradeFieldsTest = T_MineShaft.CreateInitialisedTest(nil, baseLocation0, currentDepth0, maxDepth1)

    if not mobjLocator then
        -- check if we locally remembered a mobjLocator
        assert(mobjLocator_MineShaft, "no mobjLocator to operate on")
        mobjLocator = mobjLocator_MineShaft
    end

    -- test
    local serviceResults = T_MObjHost.pt_extendAndUpgradeMObj_ASrv(enterprise_gathering, mobjLocator, upgradeParameters0, testMObjName0, upgradeFieldsTest, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

function t_gathering.T_releaseMObj_SSrv_MineShaft()
    -- prepare test

    -- test
    local serviceResults = T_MObjHost.pt_releaseMObj_SSrv(enterprise_gathering, testMObjClassName, constructParameters0, testMObjName0, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

function t_gathering.T_dismantleAndReleaseMObj_ASrv_MineShaft(mobjLocator)
    -- prepare test
    if not mobjLocator then
        -- see if we locally remembered a mobjLocator
        assert(mobjLocator_MineShaft, "no mobjLocator to operate on")
        mobjLocator = mobjLocator_MineShaft
    end

    -- modify currentDepth, to show refill of MineShaft
    local mobj = enterprise_gathering:getObject(mobjLocator) assert(mobj, "MObj(="..mobjLocator:getURI()..") not hosted by "..enterprise_gathering:getHostName())
    mobj._currentDepth = 4
    enterprise_gathering:saveObject(mobj)

    -- test
    local serviceResults = T_MObjHost.pt_dismantleAndReleaseMObj_ASrv(enterprise_gathering, mobjLocator, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    mobjLocator_MineShaft = nil
end

return t_gathering
