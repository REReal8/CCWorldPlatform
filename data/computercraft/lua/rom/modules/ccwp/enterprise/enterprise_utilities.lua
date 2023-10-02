-- define class
local Class = require "class"
local MObjHost = require "eobj_mobj_host"
local enterprise_utilities = Class.NewClass(MObjHost)

local coredht   		= require "coredht"
local coredisplay		= require "coredisplay"
local corelog   		= require "corelog"

enterprise_utilities.DHTroot    = "enterprise_utilities"

--[[
    The enterprise_utilities is a MObjHost. It hosts object for different utilities like the logger and UtilStation. For now just development utilities.
--]]

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
enterprise_utilities._hostName   = "enterprise_utilities"

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

function enterprise_utilities:getClassName()
    return "enterprise_utilities"
end

--                        _                           _   _               _
--                       (_)                         | | | |             | |
--    ___  ___ _ ____   ___  ___ ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \  __/ |   \ V /| | (_|  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/\___|_|    \_/ |_|\___\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

function enterprise_utilities.SetAsLogger()
    corelog.WriteToLog("I am assigned as logger!!")
    coredht.DHTReadyFunction(enterprise_utilities.SetAsLoggerFunction)
end

function enterprise_utilities.SetAsUserStation()
    corelog.WriteToLog("I am assigned as user station!!")
    coredht.DHTReadyFunction(enterprise_utilities.SetAsUserStationFunction)
end

function enterprise_utilities.RemoveRoles()
    corelog.WriteToLog("I am useless ;-(")
    coredht.DHTReadyFunction(enterprise_utilities.RemoveRolesFunction)
end

function enterprise_utilities.SetAsLoggerFunction()
    corelog.WriteToLog("I am assigned as logger (also in the DHT now, me so happy)!!")
    coredht.SaveData(true, enterprise_utilities.DHTroot, "loggers",         os.getComputerID())
    coredht.SaveData(nil,  enterprise_utilities.DHTroot, "user stations",   os.getComputerID())
    ActAsLogger()
end

function enterprise_utilities.SetAsUserStationFunction()
    corelog.WriteToLog("I am assigned as user station (also in the DHT now, me so happy)!!")
    coredht.SaveData(nil,   enterprise_utilities.DHTroot, "loggers",        os.getComputerID())
    coredht.SaveData(true,  enterprise_utilities.DHTroot, "user stations",  os.getComputerID())
    ActAsUserStation()
end

function enterprise_utilities.RemoveRolesFunction()
    coredht.SaveData(nil, enterprise_utilities.DHTroot, "loggers",          os.getComputerID())
    coredht.SaveData(nil, enterprise_utilities.DHTroot, "user stations",    os.getComputerID())
end

function CheckUtilitiesRole()
    -- are we the logger?
    if coredht.GetData(enterprise_utilities.DHTroot, "loggers", os.getComputerID()) then ActAsLogger() end

    -- are we the user station?
    if coredht.GetData(enterprise_utilities.DHTroot, "user stations", os.getComputerID()) then ActAsUserStation() end
end

function ActAsLogger()
    corelog.WriteToLog("I will be the logger!!")
end

function ActAsUserStation()
    corelog.WriteToLog("I will be the user station!!")

	-- our main menu
    coredisplay.MainMenu({
        clear       = true,
        func	    = UserStationMenuSearch,
        intro       = "Please type a part of an itemname to order\n",
        param	    = {},
        question    = nil
    })
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
				{key = "u", desc = "Set as user station",       func = UtilitiesMenu, param = {role = "user station"}},
				{key = "r", desc = "Remove known functions",    func = UtilitiesMenu, param = {role = "remove"}},
				{key = "x", desc = "Back to main menu",     func = function () return true end }
			},
			question = "Tell me who I am!"
		})
		return true
	else
			    if t.role == "logger"	    then enterprise_utilities.SetAsLogger()
            elseif t.role == "user station" then enterprise_utilities.SetAsUserStation()
            elseif t.role == "remove"       then enterprise_utilities.RemoveRoles()
            end

        -- we are done here, go back
		return true
	end
end

function UserStationMenuSearch(t, searchString)
    -- get all items
    local allItems      = coredht.GetData("allItems")
    local options       = {}
    local lastNumber    = 0

    -- security check
    if type(allItems) ~= "table" then return false end

    -- loop all items
    for k, v in pairs(allItems) do

        -- if the search string for matches, add found items to the options!
        local findStart, findEnd = string.find(k, searchString)
        if type(findStart) =="number" and type(findEnd) == "number" then
            lastNumber = lastNumber + 1
            table.insert(options, {key = tostring(lastNumber), desc = k, func = UserStationMenuAmount, param = {item = k}})
        end
    end

    -- do we have found anything?
    if lastNumber == 0 then

            -- not good!
            coredisplay.UpdateToDisplay("No items found :-(", 2)

    elseif lastNumber > 10 then

            -- Too much
            coredisplay.UpdateToDisplay(lastNumber.." items found, specify your search", 2)

    else
        -- add exit option
        table.insert(options, {key = "x", desc = "Back to main menu", func = function () return true end })

        -- do the screen
        coredisplay.NextScreen({
			clear = true,
			intro = "Choose an item",
			option = options,
			question	= "Make your choice",
		})

        -- screeen complete (fake)
        return true
    end
end

function UserStationMenuAmount(t)
    return true
end

-- sneaky init code
coredisplay.MainMenuAddItem("u", "Utilities", UtilitiesMenu)
coredht.DHTReadyFunction(CheckUtilitiesRole)

-- return who we really are!
return enterprise_utilities
