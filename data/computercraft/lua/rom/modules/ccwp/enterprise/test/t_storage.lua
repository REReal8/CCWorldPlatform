local t_storage = {}

local corelog = require "corelog"

local Location = require "obj_location"

local TestArrayTest = require "test_array_test"
local FieldTest = require "field_test"
local ValueTypeTest = require "value_type_test"
local MethodResultEqualTest = require "method_result_equal_test"

local T_Silo = require "test.t_mobj_silo"
local T_MObjHost = require "test.t_eobj_mobj_host"
local enterprise_storage

function t_storage.T_All()
    -- IObj methods

    -- service methods
    t_storage.T_hostMObj_SSrv_Silo()
    t_storage.T_releaseMObj_SSrv_Silo()
end

function t_storage.T_AllPhysical()
    -- IObj methods

    -- service methods
    local mobjLocator = t_storage.T_hostAndBuildMObj_ASrv_Silo()
    t_storage.T_dismantleAndReleaseMObj_ASrv_Silo(mobjLocator)
end

local testMObjClassName = "Silo"
local testMObjName = "silo"
local logOk = false
local mobjLocator_Silo = nil
local baseLocation1  = Location:newInstance(12, -12, 1, 0, 1)
local entryLocation1 = baseLocation1:getRelativeLocation(3, 3, 0)
local dropLocation1 = 1
local pickupLocation1 = 2
local locatorClassName = "URL"
local nTopChests1 = 2
local nLayers1 = 2
local constructParameters1 = {
    baseLocation    = baseLocation1,
    nTopChests      = nTopChests1,
    nLayers         = nLayers1,
}

--                        _                           _   _               _
--                       (_)                         | | | |             | |
--    ___  ___ _ ____   ___  ___ ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \  __/ |   \ V /| | (_|  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/\___|_|    \_/ |_|\___\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

function t_storage.T_hostMObj_SSrv_Silo()
    -- prepare test
    enterprise_storage = enterprise_storage or require "enterprise_storage"
    local topChestsConstructTest = FieldTest:newInstance("_topChests", TestArrayTest:newInstance(
        ValueTypeTest:newInstance("ObjArray"),
        MethodResultEqualTest:newInstance("getObjClassName", locatorClassName),
        MethodResultEqualTest:newInstance("nObjs", nTopChests1)
    ))
    local storageChestsConstructTest = FieldTest:newInstance("_storageChests", TestArrayTest:newInstance(
        ValueTypeTest:newInstance("ObjArray"),
        MethodResultEqualTest:newInstance("getObjClassName", locatorClassName),
        MethodResultEqualTest:newInstance("nObjs", nLayers1*4)
    ))
    local constructFieldsTest = T_Silo.CreateInitialisedTest(nil, baseLocation1, entryLocation1, dropLocation1, pickupLocation1, topChestsConstructTest, storageChestsConstructTest)

    -- test
    local serviceResults = T_MObjHost.pt_hostMObj_SSrv(enterprise_storage, testMObjClassName, constructParameters1, testMObjName, constructFieldsTest, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

function t_storage.T_hostAndBuildMObj_ASrv_Silo()
    -- prepare test
    enterprise_storage = enterprise_storage or require "enterprise_storage"

    -- test
    local serviceResults = T_MObjHost.pt_hostAndBuildMObj_ASrv(enterprise_storage, testMObjClassName, constructParameters1, logOk)
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
    local serviceResults = T_MObjHost.pt_releaseMObj_SSrv(enterprise_storage, testMObjClassName, constructParameters1, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

function t_storage.T_dismantleAndReleaseMObj_ASrv_Silo(mobjLocator)
    -- prepare test
    if not mobjLocator then
        -- see if we locally remembered a mobjLocator from the T_hostAndBuildMObj_ASrv_Silo test
        assert(mobjLocator_Silo, "no mobjLocator for the Silo to operate on")
        mobjLocator = mobjLocator_Silo
    end

    -- test
    local serviceResults = T_MObjHost.pt_dismantleAndReleaseMObj_ASrv(enterprise_storage, mobjLocator, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    mobjLocator_Silo = nil
end

return t_storage
