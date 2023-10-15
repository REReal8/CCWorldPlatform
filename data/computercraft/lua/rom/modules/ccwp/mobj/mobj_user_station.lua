-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local IMObj = require "i_mobj"
local IWorker = require "i_worker"
local IItemDepot = require "i_item_depot"
local UserStation = Class.NewClass(ObjBase, IMObj, IWorker, IItemDepot)

--[[
    The UserStation mobj represents a util station in the minecraft world and provides (production) services to operate on that UserStation.

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
local Location = require "obj_location"
local CodeMap = require "obj_code_map"
local LayerRectangle = require "obj_layer_rectangle"

local enterprise_chests = require "enterprise_chests"

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function UserStation:_init(...)
    -- get & check input from description
    local checkSuccess, workerId, baseLocation, inputLocator, outputLocator = InputChecker.Check([[
        Initialise a UserStation.

        Parameters:
            workerId                + (number) workerId of the UserStation
            baseLocation            + (Location) base location of the UserStation
            inputLocator            + (URL) input  chest of the UserStation (where items will be picked up from)
            outputLocator           + (URL) output chest of the UserStation (where items will be delivered)
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("UserStation:_init: Invalid input") return nil end

    -- initialisation
    ObjBase._init(self)
    self._workerId          = workerId
    self._baseLocation      = baseLocation
    self._inputLocator      = inputLocator
    self._outputLocator     = outputLocator
end

-- ToDo: should be renamed to newFromTable at some point
function UserStation:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a UserStation.

        Parameters:
            o                           + (table, {}) with object fields
                _workerId               + (number) workerId of the UserStation
                _baseLocation           - (Location) location of the UserStation
                _inputLocator           - (URL) input chest of the UserStation
                _outputLocator          - (URL) output chest of the UserStation
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("UserStation:new: Invalid input") return nil end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- end
    return o
end

-- ToDo: remove getBaseLocation
function UserStation:getBaseLocation()  return self._baseLocation   end
function UserStation:getLocation()  return self._baseLocation   end
function UserStation:getInputLocator()  return self._inputLocator   end
function UserStation:getOutputLocator() return self._outputLocator  end

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

function UserStation:getClassName()
    return "UserStation"
end

--    _____ __  __  ____  _     _
--   |_   _|  \/  |/ __ \| |   (_)
--     | | | \  / | |  | | |__  _
--     | | | |\/| | |  | | '_ \| |
--    _| |_| |  | | |__| | |_) | |
--   |_____|_|  |_|\____/|_.__/| |
--                            _/ |
--                           |__/

function UserStation:construct(...)
    -- get & check input from description
    local checkSuccess, workerId, baseLocation = InputChecker.Check([[
        This method constructs a UserStation instance from a table of parameters with all necessary fields (in an objectTable) and methods (by setmetatable) as defined in the class.

        It also ensures all child MObj's the UserStation spawns are hosted on the appropriate MObjHost (by calling hostMObj_SSrv).

        The constructed UserStation is not yet saved in the MObjHost.

        Return value:
                                        - (UserStation) the constructed UserStation

        Parameters:
            constructParameters         - (table) parameters for constructing the UserStation
                workerId                + (number) workerId of the UserStation
                baseLocation            + (Location) base location of the UserStation
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("UserStation:construct: Invalid input") return nil end

    -- determine UserStation fields
    local inputLocator = enterprise_chests:hostMObj_SSrv({className = "Chest", constructParameters = {
        baseLocation    = baseLocation:getRelativeLocation(4, 3, 0),
        accessDirection = "top",
    }}).mobjLocator
    local outputLocator = enterprise_chests:hostMObj_SSrv({className = "Chest", constructParameters = {
        baseLocation    = baseLocation:getRelativeLocation(2, 3, 0),
        accessDirection = "top",
    }}).mobjLocator

    -- construct new UserStation
    local obj = UserStation:newInstance(workerId, baseLocation:copy(), inputLocator, outputLocator)

    -- end
    return obj
end

function UserStation:destruct()
    --[[
        This method destructs a UserStation instance.

        It also ensures all child MObj's the UserStation is the parent of are released from the appropriate MObjHost (by calling releaseMObj_SSrv).

        The UserStation is not yet deleted from the MObjHost.

        Return value:
                                        - (boolean) whether the UserStation was succesfully destructed.

        Parameters:
    ]]

    -- release input/output locators
    local destructSuccess = true

    -- input locator
    if self._inputLocator:getHost() == enterprise_chests:getHostName() then
        local releaseResult = enterprise_chests:releaseMObj_SSrv({ mobjLocator = self._inputLocator })
        if not releaseResult or not releaseResult.success then corelog.Warning("UserStation:destruct(): failed releasing input locator "..self._inputLocator:getURI()) destructSuccess = false end
    end
    self._inputLocator = nil

    -- output locator
    if self._outputLocator:getHost() == enterprise_chests:getHostName() then
        local releaseResult = enterprise_chests:releaseMObj_SSrv({ mobjLocator = self._outputLocator })
        if not releaseResult or not releaseResult.success then corelog.Warning("UserStation:destruct(): failed releasing output locator "..self._outputLocator:getURI()) destructSuccess = false end
    end
    self._outputLocator = nil

    -- end
    return destructSuccess
end

function UserStation:getId()
    return tostring(self._workerId)
end

function UserStation:getWIPId()
    --[[
        Returns the unique Id of the UserStation used for administering WIP.
    ]]

    return self:getClassName().." "..self:getId()
end

local function Chest_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            ["C"]   = Block:newInstance("minecraft:chest", 0, -1),
            ["?"]   = Block:newInstance(Block.AnyBlockName()),
        }),
        CodeMap:newInstance({
            [1] = "C?C",
        })
    )
end

local function Computer_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            ["C"]   = Block:newInstance("computercraft:computer_normal", 0, -1),
        }),
        CodeMap:newInstance({
            [1] = "C",
        })
    )
end

local function Modem_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            ["M"]   = Block:newInstance("computercraft:wireless_modem_normal"),
        }),
        CodeMap:newInstance({
            [1] = "M",
        })
    )
