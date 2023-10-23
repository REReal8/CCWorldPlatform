-- define module
local enterprise_assignmentboard = {}

--[[
    The AssignmentBoard is an enterprise that offers services for the handling of Assignments.

    Assignments allow for a sequence of things to be done (e.g. moving, rotating, placing etc) without interruption
    by a turtle in the physical minecraft world.

    The enterprise maintains a list of assignments that were posted to it. It offers services for finding, applying to,
    selecting, taking and ending (removing) these assignments.

    It does so by providing the following public services
        DoAssignment_ASrv       - to post an Assignment for execution via the enterprise
        FindBestAssignment_SSrv - finds the best available Assignment
--]]

local coreutils = require "coreutils"
local corelog = require "corelog"
local coredht = require "coredht"

local InputChecker = require "input_checker"
local Callback = require "obj_callback"
local Location = require "obj_location"

local role_energizer = require "role_energizer"

local db = {
    dhtRoot         = "enterprise_assignmentboard",
    dhtList         = "assignmentList",
    dhtStatistics   = "statistics",

    skipReasons = {},
}

--                _     _ _         __                  _   _
--               | |   | (_)       / _|                | | (_)
--    _ __  _   _| |__ | |_  ___  | |_ _   _ _ __   ___| |_ _  ___  _ __  ___
--   | '_ \| | | | '_ \| | |/ __| |  _| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
--   | |_) | |_| | |_) | | | (__  | | | |_| | | | | (__| |_| | (_) | | | \__ \
--   | .__/ \__,_|_.__/|_|_|\___| |_|  \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
--   | |
--   |_|

function enterprise_assignmentboard.DoAssignment_ASrv(...)
    -- get & check input from description
    local checkSuccess, metaData, taskCall, callback = InputChecker.Check([[
        This async public service posts an Assignment for execution via the enterprise.

        The Assignment is not necessarily directly executed. It is added to the list of assignments in the
        enterprise and serviced via it's services for eventual execution.

        Return value:
                                    - (boolean) whether the assignment was scheduled successfully

        Async service return value (to Callback):
                                    - (table) results of the task function
                success             - (boolean) whether the task executed successfully

        Parameters:
            serviceData             - (table) data for this service
                metaData            + (table) with metadata on the Task (used in the the assignment selection proces (e.g. the fuel needs of the task))
                taskCall            + (TaskCall) to call to execute the assignment
            callback                + (Callback) to call once service (assignment) is ready
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("enterprise_assignmentboard.DoAssignment_ASrv: Invalid input") return Callback.ErrorCall(callback) end

    -- set metaData defaults  ToDo: consider doing with CheckInput
    metaData.startTime      = metaData.startTime    or coreutils.UniversalTime()    --> tijd wanneer de assignment uitgevoerd moet worden, zal niet starten voor deze tijd
    metaData.location       = metaData.location     or nil      --> nil-waarde voor locatie geeft aan dat locatie geen rol speelt bij de selectie
    metaData.needTool       = metaData.needTool     or false    --> needTool geeft aan dat de turtle zelf voor een tool moet zorgen
    metaData.needTurtle     = metaData.needTurtle   or true
    metaData.needTurtleId   = metaData.needTurtleId or nil      --> nil-waarde voor needTurtleId geeft aan dat workerId geen rol speelt bij de selectie
    metaData.fuelNeeded     = metaData.fuelNeeded   or 500      --> minimum amount of fuel needed to grant assignment
    metaData.itemsNeeded    = metaData.itemsNeeded  or {}       --> items needed in inventory to grant assignment
    metaData.priorityKey    = metaData.priorityKey  or ""       --> priorityKey given to assignment (it fuelTurtlePriorityKey is set for a turtle, it will only take assignments with that key)

    -- create assignment
    local assignmentId  = coreutils.NewId()
    local assignment = {
        assignmentId            = assignmentId,
        status                  = "open",
        applications            = {},

        metaData                = metaData,
        taskCall                = taskCall,
        callback                = callback,
    }

    -- log assignment
    corelog.WriteToAssignmentLog("Add new: "..textutils.serialize(assignment), assignmentId)

    -- check for new locations
    -- ToDo: consider introducing Statistics object with Location objects in it. Than have it saved and gotten as a Resource similair to how this is e.g. done for a BirchForest.
    local statistics = enterprise_assignmentboard.GetStatistics_Att()
    local statisticsChanged = false
    local location = metaData.location
    if location then
        -- min
        local minLocation = Location:new(statistics.minLocation)
        local newMinLocation = minLocation:minLocation(location)
        if not minLocation:isEqual(newMinLocation) then
            -- set new value
            statistics.minLocation = newMinLocation
            statisticsChanged = true
        end

        -- max
        local maxLocation = Location:new(statistics.maxLocation)
        local newMaxLocation = maxLocation:maxLocation(location)
        if not maxLocation:isEqual(newMaxLocation) then
            -- set new value
            statistics.maxLocation = newMaxLocation
            statisticsChanged = true
        end

        -- maxFuelNeed_Travel
        if statisticsChanged then
            statistics.maxFuelNeed_Travel = role_energizer.NeededFuelToFrom(newMinLocation, newMaxLocation)
        end
    end

    -- check for higher fuelNeed
    local fuelNeed = metaData.fuelNeeded
    if fuelNeed > statistics.maxFuelNeed_Assignment then
        -- set new value
        statistics.maxFuelNeed_Assignment = fuelNeed
        statisticsChanged = true
    end

    -- save statistics
    if statisticsChanged then
        -- save statistics
        coredht.SaveData(statistics, db.dhtRoot, db.dhtStatistics)
    end

    -- store assignment
    coredht.SaveData(assignment, db.dhtRoot, db.dhtList, assignmentId)

    -- end
    return true -- note: this implies scheduling the assignment was succesfull, it will be executed once it is pickedup by a turtle
end

local function ResetStatistics()
    return coredht.SaveData({
        maxFuelNeed_Assignment  = 0,
        minLocation             = Location:newInstance(3, 2, 1, 0, 1),
        maxLocation             = Location:newInstance(3, 2, 1, 0, 1),
        maxFuelNeed_Travel      = 0,
    }, db.dhtRoot, db.dhtStatistics)
end

function enterprise_assignmentboard.GetStatistics_Att()
    -- get statistics
    local statistics = coredht.GetData(db.dhtRoot, db.dhtStatistics)
    if not statistics then statistics = ResetStatistics() end

    return statistics
end

local function ForgetSkipReasons()
    db.skipReasons = {}
end

local function RememberSkipReason(skipReason)
    table.insert(db.skipReasons, skipReason)
end

local function KnownSkipReason(skipReason)
    -- check skipReason is known
    for i, prevSkipReason in ipairs(db.skipReasons) do
        if skipReason == prevSkipReason then return true end
    end

    -- end
    return false
end

function enterprise_assignmentboard.FindBestAssignment_SSrv(...)
    -- get & check input from description
    local checkSuccess, assignmentFilter, workerResume = InputChecker.Check([[
        This sync public service finds the best available Assignment for a Worker based on an assignmentFilter and workerResume.

        Return value:
                                    - (table)
                success             - (boolean) whether the service executed successfully
                assignmentId        - (string) id of found assignment (==nil if no assignment was found)

        Parameters:
            serviceData             - (table) data for this service
                assignmentFilter    + (table) filter to apply in finding an Assignment
                workerResume        + (table) Worker "resume" to consider in finding an Assignment
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("enterprise_assignmentboard.FindBestAssignment_SSrv: Invalid input") return {success = false} end

    -- zoeken naar een assignment om op in te schrijven
    local assignmentList = coredht.GetData(db.dhtRoot, db.dhtList)

    -- check assignmentList
    if not assignmentList or type(assignmentList) ~= "table" then corelog.Error("enterprise_assignmentboard.FindBestAssignment: Invalid assignmentList") return {success = false} end

    -- check for assignments
    if next(assignmentList) == nil then
--        corelog.WriteToAssignmentLog("There are no assignments")
        return { success = true }
    end

    -- select assignments satisfying meta conditions
    local candidateList = {}
    for assignmentId, assignmentData in pairs(assignmentList) do
        -- check assignment open
        if assignmentData.status == "open" then
            -- check metaconditions
            local conditionsMet, skipReason = enterprise_assignmentboard.MetaDataConditionsMet(assignmentData.metaData, assignmentFilter, workerResume)
            if conditionsMet then
                table.insert(candidateList, {
                    id = assignmentId,
                    metaData = assignmentData.metaData,
                })
            else
                -- debug message
                if skipReason and not KnownSkipReason(skipReason) then
                    -- Report reason for skipping for debugging purposes
                    corelog.WriteToAssignmentLog("Skipped because "..skipReason, assignmentId)

                    -- remember such that the log isn't floaded with similar messages
                    RememberSkipReason(skipReason)
                end
            end
        end
    end

    -- select best assignment
    local bestCandidateData = nil
    for i, candidateData in ipairs(candidateList) do
        bestCandidateData = enterprise_assignmentboard.BestCandidate(bestCandidateData, candidateData)
    end

    -- end
    if bestCandidateData then
        -- we found a new candidate, forget the reasons we skipped until now
        ForgetSkipReasons()

        -- return best candidate
        local result = {
            success         = true,
            assignmentId    = bestCandidateData.id
        }
        return result
    else
        -- corelog.WriteToAssignmentLog("No assignment satisfying conditions")
        return { success = true }
    end
end

function enterprise_assignmentboard.ApplyToAssignment(...)
    -- get & check input from description
    local checkSuccess, computerId, assignmentId = InputChecker.Check([[
        This function ensures the application of a computer 'computerId' to assignment 'assignmentId'.

        Return value:

        Parameters:
            computerId              + (number) id of computer
            assignmentId            + (string) id of the assignment
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("enterprise_assignmentboard.ApplyToAssignment: Invalid input") return nil end

    -- only apply when the assignment is open
    if coredht.GetData(db.dhtRoot, db.dhtList, assignmentId, "status") == "open" then
        -- add computer to the application list
        coredht.SaveData({
            time            = coreutils.UniversalTime(),
            dice            = math.random(),
            applicant       = computerId,
        }, db.dhtRoot, db.dhtList, assignmentId, "applications", computerId)
    end
end

function enterprise_assignmentboard.AssignmentSelectionProcedure(...)
    -- get & check input from description
    local checkSuccess, computerId, assignmentId = InputChecker.Check([[
        This function determines if a computer 'computerId' is selected to perform an assignment.

        Return value:
            assignment              + (table) with the assignment (data) or nil if the computer was not selected

        Parameters:
            computerId              + (number) id of computer
            assignmentId            + (string) id of the assignment
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("enterprise_assignmentboard.ApplyToAssignment: Invalid input") return nil end

    -- get assignment data
    local assignment = coredht.GetData(db.dhtRoot, db.dhtList, assignmentId)

    -- see if this assignment is still open
    if type(assignment) == "table" and assignment.status == "open" then
        -- get applications to assignment
        local applications = coredht.GetData(db.dhtRoot, db.dhtList, assignmentId, "applications")
        if type(applications) ~= "table" then corelog.Error("enterprise_assignmentboard.ApplyToAssignment: failed obtaining applications to assignment") return nil end

        -- see who got the highest dice
        local highestDiceTurtle = nil
        local highestDiceValue = 0
        for _, applicationData in pairs(applications) do
            if applicationData.dice >= highestDiceValue then
                highestDiceValue = applicationData.dice
                highestDiceTurtle = applicationData.applicant
            end
        end

        -- check if computer got the highest dice
        if highestDiceTurtle == computerId then
            return assignment
        end
    end

    -- apparently it's not for this computer
    return nil
end

function enterprise_assignmentboard.TakeAssignment(assignmentId) -- ToDo: make this a proper sync service
    -- data van de assignment ophalen
    local assignment = coredht.GetData(db.dhtRoot, db.dhtList, assignmentId)

    -- see if this assignment is still open
    if type(assignment) == "table" and assignment.status == "open" then
        -- mark as staffed
        coredht.SaveData("staffed", db.dhtRoot, db.dhtList, assignmentId, "status")

        corelog.WriteToAssignmentLog("Taken", assignmentId)
    end
end

function enterprise_assignmentboard.EndAssignment(assignmentId) -- ToDo: make this a proper sync service
    -- easy
    coredht.SaveData(nil, db.dhtRoot, db.dhtList, assignmentId)
    corelog.WriteToAssignmentLog("Ended", assignmentId)
end

function enterprise_assignmentboard.Reset()
    -- end assignments
    enterprise_assignmentboard.EndAssignments()

    -- reset statistics
    ResetStatistics()

    -- reset (local) db
    db.skipReasons  = {}
end

--    _                 _    __                  _   _
--   | |               | |  / _|                | | (_)
--   | | ___   ___ __ _| | | |_ _   _ _ __   ___| |_ _  ___  _ __  ___
--   | |/ _ \ / __/ _` | | |  _| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
--   | | (_) | (_| (_| | | | | | |_| | | | | (__| |_| | (_) | | | \__ \
--   |_|\___/ \___\__,_|_| |_|  \__,_|_| |_|\___|\__|_|\___/|_| |_|___/

function enterprise_assignmentboard.EndAssignments()
    local assignmentList = coredht.GetData(db.dhtRoot, db.dhtList)
    if not assignmentList or type(assignmentList) ~= "table" then corelog.Warning("enterprise_assignmentboard.EndAssignments: not a (valid) assignmentList") return nil end

    -- remove all assignments
    corelog.WriteToAssignmentLog("All Assignments are being ended!")
    for assignmentId, assignmentData in pairs(assignmentList) do
        -- check status and startTime
        enterprise_assignmentboard.EndAssignment(assignmentId)
    end
end

function enterprise_assignmentboard.DHTReadySetup()
    -- bestaat de entry al in de dht?
    if not coredht.GetData(db.dhtRoot)             then coredht.SaveData({}, db.dhtRoot ) end
    if not coredht.GetData(db.dhtRoot, db.dhtList) then coredht.SaveData({}, db.dhtRoot, db.dhtList ) end
end

function enterprise_assignmentboard.BestCandidate(candidateData1, candidateData2)
    -- check for data
    if not candidateData1 then
        return candidateData2
    end
    if not candidateData2 then
        return candidateData1
    end

    -- check needTurtleId
    local needTurtleId1 = candidateData1.metaData.needTurtleId
    local needTurtleId2 = candidateData2.metaData.needTurtleId
    if needTurtleId1 and not needTurtleId2 then
        return candidateData1
    elseif needTurtleId2 and not needTurtleId1 then
        return candidateData2
    else -- both are equal w.r.t. this condition
    end

    -- check fuelNeeded
    -- ToDo implement

    -- check age
    -- ToDo implement

    -- nothing else distinquishes the candidates => take first
    return candidateData1
end

function enterprise_assignmentboard.MetaDataConditionsMet(metaData, assignmentFilter, workerResume)
    -- check startTime
    local now = coreutils.UniversalTime()
    if metaData.startTime > now then
        return false, "assignment in the future (="..metaData.startTime..")"
    end

    -- check priorityKeyNeeded
    local priorityKeyNeeded = assignmentFilter.priorityKeyNeeded
    if priorityKeyNeeded ~= "" then
        if metaData.priorityKey ~= priorityKeyNeeded then
            return false, "assignment does not `have`(="..(metaData.priorityKey or "nil")..") mandatory priorityKeyNeeded (="..priorityKeyNeeded..")"
        end
    end

    -- check optional turtle conditions
    if metaData.needTurtle then
        -- check mandatory turtle
        if not workerResume then
            return false, "mandatory turtle (resume) not present"
        end

        -- check needTurtleId
        local workerId = workerResume.workerId
        if metaData.needTurtleId then
            if workerId ~= metaData.needTurtleId then
                return false, "Worker does not have(="..workerId..") mandatory workerId (="..metaData.needTurtleId..")"
            end
        end

        -- check enough fuel for assignment
        local fuelNeeded = metaData.fuelNeeded
        if metaData.location then -- optionally include traveling to assignment location from current location
            local metaDataLocation = Location:new(metaData.location) -- ToDo: consider doing elsewhere
            local location = workerResume.location
            fuelNeeded = fuelNeeded + role_energizer.NeededFuelToFrom(metaDataLocation, location)
        end
        if fuelNeeded > 0 then
            -- check fuel available
            local fuelLevel = workerResume.fuelLevel
            if fuelLevel < fuelNeeded then
                return false, "turtle does not have(="..fuelLevel..") enough(="..fuelNeeded..") fuel"
            end
        end

        -- check need pickaxe
        if metaData.needTool then
            -- check mandatory pickaxe
            local axePresent = workerResume.axePresent
            if not axePresent then
                return false, "turtle does not have mandatory pickaxe"
            end
        end

        -- check itemsNeeded
        local inventoryItems = workerResume.inventoryItems
        for itemName, itemCount in pairs(metaData.itemsNeeded) do
            -- get items in inventory
            local availableItemCount = inventoryItems[itemName] or 0

            -- add possibly equiped items (i.e., tools)
            if workerResume.leftEquiped == itemName then
                availableItemCount = availableItemCount + 1
            end
            if workerResume.rightEquiped == itemName then
                availableItemCount = availableItemCount + 1
            end

            -- enough?
            if availableItemCount < itemCount then
                return false, "turtle does not have(="..availableItemCount..") enough(="..itemCount..") "..itemName.." available"
            end
        end
    end

    return true, ""
end

return enterprise_assignmentboard
