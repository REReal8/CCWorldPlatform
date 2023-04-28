local T_Host = {}

local coreutils = require "coreutils"
local corelog = require "corelog"

local URL = require "obj_url"
local Host = require "obj_host"

local TestObj = require "test.obj_test"

function T_Host.T_All()
    -- base methods
    T_Host.T_new()
    T_Host.T_IsOfType()
    T_Host.T_isSame()
    T_Host.T_copy()

    -- specific methods
    T_Host.T_getHostLocator()
    T_Host.T_getResourceLocator()
    T_Host.T_get_save_delete_Resource()
    T_Host.T_getObjectLocator()
    T_Host.T_saveObject()
    T_Host.T_getObject()
    T_Host.T_getNumberOfObjects()
    T_Host.T_deleteObjects()

    -- helper functions
end

local hostName = "TestHost"
local hostName2 = "TestHost2"

local host1 = Host:new({
    _hostName   = hostName,
})

local compact = { compact = true }

--    _                                     _   _               _
--   | |                                   | | | |             | |
--   | |__   __ _ ___  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   | '_ \ / _` / __|/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   | |_) | (_| \__ \  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_.__/ \__,_|___/\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

function T_Host.T_new()
    -- prepare test
    corelog.WriteToLog("* Host:new() tests")

    -- test full
    local host = Host:new({
        _hostName   = hostName,
    })
    assert(host:getHostName() == hostName, "gotten getHostName(="..host:getHostName()..") not the same as expected(="..hostName..")")

    -- cleanup test
end

function T_Host.T_IsOfType()
    -- prepare test
    corelog.WriteToLog("* Host.IsOfType() tests")
    local host2 = Host:new({
        _hostName   = hostName,
    })

    -- test valid
    local isOfType = Host.IsOfType(host2)
    local expectedIsOfType = true
    assert(isOfType == expectedIsOfType, "gotten IsOfType(="..tostring(isOfType)..") not the same as expected(="..tostring(expectedIsOfType)..")")

    -- test different object
    isOfType = Host.IsOfType("a atring")
    expectedIsOfType = false
    assert(isOfType == expectedIsOfType, "gotten IsOfType(="..tostring(isOfType)..") not the same as expected(="..tostring(expectedIsOfType)..")")

    -- test invalid hostName
    host2._hostName = 1000
    isOfType = Host.IsOfType(host2)
    expectedIsOfType = false
    assert(isOfType == expectedIsOfType, "gotten IsOfType(="..tostring(isOfType)..") not the same as expected(="..tostring(expectedIsOfType)..")")
    host2._hostName = hostName

    -- cleanup test
end

function T_Host.T_isSame()
    -- prepare test
    corelog.WriteToLog("* Host:isSame() tests")
    local host2 = Host:new({
        _hostName   = hostName,
    })

    -- test same
    local isSame = host1:isSame(host2)
    local expectedIsSame = true
    assert(isSame == expectedIsSame, "gotten isSame(="..tostring(isSame)..") not the same as expected(="..tostring(expectedIsSame)..")")

    -- test different hostName
    host2._hostName = hostName2
    isSame = host1:isSame(host2)
    expectedIsSame = false
    assert(isSame == expectedIsSame, "gotten isSame(="..tostring(isSame)..") not the same as expected(="..tostring(expectedIsSame)..")")
    host2._hostName = hostName

    -- cleanup test
end

function T_Host.T_copy()
    -- prepare test
    corelog.WriteToLog("* Host:copy() tests")

    -- test
    local copy = host1:copy()
    assert(copy:isSame(host1), "gotten copy(="..textutils.serialize(copy, compact)..") not the same as expected(="..textutils.serialize(host1, compact)..")")

    -- cleanup test
end

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

local resource = {
    aNumber     = 10,
    aString     = "top",
    aTable      = {_x= -10, _y= 0, _z= 1, _dx=0, _dy=1},
}

local resourcePath1 = "/resource/id=10/subid=7"

local function SameATable(aTable1, aTable2)
    if aTable1 == nil and aTable2 == nil then return true end
    if aTable1 == nil or aTable2 == nil then return false end

    return aTable1.x == aTable2.x and aTable1.y == aTable2.y and aTable1.z == aTable2.z and aTable1.dx == aTable2.dx and aTable1.dy == aTable2.dy
end

