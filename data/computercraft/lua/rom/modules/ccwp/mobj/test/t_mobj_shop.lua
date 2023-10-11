local T_Shop = {}
local corelog = require "corelog"
local coreutils = require "coreutils"

local Callback = require "obj_callback"

local IObj = require "i_obj"
local IItemSupplier = require "i_item_supplier"
local ModuleRegistry = require "module_registry"
local moduleRegistry = ModuleRegistry:getInstance()
local ObjBase = require "obj_base"
local ObjArray = require "obj_array"
local URL = require "obj_url"
local Location = require "obj_location"

local Shop = require "mobj_shop"

local role_forester = require "role_forester"

local enterprise_turtle = require "enterprise_turtle"
local enterprise_chests = require "enterprise_chests"
local enterprise_forestry = require "enterprise_forestry"
local enterprise_shop = require "enterprise_shop"

local TestObj = require "test.obj_test"

local T_Class = require "test.t_class"
local T_IInterface = require "test.t_i_interface"
local T_IObj = require "test.t_i_obj"

local TestArrayTest = require "test_array_test"
local FieldValueEqualTest = require "field_value_equal_test"
local FieldValueTypeTest = require "field_value_type_test"
local MethodResultEqualTest = require "method_result_equal_test"

local T_IMObj = require "test.t_i_mobj"
local T_Chest = require "test.t_mobj_chest"
local T_BirchForest = require "test.t_mobj_birchforest"
local T_Host = require "test.t_host"
local t_turtle = require "test.t_turtle"

function T_Shop.T_All()
    -- initialisation
    T_Shop.T__init()
    T_Shop.T_new()
    T_Shop.T_Getters()

    -- IObj
    T_Shop.T_IObj_All()

    -- IMObj
    T_Shop.T_IMObj_All()

    -- service
    T_Shop.T_registerItemSupplier_SOSrv()
    T_Shop.T_delistItemSupplier_SOSrv()
    T_Shop.T_delistAllItemSuppliers()
    T_Shop.T_bestItemSupplier()

    -- IItemSupplier
    T_Shop.T_IItemSupplier_All()
    T_Shop.T_can_ProvideItems_QOSrv()
    T_Shop.T_needsTo_ProvideItemsTo_SOSrv()
end

local testClassName = "Shop"
local testObjName = "shop"
local logOk = false

local itemSuppliersLocators1 = ObjArray:newInstance(URL:getClassName())

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_Shop.CreateTestObj(id, itemSuppliersLocators)
    -- check input
    id = id or coreutils.NewId()
    itemSuppliersLocators = itemSuppliersLocators or itemSuppliersLocators1

    -- create testObj
    local testObj = Shop:newInstance(id, itemSuppliersLocators:copy())

    -- end
    return testObj
end

function T_Shop.CreateInitialisedTest(id, itemSuppliersLocators)
    -- check input

    -- create test
    local idTest = FieldValueTypeTest:newInstance("_id", "string") -- note: allow for testing only the type (instead of also the value)
    if id then idTest = FieldValueEqualTest:newInstance("_id", id) end
    local test = TestArrayTest:newInstance(
        idTest,
        FieldValueEqualTest:newInstance("_itemSuppliersLocators", itemSuppliersLocators)
    )

    -- end
    return test
end

function T_Shop.T__init()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":_init() tests")
    local id = coreutils.NewId()

    -- test
    local obj = T_Shop.CreateTestObj(id, itemSuppliersLocators1) assert(obj, "Failed obtaining "..testClassName)
    local test = T_Shop.CreateInitialisedTest(id, itemSuppliersLocators1)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_Shop.T_new()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() tests")
    local id = coreutils.NewId()

    -- test
    local obj = Shop:new({
        _id                     = id,

        _itemSuppliersLocators  = itemSuppliersLocators1:copy(),
    })
    local test = T_Shop.CreateInitialisedTest(id, itemSuppliersLocators1)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_Shop.T_Getters()
    -- prepare test
    corelog.WriteToLog("* "..testClassName.." getter tests")
    local id = coreutils.NewId()
    local obj = T_Shop.CreateTestObj(id, itemSuppliersLocators1) if not obj then corelog.Error("Failed obtaining Shop") return end

    -- test
    local test = TestArrayTest:newInstance(
        MethodResultEqualTest:newInstance("getItemSuppliersLocators", itemSuppliersLocators1)
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

function T_Shop.T_IObj_All()
    -- prepare test
    local id = coreutils.NewId()
    local obj = T_Shop.CreateTestObj(id) assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_Shop.CreateTestObj(id) assert(otherObj, "Failed obtaining "..testClassName)

    -- test
    T_Class.pt_IsInstanceOf(testClassName, obj, "IObj", IObj)
    T_Class.pt_IsInstanceOf(testClassName, obj, "ObjBase", ObjBase)
    T_IObj.pt_all(testClassName, obj, otherObj)
end

--    _____ __  __  ____  _     _
--   |_   _|  \/  |/ __ \| |   (_)
--     | | | \  / | |  | | |__  _
--     | | | |\/| | |  | | '_ \| |
--    _| |_| |  | | |__| | |_) | |
--   |_____|_|  |_|\____/|_.__/| |
--                            _/ |
--                           |__/

