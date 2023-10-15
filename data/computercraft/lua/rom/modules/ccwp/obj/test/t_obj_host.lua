local T_ObjHost = {}

local coreutils = require "coreutils"
local corelog = require "corelog"

local IObj = require "i_obj"
local ModuleRegistry = require "module_registry"
local moduleRegistry = ModuleRegistry:getInstance()
local URL = require "obj_url"
local ObjBase = require "obj_base"
local ObjHost = require "obj_host"

local TestObj = require "test.obj_test"

local TestArrayTest = require "test_array_test"
local FieldValueEqualTest = require "field_value_equal_test"

local T_Class = require "test.t_class"
local T_IObj = require "test.t_i_obj"

function T_ObjHost.T_All()
    -- initialisation
    T_ObjHost.T__init()
    T_ObjHost.T_new()

    -- specific
    T_ObjHost.T_getObjectLocator()
    T_ObjHost.T_saveObject()
    T_ObjHost.T_getObject()
    T_ObjHost.T_getNumberOfObjects()
    T_ObjHost.T_deleteObjects()

    -- class methods
    T_ObjHost.T_GetObject()
end

local testClassName = "ObjHost"
local testObjName = "objHost"
local logOk = false

local hostName1 = "TestObjHost"

local objHost1 = ObjHost:newInstance(hostName1)

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_ObjHost.CreateTestObj(hostName)
    -- check input
    hostName = hostName1 or hostName

    -- create testObj
    local testObj = ObjHost:newInstance(hostName)

    -- end
    return testObj
end

function T_ObjHost.CreateInitialisedTest(hostName)
    -- check input

    -- create test
    local test = TestArrayTest:newInstance(
        FieldValueEqualTest:newInstance("_hostName", hostName)
    )

    -- end
    return test
end

function T_ObjHost.T__init()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":_init() tests")

    -- test
    local obj = T_ObjHost.CreateTestObj(hostName1) assert(obj, "Failed obtaining "..testClassName)
    local test = T_ObjHost.CreateInitialisedTest(hostName1)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_ObjHost.T_new()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() tests")

    -- test full
    local obj = ObjHost:new({
        _hostName   = hostName1,
    })
    local test = T_ObjHost.CreateInitialisedTest(hostName1)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

function T_ObjHost.T_IObj_All()
    -- prepare test
    local obj = T_ObjHost.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_ObjHost.CreateTestObj() assert(otherObj, "Failed obtaining "..testClassName)

    -- test
    T_Class.pt_IsInstanceOf(testClassName, obj, "IObj", IObj)
    T_Class.pt_IsInstanceOf(testClassName, obj, "ObjBase", ObjBase)
    T_IObj.pt_all(testClassName, obj, otherObj)
end

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

local testObject = TestObj:newInstance("field1", 4)
local className = "TestObj"

function T_ObjHost.T_getObjectLocator()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":getObjectLocator tests")
    local objectId = coreutils.NewId()

    -- test with supplying className and id
    local objectLocator = objHost1:getObjectLocator(testObject, className, objectId)
    local expectedLocator = URL:newFromURI("ccwprp://"..hostName1.."/objects/class="..className.."/id="..objectId)
    assert(objectLocator:isEqual(expectedLocator), "objectLocator(="..objectLocator:getURI()..") not the same as expected(="..expectedLocator:getURI()..")")

    -- test without supplying id
    objectLocator = objHost1:getObjectLocator(testObject, className)
    expectedLocator = URL:newFromURI("ccwprp://"..hostName1.."/objects/class="..className)
    assert(objectLocator:isEqual(expectedLocator), "objectLocator(="..objectLocator:getURI()..") not the same as expected(="..expectedLocator:getURI()..")")

    -- test without supplying className (but object has getClassName method) and id
    objectLocator = objHost1:getObjectLocator(testObject)
    expectedLocator = URL:newFromURI("ccwprp://"..hostName1.."/objects/class="..className)
    assert(objectLocator:isEqual(expectedLocator), "objectLocator(="..objectLocator:getURI()..") not the same as expected(="..expectedLocator:getURI()..")")

    -- test without supplying className (but object has getClassName method) but with id
    objectLocator = objHost1:getObjectLocator(testObject, "", objectId)
    expectedLocator = URL:newFromURI("ccwprp://"..hostName1.."/objects/class="..className.."/id="..objectId)
    assert(objectLocator:isEqual(expectedLocator), "objectLocator(="..objectLocator:getURI()..") not the same as expected(="..expectedLocator:getURI()..")")

    -- cleanup test
end

