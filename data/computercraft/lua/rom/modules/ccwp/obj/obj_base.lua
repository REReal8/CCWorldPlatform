local IObj = require "i_obj"

local ObjBase = {}

--[[
    This module implements the ObjBase class.

    ObjBase provides a default implementation for the IObj interface.

    Classes inherting from ObjBase automatically have the default implementation of IObj and do not need to (but can) specify their own.
--]]

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

    -- set class info
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

    local mt = getmetatable(obj)
    while mt do
        if mt.__index == self or obj == self then
            return true
        end
        mt = getmetatable(mt.__index)
    end

    return false
end

function ObjBase:isEqual(otherObj)
    --[[
        Method that returns if the Obj is equal to another Obj.
    ]]

    -- check classes equal
    local selfClass = getmetatable(self)
    if not selfClass:isTypeOf(otherObj) then
        return false
    end

    -- check fields equal
    for fieldName, fieldValue in pairs(self) do
        -- check field identity
        if fieldValue ~= otherObj[fieldName] then
            -- is field nested IObj?
            if type(fieldValue) == "table" and Object.IsInstanceOf(fieldValue, IObj) then
                -- check nested IObj field equal
                if not fieldValue:isEqual(otherObj[fieldName]) then
                    return false
                end
            else
                return false
            end
        end
    end

    return true
end

function ObjBase:copy()
    --[[
        Method that returns a copy of the Obj.
    ]]

    local copy = setmetatable({}, getmetatable(self))

    for fieldName, fieldValue in pairs(self) do
        if type(fieldValue) == "table" and fieldValue.isInstanceOf and fieldValue:isInstanceOf(IObj) then
            copy[fieldName] = fieldValue:copy()  -- Recursively copy nested objects
        else
            copy[fieldName] = fieldValue
        end
    end

    return copy
end

-- Set up metatable for ObjBase class to inherit the IObj interface.
setmetatable(ObjBase, IObj)

return ObjBase
