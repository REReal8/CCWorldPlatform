-- define role
local role_miner = {}

--[[
    This role deals with the mining of items within mining objects (e.g. MineShaft's).
--]]

local coreutils = require "coreutils"
local corelog = require "corelog"
local coremove = require "coremove"
local coreinventory = require "coreinventory"

local InputChecker = require "input_checker"

local ItemTable = require "obj_item_table"

local enterprise_employment

--    _______        _                   __  __      _        _____        _
--   |__   __|      | |          ___    |  \/  |    | |      |  __ \      | |
--      | | __ _ ___| | _____   ( _ )   | \  / | ___| |_ __ _| |  | | __ _| |_ __ _
--      | |/ _` / __| |/ / __|  / _ \/\ | |\/| |/ _ \ __/ _` | |  | |/ _` | __/ _` |
--      | | (_| \__ \   <\__ \ | (_>  < | |  | |  __/ || (_| | |__| | (_| | || (_| |
--      |_|\__,_|___/_|\_\___/  \___/\/ |_|  |_|\___|\__\__,_|_____/ \__,_|\__\__,_|

function role_miner.MineShaft_MetaData(...)
    -- get & check input from description
    local checkSuccess, baseLocation, maxDepth, priorityKey = InputChecker.Check([[
        This function returns the MetaData for MineShaft_Task.

        Return value:
                                        - (table) metadata

        Parameters:
            taskData                    - (table) data about the task
                baseLocation            + (Location) base location of the MineShaft
                startDepth              - (number) with mining starting depth within the MineShaft
                maxDepth                + (number) with maximum depth of the MineShaft

                priorityKey             + (string, "") priorityKey for this assignment
    ]], ...)
    if not checkSuccess then corelog.Error("role_miner.MineShaft_MetaData: Invalid input") return {success = false} end

    return {
        startTime = coreutils.UniversalTime(),
        location = baseLocation:copy(),
        needTool = true,
        needTurtle = true,
        fuelNeeded = maxDepth,
        itemsNeeded = {
        },

        priorityKey = priorityKey,
    }
end

function role_miner.MineShaft_Task(...)
    -- get & check input from description
    local checkSuccess, baseLocation, startDepth, maxDepth, toProvideItems, escape, turtleLocator = InputChecker.Check([[
        This Task function mines a MineShaft for items.

        Return value:
            task result                 - (table)
                success                 - (boolean) whether the task was succesfull
                endDepth                 (number) with mining ending depth within the MineShaft

        Parameters:
            taskData                    - (table) data about the task
                baseLocation            + (Location) base location of the MineShaft
                startDepth              + (number) with mining starting depth within the MineShaft
                maxDepth                + (number) with maximum depth of the MineShaft

                provideItems            + (ItemTable) with one or more items (formatted as an array of [itemName] = itemCount key-value pairs) to mine
                escape                  + (boolean) whether Turtle should escape from the MineShaft after it's operation

                workerLocator           + (URL) locating the Turtle
    ]], ...)
    if not checkSuccess then corelog.Error("role_miner.MineShaft_Task: Invalid input") return {success = false} end

    -- get turtle we are doing task with
    enterprise_employment = enterprise_employment or require "enterprise_employment"
    local turtleObj = enterprise_employment:getObject(turtleLocator)
    if not turtleObj then corelog.Error("role_miner.MineShaft_Task: Failed obtaining Turtle "..turtleLocator:getURI()) return {success = false} end

    -- remember input items
    local beginTurtleItems = turtleObj:getInventoryAsItemTable()

    -- equip diamond_pickaxe
    local axePresent = coreinventory.Equip("minecraft:diamond_pickaxe")
    if not axePresent then corelog.Error("role_miner.MineShaft_Task: No axePresent ") return {success = false} end

    -- move to the baseLocation
    -- corelog.WriteToLog("Moving to (base)")
    -- corelog.WriteToLog(baseLocation)
    coremove.GoTo(baseLocation)

    -- perform entry sequence
    -- corelog.WriteToLog("entering...")
    local actualMineStart = -3
    local entrySequence = {
        baseLocation:getRelativeLocation(1, 0, 0),
        baseLocation:getRelativeLocation(1, 0, actualMineStart),
        baseLocation:getRelativeLocation(0, 0, actualMineStart),
    }
    for i, entryLocation in ipairs(entrySequence) do
        -- corelog.WriteToLog("Moving to")
        -- corelog.WriteToLog(entryLocation)
        coremove.GoTo(entryLocation)
    end

    -- dig a hole while depth left and not all provideItems found
    -- corelog.WriteToLog("gathering...")
    local currentDepth = startDepth
    local allProvideItemsFound = false
    local outputItems = ItemTable:newInstance()
    local wasteItems = ItemTable:newInstance()
    while currentDepth < maxDepth and not allProvideItemsFound do
        -- one layer lower
        turtle.digDown()
        coremove.Down()
        currentDepth = currentDepth + 1

        -- go round
        for i=1,4 do turtle.dig() coremove.Right() end

        -- determine output & waste items
        local serviceResults = turtleObj:getOutputAndWasteItemsSince(beginTurtleItems, toProvideItems)
        if not serviceResults or not serviceResults.success then corelog.Error("role_forester.HarvestForest_Task: Failed obtaining output & waste items") return {success = false} end
        outputItems = serviceResults.outputItems
        wasteItems = serviceResults.otherItems

        -- did we already find all?
        local uniqueProvideItems, _commonItems, _uniqueFoundItems = ItemTable.compare(toProvideItems, outputItems)
        if not uniqueProvideItems then corelog.Error("role_miner.MineShaft_Task: Failed obtaining uniqueProvideItems") return {success = false} end
        if uniqueProvideItems:isEmpty() then
            allProvideItemsFound = true
        end
    end

    -- perform exit sequence
    if escape then
        -- corelog.WriteToLog("escaping...")
        local exitSequence = {
            baseLocation:getRelativeLocation(-1, 0, actualMineStart - currentDepth),
            baseLocation:getRelativeLocation(-1, 0, actualMineStart),
            baseLocation:getRelativeLocation(-1, 0, 0),
            baseLocation:getRelativeLocation(0, 0, 0),
        }
        for i, exitLocation in ipairs(exitSequence) do
            -- corelog.WriteToLog("Moving to")
            -- corelog.WriteToLog(exitLocation)
            coremove.GoTo(exitLocation)
        end
    end

    -- determine output locator
    local turtleOutputItemsLocator = turtleLocator:copy()
    turtleOutputItemsLocator:setQuery(outputItems)

    -- determine waste locator
    local turtleWasteItemsLocator = turtleLocator:copy()
    turtleWasteItemsLocator:setQuery(wasteItems)
    if next(wasteItems) ~= nil then
        corelog.WriteToLog(">mining waste: "..textutils.serialise(wasteItems, {compact = true}))
    end

    -- end
    return {
        success                     = allProvideItemsFound,
        endDepth                    = currentDepth,
        turtleOutputItemsLocator    = turtleOutputItemsLocator,
        turtleWasteItemsLocator     = turtleWasteItemsLocator,
    }
end

return role_miner
