local t_colonization = {}

local corelog = require "corelog"

local Callback = require "obj_callback"

local enterprise_colonization = require "enterprise_colonization"

local testClassName = "enterprise_colonization"

function t_colonization.T_CreateNewWorld_ASrv()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..".CreateNewWorld_ASrv() test")
    local callback = Callback:newInstance("t_main", "GoHomeCallBack")
    local serviceData = {}

    -- test
--    corelog.WriteToLog("T_enterpise_colonization calling CreateNewWorld_ASrv("..textutils.serialize(serviceData)..", ...)")
    local scheduleResult = enterprise_colonization.CreateNewWorld_ASrv(serviceData, callback)
    assert(scheduleResult == true, "Failed schedulding CreateNewWorld_ASrv")

    -- cleanup test
end

function t_colonization.T_RecoverNewWorld_SSrv()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..".RecoverNewWorld_SSrv() test")
    local serviceData = {}

    -- test
    local scheduleResult = enterprise_colonization.RecoverNewWorld_SSrv(serviceData)
    assert(scheduleResult == true, "Failed schedulding RecoverNewWorld_SSrv")

    -- cleanup test
end

return t_colonization
