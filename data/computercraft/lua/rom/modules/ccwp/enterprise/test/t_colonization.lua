local t_colonization = {}

local corelog = require "corelog"

local Callback = require "obj_callback"

local enterprise_colonization = require "enterprise_colonization"

function t_colonization.T_CreateNewWorld()
    -- test CreateNewWorld_ASrv
    corelog.WriteToLog("# Test CreateNewWorld_ASrv")
    local callback = Callback:new({
        _moduleName     = "t_main",
        _methodName     = "GoHomeCallBack",
        _data           = { },
    })
    local serviceData = {}

--    corelog.WriteToLog("T_enterpise_colonization calling CreateNewWorld_ASrv("..textutils.serialize(serviceData)..", ...)")
    return enterprise_colonization.CreateNewWorld_ASrv(serviceData, callback)
end

return t_colonization