-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local TestObj = Class.NewClass(ObjBase)

local coreutils = require "coreutils"
local corelog = require "corelog"

local InputChecker = require "input_checker"
local Callback = require "obj_callback"
local TaskCall = require "obj_task_call"
local Location = require "obj_location"

local enterprise_assignmentboard = require "enterprise_assignmentboard"

--[[
    This module implements the class TestObj.

    A TestObj object can be used for testing object related functionality.
--]]

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function TestObj:_init(...)
    -- get & check input from description
    local checkSuccess, field1, field2 = InputChecker.Check([[
        Initialise a TestObj.

        Parameters:
            field1                  + (string) field
            field2                  + (number) field
    ]], ...)
    if not checkSuccess then corelog.Error("TestObj:_init: Invalid input") return nil end

    -- initialisation
    ObjBase._init(self)
    self._field1    = field1
    self._field2    = field2
end

-- ToDo: should be renamed to newFromTable at some point
function TestObj:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Constructs a TestObj.

        Parameters:
            o               + (table, {}) table with object fields
                _field1     - (string) field
                _field2     - (number) field
    ]], ...)
    if not checkSuccess then corelog.Error("TestObj:new: Invalid input") return {} end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- end
    return o
end

function TestObj:getField1()
    return self._field1
end

function TestObj:setField1(strValue)
    -- check input
    if type(strValue) ~= "string" then corelog.Error("TestObj:setField1: invalid strValue: "..type(strValue)) return end

    self._field1 = strValue
end

function TestObj:getField2()
    return self._field2
end

function TestObj:setField2(fieldValue)
    -- check input
    if type(fieldValue) ~= "number" then corelog.Error("TestObj:setField2: invalid fieldValue: "..type(fieldValue)) return end

    self._field2 = fieldValue
end

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

function TestObj:getClassName()
    return "TestObj"
end

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

function TestObj:field2Plus(...)
    -- get & check input from description
    local checkSuccess, addValue = InputChecker.Check([[
        This method returns the sum of field2 and addValue.

        Return value:
            input               - (?) the test input argument

        Parameters:
            addValue            + (number) value to add
    --]], ...)
    if not checkSuccess then corelog.Error("TestObj:field2Plus: Invalid input") return 99999 end

    -- determine sum
    local sum = self:getField2() + addValue

    -- end
    return sum
end

function TestObj:getTestArg(...)
    -- get & check input from description
    local checkSuccess, testArg = InputChecker.Check([[
        This public method returns a test argument.

        Return value:
            input               - (?) the test input argument

        Parameters:
            serviceData         - (table) data about the service
                testArg         + (?) as a test argument
    --]], ...)
    if not checkSuccess then corelog.Error("TestObj:getTestArg: Invalid input") return {success = false} end

    -- verify true object
    assert(Class.IsInstanceOf(self, TestObj), "TestObj:getTestArg: self(="..textutils.serialise(self)..") not of type TestObj")

    -- end
    return testArg
end

--                        _
--                       (_)
--    ___  ___ _ ____   ___  ___ ___  ___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \/ __|
--   \__ \  __/ |   \ V /| | (_|  __/\__ \
--   |___/\___|_|    \_/ |_|\___\___||___/

function TestObj:test_SOSrv(...)
    -- get & check input from description
    local checkSuccess, serviceData, testArg = InputChecker.Check([[
        This public sync service returns a test argument.

        Return value:
            success             - (boolean) whether the service executed successfully
            input               - (?) the test input argument

        Parameters:
            serviceData         + (table) data about the service
                testArg         + (?) as a test argument
    --]], ...)
    if not checkSuccess then corelog.Error("TestObj:test_SOSrv: Invalid input") return {success = false} end

    -- verify true object
    assert(Class.IsInstanceOf(self, TestObj), "TestObj:test_SOSrv: self(="..textutils.serialise(self)..") not of type TestObj")

    -- determine result to return
    local serviceResult = {
        success = true,
        input = testArg,
        selfObj = self,
    }
    if type(serviceData.serviceResult) == "table" then
        serviceResult.success = serviceData.serviceResult.success
    end

    return serviceResult
end

function TestObj:test_AOSrv(...)
    -- get & check input from description
    local checkSuccess, testArg, callback = InputChecker.Check([[
        This public async service executes an assignment with a callback function and callback data.

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
    --]], ...)
    if not checkSuccess then corelog.Error("TestObj:test_AOSrv: Invalid input") return Callback.ErrorCall(callback) end

    -- verify true object
    assert(Class.IsInstanceOf(self, TestObj), "TestObj:test_AOSrv: self(="..textutils.serialise(self)..") not of type TestObj")

    -- create assignment arguments
    local taskData = {
        input = testArg,
        selfObj = self,
    }
    local metaData = {
        startTime = coreutils.UniversalTime(),
        location = Location:newInstance(0, 0, 1, 0, 1),
        needTool = false,
        needTurtle = false,
        fuelNeeded = 0
    }

    -- do assignment
    local taskCall = TaskCall:newInstance("role_test", "Func2_Task", taskData)
    local assignmentServiceData = {
        metaData    = metaData,
        taskCall    = taskCall,
    }
    corelog.WriteToLog(">starting task "..textutils.serialize(taskCall, { compact = true }))
    return enterprise_assignmentboard.DoAssignment_ASrv(assignmentServiceData, callback)
end

return TestObj
