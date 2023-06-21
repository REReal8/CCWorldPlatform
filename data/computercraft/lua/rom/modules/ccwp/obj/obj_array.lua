local ObjArray = {
    _objClassName   = "",
}

local corelog = require "corelog"

local IObj = require "iobj"
local ObjectFactory = require "object_factory"
local objectFactory = ObjectFactory:getInstance()

--[[
    This module implements the class ObjArray.

    A ObjArray is an array of objects of the same 'class'. The class should implement the IObj interface.
--]]

--    _                                     _   _               _
--   | |                                   | | | |             | |
--   | |__   __ _ ___  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   | '_ \ / _` / __|/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   | |_) | (_| \__ \  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_.__/ \__,_|___/\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

function ObjArray:new(o)
    --[[
        Constructs a ObjArray.

        Parameters:
            o                   - (table) table with
                _objClassName   - (string) with className of objects in array (e.g. "Chest")
    --]]

    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
end

function ObjArray:getClassName()
    return "ObjArray"
end

function ObjArray:getObjClassName()
    return self._objClassName
end

function ObjArray:getObjClass()
    local objClass = objectFactory:getClass(self._objClassName)
    if not objClass then corelog.Error("ObjArray:getObjClass(): failed obtaining class "..self._objClassName.." from objectFactory") end

    return objClass
end

function ObjArray.HasFieldsOfType(objArray)
    -- check
    if type(objArray) ~= "table" then return false end
    if type(objArray._objClassName) ~= "string" then return false end

    -- check elements
    local objClass = objArray:getObjClass()
    if not objClass then return false end
    for i, obj in ipairs(objArray) do
        if not objClass.IsOfType(obj) then return false end
    end

    -- end
    return true
end

function ObjArray.HasClassNameOfType(objArray)
    -- check
    if not objArray.getClassName or objArray:getClassName() ~= ObjArray:getClassName() then return false end

    -- end
    return true
end

function ObjArray.IsOfType(objArray)
    -- check
    local isOfType = ObjArray.HasFieldsOfType(objArray) and ObjArray.HasClassNameOfType(objArray)

    -- end
    return isOfType
end

function ObjArray:isSame(objArray)
    -- check input
    if not ObjArray.IsOfType(objArray) then return false end

    -- check same class
    if self._objClassName ~= objArray._objClassName then return false end

    -- check same size
    if table.getn(self) ~= table.getn(objArray) then return false end

    -- check same elements
    for i, objA in ipairs(self) do
        -- check same obj
        local objB = objArray[i]
        if not objA:isSame(objB) then return false end
    end

    -- end
    return true
end

function ObjArray:copy()
    -- create new ObjArray
    local copy = ObjArray:new({
        _objClassName   = self._objClassName,
    })

    -- copy elements
    -- ToDo: consider if this can and should be done by new method somehow...
    for i, obj in ipairs(self) do
        copy[i] = obj:copy()
    end

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

function ObjArray:transformObjTables()
    --[[
        Transform the objects in the array that are still objTable's into objects of type 'objClass'.
    --]]

    -- get objClass
    local objClass = self:getObjClass()
    if not objClass then corelog.Error("ObjArray:transformObjTables(): failed obtaining objClass "..self:getObjClassName()) return end
    if not IObj.ImplementsInterface(objClass) then corelog.Error("ObjArray:transformObjTables(): objClass "..self:getObjClassName().." does not implement IObj interface") return end

    -- transform objectTable's
    for i, objTable in ipairs(self) do
        -- transform into obj if needed
        local obj = nil
        if objClass.IsOfType(objTable) then
            obj = objTable -- already an object of type 'class'
        else
            obj = objClass:new(objTable) -- transform
        end

        -- check obj obtained
        if objClass.IsOfType(obj) then
            -- add/ change in self array
            self[i] = obj
        else
            corelog.Warning("ObjArray:transformObjTables(): failed transforming objTable(="..textutils.serialize(objTable)..") to a "..self:getObjClassName().." object => skipped")
        end
    end
end

return ObjArray
