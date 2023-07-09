local T_Shop = {}
local corelog = require "corelog"
local coreutils = require "coreutils"

local IObj = require "iobj"
local ObjArray = require "obj_array"
local Callback = require "obj_callback"

local Location = require "obj_location"

local Shop = require "mobj_shop"

local enterprise_turtle = require "enterprise_turtle"
local enterprise_chests = require "enterprise_chests"
local enterprise_shop = require "enterprise_shop"

local T_Chest = require "test.t_mobj_chest"
local t_turtle = require "test.t_turtle"

function T_Shop.T_All()
    -- base methods
    T_Shop.T_ImplementsIObj()
    T_Shop.T_Getters()
    T_Shop.T_IsOfType()
    T_Shop.T_isSame()
    T_Shop.T_copy()

    -- specific methods

    -- service methods
    T_Shop.T_registerItemSupplier_SOSrv()
    T_Shop.T_delistItemSupplier_SOSrv()
    T_Shop.T_delistAllItemSuppliers()
    T_Shop.T_bestItemSupplier()
end

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

--    _                                     _   _               _
--   | |                                   | | | |             | |
--   | |__   __ _ ___  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   | '_ \ / _` / __|/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   | |_) | (_| \__ \  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_.__/ \__,_|___/\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

function T_Shop.T_ImplementsIObj()
    -- prepare test
    corelog.WriteToLog("* Shop IObj interface test")
    local obj = T_Shop.CreateShop() if not obj then corelog.Error("failed obtaining Shop") return end

    -- test
    local implementsInterface = IObj.ImplementsInterface(obj)
    assert(implementsInterface, "Shop class does not (fully) implement IObj interface")

    -- cleanup test
end

function T_Shop.T_Getters()
    -- prepare test
    corelog.WriteToLog("* Shop getter tests")
    local id = coreutils.NewId()
    local className = "Shop"
    local obj = T_Shop.CreateShop(itemSuppliersLocators1, id) if not obj then corelog.Error("failed obtaining Shop") return end

    -- test
    assert(obj:getClassName() == className, "gotten className(="..obj:getClassName()..") not the same as expected(="..className..")")
    assert(obj:getId() == id, "gotten id(="..obj:getId()..") not the same as expected(="..id..")")
    assert(obj:getItemSuppliersLocators():isSame(itemSuppliersLocators1), "gotten getItemSuppliersLocators(="..textutils.serialize(obj:getItemSuppliersLocators())..") not the same as expected(="..textutils.serialize(itemSuppliersLocators1)..")")

    -- cleanup test
end

function T_Shop.CreateShop(itemSuppliersLocators, id)
    -- check input
    itemSuppliersLocators = itemSuppliersLocators or itemSuppliersLocators1
    id = id or coreutils.NewId()

    -- create obj object
    local obj = Shop:new({
        _id                     = id,

        _itemSuppliersLocators  = itemSuppliersLocators:copy(),
    })

    -- end
    return obj
end

function T_Shop.T_IsOfType()
    -- prepare test
    corelog.WriteToLog("* Shop.IsOfType() tests")
    local obj = T_Shop.CreateShop() if not obj then corelog.Error("failed obtaining Shop") return end

    -- test valid
    local isOfType = Shop.IsOfType(obj)
    local expectedIsOfType = true
    assert(isOfType == expectedIsOfType, "gotten IsOfType(="..tostring(isOfType)..") not the same as expected(="..tostring(expectedIsOfType)..")")

    -- test different object
    isOfType = Shop.IsOfType("a atring")
    expectedIsOfType = false
    assert(isOfType == expectedIsOfType, "gotten IsOfType(="..tostring(isOfType)..") not the same as expected(="..tostring(expectedIsOfType)..")")

    -- test invalid _itemSuppliersLocators
    obj._itemSuppliersLocators = "a string"
    isOfType = Shop.IsOfType(obj)
    expectedIsOfType = false
    assert(isOfType == expectedIsOfType, "gotten IsOfType(="..tostring(isOfType)..") not the same as expected(="..tostring(expectedIsOfType)..")")
    obj._itemSuppliersLocators = itemSuppliersLocators1

    -- cleanup test
end

