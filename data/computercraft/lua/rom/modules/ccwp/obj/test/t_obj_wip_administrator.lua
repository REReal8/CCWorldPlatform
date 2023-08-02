local T_WIPAdministrator = {}
local corelog = require "corelog"

local ModuleRegistry = require "module_registry"
local moduleRegistry = ModuleRegistry:getInstance()
local Callback = require "obj_callback"

local ObjArray = require "obj_array"
local ObjTable = require "obj_table"
local WIPAdministrator = require "obj_wip_administrator"

function T_WIPAdministrator.T_All()
    -- interfaces
    T_WIPAdministrator.T_ImplementsIObj()

    -- base methods

    -- IObj methods

    -- specific methods
end

local workId1 = "id1"
local workId2 = "id2"
local workList1 = {
    workId1,
    workId2,
}
local workId3 = "id3"
local workList2 = {
    workId1,
    workId2,
    workId3,
}
local workId = "id"
local callbackClassName = "Callback"
local callbackList1 = ObjArray:new({
    _objClassName   = callbackClassName,
}) if not callbackList1 then return end
local callback1 = Callback:new({
    _moduleName     = "enterprise_assignmentboard",
    _methodName     = "Dummy_Callback",
    _data           = {},
})
local wipQueueClassName = "WIPQueue"
local wipQueues1 = ObjTable:new({
    _objClassName   = wipQueueClassName,
}) assert(wipQueues1)

local compact = { compact = true }

--    _       _             __
--   (_)     | |           / _|
--    _ _ __ | |_ ___ _ __| |_ __ _  ___ ___  ___
--   | | '_ \| __/ _ \ '__|  _/ _` |/ __/ _ \/ __|
--   | | | | | ||  __/ |  | || (_| | (_|  __/\__ \
--   |_|_| |_|\__\___|_|  |_| \__,_|\___\___||___/

local function ImplementsInterface(interfaceName)
    -- prepare test
    corelog.WriteToLog("* WIPAdministrator "..interfaceName.." interface test")
    local Interface = moduleRegistry:getModule(interfaceName)
    local obj = WIPAdministrator:new({
        _wipQueues      = wipQueues1:copy(),
    }) if not obj then corelog.Error("failed obtaining WIPAdministrator") return end

    -- test
    local implementsInterface = Interface.ImplementsInterface(obj)
    assert(implementsInterface, "WIPAdministrator class does not (fully) implement "..interfaceName.." interface")

    -- cleanup test
end

function T_WIPAdministrator.T_ImplementsIObj()
    ImplementsInterface("IObj")
end

--    _                                     _   _               _
--   | |                                   | | | |             | |
--   | |__   __ _ ___  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   | '_ \ / _` / __|/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   | |_) | (_| \__ \  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_.__/ \__,_|___/\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|


return T_WIPAdministrator