function T_Shop.T_IMObj_All()
    -- prepare test
    local id = coreutils.NewId()
    local obj = T_Shop.CreateTestObj(id, itemSuppliersLocators1) assert(obj, "Failed obtaining "..testClassName)

    -- local destructFieldsTest = TestArrayTest:newInstance()

    -- local constructFieldsTest = T_Shop.CreateInitialisedTest(nil, itemSuppliersLocators1)

    -- test
    -- T_IMObj.pt_IsInstanceOf_IMObj(testClassName, obj)
    -- T_IMObj.pt_Implements_IMObj(testClassName, obj)
    -- T_IMObj.pt_destruct(testClassName, Chest, constructParameters1, testObjName, destructFieldsTest, logOk)
    -- T_IMObj.pt_construct(testClassName, Chest, constructParameters1, testObjName, constructFieldsTest, logOk)
    T_IMObj.pt_getId(testClassName, obj, testObjName, logOk)
    -- T_IMObj.pt_getWIPId(testClassName, obj, testObjName, logOk)
    -- T_IMObj.pt_getBuildBlueprint(testClassName, obj, testObjName, isBlueprintTest, logOk)
    -- T_IMObj.pt_getDismantleBlueprint(testClassName, obj, testObjName, isBlueprintTest, logOk)
end

--                        _
--                       (_)
--    ___  ___ _ ____   ___  ___ ___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \
--   \__ \  __/ |   \ V /| | (_|  __/
--   |___/\___|_|    \_/ |_|\___\___|

function T_Shop.T_registerItemSupplier_SOSrv()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":registerItemSupplier_SOSrv() tests")
    local obj = T_Shop.CreateTestObj() if not obj then corelog.Error("Failed obtaining Shop") return end
    local objectLocator = enterprise_shop:getObjectLocator(obj)
    local nItemSuppliers = #obj:getItemSuppliersLocators() assert(nItemSuppliers == 0, "Shop "..obj:getId().." not empty at start")
    local itemSupplierLocator = t_turtle.GetCurrentTurtleLocator()

    local testObject = TestObj:newInstance("field1", 4)
    local testHost = T_Host.CreateTestObj()
    moduleRegistry:registerModule(testHost:getHostName(), testHost)
    local nonItemSupplierLocator = testHost:saveObject(testObject)

    -- test IItemSupplier
    local result = obj:registerItemSupplier_SOSrv({ itemSupplierLocator = itemSupplierLocator })
    assert(result.success == true, "registerItemSupplier_SOSrv services failed")
    nItemSuppliers = #obj:getItemSuppliersLocators()
    local expectedNItemSuppliers = 1
    assert(nItemSuppliers == expectedNItemSuppliers, "gotten nItemSuppliers(="..nItemSuppliers..") not the same as expected(="..expectedNItemSuppliers..")")

    -- test non IItemSupplier
    result = obj:registerItemSupplier_SOSrv({ itemSupplierLocator = nonItemSupplierLocator, suppressWarning = true })
    assert(result.success == false, "registerItemSupplier_SOSrv services should fail with a non IItemSupplier")

    -- cleanup test
    enterprise_shop:deleteResource(objectLocator) -- note: registerItemSupplier_SOSrv saved the test Shop
    moduleRegistry:delistModule(testHost:getHostName())
    testHost:deleteResource(nonItemSupplierLocator)
end

