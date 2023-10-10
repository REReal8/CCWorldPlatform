local T_ProductionSpot = {}
local corelog = require "corelog"

local IObj = require "i_obj"
local ObjBase = require "obj_base"
local Location = require "obj_location"

local ProductionSpot = require "mobj_production_spot"

local TestArrayTest = require "test_array_test"
local FieldValueEqualTest = require "field_value_equal_test"

local T_Class = require "test.t_class"
local T_IObj = require "test.t_i_obj"

function T_ProductionSpot.T_All()
    -- initialisation
    T_ProductionSpot.T__init()
    T_ProductionSpot.T_new()

    -- IObj
    T_ProductionSpot.T_IObj_All()

    -- specific
end

local testClassName = "ProductionSpot"
local testObjName = "productionSpot"
local logOk = false
local baseLocation1  = Location:newInstance(-6, 0, 1, 0, 1)
local isCraftingSpot1 = true

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_ProductionSpot.CreateTestObj(baseLocation, isCraftingSpot)
    -- check input
    baseLocation = baseLocation or baseLocation1
    isCraftingSpot = isCraftingSpot or isCraftingSpot1

    -- create testObj
    local testObj = ProductionSpot:newInstance(baseLocation:copy(), isCraftingSpot)

    -- end
    return testObj
end

function T_ProductionSpot.CreateInitialisedTest(baseLocation, isCraftingSpot)
    -- check input

    -- create test
    local test = TestArrayTest:newInstance(
        FieldValueEqualTest:newInstance("_baseLocation", baseLocation),
        FieldValueEqualTest:newInstance("_isCraftingSpot", isCraftingSpot)
    )

    -- end
    return test
end

function T_ProductionSpot.T__init()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":_init() tests")

    -- test
    local obj = T_ProductionSpot.CreateTestObj(baseLocation1, isCraftingSpot1) assert(obj, "Failed obtaining "..testClassName)
    local test = T_ProductionSpot.CreateInitialisedTest(baseLocation1, isCraftingSpot1)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_ProductionSpot.T_new()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() tests")

    -- test
    local obj = ProductionSpot:new({
        _baseLocation   = baseLocation1:copy(),
        _isCraftingSpot = isCraftingSpot1,
    })
    local test = T_ProductionSpot.CreateInitialisedTest(baseLocation1, isCraftingSpot1)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

function T_ProductionSpot.T_IObj_All()
    -- prepare test
    local obj = T_ProductionSpot.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_ProductionSpot.CreateTestObj() assert(otherObj, "Failed obtaining "..testClassName)

    -- test
    T_Class.pt_IsInstanceOf(testClassName, obj, "IObj", IObj)
    T_Class.pt_IsInstanceOf(testClassName, obj, "ObjBase", ObjBase)
    T_IObj.pt_all(testClassName, obj, otherObj)
end

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

return T_ProductionSpot
