local t_utilities = {}

local Location = require "obj_location"

local enterprise_utilities = require "enterprise_utilities"

local T_UtilStation = require "test.t_mobj_user_station"
local T_MObjHost = require "test.t_mobj_host"

function t_utilities.T_All()
    -- MObjHost
    t_utilities.T_hostMObj_SSrv_UtilStation()
    t_utilities.T_releaseMObj_SSrv_UtilStation()
end

function t_utilities.T_AllPhysical()
    -- IObj

    -- MObjHost
    local mobjLocator = t_utilities.T_buildAndHostMObj_ASrv_UtilStation()
    t_utilities.T_dismantleAndReleaseMObj_ASrv_UtilStation(mobjLocator)
end

local testMObjClassName = "UserStation"
local testMObjName = "userStation"
local logOk = false

local workerId1 = 111111
local baseLocation = Location:newInstance(-6, -12, 1, 0, 1)

local constructParameters = {
    workerId        = workerId1,
    baseLocation    = baseLocation,
}

--    __  __  ____  _     _ _    _           _                    _   _               _
--   |  \/  |/ __ \| |   (_) |  | |         | |                  | | | |             | |
--   | \  / | |  | | |__  _| |__| | ___  ___| |_   _ __ ___   ___| |_| |__   ___   __| |___
--   | |\/| | |  | | '_ \| |  __  |/ _ \/ __| __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   | |  | | |__| | |_) | | |  | | (_) \__ \ |_  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_|  |_|\____/|_.__/| |_|  |_|\___/|___/\__| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                      _/ |
--                     |__/

function t_utilities.T_hostMObj_SSrv_UtilStation()
    -- prepare test
    local constructFieldsTest = T_UtilStation.CreateInitialisedTest(workerId1, baseLocation)

    -- test
    local serviceResults = T_MObjHost.pt_hostMObj_SSrv(enterprise_utilities, testMObjClassName, constructParameters, testMObjName, constructFieldsTest, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

local mobjLocator_UtilStation = nil

function t_utilities.T_buildAndHostMObj_ASrv_UtilStation()
    -- prepare test

    -- test
    local serviceResults = T_MObjHost.pt_buildAndHostMObj_ASrv(enterprise_utilities, testMObjClassName, constructParameters, testMObjName, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test

    -- remember what we just build
    mobjLocator_UtilStation = serviceResults.mobjLocator

    -- return mobjLocator
    return serviceResults.mobjLocator
end

function t_utilities.T_releaseMObj_SSrv_UtilStation()
    -- prepare test

    -- test
    local serviceResults = T_MObjHost.pt_releaseMObj_SSrv(enterprise_utilities, testMObjClassName, constructParameters, testMObjName, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

function t_utilities.T_dismantleAndReleaseMObj_ASrv_UtilStation(mobjLocator)
    -- prepare test
    if not mobjLocator then
        -- see if we locally remembered a mobjLocator
        assert(mobjLocator_UtilStation, "no mobjLocator to operate on")
        mobjLocator = mobjLocator_UtilStation
    end

    -- test
    local serviceResults = T_MObjHost.pt_dismantleAndReleaseMObj_ASrv(enterprise_utilities, mobjLocator, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    mobjLocator_UtilStation = nil
end

return t_utilities
