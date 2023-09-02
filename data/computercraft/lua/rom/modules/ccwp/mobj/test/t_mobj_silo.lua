local T_Silo = {}
local corelog = require "corelog"
local coreutils = require "coreutils"
local coredht = require "coredht"

local Callback = require "obj_callback"

local IObj = require "i_obj"
local IItemSupplier = require "i_item_supplier"
local IItemDepot = require "i_item_depot"
local ObjBase = require "obj_base"
local ObjArray = require "obj_array"
local Location = require "obj_location"
local URL = require "obj_url"

local IMObj = require "i_mobj"
local Silo = require "mobj_silo"

local enterprise_chests = require "enterprise_chests"
local enterprise_isp = require "enterprise_isp"
local enterprise_shop = require "enterprise_shop"
local enterprise_storage = require "enterprise_storage"

local TestArrayTest = require "test_array_test"
local FieldTest = require "field_test"
local FieldValueEqualTest = require "field_value_equal_test"
local ValueTypeTest = require "value_type_test"
local FieldValueTypeTest = require "field_value_type_test"
local MethodResultEqualTest = require "method_result_equal_test"
local IsBlueprintTest = require "test.is_blueprint_test"

local T_Class = require "test.t_class"
local T_IInterface = require "test.t_i_interface"
local T_IObj = require "test.t_i_obj"
local T_IMObj = require "test.t_i_mobj"
local T_IItemSupplier = require "test.t_i_item_supplier"
local T_IItemDepot = require "test.t_i_item_depot"

local t_turtle = require "test.t_turtle"

function T_Silo.T_All()
    -- initialisation
    T_Silo.T__init()
    T_Silo.T_new()

    -- IObj methods
    T_Silo.T_IObj_All()

    -- IMObj methods
    T_Silo.T_IMObj_All()

    -- IItemSupplier methods
    T_Silo.T_IItemSupplier_All()

    -- IItemDepot methods
    T_Silo.T_IItemDepot_All()
end

local testClassName = "Silo"
local testObjName = "silo"
local logOk = false
local baseLocation1  = Location:newInstance(12, -12, 1, 0, 1)
local entryLocation1 = baseLocation1:getRelativeLocation(3, 3, 0)
local dropLocation1 = 0
local pickupLocation1 = 0
local locatorClassName = "URL"
local topChests1 = ObjArray:newInstance(locatorClassName) assert(topChests1, "Failed obtaining ObjArray")
local storageChests1 = ObjArray:newInstance(locatorClassName) assert(storageChests1, "Failed obtaining ObjArray")

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_Silo.CreateTestObj(id, baseLocation, entryLocation, dropLocation, pickupLocation, topChests, storageChests)
    -- check input
    id = id or coreutils.NewId()
    baseLocation = baseLocation or baseLocation1
    entryLocation = entryLocation or entryLocation1
    dropLocation = dropLocation or dropLocation1
    pickupLocation = pickupLocation or pickupLocation1
    topChests = topChests or topChests1
    storageChests = storageChests or storageChests1

    -- create testObj
    local testObj = Silo:newInstance(id, baseLocation:copy(), entryLocation:copy(), dropLocation, pickupLocation, topChests:copy(), storageChests:copy())

    -- end
    return testObj
end

function T_Silo.CreateInitialisedTest(id, baseLocation, entryLocation, dropLocation, pickupLocation, topChestsTest, storageChestsTest)
    -- check input

    -- create test
    local idTest = FieldValueEqualTest:newInstance("_id", id)
    if not id then
        -- note: allow for testing only the type (instead of also the value)
        idTest = FieldValueTypeTest:newInstance("_id", "string")
    end
    local test = TestArrayTest:newInstance(
        idTest,
        FieldValueEqualTest:newInstance("_baseLocation", baseLocation),
        FieldValueEqualTest:newInstance("_entryLocation", entryLocation),
        FieldValueEqualTest:newInstance("_dropLocation", dropLocation),
        FieldValueEqualTest:newInstance("_pickupLocation", pickupLocation),
        topChestsTest,
        storageChestsTest
    )

    -- end
    return test
end

