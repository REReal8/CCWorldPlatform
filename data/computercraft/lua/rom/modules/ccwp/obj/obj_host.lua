-- define class
local Class = require "class"
local Host = require "host"
local ObjHost = Class.NewClass(Host)

--[[
    This module implements the ObjHost class.

    A ObjHost is a Host that hosts Obj/object's and provides additional services on and with these Obj's.
--]]

local corelog = require "corelog"

local InputChecker = require "input_checker"
local ObjectFactory = require "object_factory"
local objectFactory = ObjectFactory:getInstance()
local ObjLocator = require "obj_locator"

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function ObjHost:_init(...)
    -- get & check input from description
    local checkSuccess, hostName = InputChecker.Check([[
        Initialise an ObjHost.

        Parameters:
            hostName                + (string) with hostName of the ObjHost
    ]], ...)
    if not checkSuccess then corelog.Error("ObjHost:_init: Invalid input") return nil end

    -- initialisation
    Host._init(self, hostName)
end

-- ToDo: should be renamed to newFromTable at some point
function ObjHost:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a ObjHost instance.

        Parameters:
            o                           + (table, {}) table with object fields
                _hostName               - (string) with hostName of the ObjHost
    ]], ...)
    if not checkSuccess then corelog.Error("ObjHost:new: Invalid input") return {} end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- end
    return o
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function ObjHost:getClassName()
    return "ObjHost"
end

--     ____  _     _ _    _           _
--    / __ \| |   (_) |  | |         | |
--   | |  | | |__  _| |__| | ___  ___| |_
--   | |  | | '_ \| |  __  |/ _ \/ __| __|
--   | |__| | |_) | | |  | | (_) \__ \ |_
--    \____/|_.__/| |_|  |_|\___/|___/\__|
--               _/ |
--              |__/

function ObjHost:getObject(...)
    -- get & check input from description
    local checkSuccess, objLocator = InputChecker.Check([[
        This method retrieves an Obj from the ObjHost using a locator (that was once provided by the ObjHost).

        Return value:
            object                  - (?) object obtained from the ObjHost

        Parameters:
            objLocator              + (ObjLocator) locator of the Obj within the ObjHost
    ]], ...)
    if not checkSuccess then corelog.Error("ObjHost:getObject: Invalid input") return nil end

    -- get className
    local className = objLocator:getObjClassName()
    if type(className) ~= "string" then corelog.Error("ObjHost:getObject: failed obtaining className from objLocator="..objLocator:getURI()) return nil end

    -- get raw Resource
    local resourceTable = self:getResource(objLocator)
    if type(resourceTable) ~= "table" then corelog.Error("ObjHost:getObject: failed obtaining resourceTable from objLocator="..objLocator:getURI()) return nil end

    -- convert to Obj
    local obj = objectFactory:create(className, resourceTable)
    if not obj then corelog.Error("ObjHost:getObject: failed converting resourceTable(="..textutils.serialise(resourceTable)..") to "..className.." Obj for objLocator="..objLocator:getURI()) return nil end

    -- end
    return obj
end

function ObjHost:getObj_SSrv(...)
    -- get & check input from description
    local checkSuccess, objLocator = InputChecker.Check([[
        This sync service saves an Obj in the ObjHost.

        Return value:
                                - (table)
                success         - (boolean) whether the service executed successfully
                obj             - (IObj) Obj obtained from the ObjHost

        Parameters:
            serviceData         - (table) data for this service
                objLocator      + (URL) locator of the Obj within the ObjHost
    ]], ...)
    if not checkSuccess then corelog.Error("ObjHost:getObj_SSrv: Invalid input") return {success = false} end

    -- save object
    local obj = self:getObject(objLocator)
    if not obj then corelog.Error("ObjHost:getObj_SSrv: Failed obtaining from objLocator="..objLocator:getURI()) return {success = false} end

    -- end
    return {
        success         = true,
        obj             = obj,
    }
end

