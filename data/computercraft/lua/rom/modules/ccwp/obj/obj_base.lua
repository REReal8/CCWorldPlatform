-- define class
local ObjBase = {}

-- set class inheritance structure
local IObj = require "i_obj"
setmetatable(ObjBase, IObj)

--[[
    This module implements the ObjBase class.

    ObjBase provides a default implementation for the IObj interface.

    Classes inherting from ObjBase automatically have the default implementation of IObj and do not need to (but can) specify their own.
--]]

local corelog = require "corelog"

local Object = require "object"

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function ObjBase:new()
    --[[
        Constructor of ObjBase class.
    ]]

    -- set instance class info
    local obj = {}
    setmetatable(obj, self)
    self.__index = self

    -- end
    return obj
end

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

function ObjBase:getClassName()
    --[[
        Method that returns the concrete className of an Obj.
    ]]

    return "ObjBase"
end

function ObjBase:isTypeOf(obj)
    --[[
        Method that returns if an object 'obj' is of type of this class.
    ]]

    -- ToDo: investigate if we can simply this using Object.IsInstanceOf, e.g.
--    return Object.IsInstanceOf(obj, self)

    local mt = getmetatable(obj)
    while mt do
        if mt.__index == self or obj == self then
            return true
        end
        mt = getmetatable(mt.__index)
    end

    return false
end

local function tablesEqual(table1, table2)
    -- check all fields equal
    for fieldName, fieldValue in pairs(table1) do
        -- check field equal
        if fieldValue ~= table2[fieldName] then
            -- check table
            if type(fieldValue) == "table" then
                -- is field nested IObj?
                if Object.IsInstanceOf(fieldValue, IObj) then
                    -- check nested IObj field equal
                    if not fieldValue:isEqual(table2[fieldName]) then
--                        corelog.WriteToLog("nested obj not of type")
                        return false
                    end
                else
                    -- check nested tables equal
                    if not tablesEqual(fieldValue, table2[fieldName]) then
                        return false
                    end
                end
            else
                -- field not equal
--                corelog.WriteToLog("field "..fieldName.." not equal")
                return false
            end
        end
    end

    -- end
    return true
end

function ObjBase:isEqual(otherObj)
    --[[
        Method that returns if the Obj is equal to another Obj.
    ]]

    -- check classes equal
    local selfClass = getmetatable(self)
    if not selfClass:isTypeOf(otherObj) then
--        corelog.WriteToLog("not of type")
        return false
    end

    -- check all fields equal
    if not tablesEqual(self, otherObj) then
--        corelog.WriteToLog("no all fields equal")
        return false
    end

--    corelog.WriteToLog("ok")
    return true
end

local function tableCopy(origTable, copyTable)
    for fieldName, fieldValue in pairs(origTable) do
        if type(fieldValue) == "table" then
            -- check if it's another IObj
            if Object.IsInstanceOf(fieldValue, IObj) then
                -- recursively copy nested IObj
                copyTable[fieldName] = fieldValue:copy()
            else
                -- recursively copy nested plane table
                copyTable[fieldName] = {}
                tableCopy(fieldValue, copyTable[fieldName])
            end
        else
            copyTable[fieldName] = fieldValue
        end
    end
end

function ObjBase:copy()
    --[[
        Method that returns a copy of the Obj.
    ]]

    -- construct Obj
    local copy = setmetatable({}, getmetatable(self))

    -- copy table elelements
    tableCopy(self, copy)

    -- end
    return copy
end

return ObjBase
