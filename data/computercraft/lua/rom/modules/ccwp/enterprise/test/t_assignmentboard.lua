local t_assignmentboard = {}

local corelog = require "corelog"
local coreutils = require "coreutils"

local Callback = require "obj_callback"
local TaskCall = require "obj_task_call"
local Location = require "obj_location"

local enterprise_assignmentboard = require "enterprise_assignmentboard"

function t_assignmentboard.T_All()
    t_assignmentboard.T_MetaDataConditionsMet()
    t_assignmentboard.T_BestCandidate()
--    t_assignmentboard.T_GetStatistics_Att() -- ToDo: fix side-effects of this test (now all currently present (test) assignments are deleted)
    t_assignmentboard.T_DoAssignment_ASrv()
end

local compact = { compact = true }

function t_assignmentboard.End(assignmentId)
    enterprise_assignmentboard.EndAssignment(assignmentId)
end

function t_assignmentboard.T_EndAssignments()
    -- prepare test
    corelog.WriteToLog("* enterprise_assignmentboard.EndAssignments() tests")

    -- test
    enterprise_assignmentboard.EndAssignments()

    -- cleanup test
end

function t_assignmentboard.T_MetaDataConditionsMet()
    -- prepare test
    corelog.WriteToLog("* enterprise_assignmentboard.MetaDataConditionsMet() tests")
    local now = coreutils.UniversalTime()
    local computerId = os.getComputerID()
    local metaData = {
        startTime = now,
        needTurtle = false,
        needTurtleId = computerId,
        needTool = false,
        fuelNeeded = 0,
        itemsNeeded = {},
        location = nil,
    }
    local assignmentFilter = {
        priorityKeyNeeded   = "",
    }
    local turtleResume = nil

    -- test startTime
    corelog.WriteToLog("  # Test startTime condition")
    metaData.startTime = now + 1000
    local conditionsMet, skipReason = enterprise_assignmentboard.MetaDataConditionsMet(metaData, assignmentFilter, turtleResume)
    local expectedconditionsMet = false
    assert(conditionsMet == expectedconditionsMet, "gotten conditionsMet(="..tostring(conditionsMet)..") not the same as expected(="..tostring(expectedconditionsMet)..")")
    metaData.startTime = now

    -- test fuelTurtlePriorityKey
    corelog.WriteToLog("  # Test fuelTurtlePriorityKey (not set)")
    local priorityKey = coreutils.NewId()
    metaData.priorityKey = priorityKey
    conditionsMet, skipReason = enterprise_assignmentboard.MetaDataConditionsMet(metaData, assignmentFilter, turtleResume)
    expectedconditionsMet = true
    assert(conditionsMet == expectedconditionsMet, "gotten conditionsMet(="..tostring(conditionsMet)..") not the same as expected(="..tostring(expectedconditionsMet)..")")
    metaData.priorityKey = ""

    corelog.WriteToLog("  # Test fuelTurtlePriorityKey (set, no key)")
    assignmentFilter.priorityKeyNeeded = priorityKey
    conditionsMet, skipReason = enterprise_assignmentboard.MetaDataConditionsMet(metaData, assignmentFilter, turtleResume)
    expectedconditionsMet = false
    assert(conditionsMet == expectedconditionsMet, "gotten conditionsMet(="..tostring(conditionsMet)..") not the same as expected(="..tostring(expectedconditionsMet)..")")
    metaData.priorityKey = ""

    corelog.WriteToLog("  # Test fuelTurtlePriorityKey (set, same key)")
    metaData.priorityKey = priorityKey
    conditionsMet, skipReason = enterprise_assignmentboard.MetaDataConditionsMet(metaData, assignmentFilter, turtleResume)
    expectedconditionsMet = true
    assert(conditionsMet == expectedconditionsMet, "gotten conditionsMet(="..tostring(conditionsMet)..") not the same as expected(="..tostring(expectedconditionsMet)..")")
    metaData.priorityKey = ""

    corelog.WriteToLog("  # Test fuelTurtlePriorityKey (set, other key)")
    local otherPriorityKey = coreutils.NewId()
    metaData.priorityKey = otherPriorityKey
    conditionsMet, skipReason = enterprise_assignmentboard.MetaDataConditionsMet(metaData, assignmentFilter, turtleResume)
    expectedconditionsMet = false
    assert(conditionsMet == expectedconditionsMet, "gotten conditionsMet(="..tostring(conditionsMet)..") not the same as expected(="..tostring(expectedconditionsMet)..")")
    metaData.priorityKey = ""
    assignmentFilter.priorityKeyNeeded = ""

    -- test needTurtle
    corelog.WriteToLog("  # Test needTurtle")
    metaData.needTurtle = true
    conditionsMet, skipReason = enterprise_assignmentboard.MetaDataConditionsMet(metaData, assignmentFilter, turtleResume)
    expectedconditionsMet = false
    assert(conditionsMet == expectedconditionsMet, "gotten conditionsMet(="..tostring(conditionsMet)..") not the same as expected(="..tostring(expectedconditionsMet)..")")
    turtleResume = { }

    -- test needTurtleId
    corelog.WriteToLog("  # Test needTurtleId (other id)")
    turtleResume.turtleId = computerId
    metaData.needTurtleId = computerId + 1000
    conditionsMet, skipReason = enterprise_assignmentboard.MetaDataConditionsMet(metaData, assignmentFilter, turtleResume)
    expectedconditionsMet = false
    assert(conditionsMet == expectedconditionsMet, "gotten conditionsMet(="..tostring(conditionsMet)..") not the same as expected(="..tostring(expectedconditionsMet)..")")
    metaData.needTurtleId = computerId

    corelog.WriteToLog("  # Test needTurtleId (current id)")
    conditionsMet, skipReason = enterprise_assignmentboard.MetaDataConditionsMet(metaData, assignmentFilter, turtleResume)
    expectedconditionsMet = true
    assert(conditionsMet == expectedconditionsMet, "gotten conditionsMet(="..tostring(conditionsMet)..") not the same as expected(="..tostring(expectedconditionsMet)..")")
    metaData.needTurtleId = nil

    -- test fuelNeeded
    -- ToDo: consider also testing with turtleResume.location
    corelog.WriteToLog("  # Test fuelNeeded (not enough)")
    turtleResume.fuelLevel = 100
    metaData.fuelNeeded = 10000
    conditionsMet, skipReason = enterprise_assignmentboard.MetaDataConditionsMet(metaData, assignmentFilter, turtleResume)
    expectedconditionsMet = false
    assert(conditionsMet == expectedconditionsMet, "gotten conditionsMet(="..tostring(conditionsMet)..") not the same as expected(="..tostring(expectedconditionsMet)..")")

    corelog.WriteToLog("  # Test fuelNeeded (enough)")
    metaData.fuelNeeded = turtleResume.fuelLevel - 10
    conditionsMet, skipReason = enterprise_assignmentboard.MetaDataConditionsMet(metaData, assignmentFilter, turtleResume)
    expectedconditionsMet = true
    assert(conditionsMet == expectedconditionsMet, "gotten conditionsMet(="..tostring(conditionsMet)..") not the same as expected(="..tostring(expectedconditionsMet)..")")

    -- test need pickaxe
    corelog.WriteToLog("  # Test need pickaxe (not needed)")
    conditionsMet, skipReason = enterprise_assignmentboard.MetaDataConditionsMet(metaData, assignmentFilter, turtleResume)
    expectedconditionsMet = true
    assert(conditionsMet == expectedconditionsMet, "gotten conditionsMet(="..tostring(conditionsMet)..") not the same as expected(="..tostring(expectedconditionsMet)..")")

    corelog.WriteToLog("  # Test need pickaxe (not present)")
    turtleResume.axePresent = false
    metaData.needTool = true
    conditionsMet, skipReason = enterprise_assignmentboard.MetaDataConditionsMet(metaData, assignmentFilter, turtleResume)
    expectedconditionsMet = false
    assert(conditionsMet == expectedconditionsMet, "gotten conditionsMet(="..tostring(conditionsMet)..") not the same as expected(="..tostring(expectedconditionsMet)..")")

    corelog.WriteToLog("  # Test need pickaxe (present)")
    turtleResume.axePresent = true
    conditionsMet, skipReason = enterprise_assignmentboard.MetaDataConditionsMet(metaData, assignmentFilter, turtleResume)
    expectedconditionsMet = true
    assert(conditionsMet == expectedconditionsMet, "gotten conditionsMet(="..tostring(conditionsMet)..") not the same as expected(="..tostring(expectedconditionsMet)..")")
    metaData.needTool = false

    -- test itemsNeeded
    corelog.WriteToLog("  # Test itemsNeeded (empty inventory)")
    turtleResume.inventoryItems = {}
    local itemsNeeded = {
        ["minecraft:torch"] = 10,
        ["minecraft:chest"] = 1,
    }
    metaData.itemsNeeded = itemsNeeded
    conditionsMet, skipReason = enterprise_assignmentboard.MetaDataConditionsMet(metaData, assignmentFilter, turtleResume)
    expectedconditionsMet = false
    assert(conditionsMet == expectedconditionsMet, "gotten conditionsMet(="..tostring(conditionsMet)..") not the same as expected(="..tostring(expectedconditionsMet)..")")

    corelog.WriteToLog("  # Test itemsNeeded (some in inventory)")
    turtleResume.inventoryItems = {
        ["minecraft:torch"] = 20,
    }
    conditionsMet, skipReason = enterprise_assignmentboard.MetaDataConditionsMet(metaData, assignmentFilter, turtleResume)
    expectedconditionsMet = false
    assert(conditionsMet == expectedconditionsMet, "gotten conditionsMet(="..tostring(conditionsMet)..") not the same as expected(="..tostring(expectedconditionsMet)..")")

    corelog.WriteToLog("  # Test itemsNeeded (all in inventory)")
    turtleResume.inventoryItems = {
        ["minecraft:torch"] = 20,
        ["minecraft:chest"] = 2,
    }
    conditionsMet, skipReason = enterprise_assignmentboard.MetaDataConditionsMet(metaData, assignmentFilter, turtleResume)
    expectedconditionsMet = true
    assert(conditionsMet == expectedconditionsMet, "gotten conditionsMet(="..tostring(conditionsMet)..") not the same as expected(="..tostring(expectedconditionsMet)..")")
    metaData.itemsNeeded = {}

    -- test other conditions
    corelog.WriteToLog("  # Test Other conditions")
    conditionsMet, skipReason = enterprise_assignmentboard.MetaDataConditionsMet(metaData, assignmentFilter, turtleResume)
    if not conditionsMet then
        corelog.WriteToLog("    ondition not met: "..skipReason)
    else
        corelog.WriteToLog("    conditions met")
    end

    -- cleanup test
