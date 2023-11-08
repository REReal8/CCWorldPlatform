local T_Turtle = {}

local corelog = require "corelog"
local coreutils = require "coreutils"

local IItemSupplier = require "i_item_supplier"
local IItemDepot = require "i_item_depot"
local IObj = require "i_obj"
local ObjBase = require "obj_base"
local Callback = require "obj_callback"
local Location = require "obj_location"
local URL = require "obj_url"

local Turtle = require "mobj_turtle"

local enterprise_employment = require "enterprise_employment"
local enterprise_chests = require "enterprise_chests"

local TestArrayTest = require "test_array_test"
local FieldValueEqualTest = require "field_value_equal_test"
local FieldValueTypeTest = require "field_value_type_test"
local MethodResultEqualTest = require "method_result_equal_test"
local IsBlueprintTest = require "test.is_blueprint_test"

local T_Class = require "test.t_class"
local T_IInterface = require "test.t_i_interface"
local T_IObj = require "test.t_i_obj"
local T_ILObj = require "test.t_i_lobj"
local T_IMObj = require "test.t_i_mobj"
local T_IWorker = require "test.t_i_worker"
local T_Chest = require "test.t_mobj_chest"

local t_employment = require "test.t_employment"

function T_Turtle.T_All()
    -- initialisation
    T_Turtle.T__init()
    T_Turtle.T_new()
    T_Turtle.T_Getters()

    -- IObj
    T_Turtle.T_IObj_All()

    -- ILObj
    T_Turtle.T_ILObj_All()

    -- IMObj
    T_Turtle.T_IMObj_All()

    -- IWorker
    T_Turtle.T_IWorker_All()

    -- IItemSupplier
    T_Turtle.T_IItemSupplier_All()
--    T_Turtle.T_needsTo_ProvideItemsTo_SOSrv()
--    T_Turtle.T_can_ProvideItems_QOSrv()

    -- IItemDepot
    T_Turtle.T_IItemDepot_All()
end

local testClassName = "Turtle"
local testObjName = "turtle"

local logOk = false

local workerId0 = 111111
local isActive_false = false
local baseLocation0  = Location:newInstance(1, -1, 3, 0, 1)
local workerLocation0  = baseLocation0:copy()
local fuelPriorityKey0 = ""
local fuelPriorityKey1 = "99:111"

local constructParameters = {
    workerId        = workerId0,
    baseLocation    = baseLocation0,
    workerLocation  = workerLocation0,
}

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_Turtle.CreateTestObj(id, workerId, isActive, baselocation, workerLocation, fuelPriorityKey)
    -- check input
    id = id or coreutils.NewId()
    workerId = workerId or workerId0
    isActive = isActive or isActive_false
    baselocation = baselocation or baseLocation0
    workerLocation = workerLocation or workerLocation0
    fuelPriorityKey = fuelPriorityKey or fuelPriorityKey0

    -- create Turtle object
    local turtleObj = Turtle:newInstance(id, workerId, isActive, baselocation, workerLocation, fuelPriorityKey)

    -- end
    return turtleObj
end

function T_Turtle.CreateInitialisedTest(id, workerId, isActive, baselocation, workerLocation, fuelPriorityKey)
    -- check input

    -- create test
    local idTest = FieldValueTypeTest:newInstance("_id", "string") -- note: allow for testing only the type (instead of also the value)
    if id then idTest = FieldValueEqualTest:newInstance("_id", id) end
    local test = TestArrayTest:newInstance(
        idTest,
        FieldValueEqualTest:newInstance("_workerId", workerId),
        FieldValueEqualTest:newInstance("_isActive", isActive),
        FieldValueEqualTest:newInstance("_baseLocation", baselocation),
        FieldValueEqualTest:newInstance("_location", workerLocation),
        FieldValueEqualTest:newInstance("_fuelPriorityKey", fuelPriorityKey)
    )

    -- end
    return test
end

