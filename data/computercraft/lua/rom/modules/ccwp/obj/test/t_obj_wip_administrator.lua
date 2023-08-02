local T_WIPAdministrator = {}
local corelog = require "corelog"

local ModuleRegistry = require "module_registry"
local moduleRegistry = ModuleRegistry:getInstance()
local Callback = require "obj_callback"

local ObjArray = require "obj_array"
local ObjTable = require "obj_table"
local WIPQueue = require "obj_wip_queue"
local WIPAdministrator = require "obj_wip_administrator"

function T_WIPAdministrator.T_All()
    -- interfaces
    T_WIPAdministrator.T_ImplementsIObj()

    -- base methods

    -- IObj methods
    T_WIPAdministrator.T_new()
    T_WIPAdministrator.T_isTypeOf()
    T_WIPAdministrator.T_isSame()
    T_WIPAdministrator.T_copy()

    -- specific methods
end

local callbackClassName = "Callback"
local callbackList1 = ObjArray:new({
    _objClassName   = callbackClassName,
}) if not callbackList1 then return end
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

function T_WIPAdministrator.T_new()
    -- prepare test
    corelog.WriteToLog("* WIPAdministrator:new() tests")

    -- test
    local obj = WIPAdministrator:new({
        _wipQueues      = wipQueues1:copy(),
    }) assert(obj)
    assert(obj._wipQueues:isSame(wipQueues1), "gotten _wipQueues(="..textutils.serialise(obj._wipQueues)..") not the same as expected(="..textutils.serialise(wipQueues1)..")")

    -- cleanup test
end

function T_WIPAdministrator.T_isTypeOf()
    -- prepare test
    corelog.WriteToLog("* WIPAdministrator:isTypeOf() tests")
    local obj2 = WIPAdministrator:new({
        _wipQueues      = wipQueues1:copy(),
    })

    -- test valid
    local isTypeOf = WIPAdministrator:isTypeOf(obj2)
    local expectedIsTypeOf = true
    assert(isTypeOf == expectedIsTypeOf, "gotten isTypeOf(="..tostring(isTypeOf)..") not the same as expected(="..tostring(expectedIsTypeOf)..")")

    -- test different object
    isTypeOf = WIPAdministrator:isTypeOf("a atring")
    expectedIsTypeOf = false
    assert(isTypeOf == expectedIsTypeOf, "gotten isTypeOf(="..tostring(isTypeOf)..") not the same as expected(="..tostring(expectedIsTypeOf)..")")

    -- cleanup test
end

function T_WIPAdministrator.T_isSame()
    -- prepare test
    corelog.WriteToLog("* WIPAdministrator:isSame() tests")
    local obj1 = WIPAdministrator:new({
        _wipQueues      = wipQueues1:copy(),
    }) assert(obj1)

    local obj2 = WIPAdministrator:new({
        _wipQueues      = wipQueues1:copy(),
    }) assert(obj2)

    local workId1 = "id1"
    local workId2 = "id2"
    local workList1 = {
        workId1,
        workId2,
    }
    local wipQueue1 = WIPQueue:new({
        _workList       = workList1,
        _callbackList   = callbackList1:copy(),
    }) assert(obj1)
    local wipQueues2 = ObjTable:new({
        _objClassName   = wipQueueClassName,

        wipQueue1,
    }) assert(wipQueues2)

    -- test same
    local isSame = obj1:isSame(obj2)
    local expectedIsSame = true
    assert(isSame == expectedIsSame, "gotten isSame(="..tostring(isSame)..") not the same as expected(="..tostring(expectedIsSame)..")")

    -- test different _wipQueues
    obj2._wipQueues = wipQueues2:copy()
    isSame = obj1:isSame(obj2)
    expectedIsSame = false
    assert(isSame == expectedIsSame, "gotten isSame(="..tostring(isSame)..") not the same as expected(="..tostring(expectedIsSame)..")")
    obj2._workList = wipQueues1:copy()

    -- cleanup test
end

function T_WIPAdministrator.T_copy()
    -- prepare test
    corelog.WriteToLog("* WIPAdministrator:copy() tests")
    local obj1 = WIPAdministrator:new({
        _wipQueues      = wipQueues1:copy(),
    }) assert(obj1)

    -- test
    local copy = obj1:copy()
    assert(copy:isSame(obj1), "gotten copy(="..textutils.serialize(copy, compact)..") not the same as expected(="..textutils.serialize(obj1, compact)..")")

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

return T_WIPAdministrator