end

function t_assignmentboard.T_BestCandidate()
    -- prepare test
    corelog.WriteToLog("* enterprise_assignmentboard.BestCandidate() tests")
    -- init candidate 1
    local now = coreutils.UniversalTime()
    local metaData1 = {
        startTime = now,
        needTurtle = true,
        needTurtleId = nil,
        needTool = true,
        fuelNeeded = 0,
        itemsNeeded = {},
        location = nil,
    }
    local assignmentId1  = coreutils.NewId()
    local candidateData1 = {
        id = assignmentId1,
        metaData = metaData1,
    }

    -- init candidate 2
    local metaData2 = {
        startTime = now,
        needTurtle = true,
        needTurtleId = nil,
        needTool = true,
        fuelNeeded = 0,
        itemsNeeded = {},
        location = nil,
    }
    local assignmentId2  = coreutils.NewId()
    local candidateData2 = {
        id = assignmentId2,
        metaData = metaData2,
    }

    -- test needTurtleId
    corelog.WriteToLog("  # Test needTurtleId is a preferred candidate")
    local currentTurtleId = os.getComputerID()
    candidateData2.metaData.needTurtleId = currentTurtleId
    local bestCandidate = enterprise_assignmentboard.BestCandidate(candidateData1, candidateData2)
    assert(bestCandidate == candidateData2, "gotten BestCandidate(="..textutils.serialize(bestCandidate, compact)..") not the same as expected(="..textutils.serialize(candidateData2, compact)..")")
    candidateData2.metaData.needTurtleId = nil

    -- cleanup test