function T_Silo.T__init()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":_init() tests")
    local id = coreutils.NewId()

    -- test
    local obj = T_Silo.CreateTestObj(id, baseLocation1, entryLocation1, dropLocation1, pickupLocation1, topChests1, storageChests1) assert(obj, "Failed obtaining "..testClassName)
    local topChestsTest = FieldValueEqualTest:newInstance("_topChests", topChests1)
    local storageChestsTest = FieldValueEqualTest:newInstance("_storageChests", storageChests1)
    local test = T_Silo.CreateInitialisedTest(id, baseLocation1, entryLocation1, dropLocation1, pickupLocation1, topChestsTest, storageChestsTest)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_Silo.T_new()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() tests")
    local id = coreutils.NewId()

    -- test
    local obj = Silo:new({
        _id             = id,

        -- locations
        _baseLocation   = baseLocation1:copy(),
        _entryLocation  = entryLocation1:copy(),

        -- pickup and drop
        _dropLocation   = dropLocation1,
        _pickupLocation = pickupLocation1,

        -- chests
        _topChests      = topChests1:copy(),
        _storageChests  = storageChests1:copy(),
    })
    local topChestsTest = FieldValueEqualTest:newInstance("_topChests", topChests1)
    local storageChestsTest = FieldValueEqualTest:newInstance("_storageChests", storageChests1)
    local test = T_Silo.CreateInitialisedTest(id, baseLocation1, entryLocation1, dropLocation1, pickupLocation1, topChestsTest, storageChestsTest)
    test:test(obj, testObjName, "", logOk)
end

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

function T_Silo.T_IObj_All()
    -- prepare test
    local id = coreutils.NewId()
    local obj = T_Silo.CreateTestObj(id) assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_Silo.CreateTestObj(id) assert(otherObj, "Failed obtaining "..testClassName)

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

local nTopChests1 = 4
local nLayers1 = 3
local constructParameters1 = {
    baseLocation    = baseLocation1,
    nTopChests      = nTopChests1,
    nLayers         = nLayers1,
}

function T_Silo.T_IMObj_All()
    -- prepare test
    local id = coreutils.NewId()
    local obj = T_Silo.CreateTestObj(id, baseLocation1, entryLocation1, dropLocation1, pickupLocation1, topChests1, storageChests1) assert(obj, "Failed obtaining "..testClassName)

    local dropLocation = 1
    local pickupLocation = 2
    local topChestsTest = FieldTest:newInstance("_topChests", TestArrayTest:newInstance(
        ValueTypeTest:newInstance("ObjArray"),
        MethodResultEqualTest:newInstance("getObjClassName", locatorClassName),
        MethodResultEqualTest:newInstance("nObjs", nTopChests1)
    ))
    local storageChestsTest = FieldTest:newInstance("_storageChests", TestArrayTest:newInstance(
        ValueTypeTest:newInstance("ObjArray"),
        MethodResultEqualTest:newInstance("getObjClassName", locatorClassName),
        MethodResultEqualTest:newInstance("nObjs", nLayers1*4)
    ))
    local constructInitialisedTest = T_Silo.CreateInitialisedTest(nil, baseLocation1, entryLocation1, dropLocation, pickupLocation, topChestsTest, storageChestsTest)

    local isBlueprintTest = IsBlueprintTest:newInstance(baseLocation1)

    -- test
    T_IMObj.pt_IsInstanceOf_IMObj(testClassName, obj)
    T_IMObj.pt_Implements_IMObj(testClassName, obj)
    T_IMObj.pt_destruct(testClassName, Silo, constructParameters1)
    T_IMObj.pt_construct(testClassName, Silo, constructParameters1, testObjName, constructInitialisedTest, logOk)
    T_IMObj.pt_getId(testClassName, obj, testObjName, logOk)
    T_IMObj.pt_getWIPId(testClassName, obj, testObjName, logOk)
    T_IMObj.pt_getBuildBlueprint(testClassName, obj, testObjName, isBlueprintTest, logOk)
    T_IMObj.pt_getDismantleBlueprint(testClassName, obj, testObjName, isBlueprintTest, logOk)
end

