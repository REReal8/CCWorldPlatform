local T_ObjArray = {}

local corelog = require "corelog"

local IObj = require "iobj"
local ObjArray = require "obj_array"
local TestObj = require "test.obj_test"
local Location = require "obj_location"

function T_ObjArray.T_All()
    -- base methods
    T_ObjArray.T_ImplementsIObj()
    T_ObjArray.T_new()
    T_ObjArray.T_IsOfType()
    T_ObjArray.T_isSame()
    T_ObjArray.T_copy()

    -- specific methods
    T_ObjArray.T_transformObjTables()
    T_ObjArray.T_new_transformsObjTables()
end

local compact = { compact = true }

--    _                                     _   _               _
--   | |                                   | | | |             | |
--   | |__   __ _ ___  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   | '_ \ / _` / __|/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   | |_) | (_| \__ \  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_.__/ \__,_|___/\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

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

function T_ObjArray.T_ImplementsIObj()
    -- prepare test
    corelog.WriteToLog("* ObjArray IObj interface test")
    local obj = ObjArray:new() if not obj then corelog.Error("failed obtaining ObjArray") return end

    -- test
    local implementsInterface = IObj.ImplementsInterface(obj)
    assert(implementsInterface, "ObjArray class does not (fully) implement IObj interface")

    -- cleanup test
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
    assert(objArray[1]:isSame(testObj1), "obj 1 in objArray(="..textutils.serialise(objArray[1], compact)..") not the same as expected(="..textutils.serialise(testObj1, compact)..")")
    assert(objArray[2]:isSame(testObj2), "obj 2 in objArray(="..textutils.serialise(objArray[2], compact)..") not the same as expected(="..textutils.serialise(testObj2, compact)..")")

    -- test default
    objArray = ObjArray:new() if not objArray then return end
    local defaultName = ""
    assert(objArray:getObjClassName() == defaultName, "gotten getObjClassName(="..objArray:getObjClassName()..") not the same as expected(="..defaultName..")")
    expectedNElements = 0
    assert(table.getn(objArray) == expectedNElements, " # elements(="..table.getn(objArray)..") not the same as expected(="..expectedNElements..")")

    -- cleanup test
end

function T_ObjArray.T_IsOfType()
    -- prepare test
    corelog.WriteToLog("* ObjArray.IsOfType() tests")
    local objArray2 = ObjArray:new({
        _objClassName   = objClassName1,

        testObj1,
        testObj2,
    })

    -- test valid
    local isOfType = ObjArray.IsOfType(objArray2)
    local expectedIsOfType = true
    assert(isOfType == expectedIsOfType, "gotten IsOfType(="..tostring(isOfType)..") not the same as expected(="..tostring(expectedIsOfType)..")")

    -- test different object
    isOfType = ObjArray.IsOfType("a string")
    expectedIsOfType = false
    assert(isOfType == expectedIsOfType, "gotten IsOfType(="..tostring(isOfType)..") not the same as expected(="..tostring(expectedIsOfType)..")")

    -- test invalid className
    objArray2._objClassName = 1000
    isOfType = ObjArray.IsOfType(objArray2)
    expectedIsOfType = false
    assert(isOfType == expectedIsOfType, "gotten IsOfType(="..tostring(isOfType)..") not the same as expected(="..tostring(expectedIsOfType)..")")
    objArray2._objClassName = objClassName1

    -- test Obj's of wrong type
    objArray2[3] = wrongTestObj1
    isOfType = ObjArray.IsOfType(objArray2)
    expectedIsOfType = false
    assert(isOfType == expectedIsOfType, "gotten IsOfType(="..tostring(isOfType)..") not the same as expected(="..tostring(expectedIsOfType)..")")
    objArray2[3] = nil

    -- cleanup test
end

