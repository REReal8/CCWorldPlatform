local T_WIPQueue = {}
local corelog = require "corelog"

local InputChecker = require "input_checker"
local ModuleRegistry = require "module_registry"
local moduleRegistry = ModuleRegistry:getInstance()
local Callback = require "obj_callback"

local ObjArray = require "obj_array"
local WIPQueue = require "obj_wip_queue"

function T_WIPQueue.T_All()
    -- interfaces
    T_WIPQueue.T_ImplementsIObj()

    -- base methods
    T_WIPQueue.T_new()
    T_WIPQueue.T_isTypeOf()
    T_WIPQueue.T_isSame()
    T_WIPQueue.T_copy()

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
local callbackClassName = "Callback"
local callbackList1 = ObjArray:new({
    _objClassName   = callbackClassName,
}) if not callbackList1 then return end

local compact = { compact = true }

--    _       _             __
--   (_)     | |           / _|
--    _ _ __ | |_ ___ _ __| |_ __ _  ___ ___  ___
--   | | '_ \| __/ _ \ '__|  _/ _` |/ __/ _ \/ __|
--   | | | | | ||  __/ |  | || (_| | (_|  __/\__ \
--   |_|_| |_|\__\___|_|  |_| \__,_|\___\___||___/

local function ImplementsInterface(interfaceName)
    -- prepare test
    corelog.WriteToLog("* WIPQueue "..interfaceName.." interface test")
    local Interface = moduleRegistry:getModule(interfaceName)
    local obj = WIPQueue:new({
        _workList       = workList1,
        _callbackList   = callbackList1:copy(),
    }) if not obj then corelog.Error("failed obtaining WIPQueue") return end

    -- test
    local implementsInterface = Interface.ImplementsInterface(obj)
    assert(implementsInterface, "WIPQueue class does not (fully) implement "..interfaceName.." interface")

    -- cleanup test
end

function T_WIPQueue.T_ImplementsIObj()
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

function T_WIPQueue.T_new()
    -- prepare test
    corelog.WriteToLog("* WIPQueue:new() tests")

    -- test full
    local obj = WIPQueue:new({
        _workList       = workList1,
        _callbackList   = callbackList1:copy(),
    }) assert(obj)
    assert(obj._workList[1] == workId1, "no workId1")
    assert(obj._workList[2] == workId2, "no workId2")
    assert(obj._callbackList:isSame(callbackList1), "gotten _callbackList(="..textutils.serialise(obj._callbackList)..") not the same as expected(="..textutils.serialise(callbackList1)..")")

    -- cleanup test
end

function T_WIPQueue.T_isTypeOf()
    -- prepare test
    corelog.WriteToLog("* WIPQueue:isTypeOf() tests")
    local obj2 = WIPQueue:new({
        _workList       = workList1,
        _callbackList   = callbackList1:copy(),
    })

    -- test valid
    local isTypeOf = WIPQueue:isTypeOf(obj2)
    local expectedIsTypeOf = true
    assert(isTypeOf == expectedIsTypeOf, "gotten isTypeOf(="..tostring(isTypeOf)..") not the same as expected(="..tostring(expectedIsTypeOf)..")")

    -- test different object
    isTypeOf = WIPQueue:isTypeOf("a atring")
    expectedIsTypeOf = false
    assert(isTypeOf == expectedIsTypeOf, "gotten isTypeOf(="..tostring(isTypeOf)..") not the same as expected(="..tostring(expectedIsTypeOf)..")")

    -- cleanup test
end

function T_WIPQueue.T_isSame()
    -- prepare test
    corelog.WriteToLog("* WIPQueue:isSame() tests")
    local obj1 = WIPQueue:new({
        _workList       = workList1,
        _callbackList   = callbackList1:copy(),
    }) assert(obj1)
    local obj2 = WIPQueue:new({
        _workList       = workList1,
        _callbackList   = callbackList1:copy(),
    }) assert(obj2)
    local callback1 = Callback:new({
        _moduleName     = "enterprise_assignmentboard",
        _methodName     = "Dummy_Callback",
        _data           = {},
    })
    local callbackList2 = ObjArray:new({
        _objClassName   = callbackClassName,

        callback1,
    }) assert(callbackList2)

    -- test same
    local isSame = obj1:isSame(obj2)
    local expectedIsSame = true
    assert(isSame == expectedIsSame, "gotten isSame(="..tostring(isSame)..") not the same as expected(="..tostring(expectedIsSame)..")")

    -- test different _workList
    obj2._workList = workList2
    isSame = obj1:isSame(obj2)
    expectedIsSame = false
    assert(isSame == expectedIsSame, "gotten isSame(="..tostring(isSame)..") not the same as expected(="..tostring(expectedIsSame)..")")
    obj2._workList = workList1

    -- test different _callbackList
    obj2._callbackList = callbackList2:copy()
    isSame = obj1:isSame(obj2)
    expectedIsSame = false
    assert(isSame == expectedIsSame, "gotten isSame(="..tostring(isSame)..") not the same as expected(="..tostring(expectedIsSame)..")")
    obj2._callbackList = callbackList1:copy()

    -- cleanup test
end

function T_WIPQueue.T_copy()
    -- prepare test
    corelog.WriteToLog("* WIPQueue:copy() tests")
    local obj1 = WIPQueue:new({
        _workList       = workList1,
        _callbackList   = callbackList1:copy(),
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

return T_WIPQueue
