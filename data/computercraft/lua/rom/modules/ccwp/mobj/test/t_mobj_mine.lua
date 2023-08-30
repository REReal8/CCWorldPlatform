local T_Mine = {}
local corelog = require "corelog"
local coreutils = require "coreutils"

local Callback = require "obj_callback"

local IObj = require "i_obj"
local IItemSupplier = require "i_item_supplier"
local ObjBase = require "obj_base"
local ObjArray = require "obj_array"
local Location = require "obj_location"
local URL = require "obj_url"

local IMObj = require "i_mobj"
local Mine = require "mobj_mine"

local enterprise_storage = require "enterprise_storage"

local TestArrayTest = require "test_array_test"
local FieldValueEqualTest = require "field_value_equal_test"
local FieldValueTypeTest = require "field_value_type_test"

local T_Class = require "test.t_class"
local T_IInterface = require "test.t_i_interface"
local T_IObj = require "test.t_i_obj"

local t_turtle = require "test.t_turtle"

function T_Mine.T_All()
    -- initialisation
    T_Mine.T_new()

    -- IObj methods
    T_Mine.T_IObj_All()

    -- IMObj methods
    T_Mine.T_IsInstanceOf_IMObj()
--    T_Mine.T_Implements_IMObj()    -- ToDo: implement
--    T_Mine.T_NewMine() -- ToDo: proper cleanup of Chests before enabling, "All tests should not have side effects"

    -- IItemSupplier methods
    T_Mine.T_IItemSupplier_All()
--    T_Mine.T_ProvideMultipleItems() -- note: Mine:provideItemsTo_AOSrv not yet fully implemented, hence disabled
end

local testClassName = "Mine"
local testObjName = "mine"
local logOk = false
local baseLocation1 = Location:newInstance(12, -6, 1, 0, 1)
local topChests1 = ObjArray:newInstance("URL") assert(topChests1, "Failed obtaining ObjArray")

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_Mine.CreateTestObj(id, baseLocation, topChests)
    -- check input
    id = id or coreutils.NewId()
    baseLocation = baseLocation or baseLocation1
    topChests = topChests or topChests1

    -- create testObj
    local testObj = Mine:new({
        _id                     = id,

        _baseLocation           = baseLocation:copy(),

        _topChests              = topChests:copy(),
    })

    -- end
    return testObj
end

function T_Mine.CreateInitialisedTest(id, baseLocation, topChestsTest)
    -- check input

    -- create test
    local idTest = FieldValueEqualTest:newInstance("_id", id)
    if not id then
        idTest = FieldValueTypeTest:newInstance("_id", "string")
    end
    local test = TestArrayTest:newInstance(
        idTest,
        FieldValueEqualTest:newInstance("_baseLocation", baseLocation),
        topChestsTest
    )

    -- end
    return test
end

function T_Mine.T_new()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() tests")
    local id = coreutils.NewId()

    -- test
    local obj = Mine:new({
        _id             = id,

        _baseLocation   = baseLocation1:copy(),

        _topChests      = topChests1:copy(),
    })
    local topChestsTest = FieldValueEqualTest:newInstance("_topChests", topChests1)
    local test = T_Mine.CreateInitialisedTest(id, baseLocation1, topChestsTest)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

local compact = { compact = true }

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

function T_Mine.T_IObj_All()
    -- prepare test
    local id = coreutils.NewId()
    local obj = T_Mine.CreateTestObj(id) assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_Mine.CreateTestObj(id) assert(otherObj, "Failed obtaining "..testClassName)

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

function T_Mine.T_IsInstanceOf_IMObj()
    -- prepare test
    local obj = T_Mine.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

    -- test
    T_Class.pt_IsInstanceOf(testClassName, obj, "IMObj", IMObj)
end

function T_Mine.T_Implements_IMObj()
    -- prepare test
    local obj = T_Mine.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

    -- test
    T_IInterface.pt_ImplementsInterface("IMObj", IMObj, testClassName, obj)
