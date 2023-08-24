-- define role
local role_fuel_worker = {}

-- ToDo: add proper module description
--[[
    This role ...
--]]

local coreutils = require "coreutils"
local corelog = require "corelog"
local coreinventory = require "coreinventory"
local InputChecker = require "input_checker"

--    _______        _                   __  __      _        _____        _
--   |__   __|      | |          ___    |  \/  |    | |      |  __ \      | |
--      | | __ _ ___| | _____   ( _ )   | \  / | ___| |_ __ _| |  | | __ _| |_ __ _
--      | |/ _` / __| |/ / __|  / _ \/\ | |\/| |/ _ \ __/ _` | |  | |/ _` | __/ _` |
--      | | (_| \__ \   <\__ \ | (_>  < | |  | |  __/ || (_| | |__| | (_| | || (_| |
--      |_|\__,_|___/_|\_\___/  \___/\/ |_|  |_|\___|\__\__,_|_____/ \__,_|\__\__,_|

function role_fuel_worker.Refuel_MetaData(taskData)
    -- check input
    if type(taskData) ~= "table" then corelog.Error("role_fuel_worker.Refuel_MetaData: Invalid taskData") return {success = false} end
    local turtleId = taskData.turtleId
    if type(turtleId) ~= "number" then corelog.Error("role_fuel_worker.Refuel_MetaData: Invalid turtleId") return {success = false} end
    local fuelItems = taskData.fuelItems
    if type(fuelItems) ~= "table" then corelog.Error("role_fuel_worker.Refuel_MetaData: Invalid fuelItems") return {success = false} end
    local priorityKey = taskData.priorityKey
    if priorityKey and type(priorityKey) ~= "string" then corelog.Error("role_fuel_worker.Refuel_MetaData: Invalid priorityKey") return {success = false} end

    return {
        startTime   = coreutils.UniversalTime(),
        location    = nil,
        needTool    = false,
        needTurtle  = true,
        fuelNeeded  = 0,
        needTurtleId= turtleId,
        itemsNeeded = coreutils.DeepCopy(fuelItems),

        priorityKey = priorityKey,
    }
end

local function Refuel(fuel)
    -- check input arguments
    if type(fuel) ~= "table" or type(fuel.itemName) ~= "string" or type(fuel.itemCount) ~= "number" or fuel.itemCount < 1 then return false end

    -- handig voor de loop
    local itemsLeft  = fuel.itemCount

    -- find the fuel in the inventory
    while coreinventory.SelectItem(fuel.itemName) and itemsLeft > 0 do
        -- how many present
        local itemsPresent  = turtle.getItemCount()

        -- how many to burn
        local itemsToBurn   = nil
        if itemsLeft < itemsPresent then itemsToBurn = itemsLeft
                                    else itemsToBurn = itemsPresent
        end

        -- do the refuelling
        turtle.refuel(itemsToBurn)

        -- adjust itemsLeft
        itemsLeft = itemsLeft - itemsToBurn
    end

    -- done
    return true
end

function role_fuel_worker.Refuel_Task(taskData)
    --[[
        This Task function (re)fuels a (the current) turtle.

        Return value:
            task result                 - (table)
                success                 - (boolean) whether the task was succesfull

        Parameters:
            taskData                    - (table) data about the task
                turtleId                - (number) id of the turtle to (re)fuel
                fuelItems               - (table) with one or more items (formatted as an array of [itemName] = itemCount key-value pairs) to refuel with
    ]]

    -- check input
    if type(taskData) ~= "table" then corelog.Error("role_fuel_worker.Refuel_Task: Invalid taskData") return {success = false} end
    local turtleId = taskData.turtleId
    if type(turtleId) ~= "number" then corelog.Error("role_fuel_worker.Refuel_Task: Invalid turtleId") return {success = false} end
    local fuelItems = taskData.fuelItems
    if type(fuelItems) ~= "table" then corelog.Error("role_fuel_worker.Refuel_Task: Invalid fuelItems") return {success = false} end

    -- check correct turtle
    local currentTurtleId = os.getComputerID()
    if currentTurtleId ~= turtleId then corelog.Error("role_fuel_worker.Refuel_Task: Current turtle(id="..currentTurtleId..") not equal to targeted turtle(id="..turtleId..")") return {success = false} end

    -- fuel from all fuelItems
    for itemName, itemCount in pairs(fuelItems) do
        local refuelResult = Refuel({itemName = itemName,  itemCount = itemCount})
        if refuelResult == false then corelog.Warning("role_fuel_worker.Refuel_Task: Failed refueling from "..itemCount.." "..itemName.."'s") return {success = false} end

        corelog.WriteToLog(">Refueled with "..itemCount.." "..itemName.."'s to "..turtle.getFuelLevel())
    end

    -- end
    return {success = true}
end

function role_fuel_worker.NeededFuelToFrom(...)
    local enterprise_energy = require "enterprise_energy"

    -- get & check input from description
    local checkSuccess, locationB, locationA = InputChecker.Check([[
        This method returns the fuel needed to travel from locationA to locationB.

        Return value:
            fuelNeed                - (number) with fuel needed to travel

        Parameters:
            locationB               + (Location) with destination location
            locationA               + (Location) with start location
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("role_fuel_worker.NeededFuelToFrom: Invalid input") return enterprise_energy.GetLargeFuelAmount_Att() end

    -- end
    return locationA:blockDistanceTo(locationB)
end

return role_fuel_worker
