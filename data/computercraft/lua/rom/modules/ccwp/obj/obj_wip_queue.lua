local WIPQueue = {
    _workList       = {},
    _callbackList   = nil,
}

local corelog = require "corelog"

local InputChecker = require "input_checker"

--[[
    This module implements the WIPQueue class.

    A WIPQueue stores administrative information for Work In Progress (WIP) on an entity.

    An example case is registering all the WIP for an MObj.

    It is typically used in combination with the WIPAdministrator.
--]]

--    _                                     _   _               _
--   | |                                   | | | |             | |
--   | |__   __ _ ___  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   | '_ \ / _` / __|/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   | |_) | (_| \__ \  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_.__/ \__,_|___/\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

function WIPQueue:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a WIPQueue.

        Parameters:
            o                           + (table) table with object fields
                _workList               - (table) with workId's
                _callbackList           - (ObjArray) with Callback's
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("WIPQueue:new: Invalid input") return nil end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- end
    return o
end

function WIPQueue:addWork(...)
    -- get & check input from description
    local checkSuccess, workId = InputChecker.Check([[
        This method adds work identified by 'workId' to the queue.

        Return value:
                                                - (boolean) whether the method was called successfully

        Parameters:
            workId                              + (string) with the id of the work
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("WIPQueue:addWork: Invalid input") return false end

    -- add to _workList
    table.insert(self._workList, workId)

    -- end
    return true
end

function WIPQueue:removeWork(...)
    -- get & check input from description
    local checkSuccess, workId = InputChecker.Check([[
        This method removes work identified by 'workId' from the queue.

        Return value:
                                                - (boolean) whether the method was called successfully

        Parameters:
            workId                              + (string) with the id of the work
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("WIPQueue:removeWork: Invalid input") return false end

    -- remove from _workList
    for i, aWorkId in ipairs(self._workList) do
        if aWorkId == workId then
            table.remove(self._workList, i)
            return true
        end
    end

    -- end
    return false
end

function WIPQueue:noWIP()
    --[[
        This method returns if the queue administers any work in progress.

        Return value:
                                                - (boolean) whether the queue is empty

        Parameters:
    ]]

    -- check _workList empty
    local noWIP = next(self._workList) == nil

    -- end
    return noWIP
end

function WIPQueue:addCallback(...)
    -- get & check input from description
    local checkSuccess, callback = InputChecker.Check([[
        This method adds a Callback to the queue.

        Return value:
                                                - (boolean) whether the method was called successfully

        Parameters:
            callback                            + (Callback) to call once service is ready
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("WIPQueue:addCallback: Invalid input") return false end

    -- add to _callbackList
    table.insert(self._callbackList, callback)

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

function WIPQueue:getClassName()
    return "WIPQueue"
end

function WIPQueue:isTypeOf(obj)
    local metatable = getmetatable(obj)
    while metatable do
        if metatable.__index == self or obj == self then
            return true
        end
        metatable = getmetatable(metatable.__index)
    end
    return false
end

function WIPQueue:isEqual(obj)
    -- check input
    if not WIPQueue:isTypeOf(obj) then return false end

    -- check same _callbackList
    if not self._callbackList:isEqual(obj._callbackList) then return false end

    -- check same _workList
    if table.getn(self._workList) ~= table.getn(obj._workList) then return false end
    for i, workIdA in ipairs(self._workList) do
        -- check same work
        local workIdB = obj._workList[i]
        if workIdA ~= workIdB then return false end
    end

    -- end
    return true
end

function WIPQueue:copy()
    -- copy _workList
    local workListCopy = {}
    for i, workId in ipairs(self._workList) do
        workListCopy[i] = workId
    end

    -- copy WIPQueue
    local copy = WIPQueue:new({
        _workList       = workListCopy,

        _callbackList   = self._callbackList:copy(),
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

function WIPQueue:callAndReleaseCallbacks()
    --[[
        This method calls all callbacks and removes them from the queue

        Return value:
                                                - (boolean) whether all callbacks where successfully called

        Parameters:
    ]]

    -- call and remove all callbacks
    local nCallbacks = #(self._callbackList)
    for i=nCallbacks, 1, -1 do
        -- get Callback
        local callback = self._callbackList[i]

        -- call Callback
        callback:call({success = true})

        -- remove from ObjArray
        table.remove(self._callbackList, i)
    end

    -- end
    return true
end

return WIPQueue
