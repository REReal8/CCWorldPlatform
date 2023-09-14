local t_storage = {}

local Location = require "obj_location"

local T_MObjHost = require "test.t_eobj_mobj_host"
local enterprise_storage

function t_storage.T_All()
    -- IObj methods

    -- service methods
--    t_storage.T_hostMObj_SSrv()
--    t_storage.T_releaseMObj_SSrv()
end

function t_storage.T_AllPhysical()
    -- IObj methods

    -- service methods
    local mobjLocator = t_storage.T_hostAndBuildMObj_ASrv_Silo()
    t_storage.T_dismantleAndReleaseMObj_ASrv_Silo(mobjLocator)
end

local logOk = true
local test_mobjClassName1 = "Silo"

--                        _                           _   _               _
--                       (_)                         | | | |             | |
--    ___  ___ _ ____   ___  ___ ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \  __/ |   \ V /| | (_|  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/\___|_|    \_/ |_|\___\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/


local mobjLocator_Silo = nil
local location1  = Location:newInstance(12, -12, 1, 0, 1)
local test_mobjConstructParameters1 = {
    baseLocation    = location1,
    nTopChests      = 2,
    nLayers         = 2,
}

function t_storage.T_hostAndBuildMObj_ASrv_Silo()
    -- prepare test
    enterprise_storage = enterprise_storage or require "enterprise_storage"

    -- test
    local serviceResults = T_MObjHost.pt_hostAndBuildMObj_ASrv(enterprise_storage, test_mobjClassName1, test_mobjConstructParameters1, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    mobjLocator_Silo = serviceResults.mobjLocator

    -- return mobjLocator
    return serviceResults.mobjLocator
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
