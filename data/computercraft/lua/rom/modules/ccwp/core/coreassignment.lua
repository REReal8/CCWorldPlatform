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
    if not turtle then corelog.WriteToLog("coreassignment.Run(): Not a turtle, not taking assignments") return end

    -- get (locator for) current Turtle
    enterprise_turtle = enterprise_turtle or require "enterprise_turtle"
    local turtleLocator = enterprise_turtle:GetCurrentTurtleLocator() if not turtleLocator then corelog.Error("coreassignment.Run: Failed obtaining current turtleLocator") return false end
    -- register current Turtle if not yet registered
    local objResourceTable = enterprise_turtle:getResource(turtleLocator)
    if not objResourceTable then
        local turtleId = os.getComputerID()
        local coremove_location = Location:new(coremove.GetLocation())
        turtleLocator = enterprise_turtle:hostMObj_SSrv({ className = "Turtle", constructParameters = {
            turtleId    = turtleId,
            location    = coremove_location,
        }}).mobjLocator
        if not turtleLocator then corelog.Error("coreassignment.Run: Failed hosting Turtle "..turtleId) return false end
    end

    -- infinite loop
    while coresystem.IsRunning() and not db.rejectAllAssignments do
        -- try get assignment for turtle
        local serviceResults = enterprise_turtle.GetAssignmentForTurtle_SSrv({ turtleLocator = turtleLocator })
        if not serviceResults or not serviceResults.success then corelog.Error("coreassignment.Run: failure in getting new assignment") end
        local nextAssignment = serviceResults.assignment

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
