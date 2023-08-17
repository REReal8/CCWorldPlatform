local T_ObjArray = {}

local corelog = require "corelog"

local IObj = require "i_obj"
local ObjBase = require "obj_base"
local ObjArray = require "obj_array"
local TestObj = require "test.obj_test"
local Location = require "obj_location"

local T_Object = require "test.t_object"
local T_IObj = require "test.t_i_obj"

function T_ObjArray.T_All()
    -- initialisation
    T_ObjArray.T_new()

    -- IObj methods
    T_ObjArray.T_IObj_All()

    -- specific methods
    T_ObjArray.T_transformObjectTables()
    T_ObjArray.T_new_transformsObjTables()
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

local testClassName = "ObjArray"
local function createTestObj()
    local testObj = ObjArray:new({
        _objClassName   = objClassName1,

        testObj1:copy(),
        testObj2:copy(),
    })

    return testObj
end

function T_ObjArray.T_new()
    -- prepare test
    corelog.WriteToLog("* ObjArray:new() tests")

    -- test full
    local objArray = ObjArray:new({
        _objClassName   = objClassName1,

        testObj1,
        testObj2,
    }) if not objArray then corelog.Warning("objArray unexpectedly nil") return end
    assert(objArray:getObjClassName() == objClassName1, "gotten getObjClassName(="..objArray:getObjClassName()..") not the same as expected(="..objClassName1..")")
    local expectedNElements = 2
    assert(table.getn(objArray) == expectedNElements, " # elements(="..table.getn(objArray)..") not the same as expected(="..expectedNElements..")")
    assert(objArray[1]:isEqual(testObj1), "obj 1 in objArray(="..textutils.serialise(objArray[1], compact)..") not the same as expected(="..textutils.serialise(testObj1, compact)..")")
    assert(objArray[2]:isEqual(testObj2), "obj 2 in objArray(="..textutils.serialise(objArray[2], compact)..") not the same as expected(="..textutils.serialise(testObj2, compact)..")")

    -- test default
    objArray = ObjArray:new() if not objArray then return end
    local defaultName = ""
    assert(objArray:getObjClassName() == defaultName, "gotten getObjClassName(="..objArray:getObjClassName()..") not the same as expected(="..defaultName..")")
    expectedNElements = 0
    assert(table.getn(objArray) == expectedNElements, " # elements(="..table.getn(objArray)..") not the same as expected(="..expectedNElements..")")

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
    local obj = createTestObj() assert(obj, "Failed obtaining "..testClassName)
    local otherObj = createTestObj() assert(obj, "Failed obtaining "..testClassName) assert(otherObj, "Failed obtaining "..testClassName)

    -- test
    T_Object.pt_IsInstanceOf(testClassName, obj, "IObj", IObj)
    T_Object.pt_IsInstanceOf(testClassName, obj, "ObjBase", ObjBase)
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
    assert(not TestObj:isTypeOf(testObject1Table), "testObject1Table incorrectly of type "..objClassName1)
    assert(not TestObj:isTypeOf(testObject2Table), "testObject2Table incorrectly of type "..objClassName1)

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
    assert(not TestObj:isTypeOf(testObject2Table), "testObject2Table incorrectly of type "..objClassName1)
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
    local objArray = ObjArray:new({
        _objClassName   = objClassName1,

        testObject1Table,
        testObject2Table,
    })
    if not objArray then return end
    assert(objArray:getObjClassName() == objClassName1, "gotten getObjClassName(="..objArray:getObjClassName()..") not the same as expected(="..objClassName1..")")
    local expectedNElements = 2
    assert(table.getn(objArray) == expectedNElements, " # elements(="..table.getn(objArray)..") not the same as expected(="..expectedNElements..")")
    local objClass = objArray:getObjClass()
    assert(objClass:isTypeOf(objArray[1]), "obj 1 in objArray(="..textutils.serialise(objArray[1], compact)..") not of type "..objClassName1)
    assert(objClass:isTypeOf(objArray[2]), "obj 2 in objArray(="..textutils.serialise(objArray[1], compact)..") not of type "..objClassName1)

    -- cleanup test
end

return T_ObjArray