function T_Shop.T_delistItemSupplier_SOSrv()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":delistItemSupplier_SOSrv() tests")
    local obj = T_Shop.CreateTestObj() if not obj then corelog.Error("Failed obtaining Shop") return end
    local objectLocator = enterprise_shop:getObjectLocator(obj)
    local nItemSuppliers = #obj:getItemSuppliersLocators() assert(nItemSuppliers == 0, "Shop "..obj:getId().." not empty at start")
    local itemSupplierLocator = t_turtle.GetCurrentTurtleLocator()
    local result = obj:registerItemSupplier_SOSrv({ itemSupplierLocator = itemSupplierLocator}) assert(result.success == true, "registerItemSupplier_SOSrv services failed")

    -- test
    result = obj:delistItemSupplier_SOSrv({ itemSupplierLocator = itemSupplierLocator})
    assert(result.success == true, "delistItemSupplier_SOSrv services failed")
    nItemSuppliers = #obj:getItemSuppliersLocators()
    local expectedNItemSuppliers = 0
    assert(nItemSuppliers == expectedNItemSuppliers, "gotten nItemSuppliers(="..nItemSuppliers..") not the same as expected(="..expectedNItemSuppliers..")")

    -- cleanup test
    enterprise_shop:deleteResource(objectLocator) -- note: delistItemSupplier_SOSrv saved the test Shop
end

function T_Shop.T_delistAllItemSuppliers()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":delistAllItemSuppliers() tests")
    local obj = T_Shop.CreateTestObj() if not obj then corelog.Error("Failed obtaining Shop") return end
    local objectLocator = enterprise_shop:getObjectLocator(obj)
    local nItemSuppliers = #obj:getItemSuppliersLocators() assert(nItemSuppliers == 0, "Shop "..obj:getId().." not empty at start")
    local itemSupplierLocator = t_turtle.GetCurrentTurtleLocator()
    local result = obj:registerItemSupplier_SOSrv({ itemSupplierLocator = itemSupplierLocator}) assert(result.success == true, "registerItemSupplier_SOSrv services failed")
    local location1 = Location:newInstance(10, 0, 1, 0, 1)

    local chest = T_Chest.CreateTestObj(nil, location1) assert(chest, "Failed obtaining Chest")
    local chestLocator = enterprise_chests:saveObject(chest)
    result = obj:registerItemSupplier_SOSrv({ itemSupplierLocator = chestLocator}) assert(result.success == true, "registerItemSupplier_SOSrv services failed")

    nItemSuppliers = #obj:getItemSuppliersLocators() assert(nItemSuppliers == 2, "Shop "..obj:getId().." does not have 2 ItemSupplier's")

    -- test
    obj:delistAllItemSuppliers()
    nItemSuppliers = #obj:getItemSuppliersLocators()
    local expectedNItemSuppliers = 0
    assert(nItemSuppliers == expectedNItemSuppliers, "gotten # ItemSuppliers(="..nItemSuppliers..") not the same as expected(="..expectedNItemSuppliers..")")

    -- cleanup test
    enterprise_shop:deleteResource(objectLocator) -- note: delistAllItemSuppliers saved the test Shop
    enterprise_chests:deleteResource(chestLocator)
end

function T_Shop.T_bestItemSupplier()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":bestItemSupplier() tests")
    local obj = T_Shop.CreateTestObj() if not obj then corelog.Error("Failed obtaining Shop") return end
    local objectLocator = enterprise_shop:getObjectLocator(obj)
    local item = {
        ["minecraft:birch_log"]  = 5,
    }
    local ingredientsItemSupplierLocator = objectLocator
    local location1 = Location:newInstance(10, 0, 1, 0, 1)
    local chest = T_Chest.CreateTestObj(nil, location1) assert(chest, "Failed obtaining Chest")
    local itemDepotLocator = enterprise_chests:saveObject(chest)

    -- test lowest fuelNeed
    local closeLocation = location1:getRelativeLocation(1, 1, 0)
    chest = T_Chest.CreateTestObj(nil, closeLocation) assert(chest, "Failed obtaining Chest")
    local closeItemSupplierLocator = enterprise_chests:saveObject(chest)
    local result = obj:registerItemSupplier_SOSrv({ itemSupplierLocator = closeItemSupplierLocator}) assert(result.success == true, "registerItemSupplier_SOSrv services failed")

    local farLocation = location1:getRelativeLocation(Location.FarX(), 1, 0)
    chest = T_Chest.CreateTestObj(nil, farLocation) assert(chest, "Failed obtaining Chest")
    local farItemSupplierLocator = enterprise_chests:saveObject(chest)
    result = obj:registerItemSupplier_SOSrv({ itemSupplierLocator = farItemSupplierLocator}) assert(result.success == true, "registerItemSupplier_SOSrv services failed")

    local bestItemSupplierLocator = obj:bestItemSupplier(item, itemDepotLocator, ingredientsItemSupplierLocator, farItemSupplierLocator, closeItemSupplierLocator)
    local expectedItemSupplierLocator = closeItemSupplierLocator
    assert(bestItemSupplierLocator:isEqual(expectedItemSupplierLocator), "gotten bestItemSupplier(="..textutils.serialize(bestItemSupplierLocator, compact)..") not the same as expected(="..textutils.serialize(expectedItemSupplierLocator, compact)..")")

    -- cleanup test
    enterprise_shop:deleteResource(objectLocator)
    enterprise_chests:deleteResource(itemDepotLocator)
    enterprise_chests:deleteResource(closeItemSupplierLocator)
    enterprise_chests:deleteResource(farItemSupplierLocator)