function T_Shop.T_isSame()
    -- prepare test
    corelog.WriteToLog("* Shop:isSame() tests")
    local id = coreutils.NewId()
    local obj = T_Shop.CreateShop(itemSuppliersLocators1, id) if not obj then corelog.Error("failed obtaining Shop") return end

    -- test same
    local obj1 = T_Shop.CreateShop(itemSuppliersLocators1, id)
    local isSame = obj1:isSame(obj)
    local expectedIsSame = true
    assert(isSame == expectedIsSame, "gotten isSame(="..tostring(isSame)..") not the same as expected(="..tostring(expectedIsSame)..")")

    -- test different _itemSuppliersLocators
    obj._itemSuppliersLocators = itemSuppliersLocators2
    isSame = obj1:isSame(obj)
    expectedIsSame = false
    assert(isSame == expectedIsSame, "gotten isSame(="..tostring(isSame)..") not the same as expected(="..tostring(expectedIsSame)..")")
    obj._itemSuppliersLocators = itemSuppliersLocators1

    -- cleanup test
end

function T_Shop.T_copy()
    -- prepare test
    corelog.WriteToLog("* Shop:copy() tests")
    local obj = T_Shop.CreateShop() if not obj then corelog.Error("failed obtaining Shop") return end

    -- test
    local copy = obj:copy()
    assert(copy:isSame(obj), "gotten copy(="..textutils.serialize(copy, compact)..") not the same as expected(="..textutils.serialize(obj, compact)..")")

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
    local obj = T_Shop.CreateShop() if not obj then corelog.Error("failed obtaining Shop") return end
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
    local obj = T_Shop.CreateShop() if not obj then corelog.Error("failed obtaining Shop") return end
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
    local obj = T_Shop.CreateShop() if not obj then corelog.Error("failed obtaining Shop") return end
    local objectLocator = enterprise_shop:getObjectLocator(obj)
    local nItemSuppliers = #obj:getItemSuppliersLocators() assert(nItemSuppliers == 0, "Shop "..obj:getId().." not empty at start")
    local itemSupplierLocator = t_turtle.GetCurrentTurtleLocator()
    local result = obj:registerItemSupplier_SOSrv({ itemSupplierLocator = itemSupplierLocator}) assert(result.success == true, "registerItemSupplier_SOSrv services failed")
    local location1 = Location:new({_x= 10, _y= 0, _z= 1, _dx=0, _dy=1})
    local chest = T_Chest.CreateChest(location1) if not chest then corelog.Error("failed obtaining Chest") return end
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
    local obj = T_Shop.CreateShop() if not obj then corelog.Error("failed obtaining Shop") return end
    local objectLocator = enterprise_shop:getObjectLocator(obj)
    local item = {
        ["minecraft:birch_log"]  = 5,
    }
    local ingredientsItemSupplierLocator = objectLocator
    local location1 = Location:new({_x= 10, _y= 0, _z= 1, _dx=0, _dy=1})
    local chest = T_Chest.CreateChest(location1) if not chest then corelog.Error("failed obtaining Chest") return end
    local itemDepotLocator = enterprise_chests:saveObject(chest)

    -- test lowest fuelNeed
    local closeLocation = location1:getRelativeLocation(1, 1, 0)
    chest = T_Chest.CreateChest(closeLocation) if not chest then corelog.Error("failed obtaining Chest") return end
    local closeItemSupplierLocator = enterprise_chests:saveObject(chest)
    local result = obj:registerItemSupplier_SOSrv({ itemSupplierLocator = closeItemSupplierLocator}) assert(result.success == true, "registerItemSupplier_SOSrv services failed")

    local farLocation = location1:getRelativeLocation(99999, 1, 0)
    chest = T_Chest.CreateChest(farLocation) if not chest then corelog.Error("failed obtaining Chest") return end
    local farItemSupplierLocator = enterprise_chests:saveObject(chest)
    result = obj:registerItemSupplier_SOSrv({ itemSupplierLocator = farItemSupplierLocator}) assert(result.success == true, "registerItemSupplier_SOSrv services failed")

    local bestItemSupplierLocator = obj:bestItemSupplier(item, itemDepotLocator, ingredientsItemSupplierLocator, farItemSupplierLocator, closeItemSupplierLocator)
    local expectedItemSupplierLocator = closeItemSupplierLocator
    assert(bestItemSupplierLocator:isSame(expectedItemSupplierLocator), "gotten bestItemSupplier(="..textutils.serialize(bestItemSupplierLocator, compact)..") not the same as expected(="..textutils.serialize(expectedItemSupplierLocator, compact)..")")

    -- cleanup test
    enterprise_shop:deleteResource(objectLocator)
    enterprise_chests:deleteResource(itemDepotLocator)
    enterprise_chests:deleteResource(closeItemSupplierLocator)
    enterprise_chests:deleteResource(farItemSupplierLocator)
end


return T_Shop
