local Host = {
    _hostName = ""
}

local corelog = require "corelog"
local coredht = require "coredht"

local InputChecker = require "input_checker"
local ModuleRegistry = require "module_registry"
local moduleRegistry = ModuleRegistry:getInstance()
local ObjectFactory = require "object_factory"
local objectFactory = ObjectFactory:getInstance()

local URL = require "obj_url"

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

function Host:getClassName()
    return "Host"
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

function Host.HasClassNameOfType(obj)
    -- check
    if not obj.getClassName or obj:getClassName() ~= Host:getClassName() then return false end

    -- end
    return true
end

function Host.IsOfType(obj)
    -- check
    local isOfType = Host.HasFieldsOfType(obj) and Host.HasClassNameOfType(obj)

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

function Host.GetHost(...)
    -- get & check input from description
    local checkSuccess, hostName, suppressWarning = InputChecker.Check([[
        This method retrieves a Host from a hostName.

        Return value:
            host                    - (Host) with the Host

        Parameters:
            hostName                + (string) with hostName of the Host
            suppressWarning         + (boolean, false) if Warning should be suppressed
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Host.GetHost: Invalid input") return nil end

    -- get Host
    local host = moduleRegistry:getModule(hostName)
    if not Host.IsOfType(host) then if not suppressWarning then corelog.Warning("Host.GetHost: No Host registered with hostName="..hostName) end return nil end

    -- end
    return host
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

function Host:isLocatorFromHost(...)
    -- get & check input from description
    local checkSuccess, locator = InputChecker.Check([[
        This method answers the question if a locator is from this Host.

        Return value:
                                    - (boolean) whether the locator is from this host

        Parameters:
            locator                 + (URL) that needs to be queried
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Host:isLocatorFromHost: Invalid input") return false end

    -- check if of this Host
    local hostField = locator:getHost()
    if type(hostField) ~= "string" then corelog.Error("Host:isLocatorFromHost: Invalid host field in locator (="..locator:getURI()..").") return false end
    if hostField == self:getHostName() then
        return true
    else
        return false
    end
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
    -- ToDo: consider also deleting pathSegments remainders from dht when there are no longer resources present in the path

    -- end
    return savedResource == nil
end

local classNamePattern = "%/class=([%w]+)"
local function GetClassName(...)
    -- get & check input from description
    local checkSuccess, objectLocator = InputChecker.Check([[
        This method gets the className corresponding to an object referenced by an objectLocator.

        Return value:
            className           - (string) the className of the object

        Parameters:
            objectLocator       + (URL) locating the object
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Host:getClassName: Invalid input") return nil end

    -- get className from path
    local className = objectLocator:getPath():match(classNamePattern)

    -- end
    return className
end

function Host:getObject(...)
    -- get & check input from description
    local checkSuccess, objectLocator = InputChecker.Check([[
        This method retrieves an object from the Host using a URL (that was once provided by the Host).

        Return value:
            object                  - (?) object obtained from the Host

        Parameters:
            objectLocator           + (URL) locator of the object within the Host
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Host:getObject: Invalid input") return nil end

    -- get className
    local className = GetClassName(objectLocator)
    if type(className) ~= "string" then corelog.Error("Host:getObject: failed obtaining className from objectLocator="..objectLocator:getURI()) return nil end

    -- get raw Resource
    local resourceTable = self:getResource(objectLocator)
    if type(resourceTable) ~= "table" then corelog.Error("Host:getObject: failed obtaining resourceTable from objectLocator="..objectLocator:getURI()) return nil end

    -- convert to object
    local object = objectFactory:create(className, resourceTable)

    -- end
    return object
end

local function GetObjectPath(...)
    -- get & check input from description
    local checkSuccess, object, className, objectId = InputChecker.Check([[
        This method provides the objectPath of an object in the Host with class className and id objectId.

        If the object has a getClassName() method the className argument can set to "".
        If the object has a getId() method the objectId argument can be set to "".

        Return value:
            resourcePath            - (string) locating the object within the Host

        Parameters:
            object                  + (table) the object
            className               + (string, "") with the name of the class of the object
            objectId                + (string, "") with the optional id of the object
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Host.GetObjectPath: Invalid input") return nil end

    -- determince resourcePath
    local objectPath = "/objects"

    -- optionally add className to resourcePath
    if className == "" then
        -- attempt to get className from object
        if object.getClassName then
            local name = object:getClassName()
            if type(name) == "string" then
                className = name
            else
                corelog.Warning("Host.GetObjectPath: object:getClassName() did not return(type="..type(name)..") a string")
            end
        else
            corelog.Warning("Host.GetObjectPath: object:getClassName() does not exist. Also not provided. => couldn't determine className")
        end
    end
    if className ~= "" then
        objectPath = objectPath.."/class="..className
    end

    -- optionally add objectId to resourcePath
    if objectId == "" then
        -- attempt to get objectId from object
        if object.getId then
            local id = object:getId()
            if type(id) == "string" then
                objectId = id
            else
                corelog.Warning("Host.GetObjectPath: object:getId() did not return(type="..type(id)..") a string")
            end
        end
    end
    if objectId ~= "" then
        objectPath = objectPath.."/id="..objectId
    end

    -- end
    return objectPath
end

function Host:getObjectLocator(...)
    -- get & check input from description
    local checkSuccess, object, className, objectId = InputChecker.Check([[
        This method provides the objectLocator of an object in the Host using a className and objectId argument.

        If the object has a getClassName() method the className argument can set to "".
        If the object has a getId() method the objectId argument can be set to "".

        Return value:
            objectLocator           - (URL) locating the object

        Parameters:
            object                  + (table) the object
            className               + (string, "") with the name of the class of the object
            objectId                + (string, "") with the optional id of the object
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Host:getObjectLocator: Invalid input") return nil end

    -- get resourcePath
    local objectPath = GetObjectPath(object, className, objectId)
    if not objectPath then corelog.Error("Host:getObjectLocator: Failed obtainng objectPath") return nil end

    -- get objectLocator
    local objectLocator = self:getResourceLocator(objectPath)
    if not objectLocator then corelog.Error("Host:getObjectLocator: Failed obtainng objectLocator") return nil end

    -- end
    return objectLocator
end

function Host:saveObject(...)
    -- get & check input from description
    local checkSuccess, object, className, objectId = InputChecker.Check([[
        This method saves an object in the Host using a className and objectId argument.

        If the object has a getClassName() method the className argument can be set to "".
        If the object has a getId() method the objectId argument can be set to "".

        Return value:
            objectLocator           - (URL) locating the object

        Parameters:
            object                  + (table) the object
            className               + (string, "") with the name of the class of the object
            objectId                + (string, "") with the optional id of the object
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Host:saveObject: Invalid input") return nil end

    -- get objectPath
    local objectPath = GetObjectPath(object, className, objectId)
    if not objectPath then corelog.Error("Host:saveObject: Failed obtaining objectPath") return nil end

    -- save resource
    local objectLocator = self:saveResource(object, objectPath)

    -- end
    return objectLocator
end

-- ToDo: consider if it's better to make this a method of a Host object (instead of the global function we have now)
function Host.SaveObject_SSrv(...)
    -- get & check input from description
    local checkSuccess, hostName, className, objectTable = InputChecker.Check([[
        This sync service saves an object in Host named hostName.

        Return value:
                                - (table)
                success         - (boolean) whether the service executed successfully
                objectLocator   - (URL) locating the object

        Parameters:
            serviceData         - (table) data for this service
                hostName        + (string) with hostName of the Host
                className       + (string) with the name of the class of the object
                objectTable     + (table) of the object
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Host.SaveObject_SSrv: Invalid input") return {success = false} end

    -- get Host
    local host = Host.GetHost(hostName)
    if not host then corelog.Error("Host.SaveObject_SSrv: host "..hostName.." not found") return {success = false} end

    -- convert to object
    local object = objectFactory:create(className, objectTable)

    -- save object
    local objectLocator = host:saveObject(object)
    if not objectLocator then corelog.Error("Host.SaveObject_SSrv: Failed saving object "..textutils.serialise(object)) return {success = false} end

    -- end
    return {
        success         = true,
        objectLocator   = objectLocator,
    }
end

local function GetObjectsPath(...)
    -- get & check input from description
    local checkSuccess, className = InputChecker.Check([[
        This method provides the objectsPath of objects in the Host with class className.

        Return value:
            objectsPath             - (string) locating the objects within the Host

        Parameters:
            className               + (string) with the name of the class of the object
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Host.GetObjectsPath: Invalid input") return nil end

    -- check className not empty
    if className == "" then corelog.Error("Host.GetObjectsPath: classname is empty") return nil end

    -- determince objectsPath
    local objectsPath = "/objects/class="..className

    -- end
    return objectsPath
end

-- ToDo: investigate if this method can be made private (as it's not envisioned to be used outside of module)
function Host:getObjects(...)
    -- get & check input from description
    local checkSuccess, className = InputChecker.Check([[
        This (private) method retrieves all the objects in the Host with class className.

        Return value:
            objects                 - (table) with the objects

        Parameters:
            className               + (string) with the name of the class of the objects
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Host:getObjects: Invalid input") return nil end

    -- get objectsPath
    local objectsPath = GetObjectsPath(className)
    if not objectsPath then corelog.Error("Host:getObjects: Failed obtainng objectsPath") return nil end

    -- get objectsLocator
    local objectsLocator = self:getResourceLocator(objectsPath)

    -- get objects
    local objects = self:getResource(objectsLocator)
    if not objects then
        -- (re)set objects
        self:saveResource({}, objectsPath)

        -- retrieve again
        objects = self:getResource(objectsLocator)
        if not objects then corelog.Error("Host:getObjects: Failed (re)setting objects") return nil end
    end

    -- end
    return objects
end

function Host:getNumberOfObjects(...)
    -- get & check input from description
    local checkSuccess, className = InputChecker.Check([[
        This method returns the number of objects in the Host with class className.

        Return value:
                                    - (number) of objects of class className hosted by the Host.

        Parameters:
            className               + (string) with the name of the class of the objects
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Host:getNumberOfObjects: Invalid input") return nil end

    -- get objects
    local objects = self:getObjects(className)
    if not objects then corelog.Error("Host:getNumberOfObjects: Failed obtaining objects of class "..className) return nil end

    -- loop on forests
    local count = 0
    for k, forest in pairs(objects) do
        count = count + 1
    end

    return count
end

function Host:deleteObjects(...)
    -- get & check input from description
    local checkSuccess, className = InputChecker.Check([[
        This method deletes all the objects in the Host with class className.

        Return value:

        Parameters:
            className               + (string) with the name of the class of the objects
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Host:deleteObjects: Invalid input") return nil end

    -- get objects
    local objects = self:getObjects(className)
    if not objects then corelog.Error("Host:deleteObjects: Failed obtaining objects of class "..className) return nil end

    -- delete all objects
--    corelog.Warning("All objects of class "..className.." are being deleted!")
    for id, object in pairs(objects) do
        -- get locator
        local objectLocator = self:getObjectLocator(object, className)

        -- delete
        self:deleteResource(objectLocator)
    end
end

return Host