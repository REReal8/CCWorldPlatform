local T_WIPAdministrator = {}
local corelog = require "corelog"

local ModuleRegistry = require "module_registry"
local moduleRegistry = ModuleRegistry:getInstance()
local Callback = require "obj_callback"

local ObjArray = require "obj_array"
local ObjTable = require "obj_table"
local WIPQueue = require "obj_wip_queue"
local WIPAdministrator = require "obj_wip_administrator"

local enterprise_administration = require "enterprise_administration"

function T_WIPAdministrator.T_All()
    -- interfaces
    T_WIPAdministrator.T_ImplementsIObj()

    -- base methods
    T_WIPAdministrator.T_removeWIPQueue()
    T_WIPAdministrator.T_getWIPQueue()

    -- IObj methods
    T_WIPAdministrator.T_new()
    T_WIPAdministrator.T_isTypeOf()
    T_WIPAdministrator.T_isSame()
    T_WIPAdministrator.T_copy()

    -- specific methods
    T_WIPAdministrator.T_administerWorkStarted()
    T_WIPAdministrator.T_waitForNoWIPOnQueue_AOSrv()
    T_WIPAdministrator.T_administerWorkCompleted()
end

local workId1 = "workId1"
local workId2 = "workId2"
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


function T_WIPAdministrator.T_removeWIPQueue()
    -- prepare test
    corelog.WriteToLog("* WIPAdministrator:removeWIPQueue() tests")
    local wipQueueId1 = "wipQueueId1"
    local wipQueue1 = WIPQueue:new({
        _workList       = {},
        _callbackList   = callbackList1:copy(),
    }) assert(wipQueue1)

    local wipQueues2 = ObjTable:new({
        _objClassName   = wipQueueClassName,
    }) assert(wipQueues2)
    wipQueues2[wipQueueId1] = wipQueue1
    local obj1 = WIPAdministrator:new({
        _wipQueues      = wipQueues2:copy(),
    }) assert(obj1)

    -- test
    local success = obj1:removeWIPQueue(wipQueueId1)
    assert(success, "removeWIPQueue failed")
    assert(not obj1._wipQueues[wipQueueId1], "WIPQueue not removed")

    -- cleanup test
end

function T_WIPAdministrator.T_getWIPQueue()
    -- prepare test
    corelog.WriteToLog("* WIPAdministrator:getWIPQueue() tests")
    local wipQueueId1 = "wipQueueId1"
    local workList1 = {
        workId1,
        workId2,
    }
    local wipQueue1 = WIPQueue:new({
        _workList       = workList1,
        _callbackList   = callbackList1:copy(),
    }) assert(wipQueue1)

    local wipQueues2 = ObjTable:new({
        _objClassName   = wipQueueClassName,
    }) assert(wipQueues2)
    wipQueues2[wipQueueId1] = wipQueue1
    local obj1 = WIPAdministrator:new({
        _wipQueues      = wipQueues2,
    }) assert(obj1)

    -- test returns already present WIPQueue
    local wipQueue = obj1:getWIPQueue(wipQueueId1)
    assert(wipQueue:isSame(wipQueue1), "gotten wipQueue(="..textutils.serialise(wipQueue)..") not the same as expected(="..textutils.serialise(wipQueue1)..")")

    -- test creates not yet present WIPQueue
    local wipQueueId2 = "wipQueueId2"
    wipQueue = obj1:getWIPQueue(wipQueueId2)
    assert(wipQueue, "WIPQueue not created")
    assert(wipQueue:noWIP(), "gotten wipQueue(="..textutils.serialise(wipQueue)..") has WIP (and hence can't be new)")

    -- cleanup test
    wipQueue1:removeWork(workId1)
    wipQueue1:removeWork(workId2)
    obj1:removeWIPQueue(wipQueueId1)
    obj1:removeWIPQueue(wipQueueId2)
end

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

local function hasWork(workList, someWorkId)
    for i, aWorkId in ipairs(workList) do
        if aWorkId == someWorkId then
            return true
        end
    end

    -- end
    return false
end

