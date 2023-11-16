-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local ILObj = require "i_lobj"
local IMObj = require "i_mobj"
local IWorker = require "i_worker"
local DisplayStation = Class.NewClass(ObjBase, ILObj, IMObj, IWorker)

--[[
    The DisplayStation Worker represents a station in the minecraft world and provides (production) services for developers to operate on that DisplayStation.

    A DisplayStation has at least 2 displays (consisting of minecraft monitors) attached. The main menu of the DisplayStation should at a minimum enable
    selecting what content is displayed on each of those displays.

    For seen content to display on the displays
        1)  Logging
        2)  Worker overview
        3)  Projects
        4)  Assignments (open, staffed, ...)
        5)  Inventory on stock
        6)  mobj's overview
--]]

local coreevent = require "coreevent"
local coretask = require "coretask"
local coredht = require "coredht"
local coredisplay = require "coredisplay"
local corelog = require "corelog"

local InputChecker = require "input_checker"
local Callback = require "obj_callback"
local ObjTable = require "obj_table"
local Block = require "obj_block"
local Location = require "obj_location"
local CodeMap = require "obj_code_map"
local LayerRectangle = require "obj_layer_rectangle"

local role_conservator = require "role_conservator"

local enterprise_chests = require "enterprise_chests"
local enterprise_shop = require "enterprise_shop"
local enterprise_employment

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

-- ToDo: add initialising additional fields here (like e.g. what to display on which display)
function DisplayStation:_init(...)
    -- get & check input from description
    local checkSuccess, workerId, isActive, baseLocation = InputChecker.Check([[
        Initialise a DisplayStation.

        Parameters:
            workerId                + (number) workerId of the DisplayStation
            isActive                + (boolean) whether the DisplayStation is active
            baseLocation            + (Location) base location of the DisplayStation
    ]], ...)
    if not checkSuccess then corelog.Error("DisplayStation:_init: Invalid input") return nil end

    -- initialisation
    ObjBase._init(self)
    self._workerId          = workerId
    self._isActive          = isActive
    self._baseLocation      = baseLocation
end

-- ToDo: add the same additional fields here in a similair way
function DisplayStation:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a DisplayStation.

        Parameters:
            o                           + (table, {}) with object fields
                _workerId               - (number) workerId of the DisplayStation
                _isActive               - (boolean, false) whether the DisplayStation is active
                _baseLocation           - (Location) location of the DisplayStation
    ]], ...)
    if not checkSuccess then corelog.Error("DisplayStation:new: Invalid input") return nil end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- end
    return o
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function DisplayStation:getClassName()
    return "DisplayStation"
end

--    _____ _      ____  _     _
--   |_   _| |    / __ \| |   (_)
--     | | | |   | |  | | |__  _
--     | | | |   | |  | | '_ \| |
--    _| |_| |___| |__| | |_) | |
--   |_____|______\____/|_.__/| |
--                           _/ |
--                          |__/

function DisplayStation:construct(...)
    -- get & check input from description
    local checkSuccess, workerId, baseLocation = InputChecker.Check([[
        This method constructs a DisplayStation instance from a table of parameters with all necessary fields (in an objectTable) and methods (by setmetatable) as defined in the class.

        The constructed DisplayStation is not yet saved in the MObjHost.

        Return value:
                                        - (DisplayStation) the constructed DisplayStation

        Parameters:
            constructParameters         - (table) parameters for constructing the DisplayStation
                workerId                + (number) workerId of the DisplayStation
                baseLocation            + (Location) base location of the DisplayStation
    ]], ...)
    if not checkSuccess then corelog.Error("DisplayStation:construct: Invalid input") return nil end

    -- determine DisplayStation fields
    -- ToDo: add default values for additional fields here (like e.g. what to display on which display). Possibly them to constructParameters if you want to set defaults from a master/ world script later

    -- construct new DisplayStation
    local obj = DisplayStation:newInstance(workerId, false, baseLocation:copy()) -- ToDo: pass additional fields in here

    -- end
    return obj
end

function DisplayStation:destruct()
    --[[
        This method destructs a DisplayStation instance.

        The DisplayStation is not yet deleted from the MObjHost.

        Return value:
                                        - (boolean) whether the DisplayStation was succesfully destructed.

        Parameters:
    ]]

    -- release input/output locators
    local destructSuccess = true

    -- end
    return destructSuccess
end

function DisplayStation:getId()
    return tostring(self._workerId)
end

function DisplayStation:getWIPId()
    --[[
        Returns the unique Id of the DisplayStation used for administering WIP.
    ]]

    return self:getClassName().." "..self:getId()
end

--    _____ __  __  ____  _     _
--   |_   _|  \/  |/ __ \| |   (_)
--     | | | \  / | |  | | |__  _
--     | | | |\/| | |  | | '_ \| |
--    _| |_| |  | | |__| | |_) | |
--   |_____|_|  |_|\____/|_.__/| |
--                            _/ |
--                           |__/

function DisplayStation:getBaseLocation() return self._baseLocation end

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