end

--    _____ _____ _                  _____                   _ _
--   |_   _|_   _| |                / ____|                 | (_)
--     | |   | | | |_ ___ _ __ ___ | (___  _   _ _ __  _ __ | |_  ___ _ __
--     | |   | | | __/ _ \ '_ ` _ \ \___ \| | | | '_ \| '_ \| | |/ _ \ '__|
--    _| |_ _| |_| ||  __/ | | | | |____) | |_| | |_) | |_) | | |  __/ |
--   |_____|_____|\__\___|_| |_| |_|_____/ \__,_| .__/| .__/|_|_|\___|_|
--                                              | |   | |
--                                              |_|   |_|

function T_Shop.T_IItemSupplier_All()
    -- prepare test
    local obj = T_Shop.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

    -- test
    T_Class.pt_IsInstanceOf(testClassName, obj, "IItemSupplier", IItemSupplier)
    T_IInterface.pt_ImplementsInterface("IItemSupplier", IItemSupplier, testClassName, obj)
end

local function provideItemsTo_AOSrv_Test(provideItems)
    -- prepare test (cont)
    corelog.WriteToLog("* "..testClassName..":provideItemsTo_AOSrv() test (of "..textutils.serialize(provideItems, compact)..")")
    local obj = T_Shop.CreateTestObj() if not obj then corelog.Error("Failed obtaining Shop") return end
    local objectLocator = enterprise_shop:getObjectLocator(obj)
    local itemDepotLocator = t_turtle.GetCurrentTurtleLocator() assert(itemDepotLocator, "Failed obtaining itemDepotLocator")
    local result = obj:registerItemSupplier_SOSrv({ itemSupplierLocator = itemDepotLocator}) assert(result.success == true, "registerItemSupplier_SOSrv services failed")
    local ingredientsItemSupplierLocator = objectLocator
    local wasteItemDepotLocator = t_turtle.GetCurrentTurtleLocator()

    local expectedDestinationItemsLocator = itemDepotLocator:copy()
    expectedDestinationItemsLocator:setQuery(provideItems)
    local callback = Callback:newInstance("T_Shop", "provideItemsTo_AOSrv_Callback", {
        ["expectedDestinationItemsLocator"] = expectedDestinationItemsLocator,
        ["objectLocator"]                   = objectLocator,
    })

    -- test
    local scheduleResult = obj:provideItemsTo_AOSrv({
        provideItems                    = provideItems,
        itemDepotLocator                = itemDepotLocator,
        ingredientsItemSupplierLocator  = ingredientsItemSupplierLocator,
        wasteItemDepotLocator           = wasteItemDepotLocator,
    }, callback)
    assert(scheduleResult == true, "failed to schedule async service")
end

function T_Shop.provideItemsTo_AOSrv_Callback(callbackData, serviceResults)
    -- test (cont)
    assert(serviceResults.success, "failed executing async service")

    local destinationItemsLocator = URL:new(serviceResults.destinationItemsLocator)
    local expectedDestinationItemsLocator = URL:new(callbackData["expectedDestinationItemsLocator"])
    assert(destinationItemsLocator:isEqual(expectedDestinationItemsLocator), "gotten destinationItemsLocator(="..textutils.serialize(destinationItemsLocator, compact)..") not the same as expected(="..textutils.serialize(expectedDestinationItemsLocator, compact)..")")

    -- cleanup test
    local objectLocator = callbackData["objectLocator"]
    enterprise_shop:deleteResource(objectLocator)

    -- end
    return true
end