end

local function ModemDismantle_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        CodeMap:newInstance({
            [1] = " ",
        })
    )
end

local function Monitor_Only_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            ["M"]   = Block:newInstance("computercraft:monitor_normal"),
            ["?"]   = Block:newInstance(Block.AnyBlockName()),
        }),
        CodeMap:newInstance({
            [1] = "MMMMMMMM?MMMMMMMM",
        })
    )
end

local function Dismantle_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            [" "]   = Block:newInstance(Block.NoneBlockName()),
            ["?"]   = Block:newInstance(Block.AnyBlockName()),
        }),
        CodeMap:newInstance({
            [8] = "                 ",
            [7] = "                 ",
            [6] = "                 ",
            [5] = "                 ",
            [4] = "                 ",
            [3] = "                 ",
            [2] = "                 ",
            [1] = "???????   ???????",
        })
    )
end

function UserStation:getBuildBlueprint()
    --[[
        This method returns a blueprint for building the UserStation in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
    ]]

    -- layer list
    local layerList = {
        { startpoint = Location:newInstance(2, 3, 0), buildDirection = "Down", layer = Chest_layer()},
        { startpoint = Location:newInstance(3, 3, 0), buildDirection = "Down", layer = Computer_layer()},
        { startpoint = Location:newInstance(3, 3, 2), buildDirection = "Down", layer = Computer_layer()},
    }
    for i=7,2,-1 do
        table.insert(layerList, { startpoint = Location:newInstance(-5, 3, i), buildDirection = "Front", layer = Monitor_Only_layer()})
    end
    table.insert(layerList, { startpoint = Location:newInstance(3, 2, 0), buildDirection = "Front", layer = Modem_layer()})
    table.insert(layerList, { startpoint = Location:newInstance(3, 2, 2), buildDirection = "Front", layer = Modem_layer()})

    -- escapeSequence
    local escapeSequence = {}

    -- blueprint
    local blueprint = {
        layerList = layerList,
        escapeSequence = escapeSequence,
    }

    -- buildLocation
    local buildLocation = self._baseLocation:copy()

    -- end
    return buildLocation, blueprint
end

function UserStation:getDismantleBlueprint()
    --[[
        This method returns a blueprint for dismantling the UserStation in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
    ]]

    -- layerList
    local layerList = {
        { startpoint = Location:newInstance(3, 2, 0), buildDirection = "Down", layer = ModemDismantle_layer()},
        { startpoint = Location:newInstance(3, 2, 2), buildDirection = "Down", layer = ModemDismantle_layer()},
        { startpoint = Location:newInstance(-5, 3, 0), buildDirection = "Front", layer = Dismantle_layer()}
    }

    -- escapeSequence
    local escapeSequence = {}

    -- blueprint
    local blueprint = {
        layerList = layerList,
        escapeSequence = escapeSequence
    }

    -- buildLocation
    local buildLocation = self._baseLocation:copy()

    -- end
    return buildLocation, blueprint
