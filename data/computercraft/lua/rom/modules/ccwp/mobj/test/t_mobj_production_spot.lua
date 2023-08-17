local T_ProductionSpot = {}
local corelog = require "corelog"

local IObj = require "i_obj"
local ObjBase = require "obj_base"
local Location = require "obj_location"

local ProductionSpot = require "mobj_production_spot"

local T_Object = require "test.t_object"
local T_IObj = require "test.t_i_obj"

function T_ProductionSpot.T_All()
    -- initialisation
    T_ProductionSpot.T_new()

    -- IObj methods
    T_ProductionSpot.T_IObj_All()

    -- specific methods
end

local location1  = Location:new({_x= -6, _y= 0, _z= 1, _dx=0, _dy=1})
local isCraftingSpot1 = true

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

local testClassName = "ProductionSpot"
function T_ProductionSpot.CreateTestObj()
    local testObj = ProductionSpot:new({
        _baseLocation   = location1:copy(),
        _isCraftingSpot = isCraftingSpot1,
    })

    return testObj
end

function T_ProductionSpot.T_new()
    -- prepare test
    corelog.WriteToLog("* ProductionSpot:new() tests")

    -- test
    local obj = ProductionSpot:new({
        _baseLocation   = location1,
        _isCraftingSpot = isCraftingSpot1,
    })
    assert(location1:isEqual(obj:getBaseLocation()), "gotten getBaseLocation(="..textutils.serialise(obj:getBaseLocation(), compact)..") not the same as expected(="..textutils.serialise(location1, compact)..")")
    assert(isCraftingSpot1 == obj:isCraftingSpot(), "gotten isCraftingSpot(="..textutils.serialise(obj:isCraftingSpot(), compact)..") not the same as expected(="..textutils.serialise(isCraftingSpot1, compact)..")")

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

return T_ProductionSpot
