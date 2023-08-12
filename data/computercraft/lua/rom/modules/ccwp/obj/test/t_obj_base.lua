local T_ObjBase = {}

local IObj = require "i_obj"
local ObjBase = require "obj_base"

local T_Object = require "test.t_object"
local T_IObj = require "test.t_iobj"

function T_ObjBase.T_All()
    -- IObj methods
    T_ObjBase.T_IsInstanceOfIObj()
    T_ObjBase.T_getClassName()
    T_ObjBase.T_isTypeOf()
    T_ObjBase.T_isEqual()
    T_ObjBase.T_copy()
end

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

local testClassName = "ObjBase"
local function createTestObj()
    local testObj = ObjBase:new()

    return testObj
end

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_ObjBase.T_IsInstanceOfIObj()
    -- prepare test
    local obj = createTestObj()

    -- test
    T_Object.pt_IsInstanceOf(testClassName, obj, "IObj", IObj)
end

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

function T_ObjBase.T_getClassName()
    -- prepare test
    local obj = createTestObj()

    -- test
    T_IObj.pt_getClassName(testClassName, obj)
end

function T_ObjBase.T_isTypeOf()
    -- prepare test
    local obj = createTestObj()

    -- test
    T_IObj.pt_isTypeOf(testClassName, obj)
end

function T_ObjBase.T_isEqual()
    -- prepare test
    local obj = createTestObj()
    obj._aNil = nil
    obj._aStr = "a string"
    obj._aNumber = 10
    obj._aBoolean = true
    obj._anIObj = createTestObj()
    obj._anIObj._aSubStr = "another string"
    local otherObj = createTestObj()
    otherObj._aNil = obj._aNil
    otherObj._aStr = obj._aStr
    otherObj._aNumber = obj._aNumber
    otherObj._aBoolean = obj._aBoolean
    otherObj._anIObj = createTestObj()
    otherObj._anIObj._aSubStr = "another string"

    -- test
    T_IObj.pt_isEqual(testClassName, obj, otherObj)
end

function T_ObjBase.T_copy()
    -- prepare test
    local obj = createTestObj()

    -- test
    T_IObj.pt_copy(testClassName, obj)
end

return T_ObjBase