end

-- ToDo: rename to a construct test
function T_Mine.T_NewMine()
    -- prepare test

    -- test
    corelog.WriteToLog("* Mine:NewMine() tests")
    local obj = Mine:NewMine({baseLocation=baseLocation1, nTopChests=2})

    -- cleanup test
end

--    _____ _____ _                  _____                   _ _                            _   _               _
--   |_   _|_   _| |                / ____|                 | (_)                          | | | |             | |
--     | |   | | | |_ ___ _ __ ___ | (___  _   _ _ __  _ __ | |_  ___ _ __   _ __ ___   ___| |_| |__   ___   __| |___
--     | |   | | | __/ _ \ '_ ` _ \ \___ \| | | | '_ \| '_ \| | |/ _ \ '__| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| |_ _| |_| ||  __/ | | | | |____) | |_| | |_) | |_) | | |  __/ |    | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____|_____|\__\___|_| |_| |_|_____/ \__,_| .__/| .__/|_|_|\___|_|    |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                                              | |   | |
--                                              |_|   |_|

function T_Mine.T_IItemSupplier_All()
    -- prepare test
    local obj = T_Mine.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

    -- test
    T_Class.pt_IsInstanceOf(testClassName, obj, "IItemSupplier", IItemSupplier)
    T_IInterface.pt_ImplementsInterface("IItemSupplier", IItemSupplier, testClassName, obj)
end

local function provideItemsTo_AOSrv_Test(provideItems)
    -- prepare test (cont)
    corelog.WriteToLog("* Mine:provideItemsTo_AOSrv() test (of "..textutils.serialize(provideItems, compact)..")")
    local obj = Mine:NewMine({baseLocation=baseLocation1, nTopChests=2}) if not obj then corelog.Error("Failed obtaining Mine") return end

    -- activate the mine
    obj:Activate()

    local mineLocator = enterprise_storage:getObjectLocator(obj)
    local itemDepotLocator = t_turtle.GetCurrentTurtleLocator() assert(itemDepotLocator, "Failed obtaining itemDepotLocator")
    local wasteItemDepotLocator = t_turtle.GetCurrentTurtleLocator()

    local expectedDestinationItemsLocator = itemDepotLocator:copy()
    expectedDestinationItemsLocator:setQuery(provideItems)
    local callback2 = Callback:newInstance("T_Mine", "provideItemsTo_AOSrv_Callback", {
        ["expectedDestinationItemsLocator"] = expectedDestinationItemsLocator,
        ["mineLocator"]                     = mineLocator,
    })

    -- test
    local scheduleResult = obj:provideItemsTo_AOSrv({
        provideItems                    = provideItems,
        itemDepotLocator                = itemDepotLocator,
        wasteItemDepotLocator           = wasteItemDepotLocator,
    }, callback2)
    assert(scheduleResult == true, "failed to schedule async service")
end

function T_Mine.provideItemsTo_AOSrv_Callback(callbackData, serviceResults)
    -- test (cont)
    assert(serviceResults.success, "failed executing async service")

    local destinationItemsLocator = URL:new(serviceResults.destinationItemsLocator)
    local expectedDestinationItemsLocator = URL:new(callbackData["expectedDestinationItemsLocator"])
    assert(destinationItemsLocator:isEqual(expectedDestinationItemsLocator), "gotten destinationItemsLocator(="..textutils.serialize(destinationItemsLocator, compact)..") not the same as expected(="..textutils.serialize(expectedDestinationItemsLocator, compact)..")")

    -- cleanup test
    local siloLocator = callbackData["siloLocator"]
    enterprise_storage:deleteResource(siloLocator)

    -- end
    return true
end

function T_Mine.T_ProvideMultipleItems()
    -- prepare test
    local provideItems = {
        ["minecraft:iron_ore"]  = 5,
        ["minecraft:coal"]      = 3,
    }

    -- test
    provideItemsTo_AOSrv_Test(provideItems)
end

return T_Mine
