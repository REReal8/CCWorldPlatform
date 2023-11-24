-- define class
local Class = require "class"
local URL = require "obj_url"
local ObjLocator = Class.NewClass(URL)

--[[
    This module implements the class ObjLocator.

    A ObjLocator is a URL that locates an Obj.
--]]

local corelog = require "corelog"

local InputChecker = require "input_checker"

local IObj = require "i_obj"

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function ObjLocator:_init(...)
    -- get & check input from description
    local checkSuccess, hostName, obj, objRef, query = InputChecker.Check([[
        Initialise a ObjLocator.

        Parameters:
            hostName                + (string) with hostName of the Host
            obj                     + (?) with IObj
            objRef                  + (string, "") with a object reference (e.g. the id of the IObj)
            query                   + (table, {}) of key-value pairs with (item) query segments
    ]], ...)
    if not checkSuccess then corelog.Error("ObjLocator:_init: Invalid input") return nil end
    if not Class.IsInstanceOf(obj, IObj) then corelog.Error("ObjLocator:_init: obj is not an IObj") return nil end

    -- determine objPath
    local objClassName = obj:getClassName()
    local objPath = "/objects/class="..objClassName
    if objRef ~= "" then
        -- ToDo: consider renaming id to ref
        objPath = objPath.."/id="..objRef
    end

    -- initialisation
    local port = nil
    URL._init(self, hostName, objPath, query, port)
end

local classNamePattern = "%/class=([%w]+)"
function ObjLocator:getObjClassName()
    -- get objClassName from path
    local objClassName = self:getPath():match(classNamePattern)
    if not objClassName then corelog.Warning("ObjLocator:getObjClassName: no objClassName in path of "..self:getURI()) return nil end

    -- end
    return objClassName
end

local objRefPattern = "%/id=([%w:]+)"
function ObjLocator:getObjRef()
    -- get objClassName from path
    local objRef = self:getPath():match(objRefPattern)
    if not objRef then corelog.Warning("ObjLocator:getObjRef: no objRef in path of "..self:getURI()) return nil end

    -- end
    return objRef
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function ObjLocator:getClassName()
    return "ObjLocator"
end

return ObjLocator