function T_Turtle.T__init()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":_init() tests")
    local id = coreutils.NewId()

    -- test
    local obj = T_Turtle.CreateTestObj(id, workerId0, isActive_false, baseLocation0, workerLocation0, fuelPriorityKey0) assert(obj, "Failed obtaining "..testClassName)
    local test = T_Turtle.CreateInitialisedTest(id, workerId0, isActive_false, baseLocation0, workerLocation0, fuelPriorityKey0)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_Turtle.T_new()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() tests")
    local id = coreutils.NewId()

    -- test
    local obj = Turtle:new({
        _id                     = id,
        _workerId               = workerId0,
        _isActive               = isActive_false,
        _baseLocation           = baseLocation0,
        _location               = workerLocation0,

        _fuelPriorityKey        = fuelPriorityKey0,
    })
    local test = T_Turtle.CreateInitialisedTest(id, workerId0, isActive_false, baseLocation0, workerLocation0, fuelPriorityKey0)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_Turtle.T_Getters()
    -- prepare test
    corelog.WriteToLog("* "..testClassName.." getter tests")
    local obj = T_Turtle.CreateTestObj(nil, workerId0, isActive_false, baseLocation0, workerLocation0, fuelPriorityKey1) assert(obj, "Failed obtaining "..testClassName)

    -- test
    local test = TestArrayTest:newInstance(
        MethodResultEqualTest:newInstance("getFuelPriorityKey", fuelPriorityKey1)
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

function T_Turtle.T_IObj_All()
    -- prepare test
    local id = coreutils.NewId()
    local obj = T_Turtle.CreateTestObj(id) assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_Turtle.CreateTestObj(id) assert(otherObj, "Failed obtaining "..testClassName)

    -- test
    T_Class.pt_IsInstanceOf(testClassName, obj, "IObj", IObj)
    T_Class.pt_IsInstanceOf(testClassName, obj, "ObjBase", ObjBase)
    T_IObj.pt_all(testClassName, obj, otherObj)
end

--    _____ _      ____  _     _
--   |_   _| |    / __ \| |   (_)
--     | | | |   | |  | | |__  _
--     | | | |   | |  | | '_ \| |
--    _| |_| |___| |__| | |_) | |
--   |_____|______\____/|_.__/| |
--                           _/ |
--                          |__/

function T_Turtle.T_ILObj_All()
    -- prepare test
    local destructFieldsTest = TestArrayTest:newInstance()

    local constructFieldsTest = T_Turtle.CreateInitialisedTest(nil, workerId0, isActive_false, baseLocation0, workerLocation0, fuelPriorityKey0)

    -- test cases
    T_ILObj.pt_all(testClassName, Turtle, {
        {
            objName             = testObjName,
            constructParameters = constructParameters,
            constructFieldsTest = constructFieldsTest,
            destructFieldsTest  = destructFieldsTest,
        },
    }, logOk)
end

--    _____ __  __  ____  _     _
--   |_   _|  \/  |/ __ \| |   (_)
--     | | | \  / | |  | | |__  _
--     | | | |\/| | |  | | '_ \| |
--    _| |_| |  | | |__| | |_) | |
--   |_____|_|  |_|\____/|_.__/| |
--                            _/ |
--                           |__/

function T_Turtle.T_IMObj_All()
    -- prepare test
    local isBlueprintTest = IsBlueprintTest:newInstance(baseLocation0)

    -- test cases
    T_IMObj.pt_all(testClassName, Turtle, {
        {
            objName                 = testObjName,
            constructParameters     = constructParameters,
            constructBlueprintTest  = isBlueprintTest,
            expectedBaseLocation    = baseLocation0:copy(),
            dismantleBlueprintTest  = isBlueprintTest,
        },
    }, logOk)
end

--    _______          __        _
--   |_   _\ \        / /       | |
--     | |  \ \  /\  / /__  _ __| | _____ _ __
--     | |   \ \/  \/ / _ \| '__| |/ / _ \ '__|
--    _| |_   \  /\  / (_) | |  |   <  __/ |
--   |_____|   \/  \/ \___/|_|  |_|\_\___|_|

function T_Turtle.T_IWorker_All()
    -- prepare test
    local obj = T_Turtle.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)
    local workerResumeTest = TestArrayTest:newInstance(
        FieldValueTypeTest:newInstance("workerId", "number"),
        FieldValueTypeTest:newInstance("location", "Location"),
        FieldValueTypeTest:newInstance("fuelLevel", "number"),
        FieldValueTypeTest:newInstance("axePresent", "boolean"),
        FieldValueTypeTest:newInstance("inventoryItems", "table"),
        FieldValueTypeTest:newInstance("leftEquiped", "string"),
        FieldValueTypeTest:newInstance("rightEquiped", "string")
    )
    local isMainUIMenuTest = TestArrayTest:newInstance(
        FieldValueTypeTest:newInstance("clear", "boolean"),
        FieldValueTypeTest:newInstance("intro", "string"),
        FieldValueTypeTest:newInstance("option", "table"),
        FieldValueTypeTest:newInstance("question", "string")
    )
    local assignmentFilterTest = TestArrayTest:newInstance(
        FieldValueTypeTest:newInstance("priorityKeyNeeded", "string")
    )

    -- test
    local expectedWorkerLocation = workerLocation0:copy()
    T_IWorker.pt_all(testClassName, obj, testObjName, expectedWorkerLocation, workerResumeTest, isMainUIMenuTest, assignmentFilterTest, logOk)
