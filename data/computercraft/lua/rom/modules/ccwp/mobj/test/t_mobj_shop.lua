local T_Shop = {}
local corelog = require "corelog"
local coreutils = require "coreutils"

local Callback = require "obj_callback"
local ModuleRegistry = require "module_registry"
local moduleRegistry = ModuleRegistry:getInstance()

local ObjArray = require "obj_array"
local URL = require "obj_url"
local Location = require "obj_location"

local Shop = require "mobj_shop"

local role_forester = require "role_forester"

local enterprise_turtle = require "enterprise_turtle"
local enterprise_chests = require "enterprise_chests"
local enterprise_forestry = require "enterprise_forestry"
local enterprise_shop = require "enterprise_shop"

local T_Obj = require "test.t_obj"

local T_Chest = require "test.t_mobj_chest"
local T_BirchForest = require "test.t_mobj_birchforest"
local t_turtle = require "test.t_turtle"

function T_Shop.T_All()
    -- initialisation
    T_Shop.T_Getters()

    -- IObj methods
    T_Shop.T_ImplementsIObj()
    T_Shop.T_isTypeOf()
    T_Shop.T_isEqual()
    T_Shop.T_copy()

    -- specific methods

    -- service methods
    T_Shop.T_registerItemSupplier_SOSrv()
    T_Shop.T_delistItemSupplier_SOSrv()
    T_Shop.T_delistAllItemSuppliers()
    T_Shop.T_bestItemSupplier()

    -- IItemSupplier methods
    T_Shop.T_ImplementsIItemSupplier()
    T_Shop.T_can_ProvideItems_QOSrv()
    T_Shop.T_needsTo_ProvideItemsTo_SOSrv()
end

local testClassName = "Shop"
local locatorClassName = "URL"
local itemSuppliersLocators1 = ObjArray:new({
    _objClassName   = locatorClassName,
})
local itemSuppliersLocator1 = enterprise_turtle.GetAnyTurtleLocator()
local itemSuppliersLocators2 = ObjArray:new({
    _objClassName   = locatorClassName,

    itemSuppliersLocator1,
})

local compact = { compact = true }