function ObjHost:saveObject(...)
    -- get & check input from description
    local checkSuccess, object, className, objectId = InputChecker.Check([[
        This method saves an object in the ObjHost using a className and objectId argument.

        If the object has a getClassName() method the className argument can be set to "".
        If the object has a getId() method the objectId argument can be set to "".

        Return value:
            objectLocator           - (URL) locating the object

        Parameters:
            object                  + (table) the object
            className               + (string, "") with the name of the class of the object
            objectId                + (string, "") with the optional id of the object
    ]], ...)
    if not checkSuccess then corelog.Error("ObjHost:saveObject: Invalid input") return nil end

    -- get objectPath
    local objectPath = ObjHost.GetObjectPath(className, objectId, object)
    if not objectPath then corelog.Error("ObjHost:saveObject: Failed obtaining objectPath") return nil end

    -- save resource
    local objectLocator = self:saveResource(object, objectPath)

    -- end
    return objectLocator
end

function ObjHost:saveObj_SSrv(...)
    -- get & check input from description
    local checkSuccess, obj = InputChecker.Check([[
        This sync service saves an Obj in the ObjHost.

        Return value:
                                - (table)
                success         - (boolean) whether the service executed successfully
                objLocator      - (URL) locating the object

        Parameters:
            serviceData         - (table) data for this service
                obj             + (table) the Obj
    ]], ...)
    if not checkSuccess then corelog.Error("ObjHost:saveObj_SSrv: Invalid input") return {success = false} end

    -- save object
    local objLocator = self:saveObject(obj)
    if not objLocator then corelog.Error("ObjHost:saveObj_SSrv: Failed saving Obj "..textutils.serialise(obj)) return {success = false} end

    -- end
    return {
        success         = true,
        objLocator      = objLocator,
    }
end

local function GetObjectsPath(...)
    -- get & check input from description
    local checkSuccess, className = InputChecker.Check([[
        This method provides the objectsPath of objects in the ObjHost with class className.

        Return value:
            objectsPath             - (string) locating the objects within the ObjHost

        Parameters:
            className               + (string) with the name of the class of the object
    --]], ...)
    if not checkSuccess then corelog.Error("ObjHost.GetObjectsPath: Invalid input") return nil end

    -- check className not empty
    if className == "" then corelog.Error("ObjHost.GetObjectsPath: classname is empty") return nil end

    -- determince objectsPath
    local objectsPath = "/objects/class="..className

    -- end
    return objectsPath
end

function ObjHost:getObjects(...)
    -- get & check input from description
    local checkSuccess, className = InputChecker.Check([[
        This (private) method retrieves all the objects in the ObjHost with class className.

        Return value:
            objects                 - (table) with the objects

        Parameters:
            className               + (string) with the name of the class of the objects
    --]], ...)
    if not checkSuccess then corelog.Error("ObjHost:getObjects: Invalid input") return nil end

    -- get objectsPath
    local objectsPath = GetObjectsPath(className)
    if not objectsPath then corelog.Error("ObjHost:getObjects: Failed obtaining objectsPath") return nil end

    -- get objectsLocator
    local objectsLocator = self:getResourceLocator(objectsPath)

    -- get objects
    local objects = self:getResource(objectsLocator)
    if not objects then
        -- (re)set objects
        self:saveResource({}, objectsPath)

        -- retrieve again
        objects = self:getResource(objectsLocator)
        if not objects then corelog.Error("ObjHost:getObjects: Failed (re)setting objects") return nil end
    end

    -- end
    return objects
end

function ObjHost:getNumberOfObjects(...)
    -- get & check input from description
    local checkSuccess, className = InputChecker.Check([[
        This method returns the number of objects in the ObjHost with class className.

        Return value:
                                    - (number) of objects of class className hosted by the ObjHost.

        Parameters:
            className               + (string) with the name of the class of the objects
    --]], ...)
    if not checkSuccess then corelog.Error("ObjHost:getNumberOfObjects: Invalid input") return -1 end

    -- get objects
    local objects = self:getObjects(className)
    if type(objects) ~= "table" then corelog.Error("ObjHost:getNumberOfObjects: Failed obtaining objects of class "..className) return -1 end

    -- loop on objects
    local count = 0
    for k, object in pairs(objects) do
        count = count + 1
    end

    return count
