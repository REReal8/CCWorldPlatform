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

function Host:getHostLocator()
    --[[
        Attribute locating this Host.

        Return value:
            hostLocator             - (URL) locating this Host

        Parameters:
            nil
    --]]

    local hostURL = URL:new()
    hostURL:setHost(self:getHostName())

    return hostURL
end

function Host:getResourceLocator(...)
    -- get & check input from description
    local checkSuccess, resourcePath = InputChecker.Check([[
        This method provides the resourceLocator of a Resource based on a resourcePath.

        Return value:
            resourceLocator         - (URL) locating the Resource

        Parameters:
            resourcePath            + (string) locating the Resource within the Host
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Host:getResourceLocator: Invalid input") return nil end

    -- construct resourceLocator
    local resourceLocator = self:getHostLocator()
    resourceLocator:setPath(resourcePath)

    -- end
    return resourceLocator
end

function Host:getResource(...)
    -- get & check input from description
    local checkSuccess, resourceLocator = InputChecker.Check([[
        This method retrieves a Resource from the Host using a URL (that was once provided by the Host).

        Return value:
            resource                - (table) Resource obtained from the Host

        Parameters:
            resourceLocator         + (URL) locator of the Resource within the Host
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Host:getResource: Invalid input") return nil end

    -- get URL components
    local hostURI = resourceLocator:getHostURI()
    if hostURI ~= self:getHostName() then corelog.Error("Host:getResource: resourceLocator(="..resourceLocator:getURI()..") not for "..self:getHostName().." Host)") return nil end
    local portURI = resourceLocator:getPortURI()
    local pathSegments = resourceLocator:pathSegments()

    -- get Resource from dht using URL components
    -- note: all current implementations of Host assume the Resource's are stored in the dht. This is the current implementation decision.
    -- The method signatures are (?should) however defined in such a way that also another mechanism (e.g. with a local table) can be implemented.
    local resource = nil
    if portURI == "" then
        resource = coredht.GetData(hostURI, table.unpack(pathSegments))
    else
        resource = coredht.GetData(hostURI, portURI, table.unpack(pathSegments))
    end

    -- end
    return resource
end

function Host:saveResource(...)
    -- get & check input from description
    local checkSuccess, resource, resourcePath = InputChecker.Check([[
        This method saves a Resource to the Host using a resourcePath.

        Return value:
            resourceLocator         - (URL) locating the Resource

        Parameters:
            resource                + (table) representing the Resource
            resourcePath            + (string) locating the Resource within the Host
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Host:saveResource: Invalid input") return nil end

    -- get resourceLocator
    local resourceLocator = self:getResourceLocator(resourcePath)
    if not resourceLocator then corelog.Error("Host:saveResource: Failed obtaining resourceLocator for Resource "..resourcePath) return nil end

    -- get URL components
    local hostURI = resourceLocator:getHostURI()
    local portURI = resourceLocator:getPortURI()
    local pathSegments = resourceLocator:pathSegments()

    -- save Resource to dht using URL components
    local savedResource = nil
    if portURI == "" then
        savedResource = coredht.SaveData(resource, hostURI, table.unpack(pathSegments))
    else
        savedResource = coredht.SaveData(resource, hostURI, portURI, table.unpack(pathSegments))
    end
    if not savedResource then corelog.Error("Host:saveResource: Failed saving Resource Resource "..resourceLocator:getURI()) return nil end

    -- end
    return resourceLocator
end

function Host:deleteResource(...)
    -- get & check input from description
    local checkSuccess, resourceLocator = InputChecker.Check([[
        This method deletes a Resource from the Host using a URL.

        Return value:
                                    + (boolean) if resource was succesfully removed

        Parameters:
            resourceLocator         + (URL) locator of the Resource within the Host
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Host:deleteResource: Invalid input") return false end

    -- get URL components
    local hostURI = resourceLocator:getHostURI()
    local portURI = resourceLocator:getPortURI()
    local pathSegments = resourceLocator:pathSegments()

    -- delete Resource from dht using URL components
    corelog.WriteToLog(">removing resource "..resourceLocator:getURI())
    local savedResource = nil
    if portURI == "" then
        savedResource = coredht.SaveData(nil, hostURI, table.unpack(pathSegments))
    else
        savedResource = coredht.SaveData(nil, hostURI, portURI, table.unpack(pathSegments))
    end

    -- end
    return savedResource == nil
end

return Host