--    _       _             __
--   (_)     | |           / _|
--    _ _ __ | |_ ___ _ __| |_ __ _  ___ ___  ___
--   | | '_ \| __/ _ \ '__|  _/ _` |/ __/ _ \/ __|
--   | | | | | ||  __/ |  | || (_| | (_|  __/\__ \
--   |_|_| |_|\__\___|_|  |_| \__,_|\___\___||___/

local function ImplementsInterface(interfaceName)
    -- prepare test
    corelog.WriteToLog("* Shop "..interfaceName.." interface test")
    local Interface = moduleRegistry:getModule(interfaceName)
    local obj = T_Shop.CreateTestObj() if not obj then corelog.Error("Failed obtaining Shop") return end

    -- test
    local implementsInterface = Interface.ImplementsInterface(obj)
    assert(implementsInterface, "Shop class does not (fully) implement "..interfaceName.." interface")

    -- cleanup test
end

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
    local testObj = Shop:new({
        _id                     = id,

        _itemSuppliersLocators  = itemSuppliersLocators:copy(),
    })

    return testObj
end

function T_Shop.T_Getters()
    -- prepare test
    corelog.WriteToLog("* Shop getter tests")
    local id = coreutils.NewId()
    local className = "Shop"
    local obj = T_Shop.CreateTestObj(id, itemSuppliersLocators1) if not obj then corelog.Error("Failed obtaining Shop") return end

    -- test
    assert(obj:getClassName() == className, "gotten className(="..obj:getClassName()..") not the same as expected(="..className..")")
    assert(obj:getId() == id, "gotten id(="..obj:getId()..") not the same as expected(="..id..")")
    assert(obj:getItemSuppliersLocators():isEqual(itemSuppliersLocators1), "gotten getItemSuppliersLocators(="..textutils.serialize(obj:getItemSuppliersLocators())..") not the same as expected(="..textutils.serialize(itemSuppliersLocators1)..")")

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

function T_Shop.T_ImplementsIObj()
    ImplementsInterface("IObj")
end

function T_Shop.T_isTypeOf()
    -- prepare test
    corelog.WriteToLog("* Shop:isTypeOf() tests")
    local obj = T_Shop.CreateTestObj() if not obj then corelog.Error("Failed obtaining Shop") return end

    -- test valid
    local isTypeOf = Shop:isTypeOf(obj)
    local expectedIsTypeOf = true
    assert(isTypeOf == expectedIsTypeOf, "gotten isTypeOf(="..tostring(isTypeOf)..") not the same as expected(="..tostring(expectedIsTypeOf)..")")

    -- test different object
    isTypeOf = Shop:isTypeOf("a atring")
    expectedIsTypeOf = false
    assert(isTypeOf == expectedIsTypeOf, "gotten isTypeOf(="..tostring(isTypeOf)..") not the same as expected(="..tostring(expectedIsTypeOf)..")")

    -- cleanup test
end

function T_Shop.T_isEqual()
    -- prepare test
    corelog.WriteToLog("* Shop:isEqual() tests")
    local id = coreutils.NewId()
    local obj = T_Shop.CreateTestObj(id, itemSuppliersLocators1) if not obj then corelog.Error("Failed obtaining Shop") return end

    -- test same
    local obj1 = T_Shop.CreateTestObj(id, itemSuppliersLocators1)
    local isEqual = obj1:isEqual(obj)
    local expectedIsEqual = true
    assert(isEqual == expectedIsEqual, "gotten isEqual(="..tostring(isEqual)..") not the same as expected(="..tostring(expectedIsEqual)..")")

    -- test different _itemSuppliersLocators
    obj._itemSuppliersLocators = itemSuppliersLocators2
    isEqual = obj1:isEqual(obj)
    expectedIsEqual = false
    assert(isEqual == expectedIsEqual, "gotten isEqual(="..tostring(isEqual)..") not the same as expected(="..tostring(expectedIsEqual)..")")
    obj._itemSuppliersLocators = itemSuppliersLocators1

    -- cleanup test
end

function T_Shop.T_copy()
    -- prepare test
    corelog.WriteToLog("* Shop:copy() tests")
    local obj = T_Shop.CreateTestObj() if not obj then corelog.Error("Failed obtaining Shop") return end

    -- test
    local copy = obj:copy()
    assert(copy:isEqual(obj), "gotten copy(="..textutils.serialize(copy, compact)..") not the same as expected(="..textutils.serialize(obj, compact)..")")

    -- cleanup test
end

--                        _                           _   _               _
--                       (_)                         | | | |             | |
--    ___  ___ _ ____   ___  ___ ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \  __/ |   \ V /| | (_|  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/\___|_|    \_/ |_|\___\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

function T_Shop.T_registerItemSupplier_SOSrv()
    -- prepare test
    corelog.WriteToLog("* Shop:registerItemSupplier_SOSrv() tests")
    local obj = T_Shop.CreateTestObj() if not obj then corelog.Error("Failed obtaining Shop") return end
    local objectLocator = enterprise_shop:getObjectLocator(obj)
    local nItemSuppliers = #obj:getItemSuppliersLocators() assert(nItemSuppliers == 0, "Shop "..obj:getId().." not empty at start")
    local itemSupplierLocator = t_turtle.GetCurrentTurtleLocator()

    -- test
    local result = obj:registerItemSupplier_SOSrv({ itemSupplierLocator = itemSupplierLocator})
    assert(result.success == true, "registerItemSupplier_SOSrv services failed")
    nItemSuppliers = #obj:getItemSuppliersLocators()
    local expectedNItemSuppliers = 1
    assert(nItemSuppliers == expectedNItemSuppliers, "gotten nItemSuppliers(="..nItemSuppliers..") not the same as expected(="..expectedNItemSuppliers..")")

    -- cleanup test
    enterprise_shop:deleteResource(objectLocator) -- note: registerItemSupplier_SOSrv saved the test Shop
end

function T_Shop.T_delistItemSupplier_SOSrv()
    -- prepare test
    corelog.WriteToLog("* Shop:delistItemSupplier_SOSrv() tests")
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
    corelog.WriteToLog("* Shop:delistAllItemSuppliers() tests")
    local obj = T_Shop.CreateTestObj() if not obj then corelog.Error("Failed obtaining Shop") return end
    local objectLocator = enterprise_shop:getObjectLocator(obj)
    local nItemSuppliers = #obj:getItemSuppliersLocators() assert(nItemSuppliers == 0, "Shop "..obj:getId().." not empty at start")
    local itemSupplierLocator = t_turtle.GetCurrentTurtleLocator()
    local result = obj:registerItemSupplier_SOSrv({ itemSupplierLocator = itemSupplierLocator}) assert(result.success == true, "registerItemSupplier_SOSrv services failed")
    local location1 = Location:new({_x= 10, _y= 0, _z= 1, _dx=0, _dy=1})

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
    corelog.WriteToLog("* Shop:bestItemSupplier() tests")
    local obj = T_Shop.CreateTestObj() if not obj then corelog.Error("Failed obtaining Shop") return end
    local objectLocator = enterprise_shop:getObjectLocator(obj)
    local item = {
        ["minecraft:birch_log"]  = 5,
    }
    local ingredientsItemSupplierLocator = objectLocator
    local location1 = Location:new({_x= 10, _y= 0, _z= 1, _dx=0, _dy=1})
    local chest = T_Chest.CreateTestObj(nil, location1) assert(chest, "Failed obtaining Chest")
    local itemDepotLocator = enterprise_chests:saveObject(chest)

    -- test lowest fuelNeed
    local closeLocation = location1:getRelativeLocation(1, 1, 0)
    chest = T_Chest.CreateTestObj(nil, closeLocation) assert(chest, "Failed obtaining Chest")
    local closeItemSupplierLocator = enterprise_chests:saveObject(chest)
    local result = obj:registerItemSupplier_SOSrv({ itemSupplierLocator = closeItemSupplierLocator}) assert(result.success == true, "registerItemSupplier_SOSrv services failed")

    local farLocation = location1:getRelativeLocation(99999, 1, 0)
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

--    _____ _____ _                  _____                   _ _                            _   _               _
--   |_   _|_   _| |                / ____|                 | (_)                          | | | |             | |
--     | |   | | | |_ ___ _ __ ___ | (___  _   _ _ __  _ __ | |_  ___ _ __   _ __ ___   ___| |_| |__   ___   __| |___
--     | |   | | | __/ _ \ '_ ` _ \ \___ \| | | | '_ \| '_ \| | |/ _ \ '__| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| |_ _| |_| ||  __/ | | | | |____) | |_| | |_) | |_) | | |  __/ |    | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____|_____|\__\___|_| |_| |_|_____/ \__,_| .__/| .__/|_|_|\___|_|    |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                                              | |   | |
--                                              |_|   |_|