--                        _                           _   _               _
--                       (_)                         | | | |             | |
--    ___  ___ _ ____   ___  ___ ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \  __/ |   \ V /| | (_|  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/\___|_|    \_/ |_|\___\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

function T_Silo.T_integrity()
    -- do the new test
    corelog.WriteToLog("* Silo:construct() tests")
    local obj = Silo:construct({baseLocation=baseLocation1, nTopChests=2, nLayers=2}) assert(obj, "Failed obtaining "..testClassName)
    local siloLocator = enterprise_storage:saveObject(obj)

    obj:IntegretyCheck()
end

--    _____ _____ _                  _____                   _ _                            _   _               _
--   |_   _|_   _| |                / ____|                 | (_)                          | | | |             | |
--     | |   | | | |_ ___ _ __ ___ | (___  _   _ _ __  _ __ | |_  ___ _ __   _ __ ___   ___| |_| |__   ___   __| |___
--     | |   | | | __/ _ \ '_ ` _ \ \___ \| | | | '_ \| '_ \| | |/ _ \ '__| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| |_ _| |_| ||  __/ | | | | |____) | |_| | |_) | |_) | | |  __/ |    | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____|_____|\__\___|_| |_| |_|_____/ \__,_| .__/| .__/|_|_|\___|_|    |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                                              | |   | |
--                                              |_|   |_|

function T_Silo.T_IItemSupplier_All()
    -- prepare test
    local obj = T_Silo.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

    -- test
    T_Class.pt_IsInstanceOf(testClassName, obj, "IItemSupplier", IItemSupplier)
    T_IInterface.pt_ImplementsInterface("IItemSupplier", IItemSupplier, testClassName, obj)
end

local function provideItemsTo_AOSrv_Test(provideItems)
    -- prepare test (cont)
    corelog.WriteToLog("* Silo:provideItemsTo_AOSrv() test (of "..textutils.serialize(provideItems, compact)..")")
    local obj = Silo:construct({baseLocation=baseLocation1, nTopChests=2, nLayers=2}) assert(obj, "Failed obtaining "..testClassName)

    -- activate the silo
    obj:Activate()

    local siloLocator = enterprise_storage:getObjectLocator(obj)
    local itemDepotLocator = t_turtle.GetCurrentTurtleLocator() assert(itemDepotLocator, "Failed obtaining itemDepotLocator")

    local expectedDestinationItemsLocator = itemDepotLocator:copy()
    expectedDestinationItemsLocator:setQuery(provideItems)
    local callback = Callback:newInstance("T_Silo", "provideItemsTo_AOSrv_Callback", {
        ["expectedDestinationItemsLocator"] = expectedDestinationItemsLocator,
        ["siloLocator"]                     = siloLocator,
    })

    -- test
    local scheduleResult = obj:provideItemsTo_AOSrv({
        provideItems                    = provideItems,
        itemDepotLocator                = itemDepotLocator,
    }, callback)
    assert(scheduleResult == true, "failed to schedule async service")
end

function T_Silo.provideItemsTo_AOSrv_Callback(callbackData, serviceResults)
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

function T_Silo.T_ProvideMultipleItems()
    -- prepare test
    local provideItems = {
        ["minecraft:birch_planks"]  = 5,
        ["minecraft:birch_log"]     = 3,
        ["minecraft:coal"]          = 7,
    }

    -- test
    provideItemsTo_AOSrv_Test(provideItems)
end

--    _____ _____ _                 _____                   _                    _   _               _
--   |_   _|_   _| |               |  __ \                 | |                  | | | |             | |
--     | |   | | | |_ ___ _ __ ___ | |  | | ___ _ __   ___ | |_   _ __ ___   ___| |_| |__   ___   __| |___
--     | |   | | | __/ _ \ '_ ` _ \| |  | |/ _ \ '_ \ / _ \| __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| |_ _| |_| ||  __/ | | | | | |__| |  __/ |_) | (_) | |_  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____|_____|\__\___|_| |_| |_|_____/ \___| .__/ \___/ \__| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                                             | |
--                                             |_|

function T_Silo.T_IItemDepot_All()
    -- prepare test
    local obj = T_Silo.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

    -- test
    T_Class.pt_IsInstanceOf(testClassName, obj, "IItemDepot", IItemDepot)
    T_IInterface.pt_ImplementsInterface("IItemDepot", IItemDepot, testClassName, obj)
end