local function ComputerDismantle_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        CodeMap:newInstance({
            [1] = " ",
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

function DisplayStation.GetBuildBlueprint(...)
    -- get & check input from description
    local checkSuccess, baseLocation = InputChecker.Check([[
        This method returns a blueprint for building a DisplayStation in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
            constructParameters         - (table) parameters for constructing the DisplayStation
                baseLocation            + (Location) base location of the DisplayStation
    ]], ...)
    if not checkSuccess then corelog.Error("DisplayStation.GetBuildBlueprint: Invalid input") return nil, nil end

    -- layer list
    local layerList = {
        { startpoint = Location:newInstance(3, 3, 2), buildDirection = "Down", layer = Computer_layer()},
    }
    for i=7,2,-1 do
        table.insert(layerList, { startpoint = Location:newInstance(-5, 3, i), buildDirection = "Front", layer = Monitor_Only_layer()})
    end
    table.insert(layerList, { startpoint = Location:newInstance(3, 2, 2), buildDirection = "Front", layer = Modem_layer()})

    -- escapeSequence
    local escapeSequence = {}

    -- blueprint
    local blueprint = {
        layerList = layerList,
        escapeSequence = escapeSequence,
    }

    -- buildLocation
    local buildLocation = baseLocation:copy()

    -- end
    return buildLocation, blueprint
end

function DisplayStation:getDismantleBlueprint()
    --[[
        This method returns a blueprint for dismantling the DisplayStation in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
    ]]

    -- layerList
    local layerList = {
        { startpoint = Location:newInstance(3, 2, 2), buildDirection = "Down", layer = ModemDismantle_layer()},
        { startpoint = Location:newInstance(-5, 3, 0), buildDirection = "Front", layer = Dismantle_layer()},
        { startpoint = Location:newInstance(3, 3, 0), buildDirection = "Down", layer = ComputerDismantle_layer()},
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

function DisplayStation:getWorkerId()
    --[[
        Get the DisplayStation workerId.

        Return value:
                                - (number) the DisplayStation workerId
    ]]

    -- end
    return self._workerId
end

local subject = "input Chest timer"

-- ToDo: here you could add timers for this specific DisplayStation if you thick that is a good idea (e.g. to ping other Workers to log them in Worker overview)
-- ToDo: note: commented code is how it is currently done in the UserStation
-- ToDo: note: alternative is to implement it using reocurring assignment
function DisplayStation:activate()
    -- check current Worker
    if self:getWorkerId() ~= os.getComputerID() then
        corelog.Warning("DisplayStation:activate() not supported on DisplayStation(="..self:getWorkerId()..") from other computer(="..os.getComputerID()..") => not adding event")
    else
        -- setup timer for input Chest checking
        -- coreevent.AddEventListener(DisplayStation.DoEventInputChestTimer, "mobj_user_station", subject)

        -- check input box for the first time!
        -- DisplayStation.DoEventInputChestTimer(subject, self:getOutputLocator())
    end

    -- set active
    self._isActive = true

    -- end
    return self:isActive()
end

-- function DisplayStation.DoEventInputChestTimer(_, outputLocator)
--     -- add the work, the real stuff
--     coretask.AddWork(role_conservator.CheckOutputChest, outputLocator)

--     -- create new event
--     coreevent.CreateTimeEvent(20 * 15, "mobj_user_station", subject, outputLocator)
-- end

function DisplayStation:deactivate()
    -- check current Worker
    if self:getWorkerId() ~= os.getComputerID() then
        corelog.Warning("DisplayStation:deactivate() not supported on DisplayStation(="..self:getWorkerId()..") from other computer(="..os.getComputerID()..") => not removing event")
    else
        -- remove timer
        -- coreevent.RemoveEventListener("mobj_user_station", subject)
    end

    -- set deactive
    self._isActive = false

    -- end
    return not self:isActive()
end

function DisplayStation:isActive()
    return self._isActive == true
end

function DisplayStation:getWorkerLocation()
    return self:getBaseLocation():getRelativeLocation(3, 3, 2) -- note: location of DisplayStation computer relative to this DisplayStation baseLocation
end

function DisplayStation:getWorkerResume()
    --[[
        Get DisplayStation resume for selecting Assignment's.

        The resume gives information on the DisplayStation and is used to determine if the DisplayStation is (best) suitable to take an Assignment.
            This is can e.g. be used to indicate location, fuel level and equiped items.

        Return value:
            resume              - (table) DisplayStation "resume" to consider in selecting Assignment's
    --]]

    -- end
    return {
        workerId        = self:getWorkerId(),
        location        = self:getWorkerLocation(),
    }
end

local function DisplayStationMenu(t, searchString)
    --
    local displayStation = t.displayStation -- note a way to pass the concrete DisplayStation instance to this function if you think you need it
end

-- ToDo: this is the hook to put the menu of the DisplayStation
function DisplayStation:getMainUIMenu()
    --[[
        Get the main (start) UI menu of the DisplayStation.

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
        func	    = DisplayStationMenu,
        intro       = "Guido: implement the specific DisplayStation menu as you would like it to be here\n",
        param	    = { displayStation = self },
        question    = nil
    }
end

-- ToDo: consider adding assigment filter criteria if you want the DisplayStation to only take specific assignments.
function DisplayStation:getAssignmentFilter()
    --[[
        Get assignment filter for finding the next best Assignment for the DisplayStation.

        The assignment filter is used to indicate to only accept assignments that satisfy certain conditions. This can e.g. be used
            to only accept assignments that are ment for this DisplayStation (i..e workerId) or only those with high priority.

        Return value:
            assignmentFilter    - (table) filter to apply in finding an Assignment
    --]]

    -- end
    return {
    }
end

return DisplayStation
