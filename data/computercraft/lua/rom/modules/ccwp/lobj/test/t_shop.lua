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

local Shop = require "shop"

local role_forester = require "role_forester"

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

local T_ILObj = require "test.t_i_lobj"
local T_IItemSupplier = require "test.t_i_item_supplier"

local T_Chest = require "test.t_mobj_chest"
local T_BirchForest = require "test.t_mobj_birchforest"
local T_ObjHost = require "test.t_obj_host"
local t_employment = require "test.t_employment"

function T_Shop.T_All()
    -- initialisation
    T_Shop.T__init()
    T_Shop.T_new()
    T_Shop.T_Getters()

    -- IObj
    T_Shop.T_IObj_All()

    -- ILObj
    T_Shop.T_ILObj_All()

    -- service
    T_Shop.T_registerItemSupplier_SOSrv()
    T_Shop.T_delistItemSupplier_SOSrv()
    T_Shop.T_delistAllItemSuppliers()
    T_Shop.T_bestItemSupplier()

    -- IItemSupplier
    T_Shop.T_IItemSupplier_All()
end

function T_Shop.T_AllPhysical()
    -- IItemSupplier
    T_Shop.T_provideItemsTo_AOSrv_MultipleItems_ToTurtle()
    T_Shop.T_provideItemsTo_AOSrv_Charcoal_ToTurtle()
    T_Shop.T_provideItemsTo_AOSrv_Torch_ToTurtle()
end

local testClassName = "Shop"
local testObjName = "shop"
local testHost = enterprise_shop

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

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
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

--    _____ _      ____  _     _
--   |_   _| |    / __ \| |   (_)
--     | | | |   | |  | | |__  _
--     | | | |   | |  | | '_ \| |
--    _| |_| |___| |__| | |_) | |
--   |_____|______\____/|_.__/| |
--                           _/ |
--                          |__/

function T_Shop.T_ILObj_All()
    -- prepare test
    local id = coreutils.NewId()
    local obj = T_Shop.CreateTestObj(id, itemSuppliersLocators1) assert(obj, "Failed obtaining "..testClassName)

    -- local destructFieldsTest = TestArrayTest:newInstance()

    -- local constructFieldsTest = T_Shop.CreateInitialisedTest(nil, itemSuppliersLocators1)

    -- test
    -- T_ILObj.pt_IsInstanceOf_IMObj(testClassName, obj)
    -- T_ILObj.pt_Implements_IMObj(testClassName, obj)

    -- T_ILObj.pt_destruct(testClassName, Chest, constructParameters1, testObjName, destructFieldsTest, logOk)
    -- T_ILObj.pt_construct(testClassName, Chest, constructParameters1, testObjName, constructFieldsTest, logOk)

    T_ILObj.pt_getId(testClassName, obj, testObjName, "", logOk)
    -- T_ILObj.pt_getWIPId(testClassName, obj, testObjName, logOk)
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
    local itemSupplierLocator = t_employment.GetCurrentTurtleLocator()

    local testObject = TestObj:newInstance("field1", 4)
    local testObjHost = T_ObjHost.CreateTestObj()
    moduleRegistry:register(testObjHost:getHostName(), testObjHost)
    local nonItemSupplierLocator = testObjHost:saveObject(testObject)

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
    moduleRegistry:delist(testObjHost:getHostName())
    testObjHost:deleteResource(nonItemSupplierLocator)
end

function T_Shop.T_delistItemSupplier_SOSrv()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":delistItemSupplier_SOSrv() tests")
    local obj = T_Shop.CreateTestObj() if not obj then corelog.Error("Failed obtaining Shop") return end
    local objectLocator = enterprise_shop:getObjectLocator(obj)
    local nItemSuppliers = #obj:getItemSuppliersLocators() assert(nItemSuppliers == 0, "Shop "..obj:getId().." not empty at start")
    local itemSupplierLocator = t_employment.GetCurrentTurtleLocator()
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
    local itemSupplierLocator = t_employment.GetCurrentTurtleLocator()
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

    -- test type
    T_Class.pt_IsInstanceOf(testClassName, obj, "IItemSupplier", IItemSupplier)
    T_IInterface.pt_ImplementsInterface("IItemSupplier", IItemSupplier, testClassName, obj)

    -- test
    T_Shop.T_can_ProvideItems_QOSrv()
    T_Shop.T_needsTo_ProvideItemsTo_SOSrv()
end

function T_Shop.T_provideItemsTo_AOSrv_MultipleItems_ToTurtle()
    -- prepare test
    local objLocator = enterprise_shop.GetShopLocator()
