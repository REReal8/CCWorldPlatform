local T_Chest = {}
local corelog = require "corelog"
local coreutils = require "coreutils"

local role_energizer = require "role_energizer"

local Callback = require "obj_callback"

local IObj = require "i_obj"
local IItemSupplier = require "i_item_supplier"
local IItemDepot = require "i_item_depot"
local ObjBase = require "obj_base"
local Location = require "obj_location"
local Inventory = require "obj_inventory"
local URL = require "obj_url"

local Chest = require "mobj_chest"

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
local T_IItemSupplier = require "test.t_i_item_supplier"
local T_IItemDepot = require "test.t_i_item_depot"

local t_employment

function T_Chest.T_All()
    -- initialisation
    T_Chest.T__init()
    T_Chest.T_new()
    T_Chest.T_Getters()

    -- IObj
    T_Chest.T_IObj_All()

    -- ILObj
    T_Chest.T_ILObj_All()

    -- IMObj
    T_Chest.T_IMObj_All()

    -- IItemSupplier
    T_Chest.T_IItemSupplier_All()

    T_Chest.T_needsTo_ProvideItemsTo_SOSrv() -- ToDo: generalise
    T_Chest.T_can_ProvideItems_QOSrv()  -- ToDo: generalise

    -- IItemDepot
    T_Chest.T_IItemDepot_All()
end

local testClassName = "Chest"
local testObjName = "chest"
local mobjHostName = "enterprise_chests"

local logOk = false

local testStartLocation  = Location:newInstance(-6, 0, 1, 0, 1)
local baseLocation0  = testStartLocation:getRelativeLocation(2, 5, 0)
local accessDirection0 = "top"
local inventoryEmpty = Inventory:newInstance()
local inventory0 = Inventory:newInstance() -- ToDo: add elements

local constructParameters0 = {
    baseLocation    = baseLocation0,
    accessDirection = accessDirection0,
}

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_Chest.CreateTestObj(id, baseLocation, accessDirection, inventory)
    -- check input
    id = id or coreutils.NewId()
    baseLocation = baseLocation or baseLocation0
    accessDirection = accessDirection or accessDirection0
    inventory = inventory or inventory0

    -- create testObj
    local testObj = Chest:newInstance(id, baseLocation:copy(), accessDirection, inventory:copy())

    -- end
    return testObj
end

function T_Chest.CreateInitialisedTest(id, baseLocation, accessDirection, inventory)
    -- check input

    -- create test
    local idTest = FieldValueTypeTest:newInstance("_id", "string") -- note: allow for testing only the type (instead of also the value)
    if id then idTest = FieldValueEqualTest:newInstance("_id", id) end
    local test = TestArrayTest:newInstance(
        idTest,
        FieldValueEqualTest:newInstance("_baseLocation", baseLocation),
        FieldValueEqualTest:newInstance("_accessDirection", accessDirection),
        FieldValueEqualTest:newInstance("_inventory", inventory)
    )

    -- end
    return test
end

