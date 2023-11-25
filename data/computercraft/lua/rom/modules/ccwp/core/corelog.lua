-- define module
local corelog = {}

-- ToDo: add proper module description
--[[
    This module ...
--]]

local coreevent = require "coreevent"
local coreassignment
local coreutils = require "coreutils"

local DisplayStation
local enterprise_employment = nil

local db	= {
	logfile			    = "/log/log.txt",
	assignmentLogFile   = "/log/coreassignment.log",
	projectsLogFile     = "/log/enterprise_projects.log",
	protocol		    = "corelog",
	loggerChannel	    = 65534,
	lastStack           = 0,
}

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

	-- responde to heartbeat
	coreevent.AddEventListener(DoEventSendHeartbeat, "mobj_display_station", "send heartbeat")
end

function CoreLogEventReadySetup()
end

function corelog.ClearLog()
	-- just overwrite the logfile, this does create a first empty line
	coreutils.WriteToFile(db.logfile, nil, "overwrite")
end

function corelog.WriteToLog(message, writeMode)
	-- set the default
	writeMode = writeMode or "append"

	-- might be a table
	if type(message) == "table" then message = textutils.serialize(message)
								else message = tostring(message)
	end

	-- write to the logfile
	coreutils.WriteToFile(db.logfile, coreutils.UniversalTime()..': '..message, writeMode)

	-- ToDo: update log when I am a display station
	-- send message two whoever is loggin our stuff
	coreevent.SendMessage({
		channel		= 65534,
		protocol	= "mobj_display_station",
		subject		= "write to log",
		message		= {text = message} })
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

	enterprise_employment = enterprise_employment or require "enterprise_employment"
	local workerLocator = enterprise_employment:getCurrentWorkerLocator() if not workerLocator then corelog.Error("corelog.SetStatus: Failed obtaining current workerLocator") return false end
    local workerObj = enterprise_employment:getObject(workerLocator) if not workerObj then corelog.Error("corelog.SetStatus: Failed obtaining Worker "..workerLocator:getURI()) return false end

	-- send to the logger (unless that's us)
	if workerObj:getClassName() == "DisplayStation" then

		-- update the status
		DisplayStation = DisplayStation or require "mobj_display_station"
		DisplayStation.UpdateStatus(statusUpdate)
	end

	-- not us, send the info
	coreevent.SendMessage({
		channel		= 65534,
		protocol	= "mobj_display_station",
		subject		= "status update",
		message		= statusUpdate})
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

function DoEventSendHeartbeat(subject, envelope)
	local fuelLevel 	= 0
	if turtle then fuelLevel = turtle.getFuelLevel() end

	-- easy reply since we have a heartbeat
	coreevent.ReplyToMessage(envelope, "receive heartbeat", {fuelLevel = fuelLevel})
end

return corelog
