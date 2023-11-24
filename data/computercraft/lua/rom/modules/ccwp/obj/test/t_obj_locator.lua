local T_ObjLocator = {}

local corelog = require "corelog"

local Class = require "class"

local IObj = require "i_obj"
local ObjBase = require "obj_base"
local ObjLocator = require "obj_locator"

local TestObj = require "test.obj_test"

local TestArrayTest = require "test_array_test"
local MethodResultEqualTest = require "method_result_equal_test"

local T_Class = require "test.t_class"
local T_URL = require "test.t_obj_url"
local T_IObj = require "test.t_i_obj"

function T_ObjLocator.T_All()
    -- initialisation
    T_ObjLocator.T__init()
    T_ObjLocator.T_new()
    T_ObjLocator.T_Getters()

    -- IObj
    T_ObjLocator.T_IObj_All()
end

local testClassName = "ObjLocator"
local testObjName = "objLocator"
local logOk = false

local hostName0 = "TestObjHost"
local locatedObj0 = TestObj:newInstance("field1", 4)
local objRef0 = ""
local objRef1 = "anObjRef"
local noQuery = {}
local itemName0 = "minecraft:torch"
local itemCount0 = 5
local itemName1 = "minecraft:birch_log"
local itemCount1 = 3
local query0 = {[itemName0] = itemCount0, [itemName1] = itemCount1}

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_ObjLocator.CreateTestObj(hostName, locatedObj, objRef, query)
    -- check input
    hostName = hostName or hostName0
    locatedObj = locatedObj or locatedObj0
    objRef = objRef or objRef1
    query = query or {[itemName0] = itemCount0, [itemName1] = itemCount1}

    -- create testObj
    local testObj = ObjLocator:newInstance(hostName, locatedObj, objRef, query)

    -- end
    return testObj
end

function T_ObjLocator.CreateInitialisedTest(hostName, locatedObj, objRef, query)
    -- check input
    assert(Class.IsInstanceOf(locatedObj, IObj), "locatedObj not an IObj")

    -- create test
    local className = locatedObj:getClassName()
    local objPath = "/objects/class="..className
    if objRef ~= "" then
        -- ToDo: consider renaming id to ref
        objPath = objPath.."/id="..objRef
    end

    local test = T_URL.CreateInitialisedTest(hostName, objPath, query, nil)

    -- end
    return test
end

function T_ObjLocator.T__init()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":_init() tests")

    -- test
    local obj = T_ObjLocator.CreateTestObj(hostName0, locatedObj0, objRef1, query0) assert(obj, "Failed obtaining "..testClassName)
    local test = T_ObjLocator.CreateInitialisedTest(hostName0, locatedObj0, objRef1, query0)
    test:test(obj, testObjName, "", logOk)

    -- test default
    obj = ObjLocator:newInstance(hostName0, locatedObj0)
    test = T_ObjLocator.CreateInitialisedTest(hostName0, locatedObj0, objRef0, noQuery)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_ObjLocator.T_new()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() tests")
    local objClassName = locatedObj0:getClassName()
    local objPath = "/objects/class="..objClassName
    if objRef1 ~= "" then
        -- ToDo: consider renaming id to ref
        objPath = objPath.."/id="..objRef1
    end

    -- test full
    local obj = ObjLocator:new({
        _host   = hostName0,
        _path   = objPath,
        _query  = query0,
        _port   = nil,
    })
    local test = T_ObjLocator.CreateInitialisedTest(hostName0, locatedObj0, objRef1, query0)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_ObjLocator.T_Getters()
    -- prepare test
    corelog.WriteToLog("* "..testClassName.." base getter tests")
    local obj = T_ObjLocator.CreateTestObj(hostName0, locatedObj0, objRef1, query0) assert(obj, "Failed obtaining "..testClassName)
    local locatedObjClassName = locatedObj0:getClassName()

    -- test
    local test = TestArrayTest:newInstance(
        MethodResultEqualTest:newInstance("getObjClassName", locatedObjClassName),
        MethodResultEqualTest:newInstance("getObjRef", objRef1)
    )
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function T_ObjLocator.T_IObj_All()
    -- prepare test
    local obj = T_ObjLocator.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_ObjLocator.CreateTestObj() assert(otherObj, "Failed obtaining "..testClassName)

    -- test
    T_Class.pt_IsInstanceOf(testClassName, obj, "IObj", IObj)
    T_Class.pt_IsInstanceOf(testClassName, obj, "ObjBase", ObjBase)
    T_IObj.pt_all(testClassName, obj, otherObj)
end

return T_ObjLocator