function T_ObjArray.T_isSame()
    -- prepare test
    corelog.WriteToLog("* ObjArray:isSame() tests")
    local objArray1 = ObjArray:new({
        _objClassName   = objClassName1,

        testObj1,
        testObj2,
    }) if not objArray1 then corelog.Warning("objArray1 unexpectedly nil") return end
    local objArray2 = ObjArray:new({
        _objClassName   = objClassName1,

        testObj1,
        testObj2,
    })

    -- test same
    local isSame = objArray1:isSame(objArray2)
    local expectedIsSame = true
    assert(isSame == expectedIsSame, "gotten isSame(="..tostring(isSame)..") not the same as expected(="..tostring(expectedIsSame)..")")

    -- test different className
    local objClassName2 = "ProductionSpot"
    objArray2._objClassName = objClassName2
    isSame = objArray1:isSame(objArray2)
    expectedIsSame = false
    assert(isSame == expectedIsSame, "gotten isSame(="..tostring(isSame)..") not the same as expected(="..tostring(expectedIsSame)..")")
    objArray2._objClassName = objClassName1

    -- test different # objects
    local testObj3 = testObj1:copy()
    objArray2[3] = testObj3
    isSame = objArray1:isSame(objArray2)
    expectedIsSame = false
    assert(isSame == expectedIsSame, "gotten isSame(="..tostring(isSame)..") not the same as expected(="..tostring(expectedIsSame)..")")
    objArray2[3] = nil

    -- cleanup test
end

function T_ObjArray.T_copy()
    -- prepare test
    corelog.WriteToLog("* ObjArray:copy() tests")
    local objArray1 = ObjArray:new({
        _objClassName   = objClassName1,

        testObj1,
        testObj2,
    }) if not objArray1 then corelog.Warning("objArray1 unexpectedly nil") return end

    -- test
    local copy = objArray1:copy()
    assert(copy:isSame(objArray1), "gotten copy(="..textutils.serialize(copy, compact)..") not the same as expected(="..textutils.serialize(objArray1, compact)..")")

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