end

--                        _
--                       (_)
--    ___  ___ _ ____   ___  ___ ___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \
--   \__ \  __/ |   \ V /| | (_|  __/
--   |___/\___|_|    \_/ |_|\___\___|

--    _____ _____ _                  _____                   _ _
--   |_   _|_   _| |                / ____|                 | (_)
--     | |   | | | |_ ___ _ __ ___ | (___  _   _ _ __  _ __ | |_  ___ _ __
--     | |   | | | __/ _ \ '_ ` _ \ \___ \| | | | '_ \| '_ \| | |/ _ \ '__|
--    _| |_ _| |_| ||  __/ | | | | |____) | |_| | |_) | |_) | | |  __/ |
--   |_____|_____|\__\___|_| |_| |_|_____/ \__,_| .__/| .__/|_|_|\___|_|
--                                              | |   | |
--                                              |_|   |_|

function T_Turtle.T_IItemSupplier_All()
    -- prepare test
    local obj = T_Turtle.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

    -- test
    T_Class.pt_IsInstanceOf(testClassName, obj, "IItemSupplier", IItemSupplier)
    T_IInterface.pt_ImplementsInterface("IItemSupplier", IItemSupplier, testClassName, obj)
end

local function provideItemsTo_AOSrv_Test(itemDepotLocator, toStr)
    -- prepare test (cont)
    corelog.WriteToLog("* "..testClassName..":provideItemsTo_AOSrv() test (to "..toStr..")")
    local objTurtle = T_Turtle.CreateTestObj() if not objTurtle then corelog.Error("Failed obtaining Turtle") return end

    local provideItems = {
        ["minecraft:birch_log"]  = 5,
    }
    local expectedDestinationItemsLocator = itemDepotLocator:copy()
    expectedDestinationItemsLocator:setQuery(provideItems)
    local callback = Callback:newInstance("T_Turtle", "provideItemsTo_AOSrv_Callback", {
        ["expectedDestinationItemsLocator"] = expectedDestinationItemsLocator,
        ["itemDepotLocator"]                = itemDepotLocator,
    })

    -- test
    local scheduleResult = objTurtle:provideItemsTo_AOSrv({
        provideItems    = provideItems,
        itemDepotLocator= itemDepotLocator,
    }, callback)
    assert(scheduleResult == true, "failed to schedule async service")
end

function T_Turtle.T_provideItemsTo_AOSrv_Turtle()
    -- prepare test
    local itemDepotLocator = t_employment.GetCurrentTurtleLocator()

    -- test
    provideItemsTo_AOSrv_Test(itemDepotLocator, "Turtle")
end

function T_Turtle.T_provideItemsTo_AOSrv_Chest()
    -- prepare test
    local chest2 = T_Chest.CreateTestObj(nil, baseLocation0:getRelativeLocation(2, 5, 0)) assert(chest2, "Failed obtaining Chest 2")
    local itemDepotLocator = enterprise_chests:saveObject(chest2)

    -- test
    provideItemsTo_AOSrv_Test(itemDepotLocator, "Chest")
end

function T_Turtle.provideItemsTo_AOSrv_Callback(callbackData, serviceResults)
    -- test (cont)
    assert(serviceResults.success, "failed executing async service")

    local destinationItemsLocator = URL:new(serviceResults.destinationItemsLocator)
    local expectedDestinationItemsLocator = URL:new(callbackData["expectedDestinationItemsLocator"])
    assert(destinationItemsLocator:isEqual(expectedDestinationItemsLocator), "gotten destinationItemsLocator(="..textutils.serialize(destinationItemsLocator, compact)..") not the same as expected(="..textutils.serialize(expectedDestinationItemsLocator, compact)..")")

    -- cleanup test
    local itemDepotLocator = callbackData["itemDepotLocator"]
    if enterprise_chests:isLocatorFromHost(itemDepotLocator) then
        enterprise_chests:deleteResource(itemDepotLocator)
    end

    -- end
    return true
