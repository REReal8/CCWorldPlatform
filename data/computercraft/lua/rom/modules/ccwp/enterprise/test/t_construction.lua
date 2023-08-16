local t_construction = {}

local corelog = require "corelog"

local Callback = require "obj_callback"

local Location = require "obj_location"
local Block = require "obj_block"
local LayerRectangle = require "obj_layer_rectangle"

local enterprise_projects = require "enterprise_projects"
local enterprise_construction = require "enterprise_construction"
local enterprise_chests = require "enterprise_chests"

local t_chests = require "test.t_chests"
local t_turtle = require "test.t_turtle"

local testStartLocation     = Location:new({_x= -6, _y= 0, _z= 1, _dx=0, _dy=1})
local testStartLocation2    = testStartLocation:getRelativeLocation(0, 6, 0)

local testBuildLayer1 = LayerRectangle:new({
    _codeArray  = {
        ["T"]   = Block:new({ _name = "minecraft:torch" }),
        ["C"]   = Block:new({ _name = "minecraft:chest", _dx =0, _dy = 1 }),
        [" "]   = Block:new({ _name = Block.NoneBlockName() }),
    },
    _codeMap    = {
        [6] = "  C ",
        [5] = "    ",
        [4] = "T   ",
        [3] = "    ",
        [2] = "    ",
        [1] = "   T",
    },
})

local testBuildLayer2 = LayerRectangle:new({
    _codeArray  = {
        ["C"]   = Block:new({ _name = "minecraft:chest", _dx =-1, _dy = 0 }),
        ["D"]   = Block:new({ _name = "minecraft:chest", _dx = 0, _dy = 1 }),
        ["E"]   = Block:new({ _name = "minecraft:chest", _dx = 0, _dy =-1 }),
        ["F"]   = Block:new({ _name = "minecraft:chest", _dx = 1, _dy = 0 }),
        [" "]   = Block:new({ _name = Block.NoneBlockName() }),
    },
    _codeMap    = {
        [3] = "DDF",
        [2] = "C F",
        [1] = "CEE",
    },
})

local testBuildLayer3 = LayerRectangle:new({
    _codeArray  = {
        ["T"]   = Block:new({ _name = "minecraft:torch" }),
        ["C"]   = Block:new({ _name = "minecraft:chest", _dx = 0, _dy = 1 }),
        [" "]   = Block:new({ _name = Block.NoneBlockName() }),
    },
    _codeMap    = {
        [6] = "  C C ",
        [5] = "      ",
        [4] = "T     ",
        [3] = "      ",
        [2] = "      ",
        [1] = "   T  ",
    },
})

local testBuildLayer4 = LayerRectangle:new({
    _codeArray  = {
        [" "]   = Block:new({ _name = Block.NoneBlockName() }),
    },
    _codeMap    = {
        [1] = " ",
    },
})

function t_construction.T_BuildLayer_ASrv_FromTurtle()
    -- test service 1
    corelog.WriteToLog("* BuildLayer_ASrv (from turtle) test")
    local buildData = {
        startpoint                  = testStartLocation,
        buildFromAbove              = true,
        layer                       = testBuildLayer1,
        materialsItemSupplierLocator= t_turtle.GetCurrentTurtleLocator(),
        wasteItemDepotLocator       = t_turtle.GetCurrentTurtleLocator(),
    }
    local callback = Callback:new({
        _moduleName     = "t_main",
        _methodName     = "Func1_Callback",
        _data           = {"some callback data"},
    })

    corelog.WriteToLog("T_construction calling BuildLayer_ASrv("..textutils.serialise(buildData)..", ...)")
    return enterprise_construction.BuildLayer_ASrv(buildData, callback)
end

