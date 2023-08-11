local ObjTable = {
    _objClassName   = "",
}

local corelog = require "corelog"

local InputChecker = require "input_checker"

local IObj = require "i_obj"
local ObjectFactory = require "object_factory"
local objectFactory = ObjectFactory:getInstance()

--[[
    This module implements the class ObjTable.

    A ObjTable is a key-value pair table of Obj's of the same 'class'. The class should implement the IObj interface.
--]]

--    _                                     _   _               _
--   | |                                   | | | |             | |
--   | |__   __ _ ___  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   | '_ \ / _` / __|/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   | |_) | (_| \__ \  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_.__/ \__,_|___/\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

function ObjTable:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Constructs an ObjTable.

        Parameters:
            o                   + (table, {}) table with
                _objClassName   - (string, "") with className of objects in ObjTable (e.g. "Chest")
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("ObjTable:new: Invalid input") return nil end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- transform Obj's if needed
    o:transformObjectTables()

    -- end
    return o
end

function ObjTable:getObjClassName()
    return self._objClassName
end

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

function ObjTable:getClassName()
    return "ObjTable"
end

function ObjTable:isTypeOf(obj)
    local metatable = getmetatable(obj)
    while metatable do
        if metatable.__index == self or obj == self then
            return true
        end
        metatable = getmetatable(metatable.__index)
    end
    return false
end

function ObjTable:isEqual(obj)
    -- check input
    if not ObjTable:isTypeOf(obj) then return false end

    -- check same class
    if self._objClassName ~= obj._objClassName then return false end

    -- check same elements as in A
    local sizeA = 0
    for key, elA in pairs(self) do
        if key ~= "_objClassName"then
            sizeA = sizeA + 1
            -- check same obj
            local elB = obj[key]
            if not elA:isEqual(elB) then return false end
        end
    end

    -- count elements B
    local sizeB = obj:nObjs()

    -- check same size
    if sizeA ~= sizeB then return false end

    -- end
    return true
end

function ObjTable:copy()
    -- create new ObjTable
    local copy = ObjTable:new({
        _objClassName   = self._objClassName,
    })

    -- copy elements
    for key, el in pairs(self) do
        if key ~= "_objClassName" then
            copy[key] = el:copy()
        end
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

function ObjTable:getObjClass()
    local objClass = objectFactory:getClass(self._objClassName)
    if not objClass then corelog.Error("ObjTable:getObjClass(): failed obtaining class "..self._objClassName.." from objectFactory (did we forget to set _objClassName?)") end

    return objClass
end

function ObjTable:nObjs()
    -- count
    local nObj = 0
    for key, el in pairs(self) do
        if key ~= "_objClassName" then
            nObj = nObj + 1
        end
    end

    -- end
    return nObj
end

function ObjTable:objs()
    --[[
        Factory for iterator over Obj's.

        note: this iterator ensures a proper iterator is obtained that skips the _objClassName field.
    --]]

    -- create iterator that skips _objClassName
    local function nextObj(table)
        local key, value = next(table)
        while key do
            if key ~= "_objClassName" then
                return key, value
            end
            key, value = next(table, key) -- Continue to the next key-value pair
        end
    end

    return nextObj, self, nil
end

function ObjTable:transformObjectTables(suppressWarning)
    --[[
        Transform the objects in the ObjTable that are still object tables into objects of type 'objClass'.

        Parameters:
            suppressWarning         + (boolean, false) if Warning should be suppressed
    --]]
    suppressWarning = suppressWarning or false

    -- check if empty
    if self:nObjs() == 0 then return end

    -- get objClass
    local objClassName = self:getObjClassName()
    local objClass = self:getObjClass()
    if not objClass then corelog.Error("ObjTable:transformObjectTables(): failed obtaining objClass "..objClassName) return end
    if not IObj.ImplementsInterface(objClass) then corelog.Error("ObjTable:transformObjectTables(): objClass "..objClassName.." does not implement IObj interface") return end

    -- transform objectTable's
    for key, objectTable in pairs(self) do
        if key ~= "_objClassName" then
            -- check if objectTable already an Obj
            local obj = nil
            if IObj.ImplementsInterface(objectTable) then
                -- check Obj of correct type
                if objClassName == objectTable:getClassName() then
                    obj = objectTable -- already an object of type 'class'
                else
                    if not suppressWarning then corelog.Warning("ObjTable:transformObjectTables(): objectTable class (="..objectTable:getClassName()..") different from objClassName(="..objClassName..")") end
                end
            else
                obj = objClass:new(objectTable) -- transform
            end

            -- add/ change in self ObjTable
            self[key] = obj

            -- check obj obtained
            if not obj then
                if not suppressWarning then corelog.Warning("ObjTable:transformObjectTables(): failed transforming objectTable(="..textutils.serialize(objectTable)..") to a "..objClassName.." object => skipped") end
            end
        end
    end
end

return ObjTable
