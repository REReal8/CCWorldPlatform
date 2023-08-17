local T_Block = {}
local corelog = require "corelog"
local coreutils = require "coreutils"

local InputChecker = require "input_checker"

local IObj = require "i_obj"
local ObjBase = require "obj_base"
local Block = require "obj_block"

local T_Object = require "test.t_object"
local T_IObj = require "test.t_i_obj"

function T_Block.T_All()
    -- initialisation
    T_Block.T_new()

    -- IObj methods
    T_Block.T_IObj_All()

    -- specific methods
    T_Block.T_isMinecraftItem()
    T_Block.T_isAnyBlock()
    T_Block.T_isNoneBlock()
    T_Block.T_isComputercraftItem()
    T_Block.T_hasValidDirection()
    T_Block.T_ParseWithCheckInput() -- ToDo: consider removing

    -- helper functions
    T_Block.T_IsBlockList()
    T_Block.T_IsEqualBlockList()
    T_Block.T_BlockListCopy()
    T_Block.T_BlockListTransform()
end

local dx1 = 0
local dx2 = -1
local dy1 = 1
local dy2 = 0
local saplingItemName = "minecraft:birch_sapling"
local furnaceItemName = "minecraft:furnace"
local chestItemName = "minecraft:chest"
local computerItemName = "computercraft:computer_normal"

local block1 = Block:new({
    _dx     = dx1,
    _dy     = dy1,
    _name   = saplingItemName,
})

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

local testClassName = "Block"
function T_Block.CreateTestObj()
    local testObj = Block:new({
        _dx     = dx1,
        _dy     = dy1,

        _name   = saplingItemName,
    })

    return testObj
end

function T_Block.T_new()
    -- prepare test
    corelog.WriteToLog("* Block:new() tests")

    -- test full
    local block = Block:new({
        _dx     = dx1,
        _dy     = dy1,

        _name   = saplingItemName,
    })
    assert(block:getDx() == dx1, "gotten getDx(="..block:getDx()..") not the same as expected(="..dx1..")")
    assert(block:getDy() == dy1, "gotten getDy(="..block:getDy()..") not the same as expected(="..dy1..")")
    assert(block:getName() == saplingItemName, "gotten getName(="..block:getName()..") not the same as expected(="..saplingItemName..")")

    -- test without orientations (i.e dx, dy)
    block = Block:new({
        _name   = saplingItemName,
    })
    assert(block:getDx() == 0, "gotten getDx(="..(block:getDx() or 0)..") not the same as expected(=0)")
    assert(block:getDy() == 0, "gotten getDy(="..(block:getDy() or 0)..") not the same as expected(=0)")
    assert(block:getName() == saplingItemName, "gotten getName(="..block:getName()..") not the same as expected(="..saplingItemName..")")

    -- test default
    block = Block:new()
    assert(block:getDx() == 0, "gotten getDx(="..(block:getDx() or 0)..") not the same as expected(=0)")
    assert(block:getDy() == 0, "gotten getDy(="..(block:getDy() or 0)..") not the same as expected(=0)")
    local dedaultName = ""
    assert(block:getName() == dedaultName, "gotten getName(="..block:getName()..") not the same as expected(="..dedaultName..")")

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

function T_Block.T_IObj_All()
    -- prepare test
    local obj = T_Block.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_Block.CreateTestObj() assert(otherObj, "Failed obtaining "..testClassName)

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

function T_Block.T_isMinecraftItem()
    -- prepare test
    corelog.WriteToLog("* Block:isMinecraftItem() tests")
    local blockName = saplingItemName
    local block2 = Block:new({
        _dx     = dx1,
        _dy     = dy1,

        _name   = blockName,
    })

    -- test minecraft item
    local isMinecraftItem = block2:isMinecraftItem()
    assert(isMinecraftItem, "gotten isMinecraftItem(="..tostring(isMinecraftItem)..") for "..blockName.." not the same as expected(true)")

    -- test blockNameAny
    blockName = Block.AnyBlockName()
    block2:setName(blockName)
    isMinecraftItem = block2:isMinecraftItem()
    assert(not isMinecraftItem, "gotten isMinecraftItem(="..tostring(isMinecraftItem)..") for "..blockName.." not the same as expected(false)")

    -- test blockNameNone
    blockName = Block.NoneBlockName()
    block2:setName(blockName)
    isMinecraftItem = block2:isMinecraftItem()
    assert(not isMinecraftItem, "gotten isMinecraftItem(="..tostring(isMinecraftItem)..") for "..blockName.." not the same as expected(false)")

    -- cleanup test
