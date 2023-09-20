local enterprise_test = {}

local coreutils = require "coreutils"
local corelog = require "corelog"

local InputChecker = require "input_checker"
local Callback = require "obj_callback"
local TaskCall = require "obj_task_call"

local Location = require "obj_location"

local enterprise_assignmentboard = require "enterprise_assignmentboard"

--[[
    The test enterprise offers test services for debugging/ testing purposes.
--]]

function enterprise_test.Test_SSrv(...)
    -- get & check input from description
    local checkSuccess, serviceData, testArg = InputChecker.Check([[
        This public sync service returns a test argument.

        Return value:
            success             - (boolean) whether the service executed successfully
            input               - (?) the test input argument

        Parameters:
            serviceData         + (table) data about the service
                testArg         + (?) as a test argument
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("enterprise_test.Test_SSrv: Invalid input") return {success = false} end

--    corelog.WriteToLog(">calling enterprise_test.Test_SSrv("..textutils.serialize(serviceData)..")")

    -- determine result to return
    local serviceResult = {
        success = true,
        input = testArg,
    }
    if type(serviceData.serviceResult) == "table" then
        serviceResult.success = serviceData.serviceResult.success
    end

    return serviceResult
end

function enterprise_test.Test_ASrv(...)
    -- get & check input from description
    local checkSuccess, testArg, callback = InputChecker.Check([[
        This public async service executes an assignment with a Callback.

        Return value:
                                - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                - (table)
                success         - (boolean) whether the service executed successfully
                input           - (?) the test input argument

        Parameters:
            serviceData         - (table) data about the service
                testArg         + (number) as a test argument
            callback            + (Callback) to call once service is ready
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("enterprise_test.Test_ASrv: Invalid input") return Callback.ErrorCall(callback) end

    -- create assignment arguments
    local taskData = {
        arg1 = testArg
    }
    local metaData = {
        startTime = coreutils.UniversalTime(),
        location = Location:newInstance(0, 0, 1, 0, 1),
        needTool = false,
        needTurtle = false,
        fuelNeeded = 0
    }

    -- do assignment
    local assignmentServiceData = {
        metaData    = metaData,
        taskCall    = TaskCall:newInstance("role_test", "Func1_Task", taskData),
    }
    return enterprise_assignmentboard.DoAssignment_ASrv(assignmentServiceData, callback)
end

return enterprise_test
