local T_Inventory = {}

local corelog = require "corelog"

local IObj = require "i_obj"
local ObjBase = require "obj_base"
local Inventory = require "obj_inventory"

local T_Class = require "test.t_object"
local T_IObj = require "test.t_i_obj"

function T_Inventory.T_All()
    -- helper functions
    T_Inventory.T_IsItemTable()
    T_Inventory.T_IsEqualItemTable()
    T_Inventory.T_ItemTableCopy()

    T_Inventory.T_IsSlotTable()
    T_Inventory.T_IsEqualSlotTable()
    T_Inventory.T_SlotTableCopy()

    -- initialisation methods
    T_Inventory.T_new()

    -- IObj methods
    T_Inventory.T_IObj_All()

    -- specific methods
    T_Inventory.T_isEmpty()
    T_Inventory.T_hasNoItems()
    T_Inventory.T_getItemTable()
    T_Inventory.T_hasItems()
    T_Inventory.T_substract()
end

local saplingItemName = "minecraft:birch_sapling"
local saplingCount1 = 10
local saplingCount2 = 10
local furnaceItemName = "minecraft:furnace"
local furnaceCount1 = 1
local chestItemName = "minecraft:chest"
local chestCount1 = 5
local itemTable1 = {
    [saplingItemName] = saplingCount1,
    [chestItemName] = chestCount1,
}
local itemTable2 = {
    [saplingItemName] = saplingCount2,
    [furnaceItemName] = furnaceCount1,
}

local compact = { compact = true }

