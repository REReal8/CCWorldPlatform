local T_Block = {}
local corelog = require "corelog"

local InputChecker = require "input_checker"

local IObj = require "i_obj"
local ObjBase = require "obj_base"
local Block = require "obj_block"

local T_Class = require "test.t_class"
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

return T_Block
