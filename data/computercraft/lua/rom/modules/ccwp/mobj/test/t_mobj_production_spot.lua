local T_ProductionSpot = {}

local corelog = require "corelog"
local coreutils = require "coreutils"

local IObj = require "i_obj"
local ObjBase = require "obj_base"
local Location = require "obj_location"

local ProductionSpot = require "mobj_production_spot"

local TestArrayTest = require "test_array_test"
local FieldValueEqualTest = require "field_value_equal_test"
local FieldValueTypeTest = require "field_value_type_test"
local MethodResultEqualTest = require "method_result_equal_test"

local T_Class = require "test.t_class"
local T_IObj = require "test.t_i_obj"
local T_ILObj = require "test.t_i_lobj"

function T_ProductionSpot.T_All()
    -- initialisation
    T_ProductionSpot.T__init()
    T_ProductionSpot.T_new()
    T_ProductionSpot.T_Getters()

    -- IObj
    T_ProductionSpot.T_IObj_All()

    -- ILObj
    T_ProductionSpot.T_ILObj_All()

    -- specific
    T_ProductionSpot.T_getFuelNeed_Production_Att()
end

function T_ProductionSpot.T_AllPhysical()
end

local testClassName = "ProductionSpot"
local testObjName = "productionSpot"
local testObjName0 = testObjName.."0"

local logOk = false

local baseLocation0  = Location:newInstance(-6, 0, 1, 0, 1)
local isCraftingSpot0 = true

local constructParameters0 = {
    baseLocation    = baseLocation0,

    isCraftingSpot  = isCraftingSpot0,
}

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_ProductionSpot.CreateTestObj(id, baseLocation, isCraftingSpot)
    -- check input
    id = id or coreutils.NewId()
    baseLocation = baseLocation or baseLocation0
    if type(isCraftingSpot) == "nil" then
        isCraftingSpot = isCraftingSpot0
    end

    -- create testObj
    local testObj = ProductionSpot:newInstance(id, baseLocation:copy(), isCraftingSpot)

    -- end
    return testObj
end

function T_ProductionSpot.CreateInitialisedTest(id, baseLocation, isCraftingSpot)
    -- check input

    -- create test
    local idTest = FieldValueTypeTest:newInstance("_id", "string")
    if id then idTest = FieldValueEqualTest:newInstance("_id", id) end
    local test = TestArrayTest:newInstance(
        idTest,
        FieldValueEqualTest:newInstance("_baseLocation", baseLocation),
        FieldValueEqualTest:newInstance("_isCraftingSpot", isCraftingSpot)
    )

    -- end
    return test
end

function T_ProductionSpot.T__init()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":_init() tests")
    local id = coreutils.NewId()

    -- test
    local obj = T_ProductionSpot.CreateTestObj(id, baseLocation0, isCraftingSpot0) assert(obj, "Failed obtaining "..testClassName)
    local test = T_ProductionSpot.CreateInitialisedTest(id, baseLocation0, isCraftingSpot0)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_ProductionSpot.T_new()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() tests")
    local id = coreutils.NewId()

    -- test
    local obj = ProductionSpot:new({
        _id             = id,

        _baseLocation   = baseLocation0:copy(),

        _isCraftingSpot = isCraftingSpot0,
    })
    local test = T_ProductionSpot.CreateInitialisedTest(id, baseLocation0, isCraftingSpot0)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_ProductionSpot.T_Getters()
    -- prepare test
    corelog.WriteToLog("* "..testClassName.." base getter tests")
    local id = coreutils.NewId()
    local obj = T_ProductionSpot.CreateTestObj(id, baseLocation0, isCraftingSpot0) assert(obj, "Failed obtaining "..testClassName)

    -- test
    local test = TestArrayTest:newInstance(
        MethodResultEqualTest:newInstance("isCraftingSpot", isCraftingSpot0)
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

function T_ProductionSpot.T_IObj_All()
    -- prepare test
    local id = coreutils.NewId()
    local obj = T_ProductionSpot.CreateTestObj(id) assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_ProductionSpot.CreateTestObj(id) assert(otherObj, "Failed obtaining "..testClassName)

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

function T_ProductionSpot.T_ILObj_All()
    -- prepare tests
    local destructFieldsTest = TestArrayTest:newInstance()

    local fieldsTest0 = T_ProductionSpot.CreateInitialisedTest(nil, baseLocation0, isCraftingSpot0)

    -- test cases
    T_ILObj.pt_all(testClassName, ProductionSpot, {
        {
            objName             = testObjName0,
            constructParameters = constructParameters0,
            constructFieldsTest = fieldsTest0,
            destructFieldsTest  = destructFieldsTest
        },
    }, logOk)

    -- cleanup test
end

--    _____               _            _   _              _____             _
--   |  __ \             | |          | | (_)            / ____|           | |
--   | |__) | __ ___   __| |_   _  ___| |_ _  ___  _ __ | (___  _ __   ___ | |_
--   |  ___/ '__/ _ \ / _` | | | |/ __| __| |/ _ \| '_ \ \___ \| '_ \ / _ \| __|
--   | |   | | | (_) | (_| | |_| | (__| |_| | (_) | | | |____) | |_) | (_) | |_
--   |_|   |_|  \___/ \__,_|\__,_|\___|\__|_|\___/|_| |_|_____/| .__/ \___/ \__|
--                                                             | |
--                                                             |_|

function T_ProductionSpot.T_getFuelNeed_Production_Att()
    -- prepare test crafting
    corelog.WriteToLog("* "..testClassName..":getFuelNeed_Production_Att() test (crafting)")
    local objCraft = T_ProductionSpot.CreateTestObj(nil, nil, true) assert(objCraft, "Failed obtaining "..testClassName)
    local craftItems = { ["minecraft:birch_planks"] = 4 }

    -- test crafting
    local fuelNeed = objCraft:getFuelNeed_Production_Att(craftItems)
    local expectedFuelNeed = 0
    assert(fuelNeed == expectedFuelNeed, "gotten fuelNeed(="..fuelNeed..") not the same as expected(="..expectedFuelNeed..")")

    -- prepare test smelting
    corelog.WriteToLog("* "..testClassName..":getFuelNeed_Production_Att() test (smelting)")
    local objSmelt = T_ProductionSpot.CreateTestObj(nil, nil, false) assert(objCraft, "Failed obtaining "..testClassName)
    local smeltItems = { ["minecraft:charcoal"] = 8 }

    -- test smelting
    fuelNeed = objSmelt:getFuelNeed_Production_Att(smeltItems)
    expectedFuelNeed = 4 + 4
    assert(fuelNeed == expectedFuelNeed, "gotten fuelNeed(="..fuelNeed..") not the same as expected(="..expectedFuelNeed..")")

    -- cleanup test
end

return T_ProductionSpot