end

function T_Block.T_isAnyBlock()
    -- prepare test
    corelog.WriteToLog("* Block:isAnyBlock() tests")
    local blockName = Block.AnyBlockName()
    local block2 = Block:new({
        _dx     = dx1,
        _dy     = dy1,

        _name   = blockName,
    })

    -- test any block
    local isAnyBlock = block2:isAnyBlock()
    assert(isAnyBlock, "gotten isAnyBlock(="..tostring(isAnyBlock)..") for "..blockName.." not the same as expected(true)")

    -- test not any block
    blockName = saplingItemName
    block2:setName(blockName)
    isAnyBlock = block2:isAnyBlock()
    assert(not isAnyBlock, "gotten isAnyBlock(="..tostring(isAnyBlock)..") for "..blockName.." not the same as expected(false)")

    -- cleanup test
end

function T_Block.T_isNoneBlock()
    -- prepare test
    corelog.WriteToLog("* Block:isNoneBlock() tests")
    local blockName = Block.NoneBlockName()
    local block2 = Block:new({
        _dx     = dx1,
        _dy     = dy1,

        _name   = blockName,
    })

    -- test any block
    local isNoneBlock = block2:isNoneBlock()
    assert(isNoneBlock, "gotten isNoneBlock(="..tostring(isNoneBlock)..") for "..blockName.." not the same as expected(true)")

    -- test not any block
    blockName = saplingItemName
    block2:setName(blockName)
    isNoneBlock = block2:isNoneBlock()
    assert(not isNoneBlock, "gotten isNoneBlock(="..tostring(isNoneBlock)..") for "..blockName.." not the same as expected(false)")

    -- cleanup test
end

function T_Block.T_isComputercraftItem()
    -- prepare test
    corelog.WriteToLog("* Block:isComputercraftItem() tests")
    local blockName = computerItemName
    local block2 = Block:new({
        _dx     = dx1,
        _dy     = dy1,

        _name   = blockName,
    })

    -- test computercraft item
    local isComputercraftItem = block2:isComputercraftItem()
    assert(isComputercraftItem, "gotten isComputercraftItem(="..tostring(isComputercraftItem)..") for "..blockName.." not the same as expected(true)")

    -- test blockNameAny
    blockName = Block.AnyBlockName()
    block2:setName(blockName)
    isComputercraftItem = block2:isComputercraftItem()
    assert(not isComputercraftItem, "gotten isComputercraftItem(="..tostring(isComputercraftItem)..") for "..blockName.." not the same as expected(false)")

    -- test blockNameNone
    blockName = Block.NoneBlockName()
    block2:setName(blockName)
    isComputercraftItem = block2:isComputercraftItem()
    assert(not isComputercraftItem, "gotten isComputercraftItem(="..tostring(isComputercraftItem)..") for "..blockName.." not the same as expected(false)")

    -- cleanup test
end

