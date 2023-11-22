local t_storage = {}

local corelog = require "corelog"

local Location = require "obj_location"
local URL = require "obj_url"

local TestArrayTest = require "test_array_test"
local FieldTest = require "field_test"
local ValueTypeTest = require "value_type_test"
local MethodResultEqualTest = require "method_result_equal_test"

local T_Silo = require "test.t_mobj_silo"
local T_MObjHost = require "test.t_mobj_host"
local enterprise_storage

function t_storage.T_All()
    -- IObj

    -- MObjHost
    t_storage.T_hostMObj_SSrv_Silo()
    t_storage.T_releaseMObj_SSrv_Silo()
end

function t_storage.T_AllPhysical()
    -- IObj

    -- MObjHost
    local mobjLocator = t_storage.T_buildAndHostMObj_ASrv_Silo()
    t_storage.T_dismantleAndReleaseMObj_ASrv_Silo(mobjLocator)
end

local testSiloClassName = "Silo"
local testSiloName = "silo"

local logOk = false

local baseLocation_Silo0  = Location:newInstance(12, -12, 1, 0, 1)
local entryLocation_Silo0 = baseLocation_Silo0:getRelativeLocation(3, 3, 0)
local dropLocation0 = 1
local pickupLocation0 = 2
local nTopChests0 = 2
local nLayers0 = 2
local constructParameters_Silo0 = {
    baseLocation    = baseLocation_Silo0,
    nTopChests      = nTopChests0,
    nLayers         = nLayers0,
}

--    __  __  ____  _     _ _    _           _                    _   _               _
--   |  \/  |/ __ \| |   (_) |  | |         | |                  | | | |             | |
--   | \  / | |  | | |__  _| |__| | ___  ___| |_   _ __ ___   ___| |_| |__   ___   __| |___
--   | |\/| | |  | | '_ \| |  __  |/ _ \/ __| __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   | |  | | |__| | |_) | | |  | | (_) \__ \ |_  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_|  |_|\____/|_.__/| |_|  |_|\___/|___/\__| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                      _/ |
--                     |__/

-- ** Chest **


-- ** Silo **

function t_storage.T_hostMObj_SSrv_Silo()
    -- prepare test
    enterprise_storage = enterprise_storage or require "enterprise_storage"
    local topChestsConstructTest = FieldTest:newInstance("_topChests", TestArrayTest:newInstance(
        ValueTypeTest:newInstance("ObjArray"),
        MethodResultEqualTest:newInstance("getObjClassName", URL:getClassName()),
        MethodResultEqualTest:newInstance("nObjs", nTopChests0)
    ))
    local storageChestsConstructTest = FieldTest:newInstance("_storageChests", TestArrayTest:newInstance(
        ValueTypeTest:newInstance("ObjArray"),
        MethodResultEqualTest:newInstance("getObjClassName", URL:getClassName()),
        MethodResultEqualTest:newInstance("nObjs", nLayers0*4)
    ))
    local constructFieldsTest = T_Silo.CreateInitialisedTest(nil, baseLocation_Silo0, entryLocation_Silo0, dropLocation0, pickupLocation0, topChestsConstructTest, storageChestsConstructTest)

    -- test
    local serviceResults = T_MObjHost.pt_hostMObj_SSrv(enterprise_storage, testSiloClassName, constructParameters_Silo0, testSiloName, constructFieldsTest, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

local mobjLocator_Silo = nil

function t_storage.T_buildAndHostMObj_ASrv_Silo()
    -- prepare test
    enterprise_storage = enterprise_storage or require "enterprise_storage"

    -- test
    local serviceResults = T_MObjHost.pt_buildAndHostMObj_ASrv(enterprise_storage, testSiloClassName, constructParameters_Silo0, testSiloName, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    mobjLocator_Silo = serviceResults.mobjLocator

    -- return mobjLocator
    return serviceResults.mobjLocator
end

function t_storage.T_releaseMObj_SSrv_Silo()
    -- prepare test
    enterprise_storage = enterprise_storage or require "enterprise_storage"

    -- test
    local serviceResults = T_MObjHost.pt_releaseMObj_SSrv(enterprise_storage, testSiloClassName, constructParameters_Silo0, testSiloName, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

function t_storage.T_dismantleAndReleaseMObj_ASrv_Silo(mobjLocator)
    -- prepare test
    if not mobjLocator then
        -- see if we locally remembered a mobjLocator
        assert(mobjLocator_Silo, "no mobjLocator to operate on")
        mobjLocator = mobjLocator_Silo
    end

    -- test
    local serviceResults = T_MObjHost.pt_dismantleAndReleaseMObj_ASrv(enterprise_storage, mobjLocator, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    mobjLocator_Silo = nil
end

return t_storage