end

--    _____ _____ _                 _____                   _
--   |_   _|_   _| |               |  __ \                 | |
--     | |   | | | |_ ___ _ __ ___ | |  | | ___ _ __   ___ | |_
--     | |   | | | __/ _ \ '_ ` _ \| |  | |/ _ \ '_ \ / _ \| __|
--    _| |_ _| |_| ||  __/ | | | | | |__| |  __/ |_) | (_) | |_
--   |_____|_____|\__\___|_| |_| |_|_____/ \___| .__/ \___/ \__|
--                                             | |
--                                             |_|

function T_Turtle.T_IItemDepot_All()
    -- prepare test
    local obj = T_Turtle.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

    -- test
    T_Class.pt_IsInstanceOf(testClassName, obj, "IItemDepot", IItemDepot)
    T_IInterface.pt_ImplementsInterface("IItemDepot", IItemDepot, testClassName, obj)
end

local function storeItemsFrom_AOSrv_Test(itemsLocator, toStr)
    -- prepare test (cont)
    corelog.WriteToLog("* "..testClassName..":storeItemsFrom_AOSrv() test (to "..toStr..")")
    local objTurtle = T_Turtle.CreateTestObj() if not objTurtle then corelog.Error("Failed obtaining Turtle") return end
    local turtleLocator = enterprise_employment:getObjectLocator(objTurtle) assert(turtleLocator, "Failed obtaining locator for "..testClassName)

    local provideItems = {
        ["minecraft:birch_log"]  = 5,
    }
    itemsLocator:setQuery(provideItems)

    local expectedDestinationItemsLocator = turtleLocator:copy()
    expectedDestinationItemsLocator:setQuery(provideItems)
    local callback = Callback:newInstance("T_Turtle", "storeItemsFrom_AOSrv_Callback", {
        ["expectedDestinationItemsLocator"] = expectedDestinationItemsLocator,
        ["itemsLocator"]                    = itemsLocator:copy(),
    })

    -- test
    local scheduleResult = objTurtle:storeItemsFrom_AOSrv({
        itemsLocator    = itemsLocator,
    }, callback)
    assert(scheduleResult == true, "failed to schedule async service")
end

function T_Turtle.T_storeItemsFrom_AOSrv_Turtle()
    -- prepare test
    local itemsLocator = t_employment.GetCurrentTurtleLocator()

    -- test
    storeItemsFrom_AOSrv_Test(itemsLocator, "Turtle")
end

function T_Turtle.T_storeItemsFrom_AOSrv_Chest()
    -- prepare test
    local chest2 = T_Chest.CreateTestObj(nil, baseLocation0:getRelativeLocation(2, 5, 0)) assert(chest2, "Failed obtaining Chest 2")
    local itemsLocator = enterprise_chests:saveObject(chest2)

    -- test
    storeItemsFrom_AOSrv_Test(itemsLocator, "Chest")
end

function T_Turtle.storeItemsFrom_AOSrv_Callback(callbackData, serviceResults)
    -- test (cont)
    assert(serviceResults.success, "failed executing async service")

    local destinationItemsLocator = URL:new(serviceResults.destinationItemsLocator)
    local expectedDestinationItemsLocator = URL:new(callbackData["expectedDestinationItemsLocator"])
    assert(destinationItemsLocator:isEqual(expectedDestinationItemsLocator), "gotten destinationItemsLocator(="..textutils.serialize(destinationItemsLocator, compact)..") not the same as expected(="..textutils.serialize(expectedDestinationItemsLocator, compact)..")")

    -- cleanup test
    local itemsLocator = callbackData["itemsLocator"]
    if enterprise_chests:isLocatorFromHost(itemsLocator) then
        enterprise_chests:deleteResource(itemsLocator)
    end

    -- end
    return true
end

function T_Turtle.T_needsTo_ProvideItemsTo_SOSrv()
    -- ToDo: consider implementing later similair to Chest tests. Now left out because Turtle inventory dependends on... well the Turtle
    -- prepare test

    -- test

    -- cleanup test
end

function T_Turtle.T_can_ProvideItems_QOSrv()
    -- ToDo: consider implementing later similair to Chest tests. Now left out because Turtle inventory dependends on... well the Turtle
    -- prepare test

    -- test

    -- cleanup test
end

return T_Turtle