function T_ObjArray.T_transformObjTables()
    -- prepare test
    corelog.WriteToLog("* ObjArray:transformObjTables() tests")
    local objArray2 = ObjArray:new({
        _objClassName   = objClassName1,
    }) if not objArray2 then corelog.Warning("objArray2 unexpectedly nil") return end
    local testObj1Table = {
        _field1 = "field1_1",
        _field2 = 1,
    }
    local testObj2Table = {
        _field1 = "field1_2",
        _field2 = 2,
    }
    assert(not TestObj.IsOfType(testObj1Table), "testObj1Table incorrectly of type "..objClassName1)
    assert(not TestObj.IsOfType(testObj2Table), "testObj2Table incorrectly of type "..objClassName1)

    -- test already only Obj's (nothing should change)
    objArray2[1] = testObj1
    objArray2[2] = testObj2
    objArray2:transformObjTables()
    local expectedNElements = 2
    assert(table.getn(objArray2) == expectedNElements, " # elements(="..table.getn(objArray2)..") not the same as expected(="..expectedNElements..")")
    assert(objArray2[1]:isSame(testObj1), "obj 1 in array(="..textutils.serialise(objArray2[1], compact)..") not the same as expected(="..textutils.serialise(testObj1, compact)..")")
    assert(objArray2[2]:isSame(testObj2), "obj 2 in array(="..textutils.serialise(objArray2[2], compact)..") not the same as expected(="..textutils.serialise(testObj2, compact)..")")
    objArray2[1] = nil
    objArray2[2] = nil

    -- test different class Obj skipped
    objArray2[1] = testObj1
    objArray2[2] = wrongTestObj1
    objArray2[3] = testObj2
    objArray2:transformObjTables(true)
    expectedNElements = 2
    assert(table.getn(objArray2) == expectedNElements, " # elements(="..table.getn(objArray2)..") not the same as expected(="..expectedNElements..")")
    assert(objArray2[1]:isSame(testObj1), "obj 1 in array(="..textutils.serialise(objArray2[1], compact)..") not the same as expected(="..textutils.serialise(testObj1, compact)..")")
    assert(objArray2[2]:isSame(testObj2), "obj 2 in array(="..textutils.serialise(objArray2[2], compact)..") not the same as expected(="..textutils.serialise(testObj2, compact)..")")
    objArray2[1] = nil
    objArray2[2] = nil
    objArray2[3] = nil

    -- test only ObjTables
    objArray2[1] = testObj1Table
    objArray2[2] = testObj2Table
    local isOfType = ObjArray.IsOfType(objArray2)
    local expectedIsOfType = false
    assert(isOfType == expectedIsOfType, "gotten IsOfType(="..tostring(isOfType)..") not the same as expected(="..tostring(expectedIsOfType)..")")
    objArray2:transformObjTables()
    isOfType = ObjArray.IsOfType(objArray2)
    expectedIsOfType = true
    assert(isOfType == expectedIsOfType, "gotten IsOfType(="..tostring(isOfType)..") not the same as expected(="..tostring(expectedIsOfType)..")")
    assert(objArray2[1]:isSame(testObj1), "obj 1 in array(="..textutils.serialise(objArray2[1], compact)..") not the same as expected(="..textutils.serialise(testObj1, compact)..")")
    assert(objArray2[2]:isSame(testObj2), "obj 2 in array(="..textutils.serialise(objArray2[2], compact)..") not the same as expected(="..textutils.serialise(testObj2, compact)..")")
    objArray2[1] = nil
    objArray2[2] = nil

    -- test mix ObjTables and Obj's
    testObj2Table = {
        _field1 = "field1_2",
        _field2 = 2,
    }
    assert(not TestObj.IsOfType(testObj2Table), "testObj2Table incorrectly of type "..objClassName1)
    objArray2[1] = testObj1
    objArray2[2] = testObj2Table
    isOfType = ObjArray.IsOfType(objArray2)
    expectedIsOfType = false
    assert(isOfType == expectedIsOfType, "gotten IsOfType(="..tostring(isOfType)..") not the same as expected(="..tostring(expectedIsOfType)..")")
    objArray2:transformObjTables()
    isOfType = ObjArray.IsOfType(objArray2)
    expectedIsOfType = true
    assert(isOfType == expectedIsOfType, "gotten IsOfType(="..tostring(isOfType)..") not the same as expected(="..tostring(expectedIsOfType)..")")
    assert(objArray2[1]:isSame(testObj1), "obj 1 in array(="..textutils.serialise(objArray2[1], compact)..") not the same as expected(="..textutils.serialise(testObj1, compact)..")")
    assert(objArray2[2]:isSame(testObj2), "obj 2 in array(="..textutils.serialise(objArray2[2], compact)..") not the same as expected(="..textutils.serialise(testObj2, compact)..")")
    objArray2[1] = nil
    objArray2[2] = nil

    -- cleanup test
end

function T_ObjArray.T_new_transformsObjTables()
    -- prepare test
    corelog.WriteToLog("* ObjArray:new() transforms objTables tests")
    local testObj1Table = {
        _field1 = "field1_1",
        _field2 = 1,
    }
    local testObj2Table = {
        _field1 = "field1_2",
        _field2 = 2,
    }

    -- test new transforms objTables
    local objArray = ObjArray:new({
        _objClassName   = objClassName1,

        testObj1Table,
        testObj2Table,
    })
    if not objArray then return end
    assert(objArray:getObjClassName() == objClassName1, "gotten getObjClassName(="..objArray:getObjClassName()..") not the same as expected(="..objClassName1..")")
    local expectedNElements = 2
    assert(table.getn(objArray) == expectedNElements, " # elements(="..table.getn(objArray)..") not the same as expected(="..expectedNElements..")")
    local objClass = objArray:getObjClass()
    assert(objClass.IsOfType(objArray[1]), "obj 1 in objArray(="..textutils.serialise(objArray[1], compact)..") not of type "..objClassName1)
    assert(objClass.IsOfType(objArray[2]), "obj 2 in objArray(="..textutils.serialise(objArray[1], compact)..") not of type "..objClassName1)

    -- cleanup test
end

return T_ObjArray
