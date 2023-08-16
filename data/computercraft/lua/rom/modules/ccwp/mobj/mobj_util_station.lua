local UtilStation = {}

local coreutils         = require "coreutils"
local corelog           = require "corelog"
local coredht           = require "coredht"

local Location          = require "obj_location"
local Block             = require "obj_block"
local LayerRectangle    = require "obj_layer_rectangle"

local db = {
    dhtRoot             = "utility_station",
}
--[[
local function RunLogger()
    -- keep track of what's happening
    coreutils.WriteToLog('We are usefull, we are logger!')
end

local function RunItemInterface()
    -- keep track of what's happening
    coreutils.WriteToLog('We are usefull, we are the item interface!')
end

function UtilStation.Run()
    local myId = os.getComputerID()
    local USdata = coredht.GetData(db.dhtRoot)

    -- to be sure
    if type(USdata) ~= "table" then USdata = {} end

    -- am I usefull?
    if myId == USdata.logger        then RunLogger() end
    if myId == USdata.itemInterface then RunItemInterface() end
end
--]]
local function Chest_layer()
    return LayerRectangle:new({
        _codeArray  = {
            ["C"]   = Block:new({ _name = "minecraft:chest" }),
            [" "]   = Block:new({ _name = Block.AnyBlockName() }),
        },
        _codeMap    = {
            [1] = "C C",
        },
    })
end

local function Computer_layer()
    return LayerRectangle:new({
        _codeArray  = {
            ["C"]   = Block:new({ _name = "computercraft:computer_normal", _dx =0, _dy = -1 }),
        },
        _codeMap    = {
            [1] = "C",
        },
    })
end

local function Modem_layer()
    return LayerRectangle:new({
        _codeArray  = {
            ["M"]   = Block:new({ _name = "computercraft:wireless_modem_normal" }),
        },
        _codeMap    = {
            [1] = "M",
        },
    })
end

local function Monitor_Only_layer()
    return LayerRectangle:new({
        _codeArray  = {
            ["M"]   = Block:new({ _name = "computercraft:monitor_normal" }),
            [" "]   = Block:new({ _name = Block.AnyBlockName() }),
        },
        _codeMap    = {
            [1] = "MMMMMMMM MMMMMMMM",
        },
    })
end

function UtilStation.GetV1SiteBuildData(serviceData)
    if type(serviceData)                ~= "table" then serviceData = {} end
    if type(serviceData.baseLocation)   ~= "tabel" then serviceData.baseLocation = Location:new({_y = -12, _x = -12, _z = 1, _dx = 0, _dy = 1}) end

    -- construct layer list
    local layerList = {
        { startpoint = Location:new({ _x= 8, _y= 3, _z= 0}), buildFromAbove = true, layer = Chest_layer()},
        { startpoint = Location:new({ _x= 9, _y= 3, _z= 0}), buildFromAbove = true, layer = Computer_layer()},
        { startpoint = Location:new({ _x= 9, _y= 2, _z= 0}), buildFromAbove = true, layer = Modem_layer()},
        { startpoint = Location:new({ _x= 9, _y= 3, _z= 2}), buildFromAbove = true, layer = Computer_layer()},
        { startpoint = Location:new({ _x= 9, _y= 2, _z= 2}), buildFromAbove = true, layer = Modem_layer()},
    }
    for i=2,8 do
        table.insert(layerList, { startpoint = Location:new({ _x= 1, _y= 3, _z= i}), buildFromAbove = true, layer = Monitor_Only_layer()})
    end



    -- compose da blueprint
    local blueprint = {
        layerList = layerList,
        escapeSequence = { Location:new({ _x= 9, _y= 5, _z= 0}) }
    }

    -- return build data
    return {
        blueprintStartpoint = serviceData.baseLocation:copy(),
        blueprint = blueprint
    }
end

return UtilStation