--    _          _                    __                  _   _
--   | |        | |                  / _|                | | (_)
--   | |__   ___| |_ __   ___ _ __  | |_ _   _ _ __   ___| |_ _  ___  _ __  ___
--   | '_ \ / _ \ | '_ \ / _ \ '__| |  _| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
--   | | | |  __/ | |_) |  __/ |    | | | |_| | | | | (__| |_| | (_) | | | \__ \
--   |_| |_|\___|_| .__/ \___|_|    |_|  \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
--                | |
--                |_|

function T_Inventory.T_IsItemTable()
    -- prepare test
    corelog.WriteToLog("* Inventory.IsItemTable() tests")

    -- test valid
    local isItemTable = Inventory.IsItemTable( itemTable1 )
    local expectedIsItemTable = true
    assert(isItemTable == expectedIsItemTable, "gotten IsItemTable(="..tostring(isItemTable)..") not the same as expected(="..tostring(expectedIsItemTable)..")")

    -- test with wrong name type
    itemTable1[20] = 50
    isItemTable = Inventory.IsItemTable( itemTable1 )
    expectedIsItemTable = false
    assert(isItemTable == expectedIsItemTable, "gotten IsItemTable(="..tostring(isItemTable)..") not the same as expected(="..tostring(expectedIsItemTable)..")")
    itemTable1[20] = nil

    -- test with wrong count type
    itemTable1.something = "a string"
    isItemTable = Inventory.IsItemTable( itemTable1 )
    expectedIsItemTable = false
    assert(isItemTable == expectedIsItemTable, "gotten IsItemTable(="..tostring(isItemTable)..") not the same as expected(="..tostring(expectedIsItemTable)..")")
    itemTable1.something = nil

    -- cleanup test
end

function T_Inventory.T_IsEqualItemTable()
    -- prepare test
    corelog.WriteToLog("* Inventory.IsEqualItemTable() tests")

    -- test same
    local isEqualItemTable = Inventory.IsEqualItemTable(itemTable1, itemTable1)
    local expectedIsEqualItemTable = true
    assert(isEqualItemTable == expectedIsEqualItemTable, "gotten IsEqualItemTable(="..tostring(isEqualItemTable)..") not the same as expected(="..tostring(expectedIsEqualItemTable)..")")

    -- test with 2 empty lists
    isEqualItemTable = Inventory.IsEqualItemTable(
        { },
        { }
    )
    expectedIsEqualItemTable = true
    assert(isEqualItemTable == expectedIsEqualItemTable, "gotten IsEqualItemTable(="..tostring(isEqualItemTable)..") not the same as expected(="..tostring(expectedIsEqualItemTable)..")")

    -- test with different items
    isEqualItemTable = Inventory.IsEqualItemTable(itemTable1, itemTable2)
    expectedIsEqualItemTable = false
    assert(isEqualItemTable == expectedIsEqualItemTable, "gotten IsEqualItemTable(="..tostring(isEqualItemTable)..") not the same as expected(="..tostring(expectedIsEqualItemTable)..")")

    -- cleanup test
end

function T_Inventory.T_ItemTableCopy()
    -- prepare test
    corelog.WriteToLog("* Inventory.ItemTableCopy() tests")

    -- test
    local copy = Inventory.ItemTableCopy(itemTable1)
    local expectedCopy = itemTable1
    assert(Inventory.IsEqualItemTable(copy, expectedCopy), "gotten ItemTableCopy(="..textutils.serialize(copy, compact)..") not the same as expected(="..textutils.serialize(expectedCopy, compact)..")")

    -- cleanup test
end

local slotTable1 = {
    { name = saplingItemName, count = saplingCount1 },
    { name = chestItemName, count = chestCount1 },
}

local slotTable2 = {
    { name = saplingItemName, count = saplingCount2 },
    { name = furnaceItemName, count = furnaceCount1 },
}

function T_Inventory.T_IsSlotTable()
    -- prepare test
    corelog.WriteToLog("* Inventory.IsSlotTable() tests")

    -- test valid
    local isSlotTable = Inventory.IsSlotTable( slotTable1 )
    local expectedIsSlotTable = true
    assert(isSlotTable == expectedIsSlotTable, "gotten IsSlotTable(="..tostring(isSlotTable)..") not the same as expected(="..tostring(expectedIsSlotTable)..")")

    -- test with wrong slotItem name type
    slotTable1[1] = { name = 40, count = saplingCount1 }
    isSlotTable = Inventory.IsSlotTable( slotTable1 )
    expectedIsSlotTable = false
    assert(isSlotTable == expectedIsSlotTable, "gotten IsSlotTable(="..tostring(isSlotTable)..") not the same as expected(="..tostring(expectedIsSlotTable)..")")
    slotTable1[1] = { name = saplingItemName, count = saplingCount1 }

    -- test with wrong slotItem count type
    slotTable1[1] = { name = saplingItemName, count =  "a string" }
    isSlotTable = Inventory.IsSlotTable( slotTable1 )
    expectedIsSlotTable = false
    assert(isSlotTable == expectedIsSlotTable, "gotten IsSlotTable(="..tostring(isSlotTable)..") not the same as expected(="..tostring(expectedIsSlotTable)..")")
    slotTable1[1] = { name = saplingItemName, count = saplingCount1 }

    -- cleanup test
end

function T_Inventory.T_IsEqualSlotTable()
    -- prepare test
    corelog.WriteToLog("* Inventory.IsEqualSlotTable() tests")

    -- test same
    local isEqualSlotTable = Inventory.IsEqualSlotTable(slotTable1, slotTable1)
    local expectedIsEqualSlotTable = true
    assert(isEqualSlotTable == expectedIsEqualSlotTable, "gotten IsEqualSlotTable(="..tostring(isEqualSlotTable)..") not the same as expected(="..tostring(expectedIsEqualSlotTable)..")")

    -- test with 2 empty lists
    isEqualSlotTable = Inventory.IsEqualSlotTable(
        { },
        { }
    )
    expectedIsEqualSlotTable = true
    assert(isEqualSlotTable == expectedIsEqualSlotTable, "gotten IsEqualSlotTable(="..tostring(isEqualSlotTable)..") not the same as expected(="..tostring(expectedIsEqualSlotTable)..")")

    -- test with different items
    isEqualSlotTable = Inventory.IsEqualSlotTable(slotTable1, slotTable2)
    expectedIsEqualSlotTable = false
    assert(isEqualSlotTable == expectedIsEqualSlotTable, "gotten IsEqualSlotTable(="..tostring(isEqualSlotTable)..") not the same as expected(="..tostring(expectedIsEqualSlotTable)..")")

    -- cleanup test
end

function T_Inventory.T_SlotTableCopy()
    -- prepare test
    corelog.WriteToLog("* Inventory.SlotTableCopy() tests")

    -- test
    local copy = Inventory.SlotTableCopy(slotTable1)
    local expectedCopy = slotTable1
    assert(Inventory.IsEqualSlotTable(copy, expectedCopy), "gotten SlotTableCopy(="..textutils.serialize(copy, compact)..") not the same as expected(="..textutils.serialize(expectedCopy, compact)..")")

    -- cleanup test
end

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

local testClassName = "Inventory"
function T_Inventory.CreateTestObj()
    local testObj = Inventory:new({
        _slotTable  = Inventory.SlotTableCopy(slotTable1),
    })

    return testObj
end

function T_Inventory.T_new()
    -- prepare test
    corelog.WriteToLog("* Inventory:new() tests")

    -- test full
    local inventory = Inventory:new({
        _slotTable  = Inventory.SlotTableCopy(slotTable1),
    })
    assert(Inventory.IsEqualSlotTable(inventory:getSlotTable(), slotTable1), "gotten getSlotTable(="..textutils.serialize(inventory:getSlotTable(), compact)..") not the same as expected(="..textutils.serialize(slotTable1)..")")

    -- test default
    inventory = Inventory:new()
    assert(Inventory.IsEqualSlotTable(inventory:getSlotTable(), {}), "gotten getSlotTable(="..textutils.serialize(inventory:getSlotTable(), compact)..") not the same as expected(="..textutils.serialize({})..")")

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

function T_Inventory.T_IObj_All()
    -- prepare test
    local obj = T_Inventory.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_Inventory.CreateTestObj() assert(otherObj, "Failed obtaining "..testClassName)

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

function T_Inventory.T_isEmpty()
    -- prepare test
    corelog.WriteToLog("* Inventory:isEmpty() tests")

    -- test not empty
    local inventory = Inventory:new({
    })
    local isEmpty = inventory:isEmpty()
    local expectedIsEmpty = true
    assert(isEmpty == expectedIsEmpty, "gotten isEmpty(="..tostring(isEmpty)..") not the same as expected(="..tostring(expectedIsEmpty)..")")

    -- test not empty
    inventory = Inventory:new({
        _slotTable  = slotTable1,
    })
    isEmpty = inventory:isEmpty()
    expectedIsEmpty = false
    assert(isEmpty == expectedIsEmpty, "gotten isEmpty(="..tostring(isEmpty)..") not the same as expected(="..tostring(expectedIsEmpty)..")")

    -- cleanup test
end

function T_Inventory.T_hasNoItems()
    -- prepare test
    corelog.WriteToLog("* Inventory:hasNoItems() tests")
    local negSlotTable1 = {
        { name = saplingItemName, count = saplingCount1 },
        { name = saplingItemName, count = -saplingCount1 },
    }
    local negSlotTable2 = {
        { name = saplingItemName, count = saplingCount1 },
        { name = saplingItemName, count = -saplingCount1 },
        { name = chestItemName, count = chestCount1 },
    }

    -- test empty
    local inventory = Inventory:new({
    })
    local hasNoItems = inventory:hasNoItems()
    local expectedHasNoItems = true
    assert(hasNoItems == expectedHasNoItems, "gotten hasNoItems(="..tostring(hasNoItems)..") not the same as expected(="..tostring(expectedHasNoItems)..")")

    -- test not empty
    inventory = Inventory:new({
        _slotTable  = Inventory.SlotTableCopy(slotTable1),
    })
    hasNoItems = inventory:hasNoItems()
    expectedHasNoItems = false
    assert(hasNoItems == expectedHasNoItems, "gotten hasNoItems(="..tostring(hasNoItems)..") not the same as expected(="..tostring(expectedHasNoItems)..")")

    -- test negative values in slot (net result = 0)
    inventory = Inventory:new({
        _slotTable  = negSlotTable1,
    })
    hasNoItems = inventory:hasNoItems()
    expectedHasNoItems = true
    assert(hasNoItems == expectedHasNoItems, "gotten hasNoItems(="..tostring(hasNoItems)..") not the same as expected(="..tostring(expectedHasNoItems)..")")

    -- test negative values in slot (net result ~= 0)
    inventory = Inventory:new({
        _slotTable  = negSlotTable2,
    })
    hasNoItems = inventory:hasNoItems()
    expectedHasNoItems = false
    assert(hasNoItems == expectedHasNoItems, "gotten hasNoItems(="..tostring(hasNoItems)..") not the same as expected(="..tostring(expectedHasNoItems)..")")

    -- cleanup test
end

function T_Inventory.T_getItemTable()
    -- prepare test
    corelog.WriteToLog("* Inventory:getItemTable() tests")

    -- test
    local inventory = Inventory:new({
        _slotTable  = Inventory.SlotTableCopy(slotTable1),
    })
    local itemTable = inventory:getItemTable()
    local isEqual = Inventory.IsEqualItemTable(itemTable, itemTable1)
    local expectedIsEqual = true
    assert(isEqual == expectedIsEqual, "gotten isEqual(="..tostring(isEqual)..") not the same as expected(="..tostring(expectedIsEqual)..")")

    -- cleanup test
end

function T_Inventory.T_hasItems()
    -- prepare test
    corelog.WriteToLog("* Inventory:hasItems() tests")
    local inventory = Inventory:new({
        _slotTable = {
            { name = "minecraft:dirt", count = 20 },
            { name = "minecraft:birch_log", count = 1 },
            { name = "minecraft:birch_sapling", count = 5 },
        }
    })

    -- test
    local itemName = "minecraft:dirt"
    local itemCount = 10
    local hasItems = inventory:hasItems( { [itemName] = itemCount} )
    assert(hasItems, "hasItems incorrectly failed for "..itemCount.." "..itemName.."'s")

    itemName = "minecraft:birch_sapling"
    itemCount = 2
    hasItems = inventory:hasItems({ [itemName] = itemCount} )
    assert(hasItems, "hasItems incorrectly failed for "..itemCount.." "..itemName.."'s")

    itemName = "minecraft:birch_log"
    itemCount = 10
    hasItems = inventory:hasItems({ [itemName] = itemCount} )
    assert(not hasItems, "hasItems incorrectly success for "..itemCount.." "..itemName.."'s")

    itemName = "minecraft:furnace"
    itemCount = 1
    hasItems = inventory:hasItems({ [itemName] = itemCount} )
    assert(not hasItems, "hasItems incorrectly success for "..itemCount.." "..itemName.."'s")

    -- cleanup test
end

function T_Inventory.T_substract()
    -- prepare test
    corelog.WriteToLog("* Inventory:substract() tests")
    local inv1 = Inventory:new({
        _slotTable = {
            { name = "minecraft:dirt", count = 20 },
            { name = "minecraft:birch_log", count = 1 },
            { name = "minecraft:birch_sapling", count = 5 },
        }
    })
    local inv2 = Inventory:new({
        _slotTable = {
            { name = "minecraft:dirt", count = 20 },
            { name = "minecraft:birch_log", count = 1 },
            [ 4 ] = { name = "minecraft:birch_sapling", count = 5 },
        }
    })
    local inv3 = Inventory:new({
        _slotTable = {
            { name = "minecraft:dirt", count = 15 },
            { name = "minecraft:birch_log", count = 1 },
            { name = "minecraft:birch_sapling", count = 3 },
        }
    })

    -- test on itself returns noItems
    local calculatedInventory = inv1:substract(inv1)
    assert(calculatedInventory:hasNoItems(), "calculatedInventory(="..textutils.serialize(calculatedInventory, compact)..") is not empty ")

    -- test different slot returns noItems
    calculatedInventory = inv1:substract(inv2)
    assert(calculatedInventory._slotTable[3].count == 5 , "calculatedInventory(="..textutils.serialize(calculatedInventory, compact)..") incorrect ")
    assert(calculatedInventory._slotTable[-4].count == -5 , "calculatedInventory(="..textutils.serialize(calculatedInventory, compact)..") incorrect ")
    assert(calculatedInventory:hasNoItems(), "calculatedInventory(="..textutils.serialize(calculatedInventory, compact)..") is not empty ")

    -- test has most items
    calculatedInventory = inv1:substract(inv3)
    assert(calculatedInventory._itemTable["minecraft:dirt"] == 5 , "calculatedInventory(="..textutils.serialize(calculatedInventory, compact)..") incorrect ")
    assert(calculatedInventory._itemTable["minecraft:birch_log"] == nil , "calculatedInventory(="..textutils.serialize(calculatedInventory, compact)..") incorrect ")
    assert(calculatedInventory._itemTable["minecraft:birch_sapling"] == 2 , "calculatedInventory(="..textutils.serialize(calculatedInventory, compact)..") incorrect ")
    assert(not calculatedInventory:hasNoItems(), "calculatedInventory(="..textutils.serialize(calculatedInventory, compact)..") is not empty ")

    -- cleanup test
end

return T_Inventory
