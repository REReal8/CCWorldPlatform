-- define module
local coreassignment = {}

--[[
    coreassignment offers functionality to have turtles execute assignments advertised by enterprise_assignmentboard.

    An assignment revolves around a Task. A Task is a sequence of things that needs to be done (i.e. moving, rotating, placing etc) without interruption
    in the physical minecraft world. A Task typically takes some time to execute.

    Two functions are involved with each assignment:
        - a task function defining the Task that needs to be executed.
        - a Callback that needs to be executed once the task has completed.

    A task function should take one parameter
        taskData                - (table) data to supply to task function to be able to perform the task
    and return a single result
        taskResult              - (table) with return data of the task function
    By convention a task function name should end with _Task (e.g. DoSomeWork_Task)
--]]

local coresystem = require "coresystem"
local coredht    = require "coredht"
local corelog    = require "corelog"
local coremove   = require "coremove"

local Callback   = require "obj_callback"
local TaskCall   = require "obj_task_call"
local Location  = require "obj_location"

local enterprise_assignmentboard = require "enterprise_assignmentboard"
local enterprise_turtle

local db = {
    rejectAllAssignments    = false,
}

--                _     _ _         __                  _   _
--               | |   | (_)       / _|                | | (_)
--    _ __  _   _| |__ | |_  ___  | |_ _   _ _ __   ___| |_ _  ___  _ __  ___
--   | '_ \| | | | '_ \| | |/ __| |  _| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
--   | |_) | |_| | |_) | | | (__  | | | |_| | | | | (__| |_| | (_) | | | \__ \
--   | .__/ \__,_|_.__/|_|_|\___| |_|  \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
--   | |
--   |_|

function coreassignment.Init()
end

function coreassignment.Setup()
    -- pas als de dht klaar is...
    coredht.DHTReadyFunction(enterprise_assignmentboard.DHTReadySetup) -- ToDo: consider doing this in enterprise_assignmentboard itself
end

function coreassignment.Run()
    -- is the dht available?
    while not coredht.IsReady() do
        -- just wait
        os.sleep(0.25)
    end

    -- only turtles take assignments
    if not turtle then corelog.WriteToLog("coreassignment.Run(): Not a turtle, not taking assignments") return false end

    -- get (locator for) current Worker
    enterprise_turtle = enterprise_turtle or require "enterprise_turtle"
    local workerLocator = enterprise_turtle:getCurrentTurtleLocator() if not workerLocator then corelog.Error("coreassignment.Run: Failed obtaining current workerLocator") return false end
    -- register current Worker if not yet registered
    local objResourceTable = enterprise_turtle:getResource(workerLocator)
    if not objResourceTable then
        local workerId = os.getComputerID()
        local coremove_location = Location:new(coremove.GetLocation())
        workerLocator = enterprise_turtle:hostMObj_SSrv({ className = "Turtle", constructParameters = {
            workerId    = workerId,
            location    = coremove_location,
        }}).mobjLocator
        if not workerLocator then corelog.Error("coreassignment.Run: Failed hosting Worker "..workerId) return false end
    end

    -- infinite loop
    while coresystem.IsRunning() and not db.rejectAllAssignments do
        -- get Worker
        local workerObj = enterprise_turtle:getObject(workerLocator) if not workerObj then corelog.Error("coreassignment.Run: Failed obtaining Worker "..workerLocator:getURI()) return false end

        -- find best next Worker assignment
        local assignmentFilter = workerObj:getAssignmentFilter()
        local workerId = workerObj:getWorkerId()
        local workerResume = workerObj:getWorkerResume()
        -- ToDo: consider if an assignment board should determine what is best...
        local serviceResults = enterprise_assignmentboard.FindBestAssignment_SSrv({ assignmentFilter = assignmentFilter, turtleResume = workerResume })
        if not serviceResults.success then corelog.Error("coreassignment.Run: FindBestAssignment_SSrv failed.") return false end
        local bestAssignmentId = serviceResults.assignmentId

        -- apply if we found a suitable assignment
        local nextAssignment = nil
        if bestAssignmentId then
            -- apply
            enterprise_assignmentboard.ApplyToAssignment(workerId, bestAssignmentId)

            -- wait, maybe more turtles have applied
            os.sleep(1.25)

            -- check who gets the assignment
            nextAssignment = enterprise_assignmentboard.AssignmentSelectionProcedure(workerId, bestAssignmentId)
        end

        -- did we get an assignment?
        if nextAssignment then
            -- do the assignment
            DoAssignment(nextAssignment)
        else
            -- update status
            corelog.SetStatus("assignment", "Idle (no assignment)", coremove.GetLocationAsString(), coremove.GetDirectionAsString())

            -- just wait a (quarter of a) second
            os.sleep(0.25)     -- apparently no assignment for me now
        end
    end
end

function coreassignment.RejectAllAssignments()
    -- just remember for now, nothing else
    db.rejectAllAssignments = true
end

function coreassignment.Reset()
    -- reset (local) db
    db.rejectAllAssignments                     = false
end

--    _                 _    __                  _   _
--   | |               | |  / _|                | | (_)
--   | | ___   ___ __ _| | | |_ _   _ _ __   ___| |_ _  ___  _ __  ___
--   | |/ _ \ / __/ _` | | |  _| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
--   | | (_) | (_| (_| | | | | | |_| | | | | (__| |_| | (_) | | | \__ \
--   |_|\___/ \___\__,_|_| |_|  \__,_|_| |_|\___|\__|_|\___/|_| |_|___/

function DoAssignment(assignment)
    -- we have taken this assignment!
    local assignmentId = assignment.assignmentId
    enterprise_assignmentboard.TakeAssignment(assignmentId)

    -- get & check CallDef's
    local taskCall = TaskCall:new(assignment.taskCall)
    if not taskCall then corelog.Error("coreassignment.DoAssignment: Invalid taskCall for assignment "..assignmentId) return end
    local callback = Callback:new(assignment.callback)
    if not callback then corelog.Error("coreassignment.DoAssignment: Invalid callback for assignment "..assignmentId) return end

    -- call task function
    corelog.WriteToAssignmentLog("Starting task", assignmentId)
--    corelog.WriteToLog("Starting "..taskCall:getModuleName().."."..taskCall:getMethodName())
    corelog.SetStatus("assignment", "Module: "..taskCall:getModuleName(), "Method: "..taskCall:getMethodName())
    local taskResult = taskCall:call()
    corelog.WriteToAssignmentLog("Completed task (result="..textutils.serialize(taskResult)..")", assignmentId)

    -- call callBack function
    corelog.WriteToAssignmentLog("Calling callback function", assignmentId)
    callback:call(taskResult)

    -- we have done all for this assignment that we needed to do
    enterprise_assignmentboard.EndAssignment(assignmentId)
end

return coreassignment
