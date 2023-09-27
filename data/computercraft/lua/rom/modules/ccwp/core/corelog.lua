-- define module
local corelog = {}

-- ToDo: add proper module description
--[[
    This module ...
--]]

local coreevent = require "coreevent"
local coreassignment
local coreutils = require "coreutils"

local db	= {
	logfile			    = "/log/log.txt",
	assignmentLogFile   = "/log/coreassignment.log",
	projectsLogFile     = "/log/enterprise_projects.log",
	protocol		    = "corelog",
	loggerChannel	    = 65534,
	lastStack           = 0,
	status				= {},
	heartbeatTimer		= 100,
}

local monitorLeft	= nil
local monitorRight	= nil

function corelog.Init()
	-- place markers in the logfile
	corelog.WriteToLog("--- starting up ---", "overwrite")
	corelog.WriteToAssignmentLog("--- starting up assignments ---", nil, "overwrite")
	corelog.WriteToProjectsLog("--- starting up projects ---", nil, "overwrite")
end

function corelog.Setup()
	corelog.WriteToLog("corelog.Setup()")

	-- start sending messages when we are ready to receive them too
	coreevent.EventReadyFunction(CoreLogEventReadySetup)

	-- check if we have monitors on our side (and we are not a turtle / pocket / command, se we are a computer)
	if peripheral.getType("left") == "monitor" and peripheral.getType("right") == "monitor" and not turtle and not pocket and not commands then
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

		-- we will be the logger of this system
		coreassignment = coreassignment or require "coreassignment"
		coreassignment.RejectAllAssignments()

		-- listen to the logger port
		coreevent.OpenChannel(db.loggerChannel, db.protocol)

		-- listen to our events
		coreevent.AddEventListener(DoEventWriteToLog, db.protocol, "write to log")
		coreevent.AddEventListener(DoEventStatusUpdate, db.protocol, "status update")
		coreevent.AddEventListener(DoEventHeartbeatTimer, db.protocol, "heartbeat timer")
		coreevent.AddEventListener(DoEventReceiveHeartbeat, db.protocol, "receive heartbeat")

		-- show who's boss!
		corelog.WriteToLog("--- starting up monitor ---")
		corelog.SetStatus("project", "I am the logger", "Just ignore me", "Have a nice day")
	else
		-- responde to heartbeat
		coreevent.AddEventListener(DoEventSendHeartbeat, db.protocol, "send heartbeat")
	end
end

function CoreLogEventReadySetup()
	-- set up heartbeat timer
	if monitorLeft and monitorRight then coreevent.CreateTimeEvent(db.heartbeatTimer, db.protocol, "heartbeat timer") end
end

function corelog.ClearLog()
	-- just overwrite the logfile, this does create a first empty line
	coreutils.WriteToFile(db.logfile, nil, "overwrite")
end

function corelog.WriteToLog(message, writeMode)
	-- set the default
	writeMode = writeMode or "append"

	-- write to the logfile
	coreutils.WriteToFile(db.logfile, message, writeMode)

	-- might be a table
	if type(message) == "table" then message = textutils.serialize(message) end

	-- send message
	if monitorLeft then
		-- we are the logging station, don't send message
		corelog.WriteToMonitor("me: "..(message or "nil message"))
 	else

		-- send message two whoever is loggin our stuff
		coreevent.SendMessage({
			channel		= db.loggerChannel,
			protocol	= db.protocol,
			subject		= "write to log",
			message		= {text = message} })
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

local function UpdateStatus(statusData, monitor)
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