function T_Block.T_hasValidDirection()
    -- prepare test
    corelog.WriteToLog("* Block:hasValidDirection() tests")
    local blockName = chestItemName
    local obj = Block:new({
        _dx     = 0,
        _dy     = 0,

        _name   = blockName,
    })

    -- test default (0,0)
    local expectedDirectionValid = false
    local directionValid = obj:hasValidDirection()
    assert(directionValid == expectedDirectionValid, "gotten hasValidDirection(="..tostring(directionValid)..") for "..blockName.." not the same as expected("..tostring(expectedDirectionValid)..")")

    -- test (0,1)
    expectedDirectionValid = true
    obj._dx = 0
    obj._dy = 1
    directionValid = obj:hasValidDirection()
    assert(directionValid == expectedDirectionValid, "gotten hasValidDirection(="..tostring(directionValid)..") for "..blockName.." not the same as expected("..tostring(expectedDirectionValid)..")")

    -- test (0,-1)
    expectedDirectionValid = true
    obj._dx = 0
    obj._dy = -1
    directionValid = obj:hasValidDirection()
    assert(directionValid == expectedDirectionValid, "gotten hasValidDirection(="..tostring(directionValid)..") for "..blockName.." not the same as expected("..tostring(expectedDirectionValid)..")")

    -- test (1,0)
    expectedDirectionValid = true
    obj._dx = 1
    obj._dy = 0
    directionValid = obj:hasValidDirection()
    assert(directionValid == expectedDirectionValid, "gotten hasValidDirection(="..tostring(directionValid)..") for "..blockName.." not the same as expected("..tostring(expectedDirectionValid)..")")

    -- test (-1,0)
    expectedDirectionValid = true
    obj._dx = -1
    obj._dy = 0
    directionValid = obj:hasValidDirection()
    assert(directionValid == expectedDirectionValid, "gotten hasValidDirection(="..tostring(directionValid)..") for "..blockName.." not the same as expected("..tostring(expectedDirectionValid)..")")

    -- test (0,9)
    expectedDirectionValid = false
    obj._dx = 0
    obj._dy = 9
    directionValid = obj:hasValidDirection()
    assert(directionValid == expectedDirectionValid, "gotten hasValidDirection(="..tostring(directionValid)..") for "..blockName.." not the same as expected("..tostring(expectedDirectionValid)..")")

    -- test (9,0)
    expectedDirectionValid = false
    obj._dx = 9
    obj._dy = 0
    directionValid = obj:hasValidDirection()
    assert(directionValid == expectedDirectionValid, "gotten hasValidDirection(="..tostring(directionValid)..") for "..blockName.." not the same as expected("..tostring(expectedDirectionValid)..")")

    -- cleanup test
end

function T_Block.T_ParseWithCheckInput()
    -- prepare test
    corelog.WriteToLog("* Block parsing with CheckInput tests")

    -- test
    local checkSuccess, block = InputChecker.Check([[
        Parameters:
            block   + (Block) object to retrieve from arg
    ]], table.unpack({ textutils.unserialize(textutils.serialize(block1)) }))
    if not checkSuccess then corelog.Error("T_Block.T_ParseWithCheckInput: Invalid input") return {success = false} end
    local isTypeOf = Block:isTypeOf(block)
    local expectedIsTypeOf = true
    assert(isTypeOf == expectedIsTypeOf, "gotten isTypeOf(="..tostring(isTypeOf)..") not the same as expected(="..tostring(expectedIsTypeOf)..")")

    -- cleanup test
end

