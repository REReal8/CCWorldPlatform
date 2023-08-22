local T_ObjTable = {}

local corelog = require "corelog"

local IObj = require "i_obj"
local ObjBase = require "obj_base"
local ObjTable = require "obj_table"
local TestObj = require "test.obj_test"
local Location = require "obj_location"

local T_Class = require "test.t_object"
local T_IObj = require "test.t_i_obj"

function T_ObjTable.T_All()
    -- initialisation
    T_ObjTable.T_new()

    -- IObj methods
    T_ObjTable.T_IObj_All()

    -- specific methods
    T_ObjTable.T_transformObjectTables()
    T_ObjTable.T_new_transformsObjTables()
end

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

local objClassName1 = "TestObj"
local testObj1 = TestObj:new({
    _field1 = "field1_1",
    _field2 = 1,
})
local testObj2 = TestObj:new({
    _field1 = "field1_2",
    _field2 = 2,
})
local wrongTestObj1 = Location:new()

local testClassName = "ObjTable"
function T_ObjTable.CreateTestObj()
    local testObj = ObjTable:new({
        _objClassName   = objClassName1,

        testObj1Key     = testObj1:copy(),
        testObj2Key     = testObj2:copy(),
    })

    return testObj
end

function T_ObjTable.T_new()
    -- prepare test
    corelog.WriteToLog("* ObjTable:new() tests")

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

function T_ObjTable.T_transformObjectTables()
    -- prepare test
    corelog.WriteToLog("* ObjTable:transformObjectTables() tests")
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
    assert(not TestObj:isTypeOf(testObject1Table), "testObject1Table incorrectly of type "..objClassName1)
    assert(not TestObj:isTypeOf(testObject2Table), "testObject2Table incorrectly of type "..objClassName1)

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
    assert(not TestObj:isTypeOf(testObject2Table), "testObject2Table incorrectly of type "..objClassName1)
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
    corelog.WriteToLog("* ObjTable:new() transforms objTables tests")
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

        testObject1Table,
        testObject2Table,
    })
    if not objTable then return end
    assert(objTable:getObjClassName() == objClassName1, "gotten getObjClassName(="..objTable:getObjClassName()..") not the same as expected(="..objClassName1..")")
    local expectedNElements = 2
    assert(table.getn(objTable) == expectedNElements, " # elements(="..table.getn(objTable)..") not the same as expected(="..expectedNElements..")")
    local objClass = objTable:getObjClass()
    assert(objClass:isTypeOf(objTable[1]), "obj 1 in objTable(="..textutils.serialise(objTable[1], compact)..") not of type "..objClassName1)
    assert(objClass:isTypeOf(objTable[2]), "obj 2 in objTable(="..textutils.serialise(objTable[1], compact)..") not of type "..objClassName1)

    -- cleanup test
end

return T_ObjTable
