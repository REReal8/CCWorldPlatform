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

local coreassignment = require "coreassignment"
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

local enterprise_storage = require "enterprise_storage"
local enterprise_shop = require "enterprise_shop"
local enterprise_employment

local monitorLeft	= nil
local monitorRight	= nil
local db = {
    loggerChannel   = 65534,
    protocol        = "mobj_display_station",
	heartbeatTimer  = 100,
	status			= {},
}

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

--    _                 _
--   | |               | |
--   | | ___   ___ __ _| |
--   | |/ _ \ / __/ _` | |
--   | | (_) | (_| (_| | |
--   |_|\___/ \___\__,_|_|
--
--

local function WriteToMonitor(message, monitor)
	-- default monitor
	monitor = monitor or monitorLeft

	-- write to an attached monitor if available (usefull for a status monitor screen)
	if monitor then
		local w, h = monitor.getSize()

		-- scroll the existing stuff up
		monitor.scroll(1)

		-- write the message
		monitor.write(message)

		-- set the cursus back at the start of the line
		monitor.setCursorPos(1,h)
	end
end

local function MonitorWriteLine(message, monitor)
	local onderaan	= true
	local x, y		= monitor.getCursorPos()
	local w, h		= monitor.getSize()


	if not onderaan and y < h then
		-- where do we start?

		-- write the line
		monitor.write(message)

		-- ready for the next line
		monitor.setCursorPos(1, y + 1)

	else
		-- scroll the existing stuff up
		monitor.scroll(1)

		-- set the cursus back at the start of the line
		monitor.setCursorPos(1,h)

		-- write the message
		monitor.write(message)
	end
end

--                _     _ _
--               | |   | (_)
--    _ __  _   _| |__ | |_  ___
--   | '_ \| | | | '_ \| | |/ __|
--   | |_) | |_| | |_) | | | (__
--   | .__/ \__,_|_.__/|_|_|\___|
--   | |
--   |_|



function DisplayStation.SetStatus(group, message, subline, details)
	-- what kind are we?
	local kind = "computer"	-- default type
	if turtle   then kind = "turtle" end
	if pocket   then kind = "pocket" end
	if commands then kind = "command computer" end

	-- get us and our fuel level
	local fuelLevel = 0
	if turtle then fuelLevel = turtle.getFuelLevel() end

	-- all relevant information for the status update together
	local statusUpdate = {
		me			= os.getComputerID(),
		kind		= kind,
		fuelLevel	= fuelLevel,
		group		= group,
		message		= message,
		subline		= subline,
		details		= details
	}

	enterprise_employment = enterprise_employment or require "enterprise_employment"
	local workerLocator = enterprise_employment:getCurrentWorkerLocator() if not workerLocator then corelog.Error("corelog.SetStatus: Failed obtaining current workerLocator") return false end
    local workerObj = enterprise_employment:getObject(workerLocator) if not workerObj then corelog.Error("corelog.SetStatus: Failed obtaining Worker "..workerLocator:getURI()) return false end

	-- send to the logger (unless that's us)
	if workerObj:getClassName() == "DisplayStation" then

		-- update the status
		DisplayStation.UpdateStatus(statusUpdate)
	end

	-- not us, send the info
	coreevent.SendMessage({
		channel		= db.loggerChannel,
		protocol	= db.protocol,
		subject		= "status update",
		message		= statusUpdate})
end

function DisplayStation.UpdateStatus(statusData, monitor)
	-- which do we use?
	monitor = monitor or monitorRight

	-- make sure the status data is valid
	if type(statusData) == "table"				then
		if not statusData.me						then return end
		if type(statusData.kind)	  ~= "string"	then statusData.kind	    = "unknown kind" end
		if type(statusData.fuelLevel) ~= "number"	then statusData.fuelLevel	= 0 end
		if type(statusData.group)	  ~= "string"	then statusData.group		= "assignment" end
		if type(statusData.message)	  ~= "string"	then statusData.message		= "" end
		if type(statusData.subline)	  ~= "string"	then statusData.subline		= "" end
		if type(statusData.details)	  ~= "string"	then statusData.details		= "" end

		-- nicer
		if statusData.fuelLevel == 0 then
			if statusData.kind == "turtle"	then statusData.fuelLevel	= "empty"
											else statusData.fuelLevel	= "n/a"
			end
		end

		-- remember the status (and forget the previous status)
		if type(db.status[statusData.me]) ~= "table" then db.status[statusData.me] = {} end
		db.status[statusData.me].kind				= statusData.kind
		db.status[statusData.me].fuelLevel			= statusData.fuelLevel
		db.status[statusData.me].heartbeat			= os.clock()
		db.status[statusData.me][statusData.group]	= statusData
	end

	-- now, show this to the monitor
	monitor.clear()

	-- maybe set cursor to be sure
	monitor.setCursorPos(1, 1)

	-- here we go
	for id, data in pairs(db.status) do

		local projectStatus		= data.project or {}
		local assignmentStatus	= data.assignment or {}

		-- check for dead mates
		local deadMessage		= "DEAD "
		if os.clock() - data.heartbeat < (db.heartbeatTimer / 20) or id == os.getComputerID() then deadMessage = "" end

		-- write!
		MonitorWriteLine("", monitor)
		MonitorWriteLine(deadMessage..(data.kind or "unknown").." "..id..", fuel: "..data.fuelLevel, monitor)
		MonitorWriteLine(string.format("%-20.20s %-20.20s", projectStatus.message or "", assignmentStatus.message or ""), monitor)
		MonitorWriteLine(string.format("%-20.20s %-20.20s", projectStatus.subline or "", assignmentStatus.subline or ""), monitor)
		MonitorWriteLine(string.format("%-20.20s %-20.20s", projectStatus.details or "", assignmentStatus.details or ""), monitor)
	end
end



--                         _
--                        | |
--     _____   _____ _ __ | |_ ___
--    / _ \ \ / / _ \ '_ \| __/ __|
--   |  __/\ V /  __/ | | | |_\__ \
--    \___| \_/ \___|_| |_|\__|___/
--
--

local function DoEventWriteToLog(subject, envelope)
	-- write the message on the monitor
	WriteToMonitor(envelope.from ..":".. (envelope.message.text or "no text?!?"))
end

local function DoEventStatusUpdate(subject, envelope)
	-- do the status update
	DisplayStation.UpdateStatus(envelope.message)
end

local function DoEventHeartbeatTimer()
    -- pass request to coreassignemnt
    coreassignment.SendHearbeatRequests()

	-- do this event again in 5
	coreevent.CreateTimeEvent(db.heartbeatTimer, db.protocol, "heartbeat timer")

	-- update the status (weird here)
	DisplayStation.UpdateStatus()
end

local function ProcessLoggingCallback(message)
   	-- ToDo: update log when I am a display station
    -- send a message to who ever is the display station
	coreevent.SendMessage({
		channel		= db.loggerChannel,
		protocol	= db.protocol,
		subject		= "write to log",
		message		= {text = message}
    })
end

local function ProcessReceiveHeartbeat(subject, envelope)
	-- remember this one is alive
	if type(db.status[envelope.from]) ~= "table" then db.status[envelope.from] = {} end
	db.status[envelope.from].heartbeat = os.clock()
	db.status[envelope.from].fuelLevel = envelope.message.fuelLevel

	-- update the status
	DisplayStation.UpdateStatus()
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
		-- get monitor handles
		monitorLeft		= peripheral.wrap("left")
		monitorRight	= peripheral.wrap("right")

		-- fresh start
		monitorLeft.clear()
		monitorRight.clear()

		-- no blinking!
		monitorLeft.setCursorBlink(false)
		monitorRight.setCursorBlink(false)

		-- start the left one at the bottom
		local w, h = monitorLeft.getSize()
		monitorLeft.setCursorPos(1,h)

		-- right monitor has bigger text size
		monitorRight.setTextScale(2)

		-- listen to the logger port
		coreevent.OpenChannel(db.loggerChannel, db.protocol)

		-- listen to our events
		coreevent.AddEventListener(DoEventWriteToLog,       db.protocol, "write to log")
		coreevent.AddEventListener(DoEventStatusUpdate,     db.protocol, "status update")
		coreevent.AddEventListener(DoEventHeartbeatTimer,   db.protocol, "heartbeat timer")

        -- setup logger hook
        corelog.SetLoggerFunction(ProcessLoggingCallback)

        -- setup heartbeat hook
        coreassignment.SetHeartbeatFunction(ProcessReceiveHeartbeat)

        -- set up heartbeat timer
	    coreevent.CreateTimeEvent(db.heartbeatTimer,        db.protocol, "heartbeat timer")

		-- show who's boss!
		corelog.WriteToLog("--- starting up monitor ---")
		DisplayStation.SetStatus("project", "I am the logger", "Just ignore me", "Have a nice day")
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