function T_ObjHost.T_saveObject()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":saveObject tests")
    local objectId = coreutils.NewId()

    -- test with supplying className and id
    local objectLocator = objHost1:saveObject(testObject, className, objectId)
    local expectedLocator = URL:newFromURI("ccwprp://"..hostName1.."/objects/class="..className.."/id="..objectId)
    assert(objectLocator:isEqual(expectedLocator), "objectLocator(="..objectLocator:getURI()..") not the same as expected(="..expectedLocator:getURI()..")")
    objHost1:deleteResource(objectLocator)
    assert(not objHost1:getResource(objectLocator), "resource not deleted")

    -- test without supplying id
    objectLocator = objHost1:saveObject(testObject, className)
    expectedLocator = URL:newFromURI("ccwprp://"..hostName1.."/objects/class="..className)
    assert(objectLocator:isEqual(expectedLocator), "objectLocator(="..objectLocator:getURI()..") not the same as expected(="..expectedLocator:getURI()..")")
    objHost1:deleteResource(objectLocator)
    assert(not objHost1:getResource(objectLocator), "resource not deleted")

    -- test without supplying className (but object has getClassName method) and id
    objectLocator = objHost1:saveObject(testObject)
    expectedLocator = URL:newFromURI("ccwprp://"..hostName1.."/objects/class="..className)
    assert(objectLocator:isEqual(expectedLocator), "objectLocator(="..objectLocator:getURI()..") not the same as expected(="..expectedLocator:getURI()..")")
    objHost1:deleteResource(objectLocator)
    assert(not objHost1:getResource(objectLocator), "resource not deleted")

    -- test without supplying className (but object has getClassName method) but with id
    objectLocator = objHost1:saveObject(testObject, "", objectId)
    expectedLocator = URL:newFromURI("ccwprp://"..hostName1.."/objects/class="..className.."/id="..objectId)
    assert(objectLocator:isEqual(expectedLocator), "objectLocator(="..objectLocator:getURI()..") not the same as expected(="..expectedLocator:getURI()..")")
    objHost1:deleteResource(objectLocator)
    assert(not objHost1:getResource(objectLocator), "resource not deleted")

    -- cleanup test
end

function T_ObjHost.T_getObject()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":getObject tests")
    local objectLocator = objHost1:saveObject(testObject, className)

    -- test get object
    local object = objHost1:getObject(objectLocator)
    assert(object:isEqual(testObject), "object(="..textutils.serialise(object, compact)..") not the same as expected(="..textutils.serialise(testObject, compact)..")")

    -- cleanup test
    objHost1:deleteResource(objectLocator)
    assert(not objHost1:getResource(objectLocator), "resource not deleted")
end

function T_ObjHost.T_getNumberOfObjects()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":getNumberOfObjects tests")
    local originalNObjects = objHost1:getNumberOfObjects(className)
    local objectId = coreutils.NewId()

    -- test
    local objectLocator = objHost1:saveObject(testObject, className, objectId) -- add an extra object
    local nObjects = objHost1:getNumberOfObjects(className)
    local expectedNObjects = originalNObjects + 1
    assert(nObjects == expectedNObjects, "gotten nObjects(="..nObjects..") not the same as expected(="..expectedNObjects..")")

    -- cleanup test
    objHost1:deleteResource(objectLocator)
    nObjects = objHost1:getNumberOfObjects(className)
    assert(nObjects == originalNObjects, "gotten nObjects(="..nObjects..") not the same as expected(="..originalNObjects..")")
end

function T_ObjHost.T_deleteObjects()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":deleteObjects tests")

    -- test
    objHost1:deleteObjects(className)
    local nObjects = objHost1:getNumberOfObjects(className)
    local expectedNObjects = 0
    assert(nObjects == expectedNObjects, "gotten nObjects(="..nObjects..") not the same as expected(="..expectedNObjects..")")

    -- cleanup test
end

--         _                                _   _               _
--        | |                              | | | |             | |
--     ___| | __ _ ___ ___   _ __ ___   ___| |_| |__   ___   __| |___
--    / __| |/ _` / __/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   | (__| | (_| \__ \__ \ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--    \___|_|\__,_|___/___/ |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--
--

function T_ObjHost.T_GetObject()
    -- prepare test
    corelog.WriteToLog("* ObjHost.GetObject(...) tests")
    moduleRegistry:register(hostName1, objHost1)

    -- test get object hosted by objHost1
    local objectLocator = objHost1:saveObject(testObject, className)
    local object = ObjHost.GetObject(objectLocator)
    assert(object and object:isEqual(testObject), "object(="..textutils.serialise(object, compact)..") not the same as expected(="..textutils.serialise(testObject, compact)..")")

    -- test get objHost1 from itself
    local hostLocator = objHost1:getHostLocator()
    object = ObjHost.GetObject(hostLocator)
    assert(object and object:isEqual(objHost1), "object(="..textutils.serialise(object, compact)..") not the same as expected(="..textutils.serialise(testObject, compact)..")")

    -- cleanup test
    objHost1:deleteResource(objectLocator)
    moduleRegistry:delist(hostName1)
end

return T_ObjHost
