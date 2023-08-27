local T_WIPAdministrator = {}
local corelog = require "corelog"

local ModuleRegistry = require "module_registry"
local moduleRegistry = ModuleRegistry:getInstance()
local Callback = require "obj_callback"

local IObj = require "i_obj"
local ObjBase = require "obj_base"
local ObjArray = require "obj_array"
local ObjTable = require "obj_table"
local WIPQueue = require "obj_wip_queue"
local WIPAdministrator = require "obj_wip_administrator"

local T_Class = require "test.t_class"
local T_IObj = require "test.t_i_obj"
local T_WIPQueue = require "test.t_obj_wip_queue"

function T_WIPAdministrator.T_All()
    -- initialisation
    T_WIPAdministrator.T_new()

    -- IObj methods
    T_WIPAdministrator.T_IObj_All()

    -- specific methods
    T_WIPAdministrator.T_removeWIPQueue()
    T_WIPAdministrator.T_getWIPQueue()
    T_WIPAdministrator.T_reset()
    T_WIPAdministrator.T_administerWorkStarted()
    T_WIPAdministrator.T_waitForNoWIPOnQueue_AOSrv()
    T_WIPAdministrator.T_administerWorkCompleted()
end

local workId1 = "workId1"
local workId2 = "workId2"
local callbackClassName = "Callback"
local callbackList1 = ObjArray:newInstance(callbackClassName) assert(callbackList1, "Failed obtaining callbackList1")
local wipQueueClassName = "WIPQueue"
local wipQueues1 = ObjTable:newInstance(wipQueueClassName) assert(wipQueues1, "Failed obtaining wipQueues1")

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

local testClassName = "WIPAdministrator"
function T_WIPAdministrator.CreateTestObj()
    local wipQueue = T_WIPQueue.CreateTestObj() assert(wipQueue, "Failed obtaining WIPQueue")
    local wipQueues = ObjTable:newInstance(wipQueueClassName, {
        wipQueue,
    }) assert(wipQueues1)

    local testObj = WIPAdministrator:new({
        _wipQueues  = wipQueues,
    })

    return testObj
end

function T_WIPAdministrator.T_new()
    -- prepare test
    corelog.WriteToLog("* WIPAdministrator:new() tests")

    -- test
    local obj = WIPAdministrator:new({
        _wipQueues      = wipQueues1:copy(),
    }) assert(obj)
    assert(obj._wipQueues:isEqual(wipQueues1), "gotten _wipQueues(="..textutils.serialise(obj._wipQueues)..") not the same as expected(="..textutils.serialise(wipQueues1)..")")

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

function T_WIPAdministrator.T_IObj_All()
    -- prepare test
    local obj = T_WIPAdministrator.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_WIPAdministrator.CreateTestObj() assert(otherObj, "Failed obtaining "..testClassName)

    -- test
    T_Class.pt_IsInstanceOf(testClassName, obj, "IObj", IObj)
    T_Class.pt_IsInstanceOf(testClassName, obj, "ObjBase", ObjBase)
    T_IObj.pt_all(testClassName, obj, otherObj)
end

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

function T_WIPAdministrator.T_removeWIPQueue()
    -- prepare test
    corelog.WriteToLog("* WIPAdministrator:removeWIPQueue() tests")
    local wipQueueId1 = "wipQueueId1"
    local wipQueue1 = WIPQueue:new({
        _workList       = {},
        _callbackList   = callbackList1:copy(),
    }) assert(wipQueue1)

    local wipQueues2 = ObjTable:newInstance(wipQueueClassName) assert(wipQueues2)
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

    local wipQueues2 = ObjTable:newInstance(wipQueueClassName) assert(wipQueues2)
    wipQueues2[wipQueueId1] = wipQueue1
    local obj1 = WIPAdministrator:new({
        _wipQueues      = wipQueues2,
    }) assert(obj1)

    -- test returns already present WIPQueue
    local wipQueue = obj1:getWIPQueue(wipQueueId1)
    assert(wipQueue:isEqual(wipQueue1), "gotten wipQueue(="..textutils.serialise(wipQueue)..") not the same as expected(="..textutils.serialise(wipQueue1)..")")

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

function T_WIPAdministrator.T_reset()
    -- prepare test
    corelog.WriteToLog("* WIPAdministrator:reset() tests")
    local wipQueueId1 = "wipQueueId1"
    local wipQueue1 = WIPQueue:new({
        _workList       = {},
        _callbackList   = callbackList1:copy(),
    }) assert(wipQueue1)

    local wipQueues = ObjTable:newInstance(wipQueueClassName) assert(wipQueues)
    wipQueues[wipQueueId1] = wipQueue1
    local obj1 = WIPAdministrator:new({
        _wipQueues      = wipQueues:copy(),
    }) assert(obj1)

    -- test
    local success = obj1:reset(wipQueueId1)
    assert(success, "reset failed")
    assert(not obj1._wipQueues[wipQueueId1], "WIPQueue not removed")

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
        if aCallback:isEqual(callback) then
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
    assert(obj1._wipQueues[wipQueueId2] == nil, "WIPQueue not removed when no WIP")

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
    assert(obj1._wipQueues[wipQueueId2] ~= nil, "WIPQueue not in WIPAdministrator")

    -- test callback(s) called when no more WIP
    success = obj1:administerWorkCompleted(wipQueueId2, workId4)
    assert(success, "administerWorkCompleted did not succeed")
    assert(callback1Called, "callback1 not called")
    assert(obj1._wipQueues[wipQueueId2] == nil, "WIPQueue not removed after no WIP")

    -- cleanup test
end

return T_WIPAdministrator