end

function ObjHost:deleteObjects(...)
    -- get & check input from description
    local checkSuccess, className = InputChecker.Check([[
        This method deletes all the objects in the ObjHost with class className.

        Return value:

        Parameters:
            className               + (string) with the name of the class of the objects
    --]], ...)
    if not checkSuccess then corelog.Error("ObjHost:deleteObjects: Invalid input") return nil end

    -- get objects
    local objects = self:getObjects(className)
    if type(objects) ~= "table" then corelog.Error("ObjHost:deleteObjects: Failed obtaining objects of class "..className) return nil end

    -- delete all objects
--    corelog.Warning("All objects of class "..className.." are being deleted!")
    for id, _obj in pairs(objects) do
        -- get locator
        local objLocator = ObjLocator:newInstance(self:getHostName(), className, id)

        -- delete
        self:deleteResource(objLocator)
    end
end

--        _        _   _
--       | |      | | (_)
--    ___| |_ __ _| |_ _  ___
--   / __| __/ _` | __| |/ __|
--   \__ \ || (_| | |_| | (__
--   |___/\__\__,_|\__|_|\___|

function ObjHost.GetObjectPath(...)
    -- get & check input from description
    local checkSuccess, className, objectId, object = InputChecker.Check([[
        This method provides the objectPath of an object in the ObjHost with class className and id objectId.

        If the object has a getClassName() method the className argument can be set to "".
        If the object has a getId() method the objectId argument can be set to "".
        If the object is not provided the className and objectId arguments are used

        Return value:
            resourcePath            - (string) locating the object within the ObjHost

        Parameters:
            className               + (string, "") with the name of the class of the object
            objectId                + (string, "") with the optional id of the object
            object                  + (table, nil) the object
    --]], ...)
    if not checkSuccess then corelog.Error("ObjHost.GetObjectPath: Invalid input") return nil end

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
                corelog.Warning("ObjHost.GetObjectPath: object:getClassName() did not return(type="..type(name)..") a string")
            end
        else
            corelog.Warning("ObjHost.GetObjectPath: object:getClassName() does not exist. Also not provided. => couldn't determine className")
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
                corelog.Warning("ObjHost.GetObjectPath: object:getId() did not return(type="..type(id)..") a string")
            end
        end
    end
    if objectId ~= "" then
        objectPath = objectPath.."/id="..objectId
    end

    -- end
    return objectPath
end

function ObjHost.GetObject(...)
    -- get & check input from description
    local checkSuccess, objectLocator = InputChecker.Check([[
        This method retrieves an object from a ObjHost using a locator (that was once provided by a ObjHost).

        The method first retrieves the ObjHost corresponding to the locator. If the locator locates the ObjHost itself it returns the ObjHost.
        Otherwise it will retrieve the object from the ObjHost with the getObject method of the ObjHost.

        Return value:
            object                  - (?) object obtained from the ObjHost

        Parameters:
            objectLocator           + (URL) locator of the object within the ObjHost
    ]], ...)
    if not checkSuccess then corelog.Error("ObjHost.GetObject: Invalid input") return nil end

    -- get ObjHost
    local host = Host.GetHost(objectLocator:getHost()) if not host then corelog.Error("ObjHost.GetObject: ObjHost of "..objectLocator:getURI().." not found") return nil end

    -- check the ObjHost itself is wanted
    if objectLocator:isEqual(host:getHostLocator()) then
        return host
    end

    -- get object from ObjHost
    local object = host:getObject(objectLocator)
    if not object then corelog.Error("ObjHost.GetObject: Failed getting object for objectLocator="..objectLocator:getURI()) return nil end

    -- end
    return object
end

return ObjHost