--    testHost:hostMObj_SSrv({ className = testClassName, constructParameters = constructParameters_L2T4 }).mobjLocator assert(objLocator, "failed hosting "..testClassName.." on "..testHost:getHostName())
    local provideItems = {
        ["minecraft:furnace"]   = 1,
        ["minecraft:charcoal"]  = 1, -- ToDo: test if furnace get produced once charcoal is being smelted (as soon as projects support parallel steps)
    }

    t_employment = t_employment or require "test.t_employment"
    local itemDepotLocator = t_employment.GetCurrentTurtleLocator() assert(itemDepotLocator, "Failed obtaining itemDepotLocator")
    local ingredientsItemSupplierLocator = t_employment.GetCurrentTurtleLocator() assert(ingredientsItemSupplierLocator, "Failed obtaining ingredientsItemSupplierLocator")
    local wasteItemDepotLocator = ingredientsItemSupplierLocator:copy()

    -- test
    T_IItemSupplier.pt_provideItemsTo_AOSrv(testClassName, objLocator, provideItems, itemDepotLocator, ingredientsItemSupplierLocator, wasteItemDepotLocator, logOk)

    -- cleanup test
--    testHost:releaseMObj_SSrv({ mobjLocator = objLocator})
end

function T_Shop.T_provideItemsTo_AOSrv_Charcoal_ToTurtle()
    -- prepare test
    local objLocator = enterprise_shop.GetShopLocator()
    local provideItems = {
        ["minecraft:charcoal"]  = 3,
    }

    t_employment = t_employment or require "test.t_employment"
    local itemDepotLocator = t_employment.GetCurrentTurtleLocator() assert(itemDepotLocator, "Failed obtaining itemDepotLocator")
    local ingredientsItemSupplierLocator = t_employment.GetCurrentTurtleLocator() assert(ingredientsItemSupplierLocator, "Failed obtaining ingredientsItemSupplierLocator")
    local wasteItemDepotLocator = ingredientsItemSupplierLocator:copy()

    -- test
    T_IItemSupplier.pt_provideItemsTo_AOSrv(testClassName, objLocator, provideItems, itemDepotLocator, ingredientsItemSupplierLocator, wasteItemDepotLocator, logOk)

    -- cleanup test
end

function T_Shop.T_provideItemsTo_AOSrv_Torch_ToTurtle()
    -- prepare test
    local objLocator = enterprise_shop.GetShopLocator()
    local provideItems = {
        ["minecraft:torch"]  = 4,
    }

    t_employment = t_employment or require "test.t_employment"
    local itemDepotLocator = t_employment.GetCurrentTurtleLocator() assert(itemDepotLocator, "Failed obtaining itemDepotLocator")
    local ingredientsItemSupplierLocator = t_employment.GetCurrentTurtleLocator() assert(ingredientsItemSupplierLocator, "Failed obtaining ingredientsItemSupplierLocator")
    local wasteItemDepotLocator = ingredientsItemSupplierLocator:copy()

    -- test
    T_IItemSupplier.pt_provideItemsTo_AOSrv(testClassName, objLocator, provideItems, itemDepotLocator, ingredientsItemSupplierLocator, wasteItemDepotLocator, logOk)

    -- cleanup test
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
    local itemDepotLocator = t_employment.GetCurrentTurtleLocator()

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

function T_Shop.T_can_ProvideItems_QOSrv()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":can_ProvideItems_QOSrv() tests")
    local obj = T_Shop.CreateTestObj() if not obj then corelog.Error("Failed obtaining obj") return end
    local objectLocator = enterprise_shop:getObjectLocator(obj)
    local forest = T_BirchForest.CreateTestObj() assert(forest, "Failed obtaining BirchForest")
    local forestLocator = enterprise_forestry:saveObject(forest)
    local result = obj:registerItemSupplier_SOSrv({ itemSupplierLocator = forestLocator}) assert(result.success == true, "registerItemSupplier_SOSrv services failed")

    -- test can
    local itemName = "minecraft:birch_log"
    local itemCount = 20
    local serviceResults = obj:can_ProvideItems_QOSrv({ provideItems = { [itemName] = itemCount} })
    assert(serviceResults.success, "can_ProvideItems_QOSrv incorrectly failed for "..itemCount.." "..itemName.."'s")

    itemName = "minecraft:birch_sapling"
    itemCount = 2
    serviceResults = obj:can_ProvideItems_QOSrv({ provideItems = { [itemName] = itemCount} })
    assert(serviceResults.success, "can_ProvideItems_QOSrv incorrectly failed for "..itemCount.." "..itemName.."'s")

    -- test can not
    itemName = "minecraft:dirt"
    itemCount = 10
    serviceResults = obj:can_ProvideItems_QOSrv({ provideItems = { [itemName] = itemCount} })
    assert(not serviceResults.success, "can_ProvideItems_QOSrv incorrectly success for "..itemCount.." "..itemName.."'s")

    -- cleanup test
    enterprise_shop:deleteResource(objectLocator)
    enterprise_forestry:deleteResource(forestLocator)
end

return T_Shop