function corelog.SetStatus(group, message, subline, details)
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

	-- send to the logger (unless that's us)
	if monitorRight then

		-- update the status
		UpdateStatus(statusUpdate)
	else

		-- not us, send the info
		coreevent.SendMessage({
			channel		= db.loggerChannel,
			protocol	= db.protocol,
			subject		= "status update",
			message		= statusUpdate})
	end
end



function corelog.WriteToMonitor(message, monitor)
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

function corelog.Warning(message)
	-- write to the logfile
	coreutils.WriteToFile(db.logfile, "WARNING:", "append") -- ToDo: consider calling WriteToLog
	coreutils.WriteToFile(db.logfile, message, "append") -- ToDo: consider calling WriteToLog

	-- format the warning
	if type(message) == "table" then message = textutils.serialize(message) end
	message = "WARNING: "..message

	-- send message two whoever is loggin our stuff
	coreevent.SendMessage({
		channel		= db.loggerChannel,
		protocol	= db.protocol,
		subject		= "write to log",
		message		= {text = message} })
end

function corelog.Error(message)
	-- write to the logfile
	coreutils.WriteToFile(db.logfile, "ERROR:", "append") -- ToDo: consider calling WriteToLog

	-- calling stack, just max once per tick
	if db.lastStack < os.clock() then

		-- reset
		db.lastStack = os.clock()

		-- write the callstack to the logfile
		coreutils.WriteToFile(db.logfile, debug.traceback())
	end

	-- requested messaage
	coreutils.WriteToFile(db.logfile, message, "append") -- ToDo: consider calling WriteToLog
end

function WriteToFormattedLog(message, id, logType, writeMode)
	-- set the default
	writeMode = writeMode or "append"

	-- write message to the logfile	in formatted log format
    local now = coreutils.UniversalTime()
    local computerId = os.getComputerID()
	local idStr = "assignment"
	local logFile = db.assignmentLogFile
	if logType == "projects" then
		idStr = "project"
		logFile = db.projectsLogFile
	end
	if id then
		idStr = idStr.." "..id.." | "
	else
		idStr = ""
	end
	coreutils.WriteToFile(logFile, "| time "..now.." | computer "..computerId.." | "..idStr..message.." |", writeMode)
end

function corelog.WriteToAssignmentLog(message, assignmentId, writeMode)
	WriteToFormattedLog(message, assignmentId, "assignment", writeMode)
end

function corelog.WriteToProjectsLog(message, projectId, writeMode)
	WriteToFormattedLog(message, projectId, "projects", writeMode)
end

function corelog.FindCaller(...) -- give ignore string as parameters. corelog.FindCaller("enterprise_projects", "enterprise_storage")
	local ignore = {method_executor = true}

	-- add all other keys to ignore
	for index, toIgnore in ipairs(arg) do ignore[ toIgnore ] = true end

	-- we don't need ourself (0) and the one calling this function (1), start witth 2
	local level = 2

	-- endless until we are at the end or found something
	while true do

		-- get the debug info
		local info = debug.getinfo(level, "Sl")

		-- at the end of the stack?
		if not info then return nil end

		-- just to be sure, skip C functions
		if info.what ~= "C" and ignore[info.short_src] == nil then -- not a C function and not in the ignore list

			-- Yahoo!
			return string.format("[%s]:%d", info.short_src, info.currentline)

		end

		-- still here, try the next level
		level = level + 1
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

function DoEventWriteToLog(subject, envelope)
	-- write the message on the monitor
	corelog.WriteToMonitor(envelope.from ..":".. (envelope.message.text or "no text?!?"))
end

function DoEventStatusUpdate(subject, envelope)
	-- do the status update
	UpdateStatus(envelope.message)
end

function DoEventHeartbeatTimer()
	-- just send a heartbeat request to anyone around
	coreevent.SendMessage({
		channel		= 65535,			-- public channel
		protocol	= db.protocol,
		subject		= "send heartbeat",
		message		= {}})

	-- do this event again in 5
	coreevent.CreateTimeEvent(db.heartbeatTimer, db.protocol, "heartbeat timer")

	-- update the status
	UpdateStatus()
end

function DoEventSendHeartbeat(subject, envelope)
	local fuelLevel 	= 0
	if turtle then fuelLevel = turtle.getFuelLevel() end

	-- easy reply since we have a heartbeat
	coreevent.ReplyToMessage(envelope, "receive heartbeat", {fuelLevel = fuelLevel})
end

function DoEventReceiveHeartbeat(subject, envelope)
	-- remember this one is alive
	if type(db.status[envelope.from]) ~= "table" then db.status[envelope.from] = {} end
	db.status[envelope.from].heartbeat = os.clock()
	db.status[envelope.from].fuelLevel = envelope.message.fuelLevel

	-- update the status
	UpdateStatus()
end

return corelog
