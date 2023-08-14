local T_CallDef = {}

local corelog = require "corelog"

local IObj = require "i_obj"
local ObjBase = require "obj_base"
local CallDef = require "obj_call_def"

local T_Object = require "test.t_object"
local T_IObj = require "test.t_i_obj"

function T_CallDef.T_All()
    -- initialisation
    T_CallDef.T_new()

    -- IObj methods
    T_CallDef.T_IObj_All()

    -- specific methods
end

local moduleName1 = "T_CallDef"
local methodName1 = "Call_Callback"
local data1 = {"some callback data"}

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

local testClassName = "CallDef"
local function createTestObj()
    local testObj = CallDef:new({
        _moduleName     = moduleName1,
        _methodName     = methodName1,
        _data           = {"some callback data"},
    })

    return testObj
end

function T_CallDef.T_new()
    -- prepare test
    corelog.WriteToLog("* CallDef:new() tests")

    -- test full
    local callback = CallDef:new({
        _moduleName     = moduleName1,
        _methodName     = methodName1,
        _data           = data1,
    })
    assert(callback:getModuleName() == moduleName1, "gotten getModuleName(="..callback:getModuleName()..") not the same as expected(="..moduleName1..")")
    assert(callback:getMethodName() == methodName1, "gotten getMethodName(="..callback:getMethodName()..") not the same as expected(="..methodName1..")")
    local data = callback:getData()
    assert(data == data1, "gotten getData(="..textutils.serialise(callback:getData(), compact)..") not the same as expected(="..textutils.serialise(data1, compact)..")")

    -- test default
    callback = CallDef:new()
    assert(callback:getModuleName() == "", "gotten getModuleName(="..(callback:getModuleName() or "nil")..") not the same as expected(='')")
    assert(callback:getMethodName() == "", "gotten getMethodName(="..(callback:getMethodName() or "nil")..") not the same as expected(='')")
    data = callback:getData()
    assert(type(data) == "table" and next(data) == nil , "gotten getData(="..textutils.serialise(callback:getData(), compact)..") not the same as expected(={})")

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

function T_CallDef.T_IObj_All()
    -- prepare test
    local obj = createTestObj() assert(obj, "failed obtaining "..testClassName)
    local otherObj = createTestObj() assert(obj, "failed obtaining "..testClassName) assert(otherObj, "failed obtaining "..testClassName)

    -- test
    T_Object.pt_IsInstanceOf(testClassName, obj, "IObj", IObj)
    T_Object.pt_IsInstanceOf(testClassName, obj, "ObjBase", ObjBase)
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

return T_CallDef
