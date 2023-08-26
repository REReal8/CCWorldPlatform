local t_builder = {}

local corelog = require "corelog"

local Location = require "obj_location"
local Block = require "obj_block"
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
local codeArray1 = {
    ["T"]   = Block:new({ _name = torchItemName }),
    ["C"]   = Block:new({ _name = chestItemName, _dx = 0, _dy = 1 }),
    ["?"]   = Block:new({ _name = Block.AnyBlockName() }),
    [" "]   = Block:new({ _name = Block.NoneBlockName() }),
}
local codeMap1 = {
    [6] = "  C ",
    [5] = "    ",
    [4] = "T   ",
    [3] = "    ",
    [2] = "    ",
    [1] = "   T",
}
local testBuildLayer1 = LayerRectangle:new({
    _codeArray  = LayerRectangle.CodeArrayCopy(codeArray1),
    _codeMap    = LayerRectangle.CodeMapCopy(codeMap1),
}) assert(testBuildLayer1, "Failed obtaining testBuildLayer1")

local testBuildLayer2 = LayerRectangle:new({
    _codeArray  = {
        ["C"]   = Block:new({ _name = chestItemName, _dx =-1, _dy = 0 }),
        ["D"]   = Block:new({ _name = chestItemName, _dx = 0, _dy = 1 }),
        ["E"]   = Block:new({ _name = chestItemName, _dx = 0, _dy =-1 }),
        ["F"]   = Block:new({ _name = chestItemName, _dx = 1, _dy = 0 }),
        [" "]   = Block:new({ _name = Block.NoneBlockName() }),
    },
    _codeMap    = {
        [3] = "DDF",
        [2] = "C F",
        [1] = "CEE",
    },
}) assert(testBuildLayer2, "Failed obtaining testBuildLayer2")

local testBuildLayer3 = LayerRectangle:new({
    _codeArray  = {
        ["T"]   = Block:new({ _name = torchItemName }),
        ["C"]   = Block:new({ _name = chestItemName, _dx =-1, _dy = 0 }),
        ["D"]   = Block:new({ _name = chestItemName, _dx = 0, _dy = 1 }),
        ["?"]   = Block:new({ _name = Block.AnyBlockName() }),
        [" "]   = Block:new({ _name = Block.NoneBlockName() }),
    },
    _codeMap    = {
        [6] = "C D  T",
        [5] = "    T ",
        [4] = "   T  ",
        [3] = "??T   ",
        [2] = " T    ",
        [1] = "T    D",
    },
}) assert(testBuildLayer3, "Failed obtaining testBuildLayer3")

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
