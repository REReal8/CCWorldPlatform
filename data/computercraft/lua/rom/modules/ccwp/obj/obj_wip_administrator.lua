local WIPAdministrator = {
    _wipQueues = nil,
}

local corelog = require "corelog"

local InputChecker = require "input_checker"
local Callback = require "obj_callback"

local ObjArray = require "obj_array"
local WIPQueue = require "obj_wip_queue"

local enterprise_administration

--[[
    This module implements the WIPAdministrator class.

    The WIPAdministrator offers methods for administering Work In Progress (WIP) of entities.
--]]

--    _                                     _   _               _
--   | |                                   | | | |             | |
--   | |__   __ _ ___  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   | '_ \ / _` / __|/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   | |_) | (_| \__ \  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_.__/ \__,_|___/\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

function WIPAdministrator:getWIPQueue(...)
    -- get & check input from description
    local checkSuccess, queueId = InputChecker.Check([[
        This method returns the WIPQueue 'queueId'.

        Return value:
            queue                               - (WIPQueue) with id 'queueId'

        Parameters:
            queueId                             + (string) with the id of the WIPQueue
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("WIPAdministrator:getWIPQueue: Invalid input") return nil end

    -- get queue
    local queue = self._wipQueues[queueId]
    if not queue then
--        corelog.WriteToLog("WIPAdministrator:getWIPQueue: WIPQueue with id="..queueId.." not yet found. Creating it")

        -- create new queue
        local callbackList = ObjArray:new({
            _objClassName   = "Callback",
        })
        queue = WIPQueue:new({
            _workList       = {},
            _callbackList   = callbackList,
        })

        -- add it to the WIPAdministrator
        self._wipQueues[queueId] = queue

        -- save
        enterprise_administration = require "enterprise_administration"
        local objLocator = enterprise_administration:saveObject(self)
        if not objLocator then corelog.Error("WIPAdministrator:getWIPQueue: Failed saving WIPAdministrator") return false end
    end

    -- end
    return queue
end

function WIPAdministrator:removeWIPQueue(...)
    -- get & check input from description
    local checkSuccess, queueId = InputChecker.Check([[
        This method removes the WIPQueue 'queueId'.

        Return value:
                                                - (boolean) whether the method was called successfully

        Parameters:
            queueId                             + (string) with the id of the WIPQueue
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("WIPAdministrator:removeWIPQueue: Invalid input") return false end

    -- get queue
    local queue = self._wipQueues[queueId]
    if not queue then corelog.Warning("WIPAdministrator:removeWIPQueue: WIPQueue "..queueId.." not present") return false end

    -- check no WIP remaining
    if not queue:noWIP() then corelog.Warning("WIPAdministrator:removeWIPQueue: WIP remaining on WIPQueue "..queueId.." => removing WIPQueue anyway ") end

    -- remove WIPQueue
    self._wipQueues[queueId] = nil

    -- save
    enterprise_administration = require "enterprise_administration"
    local objLocator = enterprise_administration:saveObject(self)
    if not objLocator then corelog.Error("WIPAdministrator:getWIPQueue: Failed saving WIPAdministrator") return false end

    -- end
    return true
end

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

function WIPAdministrator:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a WIPAdministrator.

        Parameters:
            o                           + (table) table with object fields
                _wipQueues              - (ObjTable) with WIPQueue's
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("WIPAdministrator:new: Invalid input") return {} end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- end
    return o
end

function WIPAdministrator:getClassName()
    return "WIPAdministrator"
end

function WIPAdministrator:isTypeOf(obj)
    local metatable = getmetatable(obj)
    while metatable do
        if metatable.__index == self or obj == self then
            return true
        end
        metatable = getmetatable(metatable.__index)
    end
    return false
end

function WIPAdministrator:isSame(obj)
    -- check input
    if not WIPAdministrator:isTypeOf(obj) then return false end

    -- check same object
    if not self._wipQueues:isSame(obj._wipQueues) then return false end

    -- end
    return true
end

function WIPAdministrator:copy()
    local copy = WIPAdministrator:new({
        _wipQueues  = self._wipQueues:copy(),
    })

    return copy
end

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

function WIPAdministrator:administerWorkStarted(...)
    -- get & check input from description
    local checkSuccess, queueId, workId = InputChecker.Check([[
        This method administers work identified by 'workId' to WIPQueue 'queueId'.

        Return value:
                                                - (boolean) whether the method was called successfully

        Parameters:
            queueId                             + (string) with the id of the WIPQueue
            workId                              + (string) with the id of the work
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("WIPAdministrator:administerWorkStarted: Invalid input") return false end

    -- get queue
    local queue = self:getWIPQueue(queueId)
    if not queue then corelog.Error("WIPAdministrator:administerWorkStarted: Failed obtaining WIPQueue "..queueId) return false end

    -- add work
    local success = queue:addWork(workId)
    if not success then corelog.Error("WIPAdministrator:administerWorkStarted: Failed adding work "..workId.." to WIPQueue "..queueId) return false end

    -- save
    enterprise_administration = require "enterprise_administration"
    local objLocator = enterprise_administration:saveObject(self)
    if not objLocator then corelog.Error("WIPAdministrator:administerWorkStarted: Failed saving WIPAdministrator") return false end

    -- end
    return true
end

function WIPAdministrator:administerWorkCompleted(...)
    -- get & check input from description
    local checkSuccess, queueId, workId = InputChecker.Check([[
        This method removes work identified by 'workId' from the WIPQueue 'queueId'.

        If no work is left in the queue all callbacks wanting to be informed on idle are called.

        Return value:
                                                - (boolean) whether the method was called successfully

        Parameters:
            queueId                             + (string) with the id of the WIPQueue
            workId                              + (string) with the id of the work
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("WIPAdministrator:administerWorkCompleted: Invalid input") return false end

    -- get queue
    local queue = self:getWIPQueue(queueId)
    if not queue then corelog.Error("WIPAdministrator:administerWorkCompleted: Failed obtaining WIPQueue "..queueId) return false end

    -- remove work
    local success = queue:removeWork(workId)
    if not success then corelog.Error("WIPAdministrator:administerWorkCompleted: Failed removing work "..workId.." from WIPQueue "..queueId) return false end

    -- check queue is idle (i.e. no WIP)
    if queue:noWIP() then
        -- call Callback's in callbackList of queue and clean the callbackList
        success = queue:callAndReleaseCallbacks()
        if not success then corelog.Error("WIPAdministrator:administerWorkCompleted: Failed calling Callbacks from WIPQueue "..queueId) return false end

        -- remove queue
        self._wipQueues.queueId = nil
    end

    -- save
    enterprise_administration = require "enterprise_administration"
    local objLocator = enterprise_administration:saveObject(self)
    if not objLocator then corelog.Error("WIPAdministrator:administerWorkCompleted: Failed saving WIPAdministrator") return false end

    -- end
    return true
end

function WIPAdministrator:waitForNoWIPOnQueue_AOSrv(...)
    -- get & check input from description
    local checkSuccess, queueId, callback = InputChecker.Check([[
        This async public service ensures the callback is called once the WIPQueue 'queueId' has no WIP.

        Return value:
                                                - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                                - (table)
                success                         - (boolean) whether the service executed successfully

        Parameters:
            serviceData                         - (table) data about this site
                queueId                         + (string) with the id of the WIP queue
            callback                            + (Callback) to call once service is ready
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("WIPAdministrator:waitForNoWIPOnQueue_AOSrv: Invalid input") return Callback.ErrorCall(callback) end

    -- get queue
    local queue = self:getWIPQueue(queueId)
    if not queue then corelog.Error("WIPAdministrator:waitForNoWIPOnQueue_AOSrv: Failed obtaining WIPQueue "..queueId) return false end

    -- check queue is idle (i.e. no WIP)
    if queue:noWIP() then
        -- immediatly call callback
        return callback:call({success = true})
    else
        -- add callback to callbackList of queue
        local success = queue:addCallback(callback)
        if not success then corelog.Error("WIPAdministrator:waitForNoWIPOnQueue_AOSrv: Failed adding Callback to WIPQueue "..queueId) return false end

        -- save
        enterprise_administration = require "enterprise_administration"
        local objLocator = enterprise_administration:saveObject(self)
        if not objLocator then corelog.Error("WIPAdministrator:waitForNoWIPOnQueue_AOSrv: Failed saving WIPAdministrator") return false end
    end

    -- end
    return true
end

return WIPAdministrator