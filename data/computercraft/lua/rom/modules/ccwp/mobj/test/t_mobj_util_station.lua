local T_UtilStation = {}

local corelog = require "corelog"
local coreutils = require "coreutils"

local IObj = require "i_obj"
local ObjBase = require "obj_base"

local Location = require "obj_location"

local UtilStation = require "mobj_util_station"

local TestArrayTest = require "test_array_test"
local FieldValueEqualTest = require "field_value_equal_test"
local FieldValueTypeTest = require "field_value_type_test"
local MethodResultEqualTest = require "method_result_equal_test"
local IsBlueprintTest = require "test.is_blueprint_test"

local T_Class = require "test.t_class"
local T_IObj = require "test.t_i_obj"
local T_IMObj = require "test.t_i_mobj"

function T_UtilStation.T_All()
    -- initialisation
    T_UtilStation.T__init()
    T_UtilStation.T_new()
    T_UtilStation.T_Getters()

    -- IObj methods
    T_UtilStation.T_IObj_All()

    -- IMObj methods
    T_UtilStation.T_IMObj_All()
end

local testClassName = "UtilStation"
local testObjName = "utilStation"
local logOk = false

local baseLocation0 = Location:newInstance(-6, -12, 1, 0, 1)

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_UtilStation.CreateTestObj(id, baseLocation)
    -- check input
    id = id or coreutils.NewId()
    baseLocation = baseLocation or baseLocation0

    -- create testObj
    local testObj = UtilStation:newInstance(id, baseLocation:copy())

    -- end
    return testObj
end

function T_UtilStation.CreateInitialisedTest(id, baseLocation)
    -- check input

    -- create test
    local idTest = FieldValueTypeTest:newInstance("_id", "string")
    if id then idTest = FieldValueEqualTest:newInstance("_id", id) end
    local test = TestArrayTest:newInstance(
        idTest,
        FieldValueEqualTest:newInstance("_baseLocation", baseLocation)
    )

    -- end
    return test
end

function T_UtilStation.T__init()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":_init() tests")
    local id = coreutils.NewId()

    -- test
    local obj = T_UtilStation.CreateTestObj(id, baseLocation0) assert(obj, "Failed obtaining "..testClassName)
    local test = T_UtilStation.CreateInitialisedTest(id, baseLocation0)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_UtilStation.T_new()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() tests")
    local id = coreutils.NewId()

    -- test
    local obj = UtilStation:new({
        _id             = id,
        _baseLocation   = baseLocation0:copy(),
    })
    local test = T_UtilStation.CreateInitialisedTest(id, baseLocation0)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_UtilStation.T_Getters()
    -- prepare test
    corelog.WriteToLog("* "..testClassName.." base getter tests")
    local id = coreutils.NewId()
    local obj = T_UtilStation.CreateTestObj(id, baseLocation0) assert(obj, "Failed obtaining "..testClassName)

    -- test
    local test = TestArrayTest:newInstance(
        MethodResultEqualTest:newInstance("getBaseLocation", baseLocation0)
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

function T_UtilStation.T_IObj_All()
    -- prepare test
    local id = coreutils.NewId()
    local obj = T_UtilStation.CreateTestObj(id) assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_UtilStation.CreateTestObj(id) assert(otherObj, "Failed obtaining "..testClassName)

    -- testing type
    T_Class.pt_IsInstanceOf(testClassName, obj, "IObj", IObj)
    T_Class.pt_IsInstanceOf(testClassName, obj, "ObjBase", ObjBase)

    -- test
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

function T_UtilStation.T_IMObj_All()
    -- prepare tests
    local id = coreutils.NewId()
    local obj0 = T_UtilStation.CreateTestObj(id, baseLocation0) assert(obj0, "Failed obtaining "..testClassName)
    local testObjName0 = testObjName.."0"

    local destructFieldsTest = TestArrayTest:newInstance(
    )

    local fieldsTest0 = T_UtilStation.CreateInitialisedTest(nil, baseLocation0)

    local constructParameters0 = {
        baseLocation    = baseLocation0,
    }

    local isBlueprintTest = IsBlueprintTest:newInstance(baseLocation0)

    -- testing type
    T_IMObj.pt_IsInstanceOf_IMObj(testClassName, obj0)
    T_IMObj.pt_Implements_IMObj(testClassName, obj0)

    -- test construct/ upgrade/ destruct
    T_IMObj.pt_destruct(testClassName, UtilStation, constructParameters0, testObjName0, destructFieldsTest, logOk)
    T_IMObj.pt_construct(testClassName, UtilStation, constructParameters0, testObjName0, fieldsTest0, logOk)

    -- test getters
    T_IMObj.pt_getId(testClassName, obj0, testObjName0, logOk)
    T_IMObj.pt_getWIPId(testClassName, obj0, testObjName0, logOk)

    -- test blueprints
    T_IMObj.pt_getBuildBlueprint(testClassName, obj0, testObjName0, isBlueprintTest, logOk)
    T_IMObj.pt_getDismantleBlueprint(testClassName, obj0, testObjName0, isBlueprintTest, logOk)

    -- cleanup test
end

return T_UtilStation