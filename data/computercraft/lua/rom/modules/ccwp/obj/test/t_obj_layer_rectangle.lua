local T_LayerRectangle = {}
local corelog = require "corelog"

local Class = require "class"
local IObj = require "i_obj"
local ObjBase = require "obj_base"
local ObjTable = require "obj_table"
local Block = require "obj_block"
local LayerRectangle = require "obj_layer_rectangle"

local T_Class = require "test.t_class"
local T_IObj = require "test.t_i_obj"

function T_LayerRectangle.T_All()
    -- helper functions
    T_LayerRectangle.T_IsCodeMap()
    T_LayerRectangle.T_IsEqualCodeMap()
    T_LayerRectangle.T_CodeMapCopy()

    -- initialisation
    T_LayerRectangle.T_new()
    T_LayerRectangle.T_getBlock()

    -- IObj methods
    T_LayerRectangle.T_IObj_All()

    -- specific methods
    T_LayerRectangle.T_itemsNeeded()
    T_LayerRectangle.T_transformToLayer()
    T_LayerRectangle.T_cleanCodeTable()
    T_LayerRectangle.T_removeRow()
    T_LayerRectangle.T_removeColumn()
    T_LayerRectangle.T_getCodeCol()
    T_LayerRectangle.T_removeBoundariesWithOnly()
    T_LayerRectangle.T_buildData()
end

local testClassName = "LayerRectangle"
local blockClassName = "Block"
local torchItemName = "minecraft:torch"
local saplingItemName = "minecraft:birch_sapling"
local chestItemName = "minecraft:chest"
local computerItemName = "computercraft:computer_normal"
local codeTable1 = ObjTable:newInstance(blockClassName, {
    ["T"]   = Block:newInstance(torchItemName),
    ["S"]   = Block:newInstance(saplingItemName),
    ["C"]   = Block:newInstance(chestItemName, -1, 0),
    ["D"]   = Block:newInstance(chestItemName, 0, 1),
    ["K"]   = Block:newInstance(computerItemName),
    ["?"]   = Block:newInstance(Block.AnyBlockName()),
    [" "]   = Block:newInstance(Block.NoneBlockName()),
})

