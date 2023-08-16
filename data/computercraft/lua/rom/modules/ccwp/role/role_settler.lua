local role_settler = {}

local coreutils = require "coreutils"
local corelog = require "corelog"
local coremove = require "coremove"
local coreinventory = require "coreinventory"

local InputChecker = require "input_checker"

local Location = require "obj_location"

--                _     _ _         __                  _   _
--               | |   | (_)       / _|                | | (_)
--    _ __  _   _| |__ | |_  ___  | |_ _   _ _ __   ___| |_ _  ___  _ __  ___
--   | '_ \| | | | '_ \| | |/ __| |  _| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
--   | |_) | |_| | |_) | | | (__  | | | |_| | | | | (__| |_| | (_) | | | \__ \
--   | .__/ \__,_|_.__/|_|_|\___| |_|  \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
--   | |
--   |_|

function role_settler.InitialiseCoordinates_MetaData(taskData)
    local location = Location:new(coremove.GetLocation()) --> use the current location for proper bootstrapping

    return {
        startTime = coreutils.UniversalTime(),
        location = location:copy(),
        needTool = false,
        needTurtle = true,
        fuelNeeded = 0,                         --> per definition the settler starts without fuel
        itemsNeeded = { }
    }
end

function role_settler.InitialiseCoordinates_Task(...)
    -- get & check input from description
    local checkSuccess, startLocation = InputChecker.Check([[
        This Task function does the first settling step: initialise starting world coordinates.

        Return value:
            task result                 - (table)
                success                 - (boolean) whether the task was succesfull

        Parameters:
            taskData                    - (table) data about the task
                startLocation           + (Location) locaton where first steps are to be taken
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("role_settler:InitialiseCoordinates_Task: Invalid input") return {success = false} end

    -- coordinaten stelsel goed zetten
    coremove.SetLocation(startLocation)

    -- end
    return {success = true}
end

function role_settler.CollectCobbleStone_MetaData(taskData)
    return {
        startTime = coreutils.UniversalTime(),
        location = taskData.startLocation:copy(),
        needTool = true,
        needTurtle = true,
        fuelNeeded = 100, -- ToDo: how much is needed for this step?
        itemsNeeded = {
        }
    }
end

function role_settler.CollectCobbleStone_Task(...)
    -- get & check input from description
    local checkSuccess, startLocation = InputChecker.Check([[
        This Task function collects sufficient cobblestone to build the first furnace.

        Return value:
            task result                 - (table)
                success                 - (boolean) whether the task was succesfull

        Parameters:
            taskData                    - (table) data about the task
                startLocation           + (Location) locaton where the task should start
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("role_settler:CollectCobbleStone_Task: Invalid input") return {success = false} end

    -- move to the workingLocation
    coremove.GoTo(startLocation)

    -- get into digging position
    corelog.WriteToLog (">Collecting cobblestone")
    coreinventory.Equip("minecraft:diamond_pickaxe")
    turtle.digDown()
    coremove.Down()

    -- dig a hole, get cobblestone
    local cobblestone = 0
    while cobblestone < 9 do

        -- one layer lower
        turtle.digDown()
        coremove.Down()

        -- go round
        for i=1,4 do turtle.dig() coremove.Right() end

        -- count our cobblestone
        cobblestone = coreinventory.CountItem("minecraft:cobblestone")
    end

    -- restore our crafting spot
    coremove.MoveTo({_z = startLocation:getZ() - 1})
    if coreinventory.SelectItem("minecraft:dirt") or coreinventory.SelectItem("minecraft:cobblestone") then turtle.placeDown() end

    -- end
    return {success = true}
end

return role_settler