function t_construction.T_BuildLayer_ASrv_FromChest()
    -- test service
    corelog.WriteToLog("* BuildLayer_ASrv (from chest) test")

    -- create project definition
    local buildRectangularPattern_ASrvProjectDef = {
        steps   = {
            -- host and update chest
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_projects", serviceName = "StartProject_ASrv" }, stepDataDef = {
                { keyDef = "projectDef"             , sourceStep = 0, sourceKeyDef = "projectDef" },
                { keyDef = "projectData"            , sourceStep = 0, sourceKeyDef = "projectData" },
            }},
            -- BuildLayer_ASrv
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_construction", serviceName = "BuildLayer_ASrv" }, stepDataDef = {
                { keyDef = "startpoint"                     , sourceStep = 0, sourceKeyDef = "startpoint" },
                { keyDef = "buildFromAbove"                 , sourceStep = 0, sourceKeyDef = "buildFromAbove" },
                { keyDef = "layer"                          , sourceStep = 0, sourceKeyDef = "layer" },
                { keyDef = "materialsItemSupplierLocator"   , sourceStep = 1, sourceKeyDef = "chestLocator" },
                { keyDef = "wasteItemDepotLocator"          , sourceStep = 1, sourceKeyDef = "chestLocator" },
            }},
            -- cleanup
            { stepType = "LSOSrv", stepTypeDef = { serviceName = "releaseMObj_SSrv", locatorStep = 0, locatorKeyDef = "hostLocator" }, stepDataDef = {
                { keyDef = "mobjLocator"                    , sourceStep = 1, sourceKeyDef = "chestLocator" },
            }},
        },
        returnData  = {
        }
    }
    local projectServiceData = {
        projectDef  = buildRectangularPattern_ASrvProjectDef,
        projectData = {
            -- chest
            projectDef  = t_chests.GetHostAndUpdateChestProjectDef(),
            projectData = {
                hostLocator         = enterprise_chests:getHostLocator(),
                className           = "Chest",
                constructParameters = {
                    baseLocation    = testStartLocation:getRelativeLocation(2, 5, 0),
                    accessDirection = "top",
                }
            },
            hostLocator = enterprise_chests:getHostLocator(),

            -- build data
            startpoint              = testStartLocation2,
            buildFromAbove          = true,
            layer                   = testBuildLayer1,
        },
        projectMeta = { title = "Test: Build Layer from Chest", description = "Building a test layer" },
    }

    -- start project
    local callback = Callback:new({
        _moduleName     = "t_main",
        _methodName     = "Func1_Callback",
        _data           = {"some callback data"},
    })
    return enterprise_projects.StartProject_ASrv(projectServiceData, callback)
end

function t_construction.T_BuildBlueprint_ASrv()
    -- prepare test
    corelog.WriteToLog("* BuildBlueprint_ASrv test")
    local testBlueprint1 = {
        layerList = {
            { startpoint = Location:new({ _x= 0, _y= 0, _z=  0}), buildFromAbove  = true, layer = testBuildLayer3:copy()},
            { startpoint = Location:new({ _x= 3, _y= 3, _z= -1}), buildFromAbove  = false, layer = testBuildLayer4:copy()},
            { startpoint = Location:new({ _x= 2, _y= 2, _z= -2}), buildFromAbove  = false, layer = testBuildLayer2:copy()},
            { startpoint = Location:new({ _x= 2, _y= 2, _z= -3}), buildFromAbove  = false, layer = testBuildLayer2:copy()}
        },
        escapeSequence = {
            Location:new({ _x= 3, _y= 3, _z=  1}),
        }
    }
    local blueprintBuildData = {
        blueprintStartpoint         = testStartLocation:getRelativeLocation(0, 12, 0),
        blueprint                   = testBlueprint1,
        materialsItemSupplierLocator= t_turtle.GetCurrentTurtleLocator(),
        wasteItemDepotLocator       = t_turtle.GetCurrentTurtleLocator(),
    }
    local callback = Callback:new({
        _moduleName     = "t_main",
        _methodName     = "Func1_Callback",
        _data           = {"some callback data"},
    })

    -- test
--    corelog.WriteToLog("T_construction calling BuildBlueprint_ASrv("..textutils.serialise(blueprintBuildData)..", ...)")
    enterprise_construction.BuildBlueprint_ASrv(blueprintBuildData, callback)

    -- cleanup test
end

return t_construction