function T_WIPAdministrator.T_administerWorkStarted()
    -- prepare test
    corelog.WriteToLog("* WIPAdministrator:administerWorkStarted() tests")
    local obj1 = WIPAdministrator:new({
        _wipQueues      = wipQueues1:copy(),
    }) assert(obj1)
    local workId3 = "workId3"
    local wipQueueId2 = "wipQueueId2"

    -- test
    local success = obj1:administerWorkStarted(wipQueueId2, workId3)
    assert(success, "administerWorkStarted did not succeed")
    local wipQueue = obj1:getWIPQueue(wipQueueId2)
    assert(hasWork(wipQueue._workList, workId3), "workId3 not registered")

    -- cleanup test
    wipQueue:removeWork(workId3)
    obj1:removeWIPQueue(wipQueueId2)
end

local callback1Called = false
local callback1 = Callback:new({
    _moduleName     = "T_WIPAdministrator",
    _methodName     = "waitForNoWIPOnQueue_AOSrv_Callback",
    _data           = { callbackName = "callback1", },
})

local function hasCallback(callbackList, callback)
    for i, aCallback in ipairs(callbackList) do
        if aCallback:isSame(callback) then
            return true
        end
    end

    -- end
    return false
end

function T_WIPAdministrator.T_waitForNoWIPOnQueue_AOSrv()
    -- prepare test
    corelog.WriteToLog("* WIPAdministrator:waitForNoWIPOnQueue_AOSrv() tests")
    local obj1 = WIPAdministrator:new({
        _wipQueues      = wipQueues1:copy(),
    }) assert(obj1)

    callback1Called = false

    local wipQueueId2 = "wipQueueId2"

    -- test callback called when no WIP
    local success = obj1:waitForNoWIPOnQueue_AOSrv({queueId = wipQueueId2}, callback1)
    assert(success, "waitForNoWIPOnQueue_AOSrv not a success")
    assert(callback1Called, "callback1 not called")
    callback1Called = false

    -- test callback not called and added when WIP
    local workId3 = "workId3"
    obj1:administerWorkStarted(wipQueueId2, workId3)
    success = obj1:waitForNoWIPOnQueue_AOSrv({queueId = wipQueueId2}, callback1)
    assert(success, "waitForNoWIPOnQueue_AOSrv not a success")
    assert(not callback1Called, "callback1 called")
    local wipQueue = obj1:getWIPQueue(wipQueueId2)
    assert(hasCallback(wipQueue._callbackList, callback1), "callback1 not added")

    -- cleanup test
    wipQueue:removeWork(workId3)
    obj1:removeWIPQueue(wipQueueId2)
end

function T_WIPAdministrator.waitForNoWIPOnQueue_AOSrv_Callback(callbackData, serviceResults)
    -- test (cont)
    assert(serviceResults.success, "failed executing async service")

    -- callback2
    if callbackData["callbackName"] == "callback1" then
        callback1Called = true
    end

    -- cleanup test

    -- end
    return true
end

function T_WIPAdministrator.T_administerWorkCompleted()
    -- prepare test
    corelog.WriteToLog("* WIPAdministrator:administerWorkCompleted() tests")
    local obj1 = WIPAdministrator:new({
        _wipQueues      = wipQueues1:copy(),
    }) assert(obj1)
    local workId3 = "workId3"
    local wipQueueId2 = "wipQueueId2"
    obj1:administerWorkStarted(wipQueueId2, workId3)
    local workId4 = "workId4"

    -- test work removed
    local success = obj1:administerWorkCompleted(wipQueueId2, workId3)
    assert(success, "administerWorkCompleted did not succeed")
    local wipQueue = obj1:getWIPQueue(wipQueueId2)
    assert(not hasWork(wipQueue._workList, workId3), "workId3 not removed")

    -- test callback(s) not called when still WIP
    obj1:administerWorkStarted(wipQueueId2, workId3)
    obj1:administerWorkStarted(wipQueueId2, workId4)
    callback1Called = false
    success = obj1:waitForNoWIPOnQueue_AOSrv({queueId = wipQueueId2}, callback1)

    success = obj1:administerWorkCompleted(wipQueueId2, workId3)
    assert(success, "administerWorkCompleted did not succeed")
    assert(not callback1Called, "callback1 called")

    -- test callback(s) called when no more WIP
    success = obj1:administerWorkCompleted(wipQueueId2, workId4)
    assert(success, "administerWorkCompleted did not succeed")
    assert(callback1Called, "callback1 not called")

    -- cleanup test
    obj1:removeWIPQueue(wipQueueId2)
end

return T_WIPAdministrator