local function SameResource(res1, res2)
    if res1 == nil and res2 == nil then return true end
    if res1 == nil or res2 == nil then return false end

    return res1.aNumber == res2.aNumber and res1.aString == res2.aString and SameATable(res1.aTable, res2.aTable)
end

function T_Host.T_getHostLocator()
    -- prepare test
    corelog.WriteToLog("* Host:getHostLocator() tests")

    -- test
    local hostLocator = host1:getHostLocator()
    local expectedLocator = URL:new()
    expectedLocator:setHost(hostName)
    assert(hostLocator:isSame(expectedLocator), "getHostLocator(="..hostLocator:getURI()..") not the same as expected(="..expectedLocator:getURI()..")")

    -- cleanup test
end

function T_Host.T_getResourceLocator()
    -- prepare test
    corelog.WriteToLog("* Host:getResourceLocator(...) tests")

    -- test
    local resourceLocator = host1:getResourceLocator(resourcePath1)
    local expectedLocator = URL:new()
    expectedLocator:setHost(hostName)
    expectedLocator:setPath(resourcePath1)
    assert(resourceLocator:isSame(expectedLocator), "getResourceLocator(="..resourceLocator:getURI()..") not the same as expected(="..expectedLocator:getURI()..")")

    -- cleanup test
end

function T_Host.T_get_save_delete_Resource()
    -- prepare test
    corelog.WriteToLog("* Host:getResource, saveResource, deleteResource tests")
    local resourceLocator = host1:getResourceLocator(resourcePath1)

    -- test getResource (not yet present)
    local resourceGotten = host1:getResource(resourceLocator)
    assert(not resourceGotten, "unexpected resource(="..textutils.serialize(resourceGotten, compact)..") obtained (i.e. not nil)")

    -- test save
    resourceLocator = host1:saveResource(resource, resourcePath1)
    local expectedLocator = URL:new()
    expectedLocator:setHost(hostName)
    expectedLocator:setPath(resourcePath1)
    assert(resourceLocator:isSame(expectedLocator), "getResourceLocator(="..resourceLocator:getURI()..") not the same as expected(="..expectedLocator:getURI()..")")

    -- test getResource (now present)
    resourceGotten = host1:getResource(resourceLocator)
    assert(SameResource(resource, resourceGotten), "gotten resource(="..textutils.serialize(resourceGotten, compact)..") not the same as expected(="..textutils.serialize(resource, compact)..")")

    -- test delete
    local deleteSuccess = host1:deleteResource(resourceLocator)
    assert(deleteSuccess, "delete not succesfull")

    -- test getResource (no longer present)
    resourceGotten = host1:getResource(resourceLocator)
    assert(not resourceGotten, "unexpected resource(="..textutils.serialize(resourceGotten, compact)..") obtained (i.e. not nil)")

    -- cleanup test
end

local testObject = TestObj:new({
    _field1 = "field1",
    _field2 = 4,
})
local className = "TestObj"

function T_Host.T_getObjectLocator()
    -- prepare test
    corelog.WriteToLog("* Host:getObjectLocator tests")
    local objectId = coreutils.NewId()

    -- test with supplying className and id
    local objectLocator = host1:getObjectLocator(testObject, className, objectId)
    local expectedLocator = URL:newFromURI("ccwprp://"..hostName.."/objects/class="..className.."/id="..objectId)
    assert(objectLocator:isSame(expectedLocator), "objectLocator(="..objectLocator:getURI()..") not the same as expected(="..expectedLocator:getURI()..")")

    -- test without supplying id
    objectLocator = host1:getObjectLocator(testObject, className)
    expectedLocator = URL:newFromURI("ccwprp://"..hostName.."/objects/class="..className)
    assert(objectLocator:isSame(expectedLocator), "objectLocator(="..objectLocator:getURI()..") not the same as expected(="..expectedLocator:getURI()..")")

    -- test without supplying className (but object has getClassName method) and id
    objectLocator = host1:getObjectLocator(testObject)
    expectedLocator = URL:newFromURI("ccwprp://"..hostName.."/objects/class="..className)
    assert(objectLocator:isSame(expectedLocator), "objectLocator(="..objectLocator:getURI()..") not the same as expected(="..expectedLocator:getURI()..")")

    -- test without supplying className (but object has getClassName method) but with id
    objectLocator = host1:getObjectLocator(testObject, "", objectId)
    expectedLocator = URL:newFromURI("ccwprp://"..hostName.."/objects/class="..className.."/id="..objectId)
    assert(objectLocator:isSame(expectedLocator), "objectLocator(="..objectLocator:getURI()..") not the same as expected(="..expectedLocator:getURI()..")")

    -- cleanup test
