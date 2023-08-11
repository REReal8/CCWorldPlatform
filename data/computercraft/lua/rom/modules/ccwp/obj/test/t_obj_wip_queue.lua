local T_WIPQueue = {}
local corelog = require "corelog"

local ModuleRegistry = require "module_registry"
local moduleRegistry = ModuleRegistry:getInstance()
local Callback = require "obj_callback"

local ObjArray = require "obj_array"
local WIPQueue = require "obj_wip_queue"

function T_WIPQueue.T_All()
    -- interfaces
    T_WIPQueue.T_ImplementsIObj()

    -- base methods
    T_WIPQueue.T_addWork()
    T_WIPQueue.T_removeWork()
    T_WIPQueue.T_noWIP()
    T_WIPQueue.T_addCallback()

    -- IObj methods
    T_WIPQueue.T_new()
    T_WIPQueue.T_isTypeOf()
    T_WIPQueue.T_isEqual()
    T_WIPQueue.T_copy()

    -- specific methods
    T_WIPQueue.T_callAndReleaseCallbacks()
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
local callback1 = Callback.GetNewDummyCallBack()

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

local function workListCopy(workList)
    local copy = {}
    for i, aWorkId in ipairs(workList) do
        copy[i] = aWorkId
    end

    -- end
    return copy
end

function T_WIPQueue.T_new()
    -- prepare test
    corelog.WriteToLog("* WIPQueue:new() tests")

    -- test full
    local obj = WIPQueue:new({
        _workList       = workListCopy(workList1),
        _callbackList   = callbackList1:copy(),
    }) assert(obj)
    assert(obj._workList[1] == workId1, "no workId1")
    assert(obj._workList[2] == workId2, "no workId2")
    assert(obj._callbackList:isEqual(callbackList1), "gotten _callbackList(="..textutils.serialise(obj._callbackList)..") not the same as expected(="..textutils.serialise(callbackList1)..")")

    -- cleanup test
end

local function hasWork(workList, someWorkId)
    for i, aWorkId in ipairs(workList) do
        if aWorkId == someWorkId then
            return true
        end
    end

    -- end
    return false
end

function T_WIPQueue.T_addWork()
    -- prepare test
    corelog.WriteToLog("* WIPQueue:addWork() tests")
    local obj1 = WIPQueue:new({
        _workList       = workListCopy(workList1),
        _callbackList   = callbackList1:copy(),
    }) assert(obj1)
    assert(not hasWork(obj1._workList, workId), "workId already present")

    -- test
    obj1:addWork(workId)
    assert(hasWork(obj1._workList, workId), "workId not added")

    -- cleanup test
end

function T_WIPQueue.T_removeWork()
    -- prepare test
    corelog.WriteToLog("* WIPQueue:removeWork() tests")
    local obj1 = WIPQueue:new({
        _workList       = workListCopy(workList1),
        _callbackList   = callbackList1:copy(),
    }) assert(obj1)
    obj1:addWork(workId)
    assert(hasWork(obj1._workList, workId), "workId not added")

    -- test
    obj1:removeWork(workId)
    assert(not hasWork(obj1._workList, workId), "workId not removed")

    -- cleanup test
end

function T_WIPQueue.T_noWIP()
    -- prepare test
    corelog.WriteToLog("* WIPQueue:noWIP() tests")
    local obj1 = WIPQueue:new({
        _workList       = {},
        _callbackList   = callbackList1:copy(),
    }) assert(obj1)

    -- test noWIP
    local noWIP = obj1:noWIP()
    assert(noWIP, "unexpected WIP")

    -- test WIP
    obj1:addWork(workId)
    noWIP = obj1:noWIP()
    assert(not noWIP, "unexpected no WIP")

    -- cleanup test
end

local function hasCallback(callbackList, callback)
    for i, aCallback in ipairs(callbackList) do
        if aCallback:isEqual(callback) then
            return true
        end
    end

    -- end
    return false
end

function T_WIPQueue.T_addCallback()
    -- prepare test
    corelog.WriteToLog("* WIPQueue:addCallback() tests")
    local obj1 = WIPQueue:new({
        _workList       = {},
        _callbackList   = callbackList1:copy(),
    }) assert(obj1)
    assert(not hasCallback(obj1._callbackList, callback1), "callback1 already present")

    -- test
    obj1:addCallback(callback1)
    assert(hasCallback(obj1._callbackList, callback1), "callback1 not added")

    -- cleanup test
