local T_ObjTable = {}

local corelog = require "corelog"

local Class = require "class"
local IObj = require "i_obj"
local ObjBase = require "obj_base"
local ObjTable = require "obj_table"
local TestObj = require "test.obj_test"
local Location = require "obj_location"

local FieldsTest = require "fields_test"
local FieldValueEqualTest = require "field_value_equal_test"

local T_Class = require "test.t_class"
local T_IObj = require "test.t_i_obj"

function T_ObjTable.T_All()
    -- initialisation
    T_ObjTable.T__init()
    T_ObjTable.T_new()

    -- IObj methods
    T_ObjTable.T_IObj_All()

    -- specific methods
    T_ObjTable.T_nObjs()
    T_ObjTable.T_transformObjectTables()
    T_ObjTable.T_new_transformsObjTables()
end

local testClassName = "ObjTable"
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

function T_ObjTable.CreateTestObj(objClassName, objsTable)
    -- check input
    objClassName = objClassName or objClassName1
    objsTable = objsTable or {
        testObj1Key = testObj1:copy(),
        testObj2Key = testObj2:copy(),
    }

    -- create testObj
    local testObj = ObjTable:newInstance(objClassName, objsTable)

    -- end
    return testObj
end

function T_ObjTable.CreateInitialisedTest(objClassName, objsTable)
    -- check input

    -- create test
    local test = FieldsTest:newInstance(
        FieldValueEqualTest:newInstance("_objClassName", objClassName)
    )
    for key, obj in pairs(objsTable) do
        table.insert(test._tests, FieldValueEqualTest:newInstance(key, obj))
    end

    -- end
    return test
end

function T_ObjTable.T__init()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":_init() tests")
    local objsTable = {
        testObj1Key = testObj1:copy(),
        testObj2Key = testObj2:copy(),
    }

    -- test
    local obj = T_ObjTable.CreateTestObj(objClassName1, objsTable) assert(obj, "Failed obtaining "..testClassName)
    local test = T_ObjTable.CreateInitialisedTest(objClassName1, objsTable)
    test:test(obj, "objTable", "", logOk)

    -- test default
    obj = ObjTable:newInstance()
    test = T_ObjTable.CreateInitialisedTest("", {})
    test:test(obj, "objTable", "", logOk)

    -- cleanup test
end

function T_ObjTable.T_new()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() tests")

    -- test full
    local objTable = ObjTable:new({
        _objClassName   = objClassName1,

        testObj1Key     = testObj1,
        testObj2Key     = testObj2,
    }) if not objTable then corelog.Warning("objTable unexpectedly nil") return end
    assert(objTable:getObjClassName() == objClassName1, "gotten getObjClassName(="..objTable:getObjClassName()..") not the same as expected(="..objClassName1..")")
    local expectedNElements = 2
    assert(objTable:nObjs() == expectedNElements, " # elements(="..objTable:nObjs()..") not the same as expected(="..expectedNElements..")")
    assert(objTable.testObj1Key:isEqual(testObj1), "obj 1 in objTable(="..textutils.serialise(objTable.testObj1Key, compact)..") not the same as expected(="..textutils.serialise(testObj1, compact)..")")
    assert(objTable.testObj2Key:isEqual(testObj2), "obj 2 in objTable(="..textutils.serialise(objTable.testObj2Key, compact)..") not the same as expected(="..textutils.serialise(testObj2, compact)..")")

    -- test default
    objTable = ObjTable:new() if not objTable then return end
    local defaultName = ""
    assert(objTable:getObjClassName() == defaultName, "gotten getObjClassName(="..objTable:getObjClassName()..") not the same as expected(="..defaultName..")")
    expectedNElements = 0
    assert(objTable:nObjs() == expectedNElements, " # elements(="..objTable:nObjs()..") not the same as expected(="..expectedNElements..")")

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

function T_ObjTable.T_IObj_All()
    -- prepare test
    local obj = T_ObjTable.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_ObjTable.CreateTestObj() assert(otherObj, "Failed obtaining "..testClassName)

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

function T_ObjTable.T_nObjs()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":nObjs() tests")
    local objsTable = {
        testObj1Key = testObj1:copy(),
        testObj2Key = testObj2:copy(),
    }
    local obj = T_ObjTable.CreateTestObj(objClassName1, objsTable) assert(obj, "Failed obtaining "..testClassName)

    -- test
    local expectedNElements = 2
    local nObjs = obj:nObjs()
    assert(nObjs == expectedNElements, " # elements(="..nObjs..") not the same as expected(="..expectedNElements..")")

    -- cleanup test
end


