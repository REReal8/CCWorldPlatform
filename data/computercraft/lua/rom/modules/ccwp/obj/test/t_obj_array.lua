local T_ObjArray = {}

local corelog = require "corelog"

local Class = require "class"
local IObj = require "i_obj"
local ObjBase = require "obj_base"
local ObjArray = require "obj_array"
local TestObj = require "test.obj_test"
local Location = require "obj_location"

local FieldsTest = require "fields_test"
local FieldValueEqualTest = require "field_value_equal_test"

local T_Class = require "test.t_class"
local T_IObj = require "test.t_i_obj"

function T_ObjArray.T_All()
    -- initialisation
    T_ObjArray.T__init()
    T_ObjArray.T_new()

    -- IObj methods
    T_ObjArray.T_IObj_All()

    -- specific methods
    T_ObjArray.T_nObjs()
    T_ObjArray.T_transformObjectTables()
    T_ObjArray.T_new_transformsObjTables()
end

local testClassName = "ObjArray"
local logOk = false
local objClassName1 = "TestObj"
local testObj1 = TestObj:new({
    _field1 = "field1_1",
    _field2 = 1,
})
local testObj2 = TestObj:new({
    _field1 = "field1_2",
    _field2 = 2,
})
local wrongTestObj1 = Location:newInstance()

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_ObjArray.CreateTestObj(objClassName, objsArray)
    -- check input
    objClassName = objClassName or objClassName1
    objsArray = objsArray or {
        testObj1:copy(),
        testObj2:copy(),
    }

    -- create testObj
    local testObj = ObjArray:newInstance(objClassName, objsArray)

    -- end
    return testObj
end

function T_ObjArray.CreateInitialisedTest(objClassName, objsArray)
    -- check input

    -- create test
    local test = FieldsTest:newInstance(
        FieldValueEqualTest:newInstance("_objClassName", objClassName)
    )
    for i, obj in ipairs(objsArray) do
        table.insert(test._tests, FieldValueEqualTest:newInstance(i, obj))
    end

    -- end
    return test
end

function T_ObjArray.T__init()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":_init() tests")
    local objsArray = {
        testObj1:copy(),
        testObj2:copy(),
    }

    -- test
    local obj = T_ObjArray.CreateTestObj(objClassName1, objsArray) assert(obj, "Failed obtaining "..testClassName)
    local test = T_ObjArray.CreateInitialisedTest(objClassName1, objsArray)
    test:test(obj, "objArray", "", logOk)

    -- test default
    obj = ObjArray:newInstance()
    test = T_ObjArray.CreateInitialisedTest("", {})
    test:test(obj, "objArray", "", logOk)

    -- cleanup test
end

function T_ObjArray.T_new()
    -- prepare test
    corelog.WriteToLog("* ObjArray:new() tests")
    local objsArray = {
        testObj1:copy(),
        testObj2:copy(),
    }

    -- test full
    local obj = ObjArray:new({
        _objClassName   = objClassName1,

        testObj1,
        testObj2,
    }) if not obj then corelog.Warning("obj unexpectedly nil") return end
    local test = T_ObjArray.CreateInitialisedTest(objClassName1, objsArray)
    test:test(obj, "objArray", "", logOk)

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

function T_ObjArray.T_IObj_All()
    -- prepare test
    local obj = T_ObjArray.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_ObjArray.CreateTestObj() assert(otherObj, "Failed obtaining "..testClassName)

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

function T_ObjArray.T_nObjs()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":nObjs() tests")
    local objsArray = {
        testObj1:copy(),
        testObj2:copy(),
    }
    local obj = T_ObjArray.CreateTestObj(objClassName1, objsArray) assert(obj, "Failed obtaining "..testClassName)

    -- test
    local expectedNElements = 2
    local nObjs = obj:nObjs()
    assert(nObjs == expectedNElements, " # elements(="..nObjs..") not the same as expected(="..expectedNElements..")")

    -- cleanup test
end

