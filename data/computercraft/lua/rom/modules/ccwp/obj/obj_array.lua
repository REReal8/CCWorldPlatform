local ObjArray = {
    _objClassName   = "",
}

local corelog = require "corelog"

local InputChecker = require "input_checker"

local IObj = require "i_obj"
local ObjectFactory = require "object_factory"
local objectFactory = ObjectFactory:getInstance()

--[[
    This module implements the class ObjArray.

    A ObjArray is an array of Obj's of the same 'class'. The class should implement the IObj interface.
--]]

--    _                                     _   _               _
--   | |                                   | | | |             | |
--   | |__   __ _ ___  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   | '_ \ / _` / __|/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   | |_) | (_| \__ \  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_.__/ \__,_|___/\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

function ObjArray:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Constructs an ObjArray.

        Parameters:
            o                   + (table, {}) table with
                _objClassName   - (string, "") with className of objects in array (e.g. "Chest")
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("ObjArray:new: Invalid input") return nil end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- transform Obj's if needed
    o:transformObjTables()

    -- end
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
    if not objClass then corelog.Error("ObjArray:getObjClass(): failed obtaining class "..self._objClassName.." from objectFactory (did we forget to set _objClassName?)") end

    return objClass
end

function ObjArray.HasFieldsOfType(obj)
    -- check
    if type(obj) ~= "table" then return false end
    if type(obj._objClassName) ~= "string" then return false end

    -- check elements
    local objClass = obj:getObjClass()
    if not objClass then return false end
    for i, el in ipairs(obj) do
        if not objClass:isTypeOf(el) then return false end
    end

    -- end
    return true
end

function ObjArray:isTypeOf(obj)
    local metatable = getmetatable(obj)
    while metatable do
        if metatable.__index == self or obj == self then
            return true
        end
        metatable = getmetatable(metatable.__index)
    end
    return false
end

function ObjArray:isSame(obj)
    -- check input
    if not ObjArray:isTypeOf(obj) then return false end

    -- check same class
    if self._objClassName ~= obj._objClassName then return false end

    -- check same size
    if table.getn(self) ~= table.getn(obj) then return false end

    -- check same elements
    for i, elA in ipairs(self) do
        -- check same obj
        local elB = obj[i]
        if not elA:isSame(elB) then return false end
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

function ObjArray:transformObjTables(suppressWarning)
    --[[
        Transform the objects in the array that are still object tables into objects of type 'objClass'.

        Parameters:
            suppressWarning         + (boolean, false) if Warning should be suppressed
    --]]
    suppressWarning = suppressWarning or false

    -- check if empty
    if table.getn(self) == 0 then return end

    -- get objClass
    local objClassName = self:getObjClassName()
    local objClass = self:getObjClass()
    if not objClass then corelog.Error("ObjArray:transformObjTables(): failed obtaining objClass "..objClassName) return end
    if not IObj.ImplementsInterface(objClass) then corelog.Error("ObjArray:transformObjTables(): objClass "..objClassName.." does not implement IObj interface") return end

    -- transform objectTable's
    local nrSkipped = 0
    for i, objectTable in ipairs(self) do
        -- check if objectTable already an Obj
        local obj = nil
        if IObj.ImplementsInterface(objectTable) then
            -- check Obj of correct type
            if objClassName == objectTable:getClassName() then
                obj = objectTable -- already an object of type 'class'
            else
                if not suppressWarning then corelog.Warning("ObjArray:transformObjTables(): objectTable class (="..objectTable:getClassName()..") different from objClassName(="..objClassName..")") end
            end
        else
            obj = objClass:new(objectTable) -- transform
        end

        -- add/ change in self array
        self[i] = nil
        self[i-nrSkipped] = obj

        -- check obj obtained
        if not obj then
            if not suppressWarning then corelog.Warning("ObjArray:transformObjTables(): failed transforming objectTable(="..textutils.serialize(objectTable)..") to a "..objClassName.." object => skipped") end
            nrSkipped = nrSkipped + 1
        end
    end
end

return ObjArray
