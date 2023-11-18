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
local coreevent  = require "coreevent"
local corelog    = require "corelog"
local coremove   = require "coremove"

local InputChecker = require "input_checker"

local enterprise_assignmentboard = require "enterprise_assignmentboard"
local enterprise_employment

local db = {
    rejectAllAssignments    = false,
    reboot                  = false,
}
local protocol          = "core:assignment"


-- local function needs to be declared before setup
function coreassignment.DoEventReboot(subject, envelope)
    -- set to reboot
    db.reboot = true
end

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
    -- naar deze events luisteren
    coreevent.AddEventListener(DoEventReboot,    protocol, "reboot")

    -- pas als de dht klaar is...
    coredht.DHTReadyFunction(enterprise_assignmentboard.DHTReadySetup) -- ToDo: consider doing this in enterprise_assignmentboard itself
end

function coreassignment.Run()
    -- is the dht available?
    while not coredht.IsReady() do
        -- just wait
        os.sleep(0.25)
    end

    -- get current workerLocator
    enterprise_employment = enterprise_employment or require "enterprise_employment"
    local workerLocator = enterprise_employment:getCurrentWorkerLocator() if not workerLocator then corelog.Error("coreassignment.Run: Failed obtaining current workerLocator") return false end

    -- activate Worker
    local workerObj = enterprise_employment:getObject(workerLocator) if not workerObj then corelog.Error("coreassignment.Run: Failed obtaining Worker "..workerLocator:getURI()) return false end
    workerObj:activate()
    enterprise_employment:saveObject(workerObj)

    -- infinite loop
    while coresystem.IsRunning() and not db.rejectAllAssignments do
        -- get Worker
        workerObj = enterprise_employment:getObject(workerLocator) if not workerObj then corelog.Error("coreassignment.Run: Failed obtaining Worker "..workerLocator:getURI()) return false end
        -- note: we getObject every loop as it might have changed

        -- only take work when active
        if workerObj:isActive() then
            -- find best next Worker assignment
            local assignmentFilter = workerObj:getAssignmentFilter()
            local workerId = workerObj:getWorkerId()
            local workerResume = workerObj:getWorkerResume()
            -- ToDo: consider if an assignment board should determine what is best...
            local serviceResults = enterprise_assignmentboard.FindBestAssignment_SSrv({ assignmentFilter = assignmentFilter, workerResume = workerResume })
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
                DoAssignment(workerLocator, nextAssignment)
            else
                -- apparently no assignment for me now

                -- update status
                corelog.SetStatus("assignment", "Idle (no assignment)", coremove.GetLocationAsString(), coremove.GetDirectionAsString())
            end
        end

        -- just wait a (quarter of a) second to try again
        if db.reboot then os.reboot() end
        os.sleep(0.25)
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

function DoAssignment(...)
    -- get & check input from description
    local checkSuccess, workerLocator, assignmentId, taskCall, callback  = InputChecker.Check([[
        Execute an assignment on a Worker

        Return value:

        Parameters:
            workerLocator               + (URL) locating the Worker
            assignment                  - (table) location of first tree of the forest
                assignmentId            + (string) with id of the assignment
                taskCall                + (TaskCall) with the task to call
                callback                + (Callback) with the callback to call
    ]], ...)
    if not checkSuccess then corelog.Error("coreassignment.DoAssignment: Invalid input") return {success = false} end

    -- we have taken this assignment!
    enterprise_assignmentboard.TakeAssignment(assignmentId)

    -- enhance task data with Worker executing the task
    if not taskCall._data.workerLocator then
        taskCall._data.workerLocator = workerLocator
    end

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