function T_Shop.T_ImplementsIItemSupplier()
    ImplementsInterface("IItemSupplier")
end

local function provideItemsTo_AOSrv_Test(provideItems)
    -- prepare test (cont)
    corelog.WriteToLog("* Shop:provideItemsTo_AOSrv() test (of "..textutils.serialize(provideItems, compact)..")")
    local obj = T_Shop.CreateTestObj() if not obj then corelog.Error("Failed obtaining Shop") return end
    local objectLocator = enterprise_shop:getObjectLocator(obj)
    local itemDepotLocator = t_turtle.GetCurrentTurtleLocator() assert(itemDepotLocator, "Failed obtaining itemDepotLocator")
    local result = obj:registerItemSupplier_SOSrv({ itemSupplierLocator = itemDepotLocator}) assert(result.success == true, "registerItemSupplier_SOSrv services failed")
    local ingredientsItemSupplierLocator = objectLocator
    local wasteItemDepotLocator = t_turtle.GetCurrentTurtleLocator()

    local expectedDestinationItemsLocator = itemDepotLocator:copy()
    expectedDestinationItemsLocator:setQuery(provideItems)
    local callback2 = Callback:new({
        _moduleName     = "T_Shop",
        _methodName     = "provideItemsTo_AOSrv_Callback",
        _data           = {
            ["expectedDestinationItemsLocator"] = expectedDestinationItemsLocator,
            ["objectLocator"]                   = objectLocator,
        },
    })

    -- test
    local scheduleResult = obj:provideItemsTo_AOSrv({
        provideItems                    = provideItems,
        itemDepotLocator                = itemDepotLocator,
        ingredientsItemSupplierLocator  = ingredientsItemSupplierLocator,
        wasteItemDepotLocator           = wasteItemDepotLocator,
    }, callback2)
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
    corelog.WriteToLog("* Shop:can_ProvideItems_QOSrv() tests")
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
    corelog.WriteToLog("* Shop:needsTo_ProvideItemsTo_SOSrv() tests")
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
    local expectedFuelNeed = role_forester.FuelNeededPerRound(nTrees)
    assert(needsTo_Provide.success, "needsTo_ProvideItemsTo_SOSrv failed")
    assert(needsTo_Provide.fuelNeed == expectedFuelNeed, "fuelNeed(="..needsTo_Provide.fuelNeed..") not the same as expected(="..expectedFuelNeed..")")
    assert(#needsTo_Provide.ingredientsNeed == 0, "ingredientsNeed(="..#needsTo_Provide.ingredientsNeed..") not the same as expected(=0)")

    -- cleanup test
    enterprise_shop:deleteResource(objectLocator)
    enterprise_forestry:deleteResource(forestLocator)
end

return T_Shop