end

function T_Host.T_saveObject()
    -- prepare test
    corelog.WriteToLog("* Host:saveObject tests")
    local objectId = coreutils.NewId()

    -- test with supplying className and id
    local objectLocator = host1:saveObject(testObject, className, objectId)
    local expectedLocator = URL:newFromURI("ccwprp://"..hostName.."/objects/class="..className.."/id="..objectId)
    assert(objectLocator:isSame(expectedLocator), "objectLocator(="..objectLocator:getURI()..") not the same as expected(="..expectedLocator:getURI()..")")
    host1:deleteResource(objectLocator)
    assert(not host1:getResource(objectLocator), "resource not deleted")

    -- test without supplying id
    objectLocator = host1:saveObject(testObject, className)
    expectedLocator = URL:newFromURI("ccwprp://"..hostName.."/objects/class="..className)
    assert(objectLocator:isSame(expectedLocator), "objectLocator(="..objectLocator:getURI()..") not the same as expected(="..expectedLocator:getURI()..")")
    host1:deleteResource(objectLocator)
    assert(not host1:getResource(objectLocator), "resource not deleted")

    -- test without supplying className (but object has getClassName method) and id
    objectLocator = host1:saveObject(testObject)
    expectedLocator = URL:newFromURI("ccwprp://"..hostName.."/objects/class="..className)
    assert(objectLocator:isSame(expectedLocator), "objectLocator(="..objectLocator:getURI()..") not the same as expected(="..expectedLocator:getURI()..")")
    host1:deleteResource(objectLocator)
    assert(not host1:getResource(objectLocator), "resource not deleted")

    -- test without supplying className (but object has getClassName method) but with id
    objectLocator = host1:saveObject(testObject, "", objectId)
    expectedLocator = URL:newFromURI("ccwprp://"..hostName.."/objects/class="..className.."/id="..objectId)
    assert(objectLocator:isSame(expectedLocator), "objectLocator(="..objectLocator:getURI()..") not the same as expected(="..expectedLocator:getURI()..")")
    host1:deleteResource(objectLocator)
    assert(not host1:getResource(objectLocator), "resource not deleted")

    -- cleanup test
end

function T_Host.T_getObject()
    -- prepare test
    corelog.WriteToLog("* Host:getObject tests")
    local objectLocator = host1:saveObject(testObject, className)

    -- test get object
    local object = host1:getObject(objectLocator)
    assert(object:isSame(testObject), "object(="..textutils.serialise(object, compact)..") not the same as expected(="..textutils.serialise(testObject, compact)..")")

    -- cleanup test
    host1:deleteResource(objectLocator)
    assert(not host1:getResource(objectLocator), "resource not deleted")
end

function T_Host.T_getNumberOfObjects()
    -- prepare test
    corelog.WriteToLog("* Host:getNumberOfObjects tests")
    local originalNObjects = host1:getNumberOfObjects(className)
    local objectId = coreutils.NewId()

    -- test
    local objectLocator = host1:saveObject(testObject, className, objectId) -- add an extra object
    local nObjects = host1:getNumberOfObjects(className)
    local expectedNObjects = originalNObjects + 1
    assert(nObjects == expectedNObjects, "gotten nObjects(="..nObjects..") not the same as expected(="..expectedNObjects..")")

    -- cleanup test
    host1:deleteResource(objectLocator)
    nObjects = host1:getNumberOfObjects(className)
    assert(nObjects == originalNObjects, "gotten nObjects(="..nObjects..") not the same as expected(="..originalNObjects..")")
end

function T_Host.T_deleteObjects()
    -- prepare test
    corelog.WriteToLog("* Host:deleteObjects tests")

    -- test
    host1:deleteObjects(className)
    local nObjects = host1:getNumberOfObjects(className)
    local expectedNObjects = 0
    assert(nObjects == expectedNObjects, "gotten nObjects(="..nObjects..") not the same as expected(="..expectedNObjects..")")

    -- cleanup test
end

return T_Host