function T_Silo.T_storeItemsFrom_AOSrv()
    -- prepare test
    corelog.WriteToLog("* Silo:storeItemsFrom_AOSrv() test")
    local itemsLocator = t_turtle.GetCurrentTurtleLocator() assert(itemsLocator, "Failed obtaining itemsLocator")
    local obj = Silo:construct({baseLocation=baseLocation1, nTopChests=2, nLayers=2}) assert(obj, "Failed obtaining "..testClassName)
    local siloLocator = enterprise_storage:saveObject(obj)

    local provideItems = {
        ["minecraft:birch_log"]  = 5,
        ["minecraft:birch_planks"]  = 2,
    }
    itemsLocator:setQuery(provideItems)

    local expectedDestinationItemsLocator = siloLocator:copy()
    expectedDestinationItemsLocator:setQuery(provideItems)
    local callback = Callback:newInstance("T_Silo", "storeItemsFrom_AOSrv_Callback", {
        ["expectedDestinationItemsLocator"] = expectedDestinationItemsLocator,
        ["siloLocator"]                     = siloLocator,
        ["itemsLocator"]                    = itemsLocator:copy(),
    })

    -- test
    local scheduleResult = obj:storeItemsFrom_AOSrv({
        itemsLocator    = itemsLocator,
    }, callback)
    assert(scheduleResult == true, "failed to schedule async service")

    -- cleanup test
end

function T_Silo.storeItemsFrom_AOSrv_Callback(callbackData, serviceResults)
    -- test (cont)
    assert(serviceResults.success, "failed executing async service")

    local destinationItemsLocator = URL:new(serviceResults.destinationItemsLocator)
    local expectedDestinationItemsLocator = URL:new(callbackData["expectedDestinationItemsLocator"])
    assert(destinationItemsLocator:isEqual(expectedDestinationItemsLocator), "gotten destinationItemsLocator(="..textutils.serialize(destinationItemsLocator, compact)..") not the same as expected(="..textutils.serialize(expectedDestinationItemsLocator, compact)..")")

    -- cleanup test
    local siloLocator = callbackData["siloLocator"]
    enterprise_storage:deleteResource(siloLocator)
    -- ToDo: WHO (OWNS AND SO) DELETES the CHESTS in the silo???
    local itemsLocator = callbackData["itemsLocator"]
    if enterprise_chests:isLocatorFromHost(itemsLocator) then
       enterprise_chests:deleteResource(itemsLocator)
    end

    -- end
    return true
end

function T_Silo.T_GetRandomSilo()
    local data = coredht.GetData("enterprise_storage", "objects", "class=Silo")
    if type(data) ~= "table" then return nil end
    local id = next(data)
    if not id then return nil end
    local silo = Silo:new(data[id])
    if not silo then return nil end

    -- see what's inside
--    silo:IntegretyCheck()

    -- usefull if this silo is active
    silo:Activate()

    -- do the testing
--    corelog.WriteToLog("can_ProvideItems_QOSrv test")
--    corelog.WriteToLog(silo:can_ProvideItems_QOSrv({provideItems = {["minecraft:coal"] = 7}}))

--[[     -- prepare test
    local provideItems = {
        ["minecraft:birch_planks"]  = 5,
        ["minecraft:birch_log"]     = 3,
        ["minecraft:coal"]          = 7,
    }

    -- test
    silo:provideItemsTo_AOSrv({provideItems = provideItems, itemDepotLocator = t_turtle.GetCurrentTurtleLocator()}, Callback.GetNewDummyCallBack())
 ]]
--[[
    -- da silo
    local daSilo    = silo:getObjectLocator()

    -- da shop
    local daShop = enterprise_shop.GetShopLocator()             assert(daShop, "Oops")
    local daTurtle = t_turtle.GetCurrentTurtleLocator()         assert(daTurtle, "Oops")
    local turtleLocator = daTurtle.GetCurrentTurtleLocator()
    local daCallback = Callback.GetNewDummyCallBack()

    -- da command
    --enterprise_isp.ProvideItemsTo_ASrv(...)

    -- test
    return daShop:provideItemsTo_AOSrv({
        provideItems                    = { [""] = 64},
        itemDepotLocator                = daSilo,
        ingredientsItemSupplierLocator  = turtleLocator,
        wasteItemDepotLocator           = turtleLocator,
    }, daCallback)
 ]]
end

return T_Silo