end

--    _______          __        _
--   |_   _\ \        / /       | |
--     | |  \ \  /\  / /__  _ __| | _____ _ __
--     | |   \ \/  \/ / _ \| '__| |/ / _ \ '__|
--    _| |_   \  /\  / (_) | |  |   <  __/ |
--   |_____|   \/  \/ \___/|_|  |_|\_\___|_|

function UserStation:getWorkerId()
    --[[
        Get the UserStation workerId.

        Return value:
                                - (number) the UserStation workerId
    ]]

    -- end
    return self._workerId
end

function UserStation:getWorkerResume()
    --[[
        Get UserStation resume for selecting Assignment's.

        The resume gives information on the UserStation and is used to determine if the UserStation is (best) suitable to take an Assignment.
            This is can e.g. be used to indicate location, fuel level and equiped items.

        Return value:
            resume              - (table) UserStation "resume" to consider in selecting Assignment's
    --]]

    -- end
    return {
        workerId        = self:getWorkerId(),
        location        = self:getLocation(),
    }
end

function UserStation:getMainUIMenu()
    --[[
        Get the main (start) UI menu of the UserStation.

        This menu can be used in conjuction with coredisplay.MainMenu.

        Return value:
                                - (table)
                clear           - (boolean) whether or not to clear the display,
                func	        - (function) menu function to call
                param	        - (table, {}) parameter to pass to menu function
                intro           - (string) intro to print
                question        - (string, nil) final question to print
    ]]

    -- end
    return {
        clear       = true,
        func	    = UserStationMenuSearch,
        intro       = "Please type a part of an itemname to order\n",
        param	    = {},
        question    = nil
    }
end

function UserStation:getAssignmentFilter()
    --[[
        Get assignment filter for finding the next best Assignment for the UserStation.

        The assignment filter is used to indicate to only accept assignments that satisfy certain conditions. This can e.g. be used
            to only accept assignments with high priority.

        Return value:
            assignmentFilter    - (table) filter to apply in finding an Assignment
    --]]

    -- end
    return {
    }
end

--    _____ _____ _                 _____                   _
--   |_   _|_   _| |               |  __ \                 | |
--     | |   | | | |_ ___ _ __ ___ | |  | | ___ _ __   ___ | |_
--     | |   | | | __/ _ \ '_ ` _ \| |  | |/ _ \ '_ \ / _ \| __|
--    _| |_ _| |_| ||  __/ | | | | | |__| |  __/ |_) | (_) | |_
--   |_____|_____|\__\___|_| |_| |_|_____/ \___| .__/ \___/ \__|
--                                             | |
--                                             |_|

function UserStation:storeItemsFrom_AOSrv(...)
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
    if not checkSuccess then corelog.Error("UserStation:storeItemsFrom_AOSrv: Invalid input") return Callback.ErrorCall(callback) end

    -- get output chest
    local outputChest = enterprise_chests:getObject(self._outputLocator)
    if not outputChest then corelog.Error("UserStation:storeItemsFrom_AOSrv: Failed getting outputChest object") return Callback.ErrorCall(callback) end

    -- pass to output chest
    return outputChest:storeItemsFrom_AOSrv(table.unpack(arg))
end

function UserStation:can_StoreItems_QOSrv(...)
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
    if not checkSuccess then corelog.Error("UserStation:can_StoreItems_QOSrv: Invalid input") return {success = false} end

    -- get output chest
    local outputChest = enterprise_chests:getObject(self._outputLocator)
    if not outputChest then corelog.Error("UserStation:can_StoreItems_QOSrv: Failed getting outputChest object") return {success = false} end

    -- pass to output chest
    return outputChest:can_StoreItems_QOSrv(table.unpack(arg))
end

function UserStation:needsTo_StoreItemsFrom_SOSrv(...)
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
    if not checkSuccess then corelog.Error("UserStation:needsTo_StoreItemsFrom_SOSrv: Invalid input") return {success = false} end

    -- get output chest
    local outputChest = enterprise_chests:getObject(self._outputLocator)
    if not outputChest then corelog.Error("UserStation:needsTo_StoreItemsFrom_SOSrv: Failed getting outputChest object") return {success = false} end

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

return UserStation
