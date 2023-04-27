local Host = {
    _hostName = ""
}

local corelog = require "corelog"
local coredht = require "coredht"

local InputChecker = require "input_checker"
local URL = require "obj_url"

local ObjectFactory = require "object_factory"
local objectFactory = ObjectFactory:getInstance()

--[[
    This module implements the Host class.

    A Host is an object that "hosts" Resource's to be used both inside the Host as well as outside of it.

    A Host has a (unique) hostName.

    The Host is the owner of the Resource's it hosts. This makes the Host responsible for making sure the Resource's are
    available (and possibly persistent). The Host does so via the methods getResource, saveResource and deleteResource.

    In it's core a Resource is a LUA table. Each Resource hosted by a Host can be identified by a unique resourceLocator URL. The host component of these
    URL's are equal to the hostName of the Host.

    Special kind of Resource's are objects they can also be "hosted" when the className and an optional objectId are available.
--]]

--    _                                     _   _               _
--   | |                                   | | | |             | |
--   | |__   __ _ ___  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   | '_ \ / _` / __|/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   | |_) | (_| \__ \  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_.__/ \__,_|___/\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

function Host:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a Host.

        Parameters:
            o                           + (table, {}) table with object fields
                _hostName               - (string) with hostName of the Host
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Host:new: Invalid input") return {} end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- end
    return o
end

function Host:getHostName()
    return self._hostName
end

function Host.HasFieldsOfType(obj)
    -- check
    if type(obj) ~= "table" then return false end
    if type(obj._hostName) ~= "string" then return false end

    -- end
    return true
end

function Host.HasMethodsOfType(obj)
    -- check
    if not obj.new then return false end

    -- end
    return true
end

function Host.IsOfType(obj)
    -- check
    local isOfType = Host.HasFieldsOfType(obj) and Host.HasMethodsOfType(obj)

    -- end
    return isOfType
end

function Host:isSame(obj)
    -- check input
    if not Host.IsOfType(obj) then return false end

    -- check same object
    local isSame =  self._hostName == obj._hostName

    -- end
    return isSame
end

function Host:copy()
    local copy = Host:new({
        _hostName   = self._hostName,
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

-- ToDo: further implement

return Host