end

function t_assignmentboard.T_GetStatistics_Att()
    -- prepare test
    corelog.WriteToLog("* enterprise_assignmentboard.GetStatistics_Att() test")
    enterprise_assignmentboard.Reset()

    -- test
    local statistics = enterprise_assignmentboard.GetStatistics_Att()
    local maxFuelNeed_Assignment = statistics.maxFuelNeed_Assignment
    local expectedFuelNeed = 0
--    corelog.WriteToLog("   "..maxFuelNeed_Assignment.." maxFuelNeed_Assignment")
    assert(maxFuelNeed_Assignment == expectedFuelNeed, "gotten maxFuelNeed_Assignment(="..maxFuelNeed_Assignment..") not the same as expected(="..expectedFuelNeed..")")
    local maxFuelNeed_Travel = statistics.maxFuelNeed_Travel
    expectedFuelNeed = 0
--    corelog.WriteToLog("   "..maxFuelNeed_Travel.." maxFuelNeed_Travel")
    assert(maxFuelNeed_Travel == expectedFuelNeed, "gotten maxFuelNeed_Travel(="..maxFuelNeed_Travel..") not the same as expected(="..expectedFuelNeed..")")

    -- cleanup test
end

local testValue = 20
local callbackTestValue = "some callback data"

function t_assignmentboard.T_DoAssignment_ASrv()
    -- prepare test
    corelog.WriteToLog("* enterprise_assignmentboard.DoAssignment_ASrv() tests")

    -- create assignment arguments
    local taskData = {
        arg1 = testValue
    }
    local metaData = {
        startTime = coreutils.UniversalTime(),
        location = Location:newInstance(0, 0, 1, 0, 1),
        needTool = false,
        needTurtle = false,
        fuelNeeded = 0
    }
    local taskCall = TaskCall:newInstance("role_test", "Func1_Task", taskData)
    local callback = Callback:newInstance("t_assignmentboard", "DoAssignment_ASrv_Callback", { [0] = callbackTestValue })
    local assignmentServiceData = {
        metaData    = metaData,
        taskCall    = taskCall,
    }

    -- test
    corelog.WriteToLog(">starting task "..textutils.serialize(taskCall, { compact = true }))
    local result = enterprise_assignmentboard.DoAssignment_ASrv(assignmentServiceData, callback)
    assert(result == true, "failed scheduling assignment")

    -- cleanup test
end

function t_assignmentboard.DoAssignment_ASrv_Callback(callbackData, taskResults)
    -- test (cont)
    assert(taskResults.success, "failed executing async service")
    local arg1 = taskResults.input
    local expectedArg1 = testValue
    assert(arg1 == expectedArg1, "gotten arg1(="..arg1..") not the same as expected(="..expectedArg1..")")
    local callbackValue = callbackData[0]
    local expectedCallbackValue = callbackTestValue
    assert(callbackValue == expectedCallbackValue, "gotten callbackValue(="..(callbackValue or "nil")..") not the same as expected(="..expectedCallbackValue..")")

    -- cleanup test
end

return t_assignmentboard
