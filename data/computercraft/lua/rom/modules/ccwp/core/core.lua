local core = {}

local coresystem = require "coresystem"
local coreevent = require "coreevent"
local corelog = require "corelog"
local coredisplay = require "coredisplay"
local coredht = require "coredht"
local coreinventory = require "coreinventory"
local coreassignment = require "coreassignment"
local coreutils = require "coreutils"
local coremove = require "coremove"
local coretask = require "coretask"

local db	    = {
    me				= os.getComputerID(),
    idleId			= 0,                                -- part of task...
}

local apis		= {}

-- initialize all system stuff
function core.Init()
    -- only if the system is just booted
    if coresystem.getStatus() ~= "booted" then return end

	-- init other stuff
	coredht.Init()
	coredisplay.Init()
	coreevent.Init()
	coreinventory.Init()
	coreassignment.Init()
	coremove.Init()
	coretask.Init()
	coreutils.Init()
	corelog.Init()

	-- set the new status
	coresystem.setStatus("initialized")
end

function core.Setup()
	-- only if the system is just booted
    if coresystem.getStatus() == "booted"		then core.Init() end
	if coresystem.getStatus() ~= "initialized"	then return end

	-- run all setup functions
	coredht.Setup()
	coredisplay.Setup()
	coreevent.Setup()
	coreinventory.Setup()
	coreassignment.Setup()
	coremove.Setup()
	coretask.Setup()
	coreutils.Setup()
	corelog.Setup()

	-- set new status
	coresystem.setStatus("ready")
end

-- actually run the stuff
function core.Run()
    -- check the system status
    if coresystem.getStatus() == "booted"		then core.Init()	end
    if coresystem.getStatus() == "initialized"	then core.Setup()	end

    -- check for the right system status
    if coresystem.getStatus() == "ready" then

        -- we are now officially running!!
		coresystem.setStatus("running")

    	-- run some functions in parallel
    	parallel.waitForAll(coreevent.Run, coretask.Run, coreassignment.Run, coredisplay.Run)

        -- no longer running, we're done
		coresystem.setStatus("ready")
    end
end

return core