--    _          _                    __                  _   _
--   | |        | |                  / _|                | | (_)
--   | |__   ___| |_ __   ___ _ __  | |_ _   _ _ __   ___| |_ _  ___  _ __  ___
--   | '_ \ / _ \ | '_ \ / _ \ '__| |  _| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
--   | | | |  __/ | |_) |  __/ |    | | | |_| | | | | (__| |_| | (_) | | | \__ \
--   |_| |_|\___|_| .__/ \___|_|    |_|  \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
--                | |
--                |_|

local compact = { compact = true }

local codeMap1 = {
    [6] = "CD   ?",
    [5] = "      ",
    [4] = "T  S  ",
    [3] = "  ?   ",
    [2] = "   K  ",
    [1] = "   T  ",
}

function T_LayerRectangle.T_IsCodeMap()
    -- prepare test
    corelog.WriteToLog("* LayerRectangle.IsCodeMap tests")

    -- test valid
    local isCodeMap = LayerRectangle.IsCodeMap(codeMap1)
    local expectedIsCodeMap = true
    assert(isCodeMap == expectedIsCodeMap, "gotten IsCodeMap(="..tostring(isCodeMap)..") not the same as expected(="..tostring(expectedIsCodeMap)..")")

    -- test different object
    isCodeMap = LayerRectangle.IsCodeMap("a atring")
    expectedIsCodeMap = false
    assert(isCodeMap == expectedIsCodeMap, "gotten IsCodeMap(="..tostring(isCodeMap)..") not the same as expected(="..tostring(expectedIsCodeMap)..")")

    -- cleanup test
end

function T_LayerRectangle.T_IsEqualCodeMap()
    -- prepare test
    corelog.WriteToLog("* LayerRectangle.IsEqualCodeMap() tests")
    local codeMap2 = {
        [6] = "CD   ?",
        [5] = "      ",
        [4] = "T  S  ",
        [3] = "  ?   ",
        [2] = "   K  ",
        [1] = "   T  ",
    }

    -- test same
    local isEqual = LayerRectangle.IsEqualCodeMap(codeMap1, codeMap2)
    local expectedIsEqual = true
    assert(isEqual == expectedIsEqual, "gotten IsEqualCodeMap(="..tostring(isEqual)..") not the same as expected(="..tostring(expectedIsEqual)..")")

    -- test different
    codeMap2[4] = "TTTSTT"
    isEqual = LayerRectangle.IsEqualCodeMap(codeMap1, codeMap2)
    expectedIsEqual = false
    assert(isEqual == expectedIsEqual, "gotten IsEqualCodeMap(="..tostring(isEqual)..") not the same as expected(="..tostring(expectedIsEqual)..")")
    codeMap2[4] = "T  S  "

    -- test different (size)
    codeMap2[7] = "TT  TT"
    isEqual = LayerRectangle.IsEqualCodeMap(codeMap1, codeMap2)
    expectedIsEqual = false
    assert(isEqual == expectedIsEqual, "gotten IsEqualCodeMap(="..tostring(isEqual)..") not the same as expected(="..tostring(expectedIsEqual)..")")
    codeMap2[7] = nil

    -- cleanup test
end

function T_LayerRectangle.T_CodeMapCopy()
    -- prepare test
    corelog.WriteToLog("* LayerRectangle.CodeMapCopy() tests")

    -- test
    local copy = LayerRectangle.CodeMapCopy(codeMap1)
    assert(LayerRectangle.IsEqualCodeMap(copy, codeMap1), "gotten CodeMapCopy(="..textutils.serialize(copy, compact)..") not the same as expected(="..textutils.serialize(codeMap1, compact)..")")

    -- cleanup test
end

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_LayerRectangle.CreateTestObj(codeTable, codeMap)
    -- check input
    codeTable = codeTable or codeTable1:copy()
    codeMap = codeMap or {
        [6] = "CD   ?",
        [5] = "      ",
        [4] = "T  S  ",
        [3] = "  ?   ",
        [2] = "   K  ",
        [1] = "   T  ",
    }

    -- create testObj
    local testObj = LayerRectangle:new({
        _codeTable  = codeTable,
        _codeMap    = codeMap,
    })

    -- end
    return testObj
end

local layer1 = LayerRectangle:new({
    _codeTable  = codeTable1:copy(),
    _codeMap    = codeMap1,
}) assert(layer1, "Failed obtaining layer")

function T_LayerRectangle.T_new()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() tests")

    -- test full
    local layer = LayerRectangle:new({
        _codeTable  = codeTable1:copy(),
        _codeMap    = codeMap1,
    }) assert(layer, "Failed obtaining layer")
    local expectedNColumns = 6
    assert(layer:getNColumns() == expectedNColumns, "gotten getNColumns(="..layer:getNColumns()..") not the same as expected(="..expectedNColumns..")")
    local expectedNRows = 6
    assert(layer:getNRows() == expectedNRows, "gotten getNRows(="..layer:getNRows()..") not the same as expected(="..expectedNRows..")")
    local code = layer:getCode(4, 1)
    local expectedCode = "T"
    assert(code == expectedCode, "gotten code(="..code..") not the same as expected(="..expectedCode..")")
    code = layer:getCode(1, 4)
    assert(code == expectedCode, "gotten code(="..code..") not the same as expected(="..expectedCode..")")
    code = layer:getCode(4, 4)
    expectedCode = "S"
    assert(code == expectedCode, "gotten code(="..code..") not the same as expected(="..expectedCode..")")

    -- test default
    layer = LayerRectangle:new({ _codeTable = ObjTable:newInstance(blockClassName) }) assert(layer, "Failed obtaining layer")
    expectedNColumns = 0
    assert(layer:getNColumns() == expectedNColumns, "gotten getNColumns(="..layer:getNColumns()..") not the same as expected(="..expectedNColumns..")")
    expectedNRows = 0
    assert(layer:getNRows() == expectedNRows, "gotten getNRows(="..layer:getNRows()..") not the same as expected(="..expectedNRows..")")

    -- cleanup test
end

function T_LayerRectangle.T_getBlock()
    -- prepare test
    corelog.WriteToLog("* LayerRectangle:getBlock() tests")

    -- test full
    local layer = LayerRectangle:new({
        _codeTable  = codeTable1:copy(),
        _codeMap    = codeMap1,
    }) assert(layer, "Failed obtaining layer")
    local block = layer:getBlock(4, 1)
    local expectedBlock = Block:newInstance(torchItemName)
    assert(block:isEqual(expectedBlock), "gotten block(="..textutils.serialize(block, compact)..") not the same as expected(="..textutils.serialize(expectedBlock, compact)..")")
    block = layer:getBlock(1, 4)
    expectedBlock = Block:newInstance(torchItemName)
    assert(block:isEqual(expectedBlock), "gotten block(="..textutils.serialize(block, compact)..") not the same as expected(="..textutils.serialize(expectedBlock, compact)..")")
    block = layer:getBlock(4, 4)
    expectedBlock = Block:newInstance(saplingItemName)
    assert(block:isEqual(expectedBlock), "gotten block(="..textutils.serialize(block, compact)..") not the same as expected(="..textutils.serialize(expectedBlock, compact)..")")
    block = layer:getBlock(1, 1)
    expectedBlock = Block:newInstance(Block.NoneBlockName())
    assert(block:isEqual(expectedBlock), "gotten block(="..textutils.serialize(block, compact)..") not the same as expected(="..textutils.serialize(expectedBlock, compact)..")")
    block = layer:getBlock(3, 3)
    expectedBlock = Block:newInstance(Block.AnyBlockName())
    assert(block:isEqual(expectedBlock), "gotten block(="..textutils.serialize(block, compact)..") not the same as expected(="..textutils.serialize(expectedBlock, compact)..")")
    block = layer:getBlock(1, 6)
    expectedBlock = Block:newInstance(chestItemName, -1, 0)
    assert(block:isEqual(expectedBlock), "gotten block(="..textutils.serialize(block, compact)..") not the same as expected(="..textutils.serialize(expectedBlock, compact)..")")

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

function T_LayerRectangle.T_IObj_All()
    -- prepare test
    local obj = T_LayerRectangle.CreateTestObj() assert(obj, "failed obtaining "..testClassName)
    local otherObj = T_LayerRectangle.CreateTestObj() assert(obj, "failed obtaining "..testClassName) assert(otherObj, "failed obtaining "..testClassName)

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

function T_LayerRectangle.T_itemsNeeded()
    -- prepare test
    corelog.WriteToLog("* LayerRectangle:itemsNeeded() tests")

    -- test
    local needed = layer1:itemsNeeded()
    local name = torchItemName
    local expectedCount = 2
    assert(needed[name] == expectedCount, "gotten count(="..(needed[name] or 0)..") for "..name.."'s not the same as expected(="..expectedCount..")")
    name = saplingItemName
    expectedCount = 1
    assert(needed[name] == expectedCount, "gotten count(="..(needed[name] or 0)..") for "..name.."'s not the same as expected(="..expectedCount..")")
    name = chestItemName
    expectedCount = 2
    assert(needed[name] == expectedCount, "gotten count(="..(needed[name] or 0)..") for "..name.."'s not the same as expected(="..expectedCount..")")
    name = Block.AnyBlockName()
    expectedCount = 0
    assert(not needed[name], "gotten count(="..(needed[name] or 0)..") for "..name.."'s not the same as expected(="..expectedCount..")")
    name = Block.NoneBlockName()
    expectedCount = 0
    assert(not needed[name], "gotten count(="..(needed[name] or 0)..") for "..name.."'s not the same as expected(="..expectedCount..")")

    -- cleanup test
end

function T_LayerRectangle.T_transformToLayer()
    -- prepare test
    corelog.WriteToLog("* LayerRectangle:transformToLayer() tests")
    local fromLayer = LayerRectangle:new({
        _codeTable  = ObjTable:newInstance(blockClassName, {
            ["S"]   = Block:newInstance(saplingItemName),
            ["?"]   = Block:newInstance(Block.AnyBlockName()),
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        _codeMap    = {
            [6] = "   S  ",
            [5] = "      ",
            [4] = "   S  ",
            [3] = "   ?  ",
            [2] = "   ?  ",
            [1] = "   ?  ",
        },
    }) assert(fromLayer, "Failed obtaining layer")
    local toLayer = LayerRectangle:new({
        _codeTable  = ObjTable:newInstance(blockClassName, {
            ["T"]   = Block:newInstance(torchItemName),
            ["S"]   = Block:newInstance(saplingItemName),
            ["?"]   = Block:newInstance(Block.AnyBlockName()),
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        _codeMap    = {
            [6] = "   ?  ",
            [5] = "      ",
            [4] = "T  S  ",
            [3] = "      ",
            [2] = "   ?  ",
            [1] = "   T  ",
        },
    }) assert(toLayer, "Failed obtaining layer")

    -- test
    local transformLayer = fromLayer:transformToLayer(toLayer)
    local isInstanceOf = Class.IsInstanceOf(transformLayer, LayerRectangle)
    local expectedIsInstanceOf = true
    assert(isInstanceOf, "gotten isInstanceOf(="..tostring(isInstanceOf)..") not the same as expected(="..tostring(expectedIsInstanceOf)..")")
    local expectedLayer = LayerRectangle:new({
        _codeTable  = ObjTable:newInstance(blockClassName,{
            ["T"]   = Block:newInstance(torchItemName),
            ["S"]   = Block:newInstance(saplingItemName),
            ["?"]   = Block:newInstance(Block.AnyBlockName()),
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        _codeMap    = {
            [6] = "??????",
            [5] = "??????",
            [4] = "T?????",
            [3] = "??? ??",
            [2] = "??????",
            [1] = "???T??",
        },
    })
    assert(transformLayer:isEqual(expectedLayer), "gotten transformToLayer(="..textutils.serialize(transformLayer, compact)..") not the same as expected(="..textutils.serialize(expectedLayer, compact)..")")

    -- test anyBlock added to _codeTable
    toLayer = LayerRectangle:new({
        _codeTable  = ObjTable:newInstance(blockClassName, {
            ["T"]   = Block:newInstance(torchItemName),
            ["S"]   = Block:newInstance(saplingItemName),
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        _codeMap    = {
            [6] = "      ",
            [5] = "      ",
            [4] = "T  S  ",
            [3] = "      ",
            [2] = "      ",
            [1] = "   T  ",
        },
    })
    transformLayer = fromLayer:transformToLayer(toLayer)
    isInstanceOf = Class.IsInstanceOf(transformLayer, LayerRectangle)
    expectedIsInstanceOf = true
    assert(isInstanceOf, "gotten isInstanceOf(="..tostring(isInstanceOf)..") not the same as expected(="..tostring(expectedIsInstanceOf)..")")
    expectedLayer = LayerRectangle:new({
        _codeTable  = ObjTable:newInstance(blockClassName, {
            ["T"]   = Block:newInstance(torchItemName),
            ["S"]   = Block:newInstance(saplingItemName),
            ["?"]   = Block:newInstance(Block.AnyBlockName()),
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        _codeMap    = {
            [6] = "??? ??",
            [5] = "??????",
            [4] = "T?????",
            [3] = "??? ??",
            [2] = "??? ??",
            [1] = "???T??",
        },
    })
    assert(transformLayer:isEqual(expectedLayer), "gotten transformToLayer(="..textutils.serialize(transformLayer, compact)..") not the same as expected(="..textutils.serialize(expectedLayer, compact)..")")

    -- cleanup test
end

function T_LayerRectangle.T_cleanCodeTable()
    -- prepare test
    corelog.WriteToLog("* LayerRectangle:cleanCodeTable() tests")
    local layer = LayerRectangle:new({
        _codeTable  = ObjTable:newInstance(blockClassName, {
            ["T"]   = Block:newInstance(torchItemName),
            ["S"]   = Block:newInstance(saplingItemName),
            ["C"]   = Block:newInstance(chestItemName, -1, 0),
            ["?"]   = Block:newInstance(Block.AnyBlockName()),
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        _codeMap    = {
            [4] = "    ",
            [3] = "T   ",
            [2] = "    ",
            [1] = " T  ",
        },
    }) assert(layer, "Failed obtaining layer")

    -- test
    layer:cleanCodeTable()
    local expectedCodeTable  = ObjTable:newInstance(blockClassName, {
        ["T"]   = Block:newInstance(torchItemName),
        [" "]   = Block:newInstance(Block.NoneBlockName()),
    })
    assert(layer._codeTable:isEqual(expectedCodeTable), "result codeTable(="..textutils.serialize(layer._codeTable, compact)..") not the same as expected(="..textutils.serialize(expectedCodeTable, compact)..")")

    -- cleanup test
end

function T_LayerRectangle.T_removeRow()
    -- prepare test
    corelog.WriteToLog("* LayerRectangle:removeRow() tests")

    -- test top
    local layer = layer1:copy()
    layer:removeRow(6)
    local expectedLayer = LayerRectangle:new({
        _codeTable  = ObjTable:newInstance(blockClassName, {
            ["T"]   = Block:newInstance(torchItemName),
            ["S"]   = Block:newInstance(saplingItemName),
            ["K"]   = Block:newInstance(computerItemName),
            ["?"]   = Block:newInstance(Block.AnyBlockName()),
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        _codeMap    = {
            [5] = "      ",
            [4] = "T  S  ",
            [3] = "  ?   ",
            [2] = "   K  ",
            [1] = "   T  ",
        },
    })
    assert(layer:isEqual(expectedLayer), "result layer(="..textutils.serialize(layer, compact)..") not the same as expected(="..textutils.serialize(expectedLayer, compact)..")")

    -- test a mid
    layer = layer1:copy()
    layer:removeRow(4)
    expectedLayer = LayerRectangle:new({
        _codeTable  = ObjTable:newInstance(blockClassName, {
            ["T"]   = Block:newInstance(torchItemName),
            ["C"]   = Block:newInstance(chestItemName, -1, 0),
            ["D"]   = Block:newInstance(chestItemName, 0, 1),
            ["K"]   = Block:newInstance(computerItemName),
            ["?"]   = Block:newInstance(Block.AnyBlockName()),
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        _codeMap    = {
            [5] = "CD   ?",
            [4] = "      ",
            [3] = "  ?   ",
            [2] = "   K  ",
            [1] = "   T  ",
        },
    })
    assert(layer:isEqual(expectedLayer), "result layer(="..textutils.serialize(layer, compact)..") not the same as expected(="..textutils.serialize(expectedLayer, compact)..")")

    -- test bottom
    layer = layer1:copy()
    layer:removeRow(1)
    expectedLayer = LayerRectangle:new({
        _codeTable  = ObjTable:newInstance(blockClassName, {
            ["T"]   = Block:newInstance(torchItemName),
            ["S"]   = Block:newInstance(saplingItemName),
            ["C"]   = Block:newInstance(chestItemName, -1, 0),
            ["D"]   = Block:newInstance(chestItemName, 0, 1),
            ["K"]   = Block:newInstance(computerItemName),
            ["?"]   = Block:newInstance(Block.AnyBlockName()),
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        _codeMap    = {
            [5] = "CD   ?",
            [4] = "      ",
            [3] = "T  S  ",
            [2] = "  ?   ",
            [1] = "   K  ",
        },
    })
    assert(layer:isEqual(expectedLayer), "result layer(="..textutils.serialize(layer, compact)..") not the same as expected(="..textutils.serialize(expectedLayer, compact)..")")

    -- cleanup test
end

function T_LayerRectangle.T_getCodeCol()
    -- prepare test
    corelog.WriteToLog("* LayerRectangle:getCodeCol() tests")

    -- test
    local column = layer1:getCodeCol(4)
    local expectedColumn = "TK S  "
    assert(column == expectedColumn, "gotten column(="..column..") not the same as expected(="..expectedColumn..")")

    -- cleanup test
end

function T_LayerRectangle.T_removeColumn()
    -- prepare test
    corelog.WriteToLog("* LayerRectangle:removeColumn() tests")

    -- test right
    local layer = layer1:copy()
    layer:removeColumn(6)
    local expectedLayer = LayerRectangle:new({
        _codeTable  = ObjTable:newInstance(blockClassName, {
            ["T"]   = Block:newInstance(torchItemName),
            ["S"]   = Block:newInstance(saplingItemName),
            ["C"]   = Block:newInstance(chestItemName, -1, 0),
            ["D"]   = Block:newInstance(chestItemName, 0, 1),
            ["K"]   = Block:newInstance(computerItemName),
            ["?"]   = Block:newInstance(Block.AnyBlockName()),
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        _codeMap    = {
            [6] = "CD   ",
            [5] = "     ",
            [4] = "T  S ",
            [3] = "  ?  ",
            [2] = "   K ",
            [1] = "   T ",
        },
    })
    assert(layer:isEqual(expectedLayer), "result layer(="..textutils.serialize(layer, compact)..") not the same as expected(="..textutils.serialize(expectedLayer, compact)..")")

    -- test mid
    layer = layer1:copy()
    layer:removeColumn(4)
    expectedLayer = LayerRectangle:new({
        _codeTable  = ObjTable:newInstance(blockClassName, {
            ["T"]   = Block:newInstance(torchItemName),
            ["C"]   = Block:newInstance(chestItemName, -1, 0),
            ["D"]   = Block:newInstance(chestItemName, 0, 1),
            ["?"]   = Block:newInstance(Block.AnyBlockName()),
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        _codeMap    = {
            [6] = "CD  ?",
            [5] = "     ",
            [4] = "T    ",
            [3] = "  ?  ",
            [2] = "     ",
            [1] = "     ",
        },
    })
    assert(layer:isEqual(expectedLayer), "result layer(="..textutils.serialize(layer, compact)..") not the same as expected(="..textutils.serialize(expectedLayer, compact)..")")

    -- test left
    layer = layer1:copy()
    layer:removeColumn(1)
    expectedLayer = LayerRectangle:new({
        _codeTable  = ObjTable:newInstance(blockClassName, {
            ["T"]   = Block:newInstance(torchItemName),
            ["S"]   = Block:newInstance(saplingItemName),
            ["D"]   = Block:newInstance(chestItemName, 0, 1),
            ["K"]   = Block:newInstance(computerItemName),
            ["?"]   = Block:newInstance(Block.AnyBlockName()),
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        _codeMap    = {
            [6] = "D   ?",
            [5] = "     ",
            [4] = "  S  ",
            [3] = " ?   ",
            [2] = "  K  ",
            [1] = "  T  ",
        },
    })
    assert(layer:isEqual(expectedLayer), "result layer(="..textutils.serialize(layer, compact)..") not the same as expected(="..textutils.serialize(expectedLayer, compact)..")")

    -- cleanup test
end

function T_LayerRectangle.T_removeBoundariesWithOnly()
    -- prepare test
    corelog.WriteToLog("* LayerRectangle:removeBoundariesWithOnly() tests")

    -- test right
    local layer = LayerRectangle:new({
        _codeTable  = ObjTable:newInstance(blockClassName, {
            ["T"]   = Block:newInstance(torchItemName),
            ["C"]   = Block:newInstance(chestItemName, -1, 0),
            ["?"]   = Block:newInstance(Block.AnyBlockName()),
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        _codeMap    = {
            [6] = "??????",
            [5] = "??????",
            [4] = "??TC ?",
            [3] = "?? C??",
            [2] = "??? T?",
            [1] = "??????",
        },
    }) assert(layer, "Failed obtaining layer")
    local code = "?"
    local colOffset, rowOffset = layer:removeBoundariesWithOnly(code)
    local expectedOffset = 1
    assert(rowOffset == expectedOffset, "gotten rowOffset(="..tostring(colOffset)..") for code "..code.." not the same as expected(="..tostring(expectedOffset)..")")
    expectedOffset = 2
    assert(colOffset == expectedOffset, "gotten colOffset(="..tostring(colOffset)..") for code "..code.." not the same as expected(="..tostring(expectedOffset)..")")
    local expectedLayer = LayerRectangle:new({
        _codeTable  = ObjTable:newInstance(blockClassName, {
            ["T"]   = Block:newInstance(torchItemName),
            ["C"]   = Block:newInstance(chestItemName, -1, 0),
            ["?"]   = Block:newInstance(Block.AnyBlockName()),
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        _codeMap    = {
            [3] = "TC ",
            [2] = " C?",
            [1] = "? T",
        },
    })
    assert(layer:isEqual(expectedLayer), "result layer(="..textutils.serialize(layer, compact)..") for code "..code.." not the same as expected(="..textutils.serialize(expectedLayer, compact)..")")

    -- cleanup test
end

function T_LayerRectangle.T_buildData()
    -- prepare test
    corelog.WriteToLog("* LayerRectangle:buildData() tests")

    -- test right
    local layer = LayerRectangle:new({
        _codeTable  = ObjTable:newInstance(blockClassName, {
            ["T"]   = Block:newInstance(torchItemName),
            ["C"]   = Block:newInstance(chestItemName, -1, 0),
            ["?"]   = Block:newInstance(Block.AnyBlockName()),
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        _codeMap    = {
            [6] = "??????",
            [5] = "??????",
            [4] = "??TC ?",
            [3] = "?? C??",
            [2] = "??? T?",
            [1] = "??????",
        },
    }) assert(layer, "Failed obtaining layer")
    local colOffset, rowOffset, buildLayer = layer:buildData()
    local expectedOffset = 1
    assert(rowOffset == expectedOffset, "gotten rowOffset(="..tostring(colOffset)..") for not the same as expected(="..tostring(expectedOffset)..")")
    expectedOffset = 2
    assert(colOffset == expectedOffset, "gotten colOffset(="..tostring(colOffset)..") for not the same as expected(="..tostring(expectedOffset)..")")
    local expectedLayer = LayerRectangle:new({
        _codeTable  = ObjTable:newInstance(blockClassName, {
            ["T"]   = Block:newInstance(torchItemName),
            ["C"]   = Block:newInstance(chestItemName, -1, 0),
            ["?"]   = Block:newInstance(Block.AnyBlockName()),
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        _codeMap    = {
            [3] = "TC ",
            [2] = " C?",
            [1] = "? T",
        },
    })
    assert(buildLayer:isEqual(expectedLayer), "result layer(="..textutils.serialize(layer, compact)..") for not the same as expected(="..textutils.serialize(expectedLayer, compact)..")")

    -- cleanup test
end

return T_LayerRectangle
