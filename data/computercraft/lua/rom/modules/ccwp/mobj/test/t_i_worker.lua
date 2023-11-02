local T_IWorker = {}
local corelog = require "corelog"

local IWorker = require "i_worker"

local T_IInterface = require "test.t_i_interface"
local T_Class = require "test.t_class"

local MethodResultTest = require "method_result_test"
local MultipleValuesTest = require "multiple_values_test"
local MethodResultEqualTest = require "method_result_equal_test"

function T_IWorker.pt_all(className, obj, objName, expectedWorkerLocation, workerResumeTest, isMainUIMenuTest, assignmentFilterTest, logOk)
    -- type
    T_IWorker.pt_IsInstanceOf_IWorker(className, obj)
    T_IWorker.pt_Implements_IWorker(className, obj)

    -- IWorker methods
    T_IWorker.pt_getWorkerId(className, obj, objName, nil, logOk)
    T_IWorker.pt_getWorkerLocation(className, obj, objName, expectedWorkerLocation, logOk)
    T_IWorker.pt_getWorkerResume(className, obj, objName, workerResumeTest, logOk)
    T_IWorker.pt_getMainUIMenu(className, obj, objName, isMainUIMenuTest, logOk)
    T_IWorker.pt_getAssignmentFilter(className, obj, objName, assignmentFilterTest, logOk)
end

--    _
--   | |
--   | |_ _   _ _ __   ___
--   | __| | | | '_ \ / _ \
--   | |_| |_| | |_) |  __/
--    \__|\__, | .__/ \___|
--         __/ | |
--        |___/|_|

function T_IWorker.pt_IsInstanceOf_IWorker(className, obj)
    -- prepare test
    assert(className, "no className provided")
    assert(obj, "no obj provided")

    -- test
    T_Class.pt_IsInstanceOf(className, obj, "IWorker", IWorker)
end

function T_IWorker.pt_Implements_IWorker(className, obj)
    -- prepare test
    assert(className, "no className provided")
    assert(obj, "no obj provided")

    -- test
    T_IInterface.pt_ImplementsInterface("IWorker", IWorker, className, obj)
end

--    _______          __        _
--   |_   _\ \        / /       | |
--     | |  \ \  /\  / /__  _ __| | _____ _ __
--     | |   \ \/  \/ / _ \| '__| |/ / _ \ '__|
--    _| |_   \  /\  / (_) | |  |   <  __/ |
--   |_____|   \/  \/ \___/|_|  |_|\_\___|_|

function T_IWorker.pt_getWorkerId(className, obj, objName, expectedWorkerId, logOk)
    -- prepare test
    assert(className, "no className provided")
    assert(obj, "no obj provided")
    assert(objName, "no objName provided")
    expectedWorkerId = expectedWorkerId or obj._workerId
    assert(type(logOk) == "boolean", "no logOk provided")
    corelog.WriteToLog("* "..className..":getWorkerId() tests")

    -- test
    local test = MethodResultEqualTest:newInstance("getWorkerId", expectedWorkerId)
    test:test(obj, objName, "", logOk)
end

function T_IWorker.pt_getWorkerLocation(className, obj, objName, expectedWorkerLocation, logOk)
    -- prepare test
    assert(className, "no className provided")
    assert(obj, "no obj provided")
    assert(objName, "no objName provided")
    assert(expectedWorkerLocation, "no expectedWorkerLocation provided")
    assert(type(logOk) == "boolean", "no logOk provided")
    corelog.WriteToLog("* "..className..":getWorkerLocation() tests")

    -- test
    local test = MethodResultEqualTest:newInstance("getWorkerLocation", expectedWorkerLocation)
    test:test(obj, objName, "", logOk)
end

function T_IWorker.pt_getWorkerResume(className, obj, objName, workerResumeTest, logOk)
    -- prepare test
    assert(className, "no className provided")
    assert(obj, "no obj provided")
    assert(objName, "no objName provided")
    assert(workerResumeTest, "no workerResumeTest provided")
    assert(type(logOk) == "boolean", "no logOk provided")
    corelog.WriteToLog("* "..className..":getWorkerResume() tests")

    -- test
    local test = MethodResultTest:newInstance("getWorkerResume", false, MultipleValuesTest:newInstance(workerResumeTest))
    test:test(obj, objName, "", logOk)
end

function T_IWorker.pt_getMainUIMenu(className, obj, objName, isMainUIMenuTest, logOk)
    -- prepare test
    assert(className, "no className provided")
    assert(obj, "no obj provided")
    assert(objName, "no objName provided")
    assert(isMainUIMenuTest, "no isMainUIMenuTest provided")
    assert(type(logOk) == "boolean", "no logOk provided")
    corelog.WriteToLog("* "..className..":getMainUIMenu() tests")

    -- test
    local test = MethodResultTest:newInstance("getMainUIMenu", false, MultipleValuesTest:newInstance(isMainUIMenuTest))
    test:test(obj, objName, "", logOk)
end

function T_IWorker.pt_getAssignmentFilter(className, obj, objName, assignmentFilterTest, logOk)
    -- prepare test
    assert(className, "no className provided")
    assert(obj, "no obj provided")
    assert(objName, "no objName provided")
    assert(assignmentFilterTest, "no assignmentFilterTest provided")
    assert(type(logOk) == "boolean", "no logOk provided")
    corelog.WriteToLog("* "..className..":getAssignmentFilter() tests")

    -- test
    local test = MethodResultTest:newInstance("getAssignmentFilter", false, MultipleValuesTest:newInstance(assignmentFilterTest))
    test:test(obj, objName, "", logOk)
end

return T_IWorker
