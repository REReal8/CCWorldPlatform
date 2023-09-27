-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local IMObj = require "i_mobj"
local IItemDepot = require "i_item_depot"
local UtilStation = Class.NewClass(ObjBase, IMObj, IItemDepot)

--[[
    The UtilStation mobj represents a util station in the minecraft world and provides (production) services to operate on that UtilStation.

    There are (currently) two services
        logger screens
        item input and output chests
--]]

local corelog = require "corelog"
local coreutils = require "coreutils"

local InputChecker = require "input_checker"
local Callback = require "obj_callback"
local ObjTable = require "obj_table"
local Block = require "obj_block"
local CodeMap = require "obj_code_map"
local LayerRectangle = require "obj_layer_rectangle"

local enterprise_chests = require "enterprise_chests"

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function UtilStation:_init(...)
    -- get & check input from description
    local checkSuccess, id, baseLocation, outputLocator = InputChecker.Check([[
        Initialise a UtilStation.

        Parameters:
            id                      + (string) id of the UtilStation
            baseLocation            + (Location) base location of the UtilStation
            outputLocator           + (URL) output chest of the UtilStation
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("UtilStation:_init: Invalid input") return nil end

    -- initialisation
    ObjBase._init(self)
    self._id                = id
    self._baseLocation      = baseLocation
    self._outputLocator     = outputLocator
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
                _outputLocator          - (URL) output chest of the UtilStation
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

function UtilStation:getOutputLocator()
    return self._outputLocator
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
    local outputLocator = enterprise_chests:hostMObj_SSrv({ className = "Chest", constructParameters = {
        baseLocation    = baseLocation:getRelativeLocation(2, 3, 0),
        accessDirection = "top",
    }}).mobjLocator

    -- construct new UtilStation
    local obj = UtilStation:newInstance(id, baseLocation:copy(), outputLocator)

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

    -- release outputLocator
    local destructSuccess = true
    local outputLocator = self._outputLocator
    local hostName = outputLocator:getHost()
    if hostName == enterprise_chests:getHostName() then
        local releaseResult = enterprise_chests:releaseMObj_SSrv({ mobjLocator = outputLocator })
        if not releaseResult or not releaseResult.success then corelog.Warning("UtilStation:destruct(): failed releasing output locator "..outputLocator:getURI()) destructSuccess = false end
    end
    self._outputLocator = nil

    -- end
    return destructSuccess
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

--    _____ _____ _                 _____                   _                    _   _               _
--   |_   _|_   _| |               |  __ \                 | |                  | | | |             | |
--     | |   | | | |_ ___ _ __ ___ | |  | | ___ _ __   ___ | |_   _ __ ___   ___| |_| |__   ___   __| |___
--     | |   | | | __/ _ \ '_ ` _ \| |  | |/ _ \ '_ \ / _ \| __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| |_ _| |_| ||  __/ | | | | | |__| |  __/ |_) | (_) | |_  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____|_____|\__\___|_| |_| |_|_____/ \___| .__/ \___/ \__| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                                             | |
--                                             |_|

function UtilStation:storeItemsFrom_AOSrv(...)
    -- get & check input from description
    local checkSuccess, itemsLocator, assignmentsPriorityKey, callback = InputChecker.Check([[
        This async public ItemDepot service stores items from an ItemSupplier.

        An ItemDepot should take special care the transfer from the turtle inventory gets priority over other assignments to the turtle.

        Return value:
                                        - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                        - (table)
                success                 - (boolean) whether the service executed successfully
                destinationItemsLocator - (URL) stating the final ItemDepot and the items that where stored
                                            (upon service succes the "base" component of this URL should be equal to itemDepotLocator
                                            and the "query" should be equal to the "query" component of the itemsLocator)

        Parameters:
            serviceData                 - (table) data about the service
                itemsLocator            + (URL) locating the items to store
                                            (the "base" component of the URL specifies the ItemSupplier that provides the items)
                                            (the "query" component of the URL specifies the items)
                assignmentsPriorityKey  + (string, "") priorityKey that should be set for all assignments triggered by this service
            callback                    + (Callback) to call once service is ready
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("UtilStation:storeItemsFrom_AOSrv: Invalid input") return Callback.ErrorCall(callback) end

    -- get output chest
    local outputChest = enterprise_chests:getObject(self._outputLocator)
    if not outputChest then corelog.Error("UtilStation:storeItemsFrom_AOSrv: Failed getting outputChest object") return Callback.ErrorCall(callback) end

    -- pass to output chest
    return outputChest:storeItemsFrom_AOSrv(table.unpack(arg))
end

function UtilStation:can_StoreItems_QOSrv(...)
    -- get & check input from description
    local checkSuccess, itemsLocator = InputChecker.Check([[
        This sync public query service answers the question whether the ItemDepot can store specific items.

        Return value:
                                    - (table)
                success             - (boolean) whether the answer to the question is true

        Parameters:
            serviceData             - (table) data to the query
                itemsLocator        + (URL) locating the items that need to be stored
                                        (the "base" component of the URL specifies the ItemDepot to store the items in)
                                        (the "query" component of the URL specifies the items to query for)
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("UtilStation:can_StoreItems_QOSrv: Invalid input") return {success = false} end

    -- get output chest
    local outputChest = enterprise_chests:getObject(self._outputLocator)
    if not outputChest then corelog.Error("UtilStation:can_StoreItems_QOSrv: Failed getting outputChest object") return {success = false} end

    -- pass to output chest
    return outputChest:can_StoreItems_QOSrv(table.unpack(arg))
end

function UtilStation:needsTo_StoreItemsFrom_SOSrv(...)
    -- get & check input from description
    local checkSuccess, itemsLocator = InputChecker.Check([[
        This sync public service returns the needs to store specific items from an ItemSupplier.

        Return value:
                                                - (table)
                success                         - (boolean) whether the service executed correctly
                fuelNeed                        - (number) amount of fuel needed to store items

        Parameters:
            serviceData                         - (table) data to the query
                itemsLocator                    + (URL) locating the items to store
                                                    (the "base" component of the URL specifies the ItemSupplier that provides the items)
                                                    (the "query" component of the URL specifies the items)
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("UtilStation:needsTo_StoreItemsFrom_SOSrv: Invalid input") return {success = false} end

    -- get output chest
    local outputChest = enterprise_chests:getObject(self._outputLocator)
    if not outputChest then corelog.Error("UtilStation:needsTo_StoreItemsFrom_SOSrv: Failed getting outputChest object") return {success = false} end

    -- pass to output chest
    return outputChest:needsTo_StoreItemsFrom_SOSrv(table.unpack(arg))
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
