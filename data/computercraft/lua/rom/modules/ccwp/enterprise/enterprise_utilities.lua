-- define class
local Class = require "class"
local MObjHost = require "mobj_host"
local enterprise_utilities = Class.NewClass(MObjHost)

--[[
    The enterprise_utilities is a MObjHost. It hosts object for different utilities like the logger and UserStation. For now just development utilities.
--]]

local coredht   		= require "coredht"
local coredisplay		= require "coredisplay"
local coreevent 		= require "coreevent"
local corelog   		= require "corelog"
local coretask   		= require "coretask"

local Callback          = require "obj_callback"
local ObjHost           = require "obj_host"
local ItemTable         = require "obj_item_table"
local Location          = require "obj_location"

local enterprise_chests = require "enterprise_chests"
local enterprise_dump   = require "enterprise_dump"

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

function DoEventInputChestTimer()
    -- add the work, the real stuff
    coretask.AddWork(CheckInputChest, {})

    -- create new event
    coreevent.CreateTimeEvent(20 * 15, "mobj_user_station", "input Chest timer")
end

function CheckInputChest()
    -- set timer for input box (15 sec)
    local inputChest    = peripheral.wrap("left")
    local itemTable     = ItemTable:new({})

    -- find first empty slot from the end
    local firstEmpty    = 27
    while firstEmpty > 0 do
        -- we are done if this slot is empty
        if inputChest.getItemDetail(firstEmpty) == nil then break end

        -- check another
        firstEmpty = firstEmpty - 1
    end

    -- any new items?
    local numberOfNewItems  = 0
    while numberOfNewItems < 27 do
        -- get the details of this slot
        local itemDetail = inputChest.getItemDetail(numberOfNewItems + 1)

        -- is the slot filled?
        if type(itemDetail) == "nil" then break end

        -- add items to the order
        itemTable:add(itemDetail.name, itemDetail.count)

        -- move the item to the end
        inputChest.pushItems("left", numberOfNewItems + 1, itemDetail.count, firstEmpty)

        -- update
        firstEmpty          = firstEmpty - 1
        numberOfNewItems    = numberOfNewItems + 1
    end

    -- did we find anything
    if itemTable and not itemTable:isEmpty() then

        -- create items locator (temp solution) ToDo !!
        local inputChestLocator = enterprise_chests:hostMObj_SSrv({
            className           = "Chest",
            constructParameters = {
                baseLocation        = Location:newInstance(-2, -9, 1, 0, 1),
                accessDirection     = "top"
            }
        }).mobjLocator

        -- add the items to the locator
        inputChestLocator:setQuery(itemTable)

        -- store the items in the default dump site
        local dumpLocator = enterprise_dump.GetDumpLocator()
        local dumpObject  = ObjHost.GetObject(dumpLocator)

        -- ask the dump to store our items
        if dumpObject == nil then return end
        dumpObject:storeItemsFrom_AOSrv({itemsLocator = inputChestLocator}, Callback.GetNewDummyCallBack())
    end
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
