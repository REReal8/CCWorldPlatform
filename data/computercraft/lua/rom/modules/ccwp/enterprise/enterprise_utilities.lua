-- define class
local Class = require "class"
local MObjHost = require "mobj_host"
local enterprise_utilities = Class.NewClass(MObjHost)

--[[
    The enterprise_utilities is a MObjHost. It hosts object for different utilities like the logger and UserStation. For now just development utilities.
--]]

local coredht   		= require "coredht"
local coredisplay		= require "coredisplay"
local corelog   		= require "corelog"

enterprise_utilities.DHTroot    = "enterprise_utilities"

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

-- note: currently enterprise is treated like a singleton, but by directly using the name of the module
-- ToDo: consider making changes to enterprise to
--          - explicitly make it a singleton (by construction with :newInstance(hostName) and using the singleton pattern)
--          - properly initialise it (by adding and implementing the _init method)
--          - adopt other classes to these changes
enterprise_utilities._hostName = "enterprise_utilities"

-- setup code
function enterprise_utilities.Setup()
    coredisplay.MainMenuAddItem("u", "Utilities", UtilitiesMenu)
    coredht.DHTReadyFunction(CheckUtilitiesRole)
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function enterprise_utilities:getClassName()
    return "enterprise_utilities"
end

--                        _
--                       (_)
--    ___  ___ _ ____   ___  ___ ___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \
--   \__ \  __/ |   \ V /| | (_|  __/
--   |___/\___|_|    \_/ |_|\___\___|

function enterprise_utilities.SetAsLogger()
    corelog.WriteToLog("I am assigned as logger!!")
    coredht.DHTReadyFunction(enterprise_utilities.SetAsLoggerFunction)
end

function enterprise_utilities.RemoveRoles()
    corelog.WriteToLog("I am useless ;-(")
    coredht.DHTReadyFunction(enterprise_utilities.RemoveRolesFunction)
end

function enterprise_utilities.SetAsLoggerFunction()
    corelog.WriteToLog("I am assigned as logger (also in the DHT now, me so happy)!!")
    coredht.SaveData(true, enterprise_utilities.DHTroot, "loggers",         os.getComputerID())
    ActAsLogger()
end

function enterprise_utilities.RemoveRolesFunction()
    coredht.SaveData(nil, enterprise_utilities.DHTroot, "loggers",          os.getComputerID())
end

function CheckUtilitiesRole()
    -- are we the logger?
    if coredht.GetData(enterprise_utilities.DHTroot, "loggers", os.getComputerID()) then ActAsLogger() end
end

function ActAsLogger()
    corelog.WriteToLog("I will be the logger!!")
end

--        _ _           _
--       | (_)         | |
--     __| |_ ___ _ __ | | __ _ _   _
--    / _` | / __| '_ \| |/ _` | | | |
--   | (_| | \__ \ |_) | | (_| | |_| |
--    \__,_|_|___/ .__/|_|\__,_|\__, |
--               | |             __/ |
--               |_|            |___/

-- screen for the utilities
function UtilitiesMenu( t )
    -- first screen?
	if t == nil or t.role == nil then
		coredisplay.NextScreen({
			clear = true,
			intro = "Available actions",
			option = {
				{key = "l", desc = "Set as logger",             func = UtilitiesMenu, param = {role = "logger"}},
				{key = "r", desc = "Remove known functions",    func = UtilitiesMenu, param = {role = "remove"}},
				{key = "x", desc = "Back to main menu",     func = function () return true end }
			},
			question = "Tell me who I am!"
		})
		return true
	else
			    if t.role == "logger"	    then enterprise_utilities.SetAsLogger()
            elseif t.role == "remove"       then enterprise_utilities.RemoveRoles()
            end

        -- we are done here, go back
		return true
	end
end

-- return who we really are!
return enterprise_utilities