end

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

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

function T_WIPQueue.T_isEqual()
    -- prepare test
    corelog.WriteToLog("* WIPQueue:isEqual() tests")
    local obj1 = WIPQueue:new({
        _workList       = workListCopy(workList1),
        _callbackList   = callbackList1:copy(),
    }) assert(obj1)
    local obj2 = WIPQueue:new({
        _workList       = workListCopy(workList1),
        _callbackList   = callbackList1:copy(),
    }) assert(obj2)
    local callbackList2 = ObjArray:new({
        _objClassName   = callbackClassName,

        callback1,
    }) assert(callbackList2)

    -- test same
    local isEqual = obj1:isEqual(obj2)
    local expectedIsEqual = true
    assert(isEqual == expectedIsEqual, "gotten isEqual(="..tostring(isEqual)..") not the same as expected(="..tostring(expectedIsEqual)..")")

    -- test different _workList
    obj2._workList = workListCopy(workList2)
    isEqual = obj1:isEqual(obj2)
    expectedIsEqual = false
    assert(isEqual == expectedIsEqual, "gotten isEqual(="..tostring(isEqual)..") not the same as expected(="..tostring(expectedIsEqual)..")")
    obj2._workList = workListCopy(workList1)

    -- test different _callbackList
    obj2._callbackList = callbackList2:copy()
    isEqual = obj1:isEqual(obj2)
    expectedIsEqual = false
    assert(isEqual == expectedIsEqual, "gotten isEqual(="..tostring(isEqual)..") not the same as expected(="..tostring(expectedIsEqual)..")")
    obj2._callbackList = callbackList1:copy()

    -- cleanup test
end

function T_WIPQueue.T_copy()
    -- prepare test
    corelog.WriteToLog("* WIPQueue:copy() tests")
    local obj1 = WIPQueue:new({
        _workList       = workListCopy(workList1),
        _callbackList   = callbackList1:copy(),
    }) assert(obj1)

    -- test
    local copy = obj1:copy()
    assert(copy:isEqual(obj1), "gotten copy(="..textutils.serialize(copy, compact)..") not the same as expected(="..textutils.serialize(obj1, compact)..")")

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

local callback2Called = false
local callback3Called = false

function T_WIPQueue.T_callAndReleaseCallbacks()
    -- prepare test
    corelog.WriteToLog("* WIPQueue:callAndReleaseCallbacks() tests")
    local obj1 = WIPQueue:new({
        _workList       = {},
        _callbackList   = callbackList1:copy(),
    }) assert(obj1)

    local callback2 = Callback:new({
        _moduleName     = "T_WIPQueue",
        _methodName     = "callAndReleaseCallbacks_Callback",
        _data           = { callbackName = "callback2", },
    })
    obj1:addCallback(callback2)
    callback2Called = false

    local callback3 = Callback:new({
        _moduleName     = "T_WIPQueue",
        _methodName     = "callAndReleaseCallbacks_Callback",
        _data           = { callbackName = "callback3", },
    })
    obj1:addCallback(callback3)
    callback3Called = false

    -- test
    local succes = obj1:callAndReleaseCallbacks(callback1)
    assert(succes, "callAndReleaseCallbacks not a success")
    assert(callback2Called, "callback2 not called")
    assert(not hasCallback(obj1._callbackList, callback2), "callback2 not removed")
    assert(callback3Called, "callback3 not called")
    assert(not hasCallback(obj1._callbackList, callback3), "callback3 not removed")

    -- cleanup test
end

function T_WIPQueue.callAndReleaseCallbacks_Callback(callbackData, serviceResults)
    -- test (cont)
    assert(serviceResults.success, "failed executing async service")

    -- callback2
    if callbackData["callbackName"] == "callback2" then
        callback2Called = true
    end

    -- callback3
    if callbackData["callbackName"] == "callback3" then
        callback3Called = true
    end

    -- cleanup test

    -- end
    return true
end

return T_WIPQueue