function T_ObjArray.T_transformObjectTables()
    -- prepare test
    corelog.WriteToLog("* ObjArray:transformObjectTables() tests")
    local objArray2 = ObjArray:new({
        _objClassName   = objClassName1,
    }) if not objArray2 then corelog.Warning("objArray2 unexpectedly nil") return end
    local testObject1Table = {
        _field1 = "field1_1",
        _field2 = 1,
    }
    local testObject2Table = {
        _field1 = "field1_2",
        _field2 = 2,
    }
    assert(not Class.IsInstanceOf(testObject1Table, TestObj), "testObject1Table incorrectly of type "..objClassName1)
    assert(not Class.IsInstanceOf(testObject2Table, TestObj), "testObject2Table incorrectly of type "..objClassName1)

    -- test already only Obj's (nothing should change)
    objArray2[1] = testObj1
    objArray2[2] = testObj2
    objArray2:transformObjectTables()
    local expectedNElements = 2
    assert(table.getn(objArray2) == expectedNElements, " # elements(="..table.getn(objArray2)..") not the same as expected(="..expectedNElements..")")
    assert(objArray2[1]:isEqual(testObj1), "obj 1 in array(="..textutils.serialise(objArray2[1], compact)..") not the same as expected(="..textutils.serialise(testObj1, compact)..")")
    assert(objArray2[2]:isEqual(testObj2), "obj 2 in array(="..textutils.serialise(objArray2[2], compact)..") not the same as expected(="..textutils.serialise(testObj2, compact)..")")
    objArray2[1] = nil
    objArray2[2] = nil

    -- test different class Obj skipped
    objArray2[1] = testObj1
    objArray2[2] = wrongTestObj1
    objArray2[3] = testObj2
    objArray2:transformObjectTables(true)
    expectedNElements = 2
    assert(table.getn(objArray2) == expectedNElements, " # elements(="..table.getn(objArray2)..") not the same as expected(="..expectedNElements..")")
    assert(objArray2[1]:isEqual(testObj1), "obj 1 in array(="..textutils.serialise(objArray2[1], compact)..") not the same as expected(="..textutils.serialise(testObj1, compact)..")")
    assert(objArray2[2]:isEqual(testObj2), "obj 2 in array(="..textutils.serialise(objArray2[2], compact)..") not the same as expected(="..textutils.serialise(testObj2, compact)..")")
    objArray2[1] = nil
    objArray2[2] = nil
    objArray2[3] = nil

    -- test only object tables
    objArray2[1] = testObject1Table
    objArray2[2] = testObject2Table
    objArray2:transformObjectTables()
    assert(objArray2[1]:isEqual(testObj1), "obj 1 in array(="..textutils.serialise(objArray2[1], compact)..") not the same as expected(="..textutils.serialise(testObj1, compact)..")")
    assert(objArray2[2]:isEqual(testObj2), "obj 2 in array(="..textutils.serialise(objArray2[2], compact)..") not the same as expected(="..textutils.serialise(testObj2, compact)..")")
    objArray2[1] = nil
    objArray2[2] = nil

    -- test mix ObjTables and Obj's
    testObject2Table = {
        _field1 = "field1_2",
        _field2 = 2,
    }
    assert(not Class.IsInstanceOf(testObject2Table, TestObj), "testObject2Table incorrectly of type "..objClassName1)

    objArray2[1] = testObj1
    objArray2[2] = testObject2Table
    objArray2:transformObjectTables()
    assert(objArray2[1]:isEqual(testObj1), "obj 1 in array(="..textutils.serialise(objArray2[1], compact)..") not the same as expected(="..textutils.serialise(testObj1, compact)..")")
    assert(objArray2[2]:isEqual(testObj2), "obj 2 in array(="..textutils.serialise(objArray2[2], compact)..") not the same as expected(="..textutils.serialise(testObj2, compact)..")")
    objArray2[1] = nil
    objArray2[2] = nil

    -- cleanup test
end

function T_ObjArray.T_new_transformsObjTables()
    -- prepare test
    corelog.WriteToLog("* ObjArray:new() transforms objTables tests")
    local testObject1Table = {
        _field1 = "field1_1",
        _field2 = 1,
    }
    local testObject2Table = {
        _field1 = "field1_2",
        _field2 = 2,
    }

    -- test new transforms objTables
    local obj = ObjArray:new({
        _objClassName   = objClassName1,

        testObject1Table,
        testObject2Table,
    })
    if not obj then return end
    assert(obj:getObjClassName() == objClassName1, "gotten getObjClassName(="..obj:getObjClassName()..") not the same as expected(="..objClassName1..")")
    local expectedNElements = 2
    assert(table.getn(obj) == expectedNElements, " # elements(="..table.getn(obj)..") not the same as expected(="..expectedNElements..")")
    local objClass = obj:getObjClass()

    assert(Class.IsInstanceOf(obj[1], objClass), "obj 1 in obj(="..textutils.serialise(obj[1], compact)..") not of type "..objClassName1)
    assert(Class.IsInstanceOf(obj[2], objClass), "obj 2 in obj(="..textutils.serialise(obj[1], compact)..") not of type "..objClassName1)

    -- cleanup test
end

return T_ObjArray
