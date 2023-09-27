-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local IMObj = require "i_mobj"
local UtilStation = Class.NewClass(ObjBase, IMObj)

--[[
    The UtilStation mobj represents a util station in the minecraft world and provides (production) services to operate on that UtilStation.

    There are (currently) two services
        logger screens
        item input and output chests
--]]

local corelog = require "corelog"
local coreutils = require "coreutils"

local ObjArray = require "obj_array"
local InputChecker = require "input_checker"
local Callback = require "obj_callback"
local TaskCall = require "obj_task_call"
local ObjTable = require "obj_table"
local Location = require "obj_location"
local Block = require "obj_block"
local CodeMap = require "obj_code_map"
local LayerRectangle = require "obj_layer_rectangle"

local ProductionSpot = require "mobj_production_spot"

local role_alchemist = require "role_alchemist"
local role_fuel_worker = require "role_fuel_worker"

local enterprise_projects = require "enterprise_projects"
local enterprise_isp = require "enterprise_isp"
local enterprise_turtle = require "enterprise_turtle"
local enterprise_assignmentboard = require "enterprise_assignmentboard"
local enterprise_chests = require "enterprise_chests"
local enterprise_energy = require "enterprise_energy"
local enterprise_manufacturing

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function UtilStation:_init(...)
    -- get & check input from description
    local checkSuccess, id, baseLocation = InputChecker.Check([[
        Initialise a UtilStation.

        Parameters:
            id                      + (string) id of the UtilStation
            baseLocation            + (Location) base location of the UtilStation
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("UtilStation:_init: Invalid input") return nil end

    -- initialisation
    ObjBase._init(self)
    self._id                = id
    self._baseLocation      = baseLocation
end

-- ToDo: should be renamed to newFromTable at some point
function UtilStation:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a UtilStation.

        Parameters:
            o                           + (table, {}) with object fields
                _id                     - (string) id of the UtilStation
                _baseLocation           - (Location) location of the UtilStation
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("UtilStation:new: Invalid input") return nil end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- end
    return o
end

function UtilStation:getBaseLocation()
    return self._baseLocation
end

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

function UtilStation:getClassName()
    return "UtilStation"
end

--    _____ __  __  ____  _     _                  _   _               _
--   |_   _|  \/  |/ __ \| |   (_)                | | | |             | |
--     | | | \  / | |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | | | |\/| | |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| |_| |  | | |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____|_|  |_|\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                            _/ |
--                           |__/

function UtilStation:construct(...)
    -- get & check input from description
    local checkSuccess, baseLocation = InputChecker.Check([[
        This method constructs a UtilStation instance from a table of parameters with all necessary fields (in an objectTable) and methods (by setmetatable) as defined in the class.

        It also ensures all child MObj's the UtilStation spawns are hosted on the appropriate MObjHost (by calling hostMObj_SSrv).

        The constructed UtilStation is not yet saved in the Host.

        Return value:
                                        - (UtilStation) the constructed UtilStation

        Parameters:
            constructParameters         - (table) parameters for constructing the UtilStation
                baseLocation            + (Location) base location of the UtilStation
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("UtilStation:construct: Invalid input") return nil end

    -- determine UtilStation fields
    local id = coreutils.NewId()

    -- construct new UtilStation
    local obj = UtilStation:newInstance(id, baseLocation:copy())

    -- end
    return obj
end

function UtilStation:destruct()
    --[[
        This method destructs a UtilStation instance.

        It also ensures all child MObj's the UtilStation is the parent of are released from the appropriate MObjHost (by calling releaseMObj_SSrv).

        The UtilStation is not yet deleted from the Host.

        Return value:
                                        - (boolean) whether the UtilStation was succesfully destructed.

        Parameters:
    ]]

    -- end
    return true
end

function UtilStation:getId()
    return self._id
end

function UtilStation:getWIPId()
    --[[
        Returns the unique Id of the UtilStation used for administering WIP.
    ]]

    return self:getClassName().." "..self:getId()
end

local blockClassName = "Block"
local function Chest_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(blockClassName, {
            ["C"]   = Block:newInstance("minecraft:chest"),
            [" "]   = Block:newInstance(Block.AnyBlockName()),
        }),
        CodeMap:newInstance({
            [1] = "C C",
        })
    )
end

local function Computer_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(blockClassName, {
            ["C"]   = Block:newInstance("computercraft:computer_normal", 0, -1),
        }),
        CodeMap:newInstance({
            [1] = "C",
        })
    )
end

local function Modem_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(blockClassName, {
            ["M"]   = Block:newInstance("computercraft:wireless_modem_normal"),
        }),
        CodeMap:newInstance({
            [1] = "M",
        })
    )
end

local function Monitor_Only_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(blockClassName, {
            ["M"]   = Block:newInstance("computercraft:monitor_normal"),
            [" "]   = Block:newInstance(Block.AnyBlockName()),
        }),
        CodeMap:newInstance({
            [1] = "MMMMMMMM MMMMMMMM",
        })
    )
end

-- ToDo blueprint does not work because is needs to be build from the front, which is something the builder does not yet support.
function UtilStation:getBuildBlueprint()
    --[[
        This method returns a blueprint for building the UtilStation in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
    ]]

    -- construct layer list

    corelog.Warning("UtilStation:getBuildBlueprint(): blueprint does not work because is needs to be build from the front, which is something the builder does not yet support.")
    local layerList = {
    --     { startpoint = Location:newInstance(8, 3, 0), buildFromAbove = true, layer = Chest_layer()},
    --     { startpoint = Location:newInstance(9, 3, 0), buildFromAbove = true, layer = Computer_layer()},
    --     { startpoint = Location:newInstance(9, 2, 0), buildFromAbove = true, layer = Modem_layer()},
    --     { startpoint = Location:newInstance(9, 3, 2), buildFromAbove = true, layer = Computer_layer()},
    --     { startpoint = Location:newInstance(9, 2, 2), buildFromAbove = true, layer = Modem_layer()},
    }
    -- for i=2,8 do
    --     table.insert(layerList, { startpoint = Location:newInstance(1, 3, i), buildFromAbove = true, layer = Monitor_Only_layer()})
    -- end

    -- determine escapeSequence
    local escapeSequence = {}

    -- determine blueprint
    local blueprint = {
        layerList = layerList,
        escapeSequence = escapeSequence,
    }

    -- determine buildLocation
    local buildLocation = self._baseLocation:copy()

    -- end
    return buildLocation, blueprint
end

function UtilStation:getDismantleBlueprint()
    --[[
        This method returns a blueprint for dismantling the UtilStation in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
    ]]

    -- not implemented ToDo
    corelog.Warning("UtilStation:getDismantleBlueprint(): Don't know how to make a dismantle blueprint for a UtilStation, we returned an empty blueprint (we so nauty)")

    -- determine layerList
    local layerList = {}

    -- determine escapeSequence
    local escapeSequence = {}

    -- determine blueprint
    local blueprint = {
        layerList = layerList,
        escapeSequence = escapeSequence
    }

    -- determine buildLocation
    local buildLocation = self._baseLocation:copy()

    -- end
    return buildLocation, blueprint
end

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

return UtilStation
