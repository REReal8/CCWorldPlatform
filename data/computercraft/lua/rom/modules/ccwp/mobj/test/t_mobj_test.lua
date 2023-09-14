local T_TestMObj = {}
local corelog = require "corelog"
local coreutils = require "coreutils"

local IObj = require "i_obj"
local ObjBase = require "obj_base"
local Location = require "obj_location"

local IMObj = require "i_mobj"

local TestMObj = require "test.mobj_test"

local TestArrayTest = require "test_array_test"
local FieldValueEqualTest = require "field_value_equal_test"
local FieldValueTypeTest = require "field_value_type_test"
local MethodResultEqualTest = require "method_result_equal_test"
local IsBlueprintTest = require "test.is_blueprint_test"

local T_Class = require "test.t_class"
local T_IObj = require "test.t_i_obj"
local T_IMObj = require "test.t_i_mobj"

function T_TestMObj.T_All()
    -- initialisation
    T_TestMObj.T__init()
    T_TestMObj.T_new()
    T_TestMObj.T_Getters()

    -- IObj methods
    T_TestMObj.T_IObj_All()

    -- IMObj methods
    T_TestMObj.T_IMObj_All()
end

local testClassName = "TestMObj"
local testObjName = "testMObj"
local logOk = false
local baseLocation1  = Location:newInstance(-6, 0, 1, 0, 1)
local field1_1 = "field1 1"

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_TestMObj.CreateTestObj(id, baseLocation, field1)
    -- check input
    id = id or coreutils.NewId()
    baseLocation = baseLocation or baseLocation1
    field1 = field1 or field1_1

    -- create testObj
    local testObj = TestMObj:newInstance(id, baseLocation:copy(), field1)

    -- end
    return testObj
end

function T_TestMObj.CreateInitialisedTest(id, baseLocation, field1)
    -- check input

    -- create test
    local idTest = FieldValueTypeTest:newInstance("_id", "string") -- note: allow for testing only the type (instead of also the value)
    if id then idTest = FieldValueEqualTest:newInstance("_id", id) end
    local test = TestArrayTest:newInstance(
        idTest,
        FieldValueEqualTest:newInstance("_baseLocation", baseLocation),
        FieldValueEqualTest:newInstance("_field1", field1)
    )

    -- end
    return test
end

function T_TestMObj.T__init()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":_init() tests")
    local id = coreutils.NewId()

    -- test
    local obj = T_TestMObj.CreateTestObj(id, baseLocation1, field1_1) assert(obj, "Failed obtaining "..testClassName)
    local test = T_TestMObj.CreateInitialisedTest(id, baseLocation1, field1_1)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_TestMObj.T_new()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() tests")
    local id = coreutils.NewId()

    -- test
    local obj = TestMObj:new({
        _id             = id,

        _baseLocation   = baseLocation1:copy(),
        _field1         = field1_1,
    })
    local test = T_TestMObj.CreateInitialisedTest(id, baseLocation1, field1_1)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_TestMObj.T_Getters()
    -- prepare test
    corelog.WriteToLog("* "..testClassName.." base getter tests")
    local id = coreutils.NewId()
    local obj = T_TestMObj.CreateTestObj(id, baseLocation1, field1_1) assert(obj, "Failed obtaining "..testClassName)

    -- test
    local test = TestArrayTest:newInstance(
        MethodResultEqualTest:newInstance("getBaseLocation", baseLocation1),
        MethodResultEqualTest:newInstance("getField1", field1_1)
    )
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

function T_TestMObj.T_IObj_All()
    -- prepare test
    local id = coreutils.NewId()
    local obj = T_TestMObj.CreateTestObj(id) assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_TestMObj.CreateTestObj(id) assert(otherObj, "Failed obtaining "..testClassName)

    -- test
    T_Class.pt_IsInstanceOf(testClassName, obj, "IObj", IObj)
    T_Class.pt_IsInstanceOf(testClassName, obj, "ObjBase", ObjBase)
    T_IObj.pt_all(testClassName, obj, otherObj)
end

--    _____ __  __  ____  _     _                  _   _               _
--   |_   _|  \/  |/ __ \| |   (_)                | | | |             | |
--     | | | \  / | |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | | | |\/| | |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| |_| |  | | |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____|_|  |_|\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                            _/ |
--                           |__/

local constructParameters1 = {
    baseLocation    = baseLocation1,
    field1Value     = field1_1,
}

function T_TestMObj.T_IMObj_All()
    -- prepare test
    local id = coreutils.NewId()
    local obj = T_TestMObj.CreateTestObj(id, baseLocation1, field1_1) assert(obj, "Failed obtaining "..testClassName)

    local destructFieldsTest = TestArrayTest:newInstance()

    local constructFieldsTest = T_TestMObj.CreateInitialisedTest(nil, baseLocation1, field1_1)

    local isBlueprintTest = IsBlueprintTest:newInstance(baseLocation1)

    -- test
    T_IMObj.pt_IsInstanceOf_IMObj(testClassName, obj)
    T_IMObj.pt_Implements_IMObj(testClassName, obj)
    T_IMObj.pt_destruct(testClassName, TestMObj, constructParameters1, testObjName, destructFieldsTest, logOk)
    T_IMObj.pt_construct(testClassName, TestMObj, constructParameters1, testObjName, constructFieldsTest, logOk)
    T_IMObj.pt_getId(testClassName, obj, testObjName, logOk)
    T_IMObj.pt_getWIPId(testClassName, obj, testObjName, logOk)
    T_IMObj.pt_getBuildBlueprint(testClassName, obj, testObjName, isBlueprintTest, logOk)
    T_IMObj.pt_getDismantleBlueprint(testClassName, obj, testObjName, isBlueprintTest, logOk)
end

return T_TestMObj
