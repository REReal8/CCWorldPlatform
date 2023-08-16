local T_ItemTable = {}

local corelog = require "corelog"

local IObj = require "i_obj"
local ObjBase = require "obj_base"
local ItemTable = require "obj_item_table"

local T_Object = require "test.t_object"
local T_IObj = require "test.t_i_obj"

function T_ItemTable.T_All()
    -- IObj methods
    T_ItemTable.T_IObj_All()

    -- specific methods
    T_ItemTable.T_isEmpty()
    T_ItemTable.T_hasNoItems()
    T_ItemTable.T_combine()
    T_ItemTable.T_compare()
end

local testTable1    = ItemTable:new({
    ["minecraft:coal"]      = 5,
    ["minecraft:torch"]     = 11,
})
local testTable2    = ItemTable:new({
    ["minecraft:coal"]      = 15,
    ["minecraft:furnace"]   = 27,
})
local testTable3    = ItemTable:new({
    ["minecraft:coal"]      = 0,
})

local testTable4    = ItemTable:new({
})
local testTable5    = ItemTable:new({
    ["minecraft:birch_log"]  = 3,
})

local functionResult = nil
local expectedResult = nil

--    _          _                    __                  _   _
--   | |        | |                  / _|                | | (_)
--   | |__   ___| |_ __   ___ _ __  | |_ _   _ _ __   ___| |_ _  ___  _ __  ___
--   | '_ \ / _ \ | '_ \ / _ \ '__| |  _| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
--   | | | |  __/ | |_) |  __/ |    | | | |_| | | | | (__| |_| | (_) | | | \__ \
--   |_| |_|\___|_| .__/ \___|_|    |_|  \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
--                | |
--                |_|

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

local testClassName = "ItemTable"
local function createTestObj()
    local testObj = ItemTable:new({
        ["minecraft:coal"]      = 5,
        ["minecraft:torch"]     = 11,
    })

    return testObj
end

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

function T_ItemTable.T_IObj_All()
    -- prepare test
    local obj = createTestObj() assert(obj, "failed obtaining "..testClassName)
    local otherObj = createTestObj() assert(obj, "failed obtaining "..testClassName) assert(otherObj, "failed obtaining "..testClassName)

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

function T_ItemTable.T_isEmpty()
    -- prepare test
    corelog.WriteToLog("* ItemTable:isEmpty() tests")

    -- test same
    functionResult = testTable1:isEmpty()
    expectedResult = false
    assert(functionResult == expectedResult, "gotten IsEqualItemTable(="..tostring(functionResult)..") not the same as expected(="..tostring(expectedResult)..")")

    functionResult = testTable2:isEmpty()
    expectedResult = false
    assert(functionResult == expectedResult, "gotten IsEqualItemTable(="..tostring(functionResult)..") not the same as expected(="..tostring(expectedResult)..")")

    functionResult = testTable3:isEmpty()
    expectedResult = false
    assert(functionResult == expectedResult, "gotten IsEqualItemTable(="..tostring(functionResult)..") not the same as expected(="..tostring(expectedResult)..")")

    functionResult = testTable4:isEmpty()
    expectedResult = true
    assert(functionResult == expectedResult, "gotten IsEqualItemTable(="..tostring(functionResult)..") not the same as expected(="..tostring(expectedResult)..")")
end

function T_ItemTable.T_hasNoItems()
    -- prepare test
    corelog.WriteToLog("* ItemTable:hasNoItems() tests")

    -- test same
    functionResult = testTable1:hasNoItems()
    expectedResult = false
    assert(functionResult == expectedResult, "gotten IsEqualItemTable(="..tostring(functionResult)..") not the same as expected(="..tostring(expectedResult)..")")

    functionResult = testTable2:hasNoItems()
    expectedResult = false
    assert(functionResult == expectedResult, "gotten IsEqualItemTable(="..tostring(functionResult)..") not the same as expected(="..tostring(expectedResult)..")")

    functionResult = testTable3:hasNoItems()
    expectedResult = true
    assert(functionResult == expectedResult, "gotten IsEqualItemTable(="..tostring(functionResult)..") not the same as expected(="..tostring(expectedResult)..")")

    functionResult = testTable4:hasNoItems()
    expectedResult = true
    assert(functionResult == expectedResult, "gotten IsEqualItemTable(="..tostring(functionResult)..") not the same as expected(="..tostring(expectedResult)..")")
end

function T_ItemTable.T_combine()
    -- prepare test
    corelog.WriteToLog("* ItemTable:combine() tests")

    -- testing
    local testTable = ItemTable.combine(testTable1, testTable3) assert(testTable, "failed combining tables")
    functionResult = testTable:isEqual(testTable1)
    expectedResult = true
    assert(functionResult == expectedResult, "gotten IsEqualItemTable(="..tostring(functionResult)..") not the same as expected(="..tostring(expectedResult)..")")

    testTable = ItemTable.combine(testTable1, testTable4) assert(testTable, "failed combining tables")
    functionResult = testTable:isEqual(testTable1)
    expectedResult = true
    assert(functionResult == expectedResult, "gotten IsEqualItemTable(="..tostring(functionResult)..") not the same as expected(="..tostring(expectedResult)..")")

    testTable = ItemTable.combine(testTable1, testTable2) assert(testTable, "failed combining tables")
    functionResult = testTable:isEqual(ItemTable:new({["minecraft:coal"] = 20, ["minecraft:torch"] = 11, ["minecraft:furnace"] = 27}))
    expectedResult = true
    assert(functionResult == expectedResult, "gotten IsEqualItemTable(="..tostring(functionResult)..") not the same as expected(="..tostring(expectedResult)..")")
end

function T_ItemTable.T_compare()
    -- prepare test
    corelog.WriteToLog("* ItemTable:compare() tests")

    -- compare with itself
    local t1, t2, t3 = ItemTable.compare(testTable2, testTable2) assert(t1 and t2 and t3, "failed comparing")

    functionResult = t1:isEmpty()
    expectedResult = true
    assert(functionResult == expectedResult, "gotten IsEqualItemTable(="..tostring(functionResult)..") not the same as expected(="..tostring(expectedResult)..")")
    functionResult = t2:isEqual(testTable2)
    expectedResult = true
    assert(functionResult == expectedResult, "gotten IsEqualItemTable(="..tostring(functionResult)..") not the same as expected(="..tostring(expectedResult)..")")
    functionResult = t3:isEmpty()
    expectedResult = true
    assert(functionResult == expectedResult, "gotten IsEqualItemTable(="..tostring(functionResult)..") not the same as expected(="..tostring(expectedResult)..")")

    -- compare filled with empty table
    t1, t2, t3 = ItemTable.compare(testTable1, testTable4) assert(t1 and t2 and t3, "failed comparing")

    functionResult = t1:isEqual(testTable1)
    expectedResult = true
    assert(functionResult == expectedResult, "gotten IsEqualItemTable(="..tostring(functionResult)..") not the same as expected(="..tostring(expectedResult)..")")
    functionResult = t2:isEmpty()
    expectedResult = true
    assert(functionResult == expectedResult, "gotten IsEqualItemTable(="..tostring(functionResult)..") not the same as expected(="..tostring(expectedResult)..")")
    functionResult = t3:isEmpty()
    expectedResult = true
    assert(functionResult == expectedResult, "gotten IsEqualItemTable(="..tostring(functionResult)..") not the same as expected(="..tostring(expectedResult)..")")

    -- compare two filled tables
    t1, t2, t3 = ItemTable.compare(testTable1, testTable2) assert(t1 and t2 and t3, "failed comparing")

    functionResult = t1:isEqual(ItemTable:new({["minecraft:torch"] = 11}))
    expectedResult = true
    assert(functionResult == expectedResult, "gotten IsEqualItemTable(="..tostring(functionResult)..") not the same as expected(="..tostring(expectedResult)..")")
    functionResult = t2:isEqual(ItemTable:new({["minecraft:coal"] = 5}))
    expectedResult = true
    assert(functionResult == expectedResult, "gotten IsEqualItemTable(="..tostring(functionResult)..") not the same as expected(="..tostring(expectedResult)..")")
    functionResult = t3:isEqual(ItemTable:new({["minecraft:coal"] = 10, ["minecraft:furnace"] = 27}))
    expectedResult = true
    assert(functionResult == expectedResult, "gotten IsEqualItemTable(="..tostring(functionResult)..") not the same as expected(="..tostring(expectedResult)..")")
end

return T_ItemTable