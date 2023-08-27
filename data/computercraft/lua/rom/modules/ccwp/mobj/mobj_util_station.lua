-- define module
local UtilStation = {}
-- ToDo: consider making this a class (inherting from at least ObjBase)

-- ToDo: add proper description here
--[[
    The UtilStation ...
--]]

local coreutils         = require "coreutils"
local corelog           = require "corelog"
local coredht           = require "coredht"

local Location          = require "obj_location"
local Block             = require "obj_block"
local ObjTable = require "obj_table"
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
local blockClassName = "Block"
local function Chest_layer()
    return LayerRectangle:new({
        _codeTable  = ObjTable:newInstance(blockClassName, {
            ["C"]   = Block:newInstance("minecraft:chest"),
            [" "]   = Block:newInstance(Block.AnyBlockName()),
        }),
        _codeMap    = {
            [1] = "C C",
        },
    })
end

local function Computer_layer()
    return LayerRectangle:new({
        _codeTable  = ObjTable:newInstance(blockClassName, {
            ["C"]   = Block:newInstance("computercraft:computer_normal", 0, -1),
        }),
        _codeMap    = {
            [1] = "C",
        },
    })
end

local function Modem_layer()
    return LayerRectangle:new({
        _codeTable  = ObjTable:newInstance(blockClassName, {
            ["M"]   = Block:newInstance("computercraft:wireless_modem_normal"),
        }),
        _codeMap    = {
            [1] = "M",
        },
    })
end

local function Monitor_Only_layer()
    return LayerRectangle:new({
        _codeTable  = ObjTable:newInstance(blockClassName, {
            ["M"]   = Block:newInstance("computercraft:monitor_normal"),
            [" "]   = Block:newInstance(Block.AnyBlockName()),
        }),
        _codeMap    = {
            [1] = "MMMMMMMM MMMMMMMM",
        },
    })
end

function UtilStation.GetV1SiteBuildData(serviceData)
    if type(serviceData)                ~= "table" then serviceData = {} end
    if type(serviceData.baseLocation)   ~= "tabel" then serviceData.baseLocation = Location:newInstance(-12, -12, 1, 0, 1) end

    -- construct layer list
    local layerList = {
        { startpoint = Location:newInstance(8, 3, 0), buildFromAbove = true, layer = Chest_layer()},
        { startpoint = Location:newInstance(9, 3, 0), buildFromAbove = true, layer = Computer_layer()},
        { startpoint = Location:newInstance(9, 2, 0), buildFromAbove = true, layer = Modem_layer()},
        { startpoint = Location:newInstance(9, 3, 2), buildFromAbove = true, layer = Computer_layer()},
        { startpoint = Location:newInstance(9, 2, 2), buildFromAbove = true, layer = Modem_layer()},
    }
    for i=2,8 do
        table.insert(layerList, { startpoint = Location:newInstance(1, 3, i), buildFromAbove = true, layer = Monitor_Only_layer()})
    end



    -- compose da blueprint
    local blueprint = {
        layerList = layerList,
        escapeSequence = { Location:newInstance(9, 5, 0) }
    }

    -- return build data
    return {
        blueprintStartpoint = serviceData.baseLocation:copy(),
        blueprint = blueprint
    }
end

return UtilStation