function T_Chest.T__init()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":_init() tests")
    local id = coreutils.NewId()

    -- test
    local obj = T_Chest.CreateTestObj(id, baseLocation0, accessDirection0, inventory0) assert(obj, "Failed obtaining "..testClassName)
    local test = T_Chest.CreateInitialisedTest(id, baseLocation0, accessDirection0, inventory0)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_Chest.T_new()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() tests")
    local id = coreutils.NewId()

    -- test
    local obj = Chest:new({
        _id                     = id,

        _baseLocation           = baseLocation0:copy(),
        _accessDirection        = accessDirection0,
        _inventory              = inventory0:copy(),
    })
    local test = T_Chest.CreateInitialisedTest(id, baseLocation0, accessDirection0, inventory0)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_Chest.T_Getters()
    -- prepare test
    corelog.WriteToLog("* "..testClassName.." base getter tests")
    local obj = T_Chest.CreateTestObj(nil, baseLocation0, accessDirection0, inventory0) assert(obj, "Failed obtaining "..testClassName)

    -- test
    local test = TestArrayTest:newInstance(
        MethodResultEqualTest:newInstance("getAccessDirection", accessDirection0),
        MethodResultEqualTest:newInstance("getInventory", inventory0)
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

function T_Chest.T_IObj_All()
    -- prepare test
    local id = coreutils.NewId()
    local obj = T_Chest.CreateTestObj(id) assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_Chest.CreateTestObj(id) assert(otherObj, "Failed obtaining "..testClassName)

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

function T_Chest.T_ILObj_All()
    -- prepare test
    local destructFieldsTest = TestArrayTest:newInstance()

    local fieldsTest1 = T_Chest.CreateInitialisedTest(nil, baseLocation0, accessDirection0, inventoryEmpty)

    -- test cases
    T_ILObj.pt_all(testClassName, Chest, {
        {
            objName             = testObjName,
            constructParameters = constructParameters0,
            constructFieldsTest = fieldsTest1,
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

function T_Chest.T_IMObj_All()
    -- prepare test
    local isBlueprintTest = IsBlueprintTest:newInstance(baseLocation0)

    -- test cases
    T_IMObj.pt_all(testClassName, Chest, {
        {
            objName                 = testObjName,
            constructParameters     = constructParameters0,
            constructBlueprintTest  = isBlueprintTest,
            expectedBaseLocation    = baseLocation0:copy(),
            dismantleBlueprintTest  = isBlueprintTest,
        },
    }, logOk)
end

--                        _
--                       (_)
--    ___  ___ _ ____   ___  ___ ___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \
--   \__ \  __/ |   \ V /| | (_|  __/
--   |___/\___|_|    \_/ |_|\___\___|

function T_Chest.T_updateChestRecord_AOSrv()
    -- prepare test
    corelog.WriteToLog("* Chest:updateChestRecord_AOSrv test")
    local obj = T_Chest.CreateTestObj(nil, baseLocation0) assert(obj, "Failed obtaining "..testClassName)
    local chestLocator = enterprise_chests:saveObject(obj)

    local callback = Callback:newInstance("T_Chest", "updateChestRecord_AOSrv_Callback", {
        ["chestLocator"] = chestLocator,
    })

    -- test
    local scheduleResult = obj:updateChestRecord_AOSrv({}, callback)
    assert(scheduleResult == true, "failed to schedule async service")
end

function T_Chest.updateChestRecord_AOSrv_Callback(callbackData, serviceResults)
    -- test (cont)
    assert(serviceResults.success, "failed executing async service")
    local chestLocator = callbackData["chestLocator"]
    local updatedChest = enterprise_chests:getObject(chestLocator)
    assert (updatedChest, "Chest not saved")

    -- cleanup test
    enterprise_chests:deleteResource(chestLocator)

    -- end
    return true
end

--    _____ _____ _                  _____                   _ _
--   |_   _|_   _| |                / ____|                 | (_)
--     | |   | | | |_ ___ _ __ ___ | (___  _   _ _ __  _ __ | |_  ___ _ __
--     | |   | | | __/ _ \ '_ ` _ \ \___ \| | | | '_ \| '_ \| | |/ _ \ '__|
--    _| |_ _| |_| ||  __/ | | | | |____) | |_| | |_) | |_) | | |  __/ |
--   |_____|_____|\__\___|_| |_| |_|_____/ \__,_| .__/| .__/|_|_|\___|_|
--                                              | |   | |
--                                              |_|   |_|

function T_Chest.T_IItemSupplier_All()
    -- prepare test
    local obj = T_Chest.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

    -- test
    T_Class.pt_IsInstanceOf(testClassName, obj, "IItemSupplier", IItemSupplier)
    T_IInterface.pt_ImplementsInterface("IItemSupplier", IItemSupplier, testClassName, obj)
end

function T_Chest.T_provideItemsTo_AOSrv_Turtle()
    -- prepare test
    --note: as a test short cut we do not have to set the Inventory content here. We just assume the test Chest is present. FetchItemsFromChestIntoTurtle_Task should make sure the inventory is obtained

    t_employment = t_employment or require "test.t_employment"
    local itemDepotLocator = t_employment.GetCurrentTurtleLocator()

    local provideItems = {
        ["minecraft:birch_log"]  = 5,
    }

    -- test
    T_IItemSupplier.pt_provideItemsTo_AOSrv_Test(mobjHostName, testClassName, constructParameters0, provideItems, itemDepotLocator)

    -- cleanup test
end

function T_Chest.T_provideItemsTo_AOSrv_Chest()
    -- prepare test
    local obj2 = T_Chest.CreateTestObj(nil, baseLocation0:getRelativeLocation(0, 6, 0)) assert(obj2, "Failed obtaining "..testClassName.." 2")
    local itemDepotLocator = enterprise_chests:saveObject(obj2)

    local provideItems = {
        ["minecraft:birch_log"]  = 5,
    }

    -- test
    T_IItemSupplier.pt_provideItemsTo_AOSrv_Test(mobjHostName, testClassName, constructParameters0, provideItems, itemDepotLocator)

    -- cleanup test
    enterprise_chests:deleteResource(itemDepotLocator)
end

function T_Chest.T_needsTo_ProvideItemsTo_SOSrv()
    -- prepare test
    corelog.WriteToLog("* Chest:needsTo_ProvideItemsTo_SOSrv() tests")
    local obj = T_Chest.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)
    local provideItems = {
        ["minecraft:birch_log"]  = 5,
    }

    local obj2 = T_Chest.CreateTestObj(nil, baseLocation0:getRelativeLocation(0, 6, 0)) assert(obj2, "Failed obtaining "..testClassName.." 2")
    local itemDepotLocator = enterprise_chests:saveObject(obj2)
    local itemDepotLocation = obj2:getBaseLocation()

    -- test
    local needsTo_Provide = obj:needsTo_ProvideItemsTo_SOSrv({
        provideItems    = provideItems,
        itemDepotLocator= itemDepotLocator,
    })
    local expectedFuelNeed = 1 * role_energizer.NeededFuelToFrom(itemDepotLocation, obj:getBaseLocation())
    assert(needsTo_Provide.success, "needsTo_ProvideItemsTo_SOSrv failed")
    assert(needsTo_Provide.fuelNeed == expectedFuelNeed, "fuelNeed(="..needsTo_Provide.fuelNeed..") not the same as expected(="..expectedFuelNeed..")")
    assert(#needsTo_Provide.ingredientsNeed == 0, "ingredientsNeed(="..#needsTo_Provide.ingredientsNeed..") not the same as expected(=0)")

    -- cleanup test
    enterprise_chests:deleteResource(itemDepotLocator)
end

function T_Chest.T_can_ProvideItems_QOSrv()
    -- prepare test
    corelog.WriteToLog("* Chest:can_ProvideItems_QOSrv() tests")
    local inventory = Inventory:newInstance({
            { name = "minecraft:dirt", count = 20 },
        })
    local obj = T_Chest.CreateTestObj(nil, baseLocation0, accessDirection0, inventory) assert(obj, "Failed obtaining "..testClassName)

    -- test can
    local itemName = "minecraft:dirt"
    local itemCount = 10
    local serviceResults = obj:can_ProvideItems_QOSrv({ provideItems = { [itemName] = itemCount} })
    assert(serviceResults.success, "can_ProvideItems_QOSrv incorrectly failed for "..itemCount.." "..itemName.."'s")

    -- test can not
    itemName = "minecraft:furnace"
    itemCount = 1
    serviceResults = obj:can_ProvideItems_QOSrv({ provideItems = { [itemName] = itemCount} })
    assert(not serviceResults.success, "can_ProvideItems_QOSrv incorrectly success for "..itemCount.." "..itemName.."'s")

    -- cleanup test
end

--    _____ _____ _                 _____                   _
--   |_   _|_   _| |               |  __ \                 | |
--     | |   | | | |_ ___ _ __ ___ | |  | | ___ _ __   ___ | |_
--     | |   | | | __/ _ \ '_ ` _ \| |  | |/ _ \ '_ \ / _ \| __|
--    _| |_ _| |_| ||  __/ | | | | | |__| |  __/ |_) | (_) | |_
--   |_____|_____|\__\___|_| |_| |_|_____/ \___| .__/ \___/ \__|
--                                             | |
--                                             |_|

function T_Chest.T_IItemDepot_All()
    -- prepare test
    local obj = T_Chest.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

    -- test
    T_Class.pt_IsInstanceOf(testClassName, obj, "IItemDepot", IItemDepot)
    T_IInterface.pt_ImplementsInterface("IItemDepot", IItemDepot, testClassName, obj)
end

local function storeItemsFrom_AOSrv_Test(itemsLocator, toStr)
    -- prepare test (cont)
    corelog.WriteToLog("* Chest:storeItemsFrom_AOSrv() test (to "..toStr..")")
    local obj = T_Chest.CreateTestObj(nil, baseLocation0) assert(obj, "Failed obtaining "..testClassName)
    --note: as a test short cut we do not have to set the Inventory content here. We just assume the test Chest is present. FetchItemsFromChestIntoTurtle_Task should make sure the inventory is obtained
    local chestLocator = enterprise_chests:getObjectLocator(obj)

    local provideItems = {
        ["minecraft:birch_log"]  = 5,
    }
    itemsLocator:setQuery(provideItems)

    local expectedDestinationItemsLocator = chestLocator:copy()
    expectedDestinationItemsLocator:setQuery(provideItems)
    local callback = Callback:newInstance("T_Chest", "storeItemsFrom_AOSrv_Callback", {
        ["expectedDestinationItemsLocator"] = expectedDestinationItemsLocator,
        ["chestLocator"]                    = chestLocator,
        ["itemsLocator"]                    = itemsLocator:copy(),
    })

    -- test
    local scheduleResult = obj:storeItemsFrom_AOSrv({
        itemsLocator    = itemsLocator,
    }, callback)
    assert(scheduleResult == true, "failed to schedule async service")
end

function T_Chest.T_storeItemsFrom_AOSrv_Turtle()
    -- prepare test
    t_employment = t_employment or require "test.t_employment"
    local itemsLocator = t_employment.GetCurrentTurtleLocator()

    -- test
    storeItemsFrom_AOSrv_Test(itemsLocator, "Turtle")
end

function T_Chest.T_storeItemsFrom_AOSrv_Chest()
    -- prepare test
    local obj2 = T_Chest.CreateTestObj(nil, baseLocation0) assert(obj2, "Failed obtaining "..testClassName.." 2")
    local itemsLocator = enterprise_chests:saveObject(obj2)

    -- test
    storeItemsFrom_AOSrv_Test(itemsLocator, "Chest")
end

function T_Chest.storeItemsFrom_AOSrv_Callback(callbackData, serviceResults)
    -- test (cont)
    assert(serviceResults.success, "failed executing async service")

    local destinationItemsLocator = URL:new(serviceResults.destinationItemsLocator)
    local expectedDestinationItemsLocator = URL:new(callbackData["expectedDestinationItemsLocator"])
    assert(destinationItemsLocator:isEqual(expectedDestinationItemsLocator), "gotten destinationItemsLocator(="..textutils.serialize(destinationItemsLocator, compact)..") not the same as expected(="..textutils.serialize(expectedDestinationItemsLocator, compact)..")")

    -- cleanup test
    local chestLocator = callbackData["chestLocator"]
    enterprise_chests:deleteResource(chestLocator)
    local itemsLocator = callbackData["itemsLocator"]
    if enterprise_chests:isLocatorFromHost(itemsLocator) then
        enterprise_chests:deleteResource(itemsLocator)
    end

    -- end
    return true
end

return T_Chest