--    _          _                    __                  _   _
--   | |        | |                  / _|                | | (_)
--   | |__   ___| |_ __   ___ _ __  | |_ _   _ _ __   ___| |_ _  ___  _ __  ___
--   | '_ \ / _ \ | '_ \ / _ \ '__| |  _| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
--   | | | |  __/ | |_) |  __/ |    | | | |_| | | | | (__| |_| | (_) | | | \__ \
--   |_| |_|\___|_| .__/ \___|_|    |_|  \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
--                | |
--                |_|

function T_Block.T_IsBlockList()
    -- prepare test
    corelog.WriteToLog("* Block.IsBlockList() tests")
    local block2 = Block:new({
        _name   = furnaceItemName,
    })

    -- test two valid blocks
    local isBlockList = Block.IsBlockList( { block1, block2 } )
    local expectedIsBlockList = true
    assert(isBlockList == expectedIsBlockList, "gotten IsBlockList(="..tostring(isBlockList)..") not the same as expected(="..tostring(expectedIsBlockList)..")")

    -- test one valid block + one almost valid block
    block2._name = 10
    isBlockList = Block.IsBlockList( { block1, block2 } )
    expectedIsBlockList = false
    assert(isBlockList == expectedIsBlockList, "gotten IsBlockList(="..tostring(isBlockList)..") not the same as expected(="..tostring(expectedIsBlockList)..")")
    block2._name = furnaceItemName

    -- test two valid blocks + different object
    isBlockList = Block.IsBlockList( { block1, block2, "a string" } )
    expectedIsBlockList = false
    assert(isBlockList == expectedIsBlockList, "gotten IsBlockList(="..tostring(isBlockList)..") not the same as expected(="..tostring(expectedIsBlockList)..")")

    -- cleanup test
end

function T_Block.T_IsEqualBlockList()
    -- prepare test
    corelog.WriteToLog("* Block.IsEqualBlockList() tests")
    local block2 = Block:new({
        _name   = furnaceItemName,
    })

    -- test with same blocks in same order
    local isEqualBlockList = Block.IsEqualBlockList(
        { block1:copy(), block2:copy() },
        { block1:copy(), block2:copy() }
    )
    local expectedIsEqualBlockList = true
    assert(isEqualBlockList == expectedIsEqualBlockList, "gotten IsEqualBlockList(="..tostring(isEqualBlockList)..") not the same as expected(="..tostring(expectedIsEqualBlockList)..")")

    -- test with 2 empty lists
    isEqualBlockList = Block.IsEqualBlockList(
        { },
        { }
    )
    expectedIsEqualBlockList = true
    assert(isEqualBlockList == expectedIsEqualBlockList, "gotten IsEqualBlockList(="..tostring(isEqualBlockList)..") not the same as expected(="..tostring(expectedIsEqualBlockList)..")")

    -- test with same blocks in different order
    isEqualBlockList = Block.IsEqualBlockList(
        { block1:copy(), block2:copy() },
        { block2:copy(), block1:copy() }
    )
    expectedIsEqualBlockList = false
    assert(isEqualBlockList == expectedIsEqualBlockList, "gotten IsEqualBlockList(="..tostring(isEqualBlockList)..") not the same as expected(="..tostring(expectedIsEqualBlockList)..")")

    -- test with different blocks
    isEqualBlockList = Block.IsEqualBlockList(
        { block1:copy(), block2:copy() },
        { block1:copy(), Block:new({ _name = chestItemName,}) }
    )
    expectedIsEqualBlockList = false
    assert(isEqualBlockList == expectedIsEqualBlockList, "gotten IsEqualBlockList(="..tostring(isEqualBlockList)..") not the same as expected(="..tostring(expectedIsEqualBlockList)..")")

    -- cleanup test
end

function T_Block.T_BlockListCopy()
    -- prepare test
    corelog.WriteToLog("* Block.BlockListCopy() tests")
    local block2 = Block:new({
        _name   = furnaceItemName,
    })

    -- test
    local copy = Block.BlockListCopy({ block1:copy(), block2:copy() })
    local expectedCopy = { block1:copy(), block2:copy() }
    assert(Block.IsEqualBlockList(copy, expectedCopy), "gotten BlockListCopy(="..textutils.serialize(copy, compact)..") not the same as expected(="..textutils.serialize(expectedCopy, compact)..")")

    -- cleanup test
end

function T_Block.T_BlockListTransform()
    -- prepare test
    corelog.WriteToLog("* Block.BlockListTransform() tests")
    local block1Table = {
        _dx     = dx1,
        _dy     = dy1,
        _name   = saplingItemName,
    }
    local block2Table = {
        _name   = furnaceItemName,
    }

    -- test full
    local blockListTable = { coreutils.DeepCopy(block1Table), coreutils.DeepCopy(block2Table) }
    assert(not Block.IsBlockList(blockListTable), "prepared blockList already a BlockList")
    local transformedBlockList = Block.BlockListTransform(blockListTable)
    assert(Block.IsBlockList(transformedBlockList), "transformed blockList not a BlockList")

    -- test partial
    blockListTable = { block1, coreutils.DeepCopy(block2Table) }
    assert(not Block.IsBlockList(blockListTable), "prepared blockList already a BlockList")
    transformedBlockList = Block.BlockListTransform(blockListTable)
    assert(Block.IsBlockList(transformedBlockList), "transformed blockList not a BlockList")

    -- cleanup test
end

return T_Block