function T_ObjTable.T_transformObjectTables()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":transformObjectTables() tests")
    local objTable2 = ObjTable:new({
        _objClassName   = objClassName1,
    }) if not objTable2 then corelog.Warning("objTable2 unexpectedly nil") return end
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
    objTable2.testObj1Key = testObj1
    objTable2.testObj2Key = testObj2
    objTable2:transformObjectTables()
    local expectedNElements = 2
    assert(objTable2:nObjs() == expectedNElements, " # elements(="..objTable2:nObjs()..") not the same as expected(="..expectedNElements..")")
    assert(objTable2.testObj1Key:isEqual(testObj1), "obj 1 in array(="..textutils.serialise(objTable2.testObj1Key, compact)..") not the same as expected(="..textutils.serialise(testObj1, compact)..")")
    assert(objTable2.testObj2Key:isEqual(testObj2), "obj 2 in array(="..textutils.serialise(objTable2.testObj2Key, compact)..") not the same as expected(="..textutils.serialise(testObj2, compact)..")")
    objTable2.testObj1Key = nil
    objTable2.testObj2Key = nil

    -- test different class Obj skipped
    objTable2.testObj1Key = testObj1
    objTable2.testObj3Key = wrongTestObj1
    objTable2.testObj2Key = testObj2
    objTable2:transformObjectTables(true)
    expectedNElements = 2
    assert(objTable2:nObjs() == expectedNElements, " # elements(="..objTable2:nObjs()..") not the same as expected(="..expectedNElements..")")
    assert(objTable2.testObj1Key:isEqual(testObj1), "obj 1 in array(="..textutils.serialise(objTable2.testObj1Key, compact)..") not the same as expected(="..textutils.serialise(testObj1, compact)..")")
    assert(objTable2.testObj2Key:isEqual(testObj2), "obj 2 in array(="..textutils.serialise(objTable2.testObj2Key, compact)..") not the same as expected(="..textutils.serialise(testObj2, compact)..")")
    objTable2.testObj1Key = nil
    objTable2.testObj2Key = nil
    objTable2.testObj3Key = nil

    -- test only object tables
    objTable2.testObj1Key = testObject1Table
    objTable2.testObj2Key = testObject2Table
    objTable2:transformObjectTables()
    assert(objTable2.testObj1Key:isEqual(testObj1), "obj 1 in array(="..textutils.serialise(objTable2.testObj1Key, compact)..") not the same as expected(="..textutils.serialise(testObj1, compact)..")")
    assert(objTable2.testObj2Key:isEqual(testObj2), "obj 2 in array(="..textutils.serialise(objTable2.testObj2Key, compact)..") not the same as expected(="..textutils.serialise(testObj2, compact)..")")
    objTable2.testObj1Key = nil
    objTable2.testObj2Key = nil

    -- test mix ObjTables and Obj's
    testObject2Table = {
        _field1 = "field1_2",
        _field2 = 2,
    }
    assert(not Class.IsInstanceOf(testObject2Table, TestObj), "testObject2Table incorrectly of type "..objClassName1)

    objTable2.testObj1Key = testObj1
    objTable2.testObj2Key = testObject2Table
    objTable2:transformObjectTables()
    assert(objTable2.testObj1Key:isEqual(testObj1), "obj 1 in array(="..textutils.serialise(objTable2.testObj1Key, compact)..") not the same as expected(="..textutils.serialise(testObj1, compact)..")")
    assert(objTable2.testObj2Key:isEqual(testObj2), "obj 2 in array(="..textutils.serialise(objTable2.testObj2Key, compact)..") not the same as expected(="..textutils.serialise(testObj2, compact)..")")
    objTable2.testObj1Key = nil
    objTable2.testObj2Key = nil

    -- cleanup test
end

function T_ObjTable.T_new_transformsObjTables()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() transforms objTables tests")
    local testObject1Table = {
        _field1 = "field1_1",
        _field2 = 1,
    }
    local testObject2Table = {
        _field1 = "field1_2",
        _field2 = 2,
    }

    -- test new transforms objTables
    local objTable = ObjTable:new({
        _objClassName   = objClassName1,

        testObj1        = testObject1Table,
        testObj2        = testObject2Table,
    })
    if not objTable then return end
    assert(objTable:getObjClassName() == objClassName1, "gotten getObjClassName(="..objTable:getObjClassName()..") not the same as expected(="..objClassName1..")")
    local expectedNElements = 2
    assert(objTable:nObjs() == expectedNElements, " # elements(="..objTable:nObjs()..") not the same as expected(="..expectedNElements..")")
    local objClass = objTable:getObjClass()
    assert(Class.IsInstanceOf(objTable.testObj1, objClass), "obj 1 in objTable(="..textutils.serialise(objTable.testObj1, compact)..") not of type "..objClassName1)
    assert(Class.IsInstanceOf(objTable.testObj2, objClass), "obj 2 in objTable(="..textutils.serialise(objTable.testObj2, compact)..") not of type "..objClassName1)

    -- cleanup test
end

return T_ObjTable