function T_Shop.T_ProvideMultipleItems()
    -- prepare test
    local provideItems = {
        ["minecraft:furnace"]   = 1,
        ["minecraft:charcoal"]  = 1, -- ToDo: test if furnace get produced once charcoal is being smelted (as soon as projects support parallel steps)
    }

    -- test
    provideItemsTo_AOSrv_Test(provideItems)
end

function T_Shop.T_ProvideCharcoal()
    -- prepare test
    local provideItems = {
        ["minecraft:charcoal"]  = 3,
    }

    -- test
    provideItemsTo_AOSrv_Test(provideItems)
end

function T_Shop.T_ProvideTorch()
    -- prepare test
    local provideItems = {
        ["minecraft:torch"]  = 4,
    }

    -- test
    provideItemsTo_AOSrv_Test(provideItems)
end

function T_Shop.T_can_ProvideItems_QOSrv()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":can_ProvideItems_QOSrv() tests")
    local obj = T_Shop.CreateTestObj() if not obj then corelog.Error("Failed obtaining obj") return end
    local objectLocator = enterprise_shop:getObjectLocator(obj)
    local forest = T_BirchForest.CreateTestObj() assert(forest, "Failed obtaining BirchForest")
    local forestLocator = enterprise_forestry:saveObject(forest)
    local result = obj:registerItemSupplier_SOSrv({ itemSupplierLocator = forestLocator}) assert(result.success == true, "registerItemSupplier_SOSrv services failed")

    -- test
    local itemName = "minecraft:birch_log"
    local itemCount = 20
    local serviceResults = obj:can_ProvideItems_QOSrv({ provideItems = { [itemName] = itemCount} })
    assert(serviceResults.success, "can_ProvideItems_QOSrv incorrectly failed for "..itemCount.." "..itemName.."'s")

    itemName = "minecraft:birch_sapling"
    itemCount = 2
    serviceResults = obj:can_ProvideItems_QOSrv({ provideItems = { [itemName] = itemCount} })
    assert(serviceResults.success, "can_ProvideItems_QOSrv incorrectly failed for "..itemCount.." "..itemName.."'s")

    itemName = "minecraft:dirt"
    itemCount = 10
    serviceResults = obj:can_ProvideItems_QOSrv({ provideItems = { [itemName] = itemCount} })
    assert(not serviceResults.success, "can_ProvideItems_QOSrv incorrectly success for "..itemCount.." "..itemName.."'s")

    -- cleanup test
    enterprise_shop:deleteResource(objectLocator)
    enterprise_forestry:deleteResource(forestLocator)
end

function T_Shop.T_needsTo_ProvideItemsTo_SOSrv()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":needsTo_ProvideItemsTo_SOSrv() tests")
    local obj = T_Shop.CreateTestObj() if not obj then corelog.Error("Failed obtaining obj") return end
    local objectLocator = enterprise_shop:getObjectLocator(obj)
    local ingredientsItemSupplierLocator = objectLocator
    local nTrees = 1
    local forest = T_BirchForest.CreateTestObj() assert(forest, "Failed obtaining BirchForest")
    local forestLocator = enterprise_forestry:saveObject(forest)
    local result = obj:registerItemSupplier_SOSrv({ itemSupplierLocator = forestLocator}) assert(result.success == true, "registerItemSupplier_SOSrv services failed")

    local provideItems = {
        ["minecraft:birch_log"]  = 5,
    }
    local itemDepotLocator = t_turtle.GetCurrentTurtleLocator()

    -- test
    local needsTo_Provide = obj:needsTo_ProvideItemsTo_SOSrv({
        provideItems                    = provideItems,
        itemDepotLocator                = itemDepotLocator,
        ingredientsItemSupplierLocator  = ingredientsItemSupplierLocator,
    })
    local storeFuelPerRound = 1 + 1
    local expectedFuelNeed = role_forester.FuelNeededPerRound(nTrees) + storeFuelPerRound
    assert(needsTo_Provide.success, "needsTo_ProvideItemsTo_SOSrv failed")
    assert(needsTo_Provide.fuelNeed == expectedFuelNeed, "fuelNeed(="..needsTo_Provide.fuelNeed..") not the same as expected(="..expectedFuelNeed..")")
    assert(#needsTo_Provide.ingredientsNeed == 0, "ingredientsNeed(="..#needsTo_Provide.ingredientsNeed..") not the same as expected(=0)")

    -- cleanup test
    enterprise_shop:deleteResource(objectLocator)
    enterprise_forestry:deleteResource(forestLocator)
end

return T_Shop
