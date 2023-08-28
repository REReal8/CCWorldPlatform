local t_builder = {}

local corelog = require "corelog"

local ObjTable = require "obj_table"
local Location = require "obj_location"
local Block = require "obj_block"
local CodeMap = require "obj_code_map"
local LayerRectangle = require "obj_layer_rectangle"

local role_builder = require "role_builder"

function t_builder.T_All()
--    T_PatternsSubstract()
    t_builder.T_BuildLayer_MetaData()
    t_builder.T_BuildBlueprint_MetaData()
end

local testStartLocation = Location:newInstance(-6, 0, 1, 0, 1)

local size_x1 = 4
local size_y1 = 6
local chestItemName = "minecraft:chest"
local torchItemName = "minecraft:torch"
local blockClassName = "Block"
local codeTable1 = ObjTable:newInstance(blockClassName, {
    ["T"]   = Block:newInstance(torchItemName),
    ["C"]   = Block:newInstance(chestItemName, 0, 1),
    ["?"]   = Block:newInstance(Block.AnyBlockName()),
    [" "]   = Block:newInstance(Block.NoneBlockName()),
})
local codeMap1 = CodeMap:newInstance({
    [6] = "  C ",
    [5] = "    ",
    [4] = "T   ",
    [3] = "    ",
    [2] = "    ",
    [1] = "   T",
}) assert(codeMap1, "Failed obtaining codeMap1")
local testBuildLayer1 = LayerRectangle:newInstance(codeTable1:copy(), codeMap1:copy()) assert(testBuildLayer1, "Failed obtaining testBuildLayer1")

local testBuildLayer2 = LayerRectangle:newInstance(
    ObjTable:newInstance(blockClassName, {
        ["C"]   = Block:newInstance(chestItemName, -1, 0),
        ["D"]   = Block:newInstance(chestItemName, 0, 1),
        ["E"]   = Block:newInstance(chestItemName, 0, -1),
        ["F"]   = Block:newInstance(chestItemName, 1, 0),
        [" "]   = Block:newInstance(Block.NoneBlockName()),
    }),
    CodeMap:newInstance({
        [3] = "DDF",
        [2] = "C F",
        [1] = "CEE",
    })
) assert(testBuildLayer2, "Failed obtaining testBuildLayer2")

local testBuildLayer3 = LayerRectangle:newInstance(
    ObjTable:newInstance(blockClassName, {
        ["T"]   = Block:newInstance(torchItemName),
        ["C"]   = Block:newInstance(chestItemName, -1, 0),
        ["D"]   = Block:newInstance(chestItemName, 0, 1),
        ["?"]   = Block:newInstance(Block.AnyBlockName()),
        [" "]   = Block:newInstance(Block.NoneBlockName()),
    }),
    CodeMap:newInstance({
        [6] = "C D  T",
        [5] = "    T ",
        [4] = "   T  ",
        [3] = "??T   ",
        [2] = " T    ",
        [1] = "T    D",
    })
) assert(testBuildLayer3, "Failed obtaining testBuildLayer3")

local compact = { compact = true }

function t_builder.T_BuildLayer_MetaData()
    -- prepare test
    corelog.WriteToLog("* role_builder BuildLayer_MetaData test")
    local buildFromAbove = true
    local buildData = {startpoint = testStartLocation, buildFromAbove = buildFromAbove, layer = testBuildLayer1}

    -- test
    local metaData = role_builder.BuildLayer_MetaData(buildData)
    local deltaZ = 1 if not buildFromAbove then deltaZ = -1 end
    local expectedLocation = testStartLocation:getRelativeLocation(0, 0, deltaZ)
    assert(metaData.location:isEqual(expectedLocation), "gotten location(="..textutils.serialize(metaData.location, compact)..") not the same as expected(="..textutils.serialize(expectedLocation, compact)..")")
    assert(metaData.needTool, "gotten needTool(="..tostring(metaData.needTool)..") not the same as expected(=true)")
    assert(metaData.needTurtle, "gotten needTurtle(="..tostring(metaData.needTurtle)..") not the same as expected(=true)")
    local expectedFuelNeeded = size_x1*size_y1 - 1
    assert(metaData.fuelNeeded == expectedFuelNeeded, "gotten fuelNeeded(="..metaData.fuelNeeded..") not the same as expected(="..expectedFuelNeeded..")")
    assert(metaData.itemsNeeded[chestItemName] == 1, "gotten itemCount(="..metaData.itemsNeeded[chestItemName]..") for "..chestItemName.."'s not the same as expected(=1)")
    assert(metaData.itemsNeeded[torchItemName] == 2, "gotten itemCount(="..metaData.itemsNeeded[torchItemName]..") for "..torchItemName.."'s not the same as expected(=2)")

    -- cleanup test
end

function t_builder.T_BuildBlueprint_MetaData()
    -- prepare test
    corelog.WriteToLog("* role_builder BuildBlueprint_MetaData test")
    local testBlueprint = {
        layerList = {
            { startpoint = Location:newInstance(0, 0, 0), buildFromAbove  = true, layer = testBuildLayer1:copy()},
            { startpoint = Location:newInstance(3, 3, -1), buildFromAbove  = false, layer = testBuildLayer2:copy()},
        },
        escapeSequence = {
            Location:newInstance(3, 3, 1),
        }
    }
    local blueprintBuildData = {blueprintStartpoint = testStartLocation:getRelativeLocation(6, 0, 0), blueprint = testBlueprint}

    -- test
    local metaData = role_builder.BuildBlueprint_MetaData(blueprintBuildData)
    local expectedLocation = testStartLocation:getRelativeLocation(6, 0, 0)
    assert(metaData.location:isEqual(expectedLocation), "gotten location(="..textutils.serialize(metaData.location, compact)..") not the same as expected(="..textutils.serialize(expectedLocation, compact)..")")
    assert(metaData.needTool, "gotten needTool(="..tostring(metaData.needTool)..") not the same as expected(=true)")
    assert(metaData.needTurtle, "gotten needTurtle(="..tostring(metaData.needTurtle)..") not the same as expected(=true)")
    local expectedFuelNeeded = 47
    assert(metaData.fuelNeeded == expectedFuelNeeded, "gotten fuelNeeded(="..metaData.fuelNeeded..") not the same as expected(="..expectedFuelNeeded..")")
    assert(metaData.itemsNeeded[chestItemName] == 9, "gotten itemCount(="..metaData.itemsNeeded[chestItemName]..") for "..chestItemName.."'s not the same as expected(=9)")
    assert(metaData.itemsNeeded[torchItemName] == 2, "gotten itemCount(="..metaData.itemsNeeded[torchItemName]..") for "..torchItemName.."'s not the same as expected(=2)")

    -- cleanup test
end

function t_builder.T_BuildLayer_Task()
    -- prepare test
    corelog.WriteToLog("* role_builder BuildLayer_Task test")
    local testBuildLayer = testBuildLayer3:copy()
    local buildData = {startpoint = testStartLocation, buildFromAbove = true, replacePresentObjects = false, layer = testBuildLayer}

    -- test
    role_builder.BuildLayer_Task(buildData)

    -- cleanup test
end

return t_builder
