-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local CallDef = Class.NewClass(ObjBase)

--[[
    This module implements the class CallDef.

    A CallDef defines the function call of a Method of a Module, including a table with possible method arguments.
--]]

local corelog = require "corelog"

local InputChecker = require "input_checker"

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function CallDef:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a CallDef from table.

        Parameters:
            o                       + (table, {}) table with object fields
                _moduleName         - (string, "") name of module to call
                _methodName         - (string, "") name of method to call
                _data               - (table, {}) with arguments to pass to method call
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("CallDef:new: Invalid input") return {} end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- end
    return o
end

function CallDef:getModuleName()
    return self._moduleName
end

function CallDef:getMethodName()
    return self._methodName
end

function CallDef:getData()
    return self._data
end

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

function CallDef:getClassName()
    return "CallDef"
end

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

return CallDef
