local T_Factory = {}

local corelog = require "corelog"
local coreutils = require "coreutils"
local coremove = require "coremove"

local Callback = require "obj_callback"
local ModuleRegistry = require "module_registry"
local moduleRegistry = ModuleRegistry:getInstance()

local ObjArray = require "obj_array"
local Location = require "obj_location"
local URL = require "obj_url"

local ProductionSpot = require "mobj_production_spot"
local Factory = require "mobj_factory"

local enterprise_turtle = require "enterprise_turtle"
local enterprise_chests = require "enterprise_chests"

local T_Obj = require "test.t_obj"

local T_Chest = require "test.t_mobj_chest"
local t_turtle = require "test.t_turtle"

function T_Factory.T_All()
    -- interfaces
    T_Factory.T_ImplementsIObj()
    T_Factory.T_ImplementsIItemSupplier()

    -- base methods
    T_Factory.T_new()
    T_Factory.T_isTypeOf()
    T_Factory.T_isSame()
    T_Factory.T_copy()

    -- specific methods
    T_Factory.T_getAvailableInputLocator()
    T_Factory.T_getAvailableOutputLocator()
    T_Factory.T_getAvailableCraftSpot()
    T_Factory.T_getAvailableSmeltSpot()

    -- service methods
    T_Factory.T_getFuelNeed_Production_Att()
    T_Factory.T_getProductionLocation_Att()

    -- IItemSupplier methods
    T_Factory.T_can_ProvideItems_QOSrv()
end

local compact = { compact = true }

--    _       _             __
--   (_)     | |           / _|
--    _ _ __ | |_ ___ _ __| |_ __ _  ___ ___  ___
--   | | '_ \| __/ _ \ '__|  _/ _` |/ __/ _ \/ __|
--   | | | | | ||  __/ |  | || (_| | (_|  __/\__ \
--   |_|_| |_|\__\___|_|  |_| \__,_|\___\___||___/

local function ImplementsInterface(interfaceName)
    -- prepare test
    corelog.WriteToLog("* Factory "..interfaceName.." interface test")
    local Interface = moduleRegistry:getModule(interfaceName)
    local obj = T_Factory.CreateFactory() if not obj then corelog.Error("failed obtaining Factory") return end

    -- test
    local implementsInterface = Interface.ImplementsInterface(obj)
    assert(implementsInterface, "Factory class does not (fully) implement "..interfaceName.." interface")

    -- cleanup test
end

function T_Factory.T_ImplementsIObj()
    ImplementsInterface("IObj")
end

function T_Factory.T_ImplementsIItemSupplier()
    ImplementsInterface("IItemSupplier")
end

--    _                                     _   _               _
--   | |                                   | | | |             | |
--   | |__   __ _ ___  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   | '_ \ / _` / __|/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   | |_) | (_| \__ \  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_.__/ \__,_|___/\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

local location1  = Location:new({_x= -12, _y= 0, _z= 1, _dx=0, _dy=1})
local inputLocator1 = enterprise_turtle.GetAnyTurtleLocator()
local locatorClassName = "URL"
local inputLocators1 = ObjArray:new({ _objClassName = locatorClassName, inputLocator1, })
local outputLocator1 = enterprise_turtle.GetAnyTurtleLocator()
local outputLocators1 = ObjArray:new({ _objClassName = locatorClassName, outputLocator1, })
local productionSpotClassName = "ProductionSpot"
local craftingSpot1 = ProductionSpot:new({ _baseLocation = location1:getRelativeLocation(3, 3, -4), _isCraftingSpot = true })
local craftingSpots1 = ObjArray:new({ _objClassName = productionSpotClassName, craftingSpot1, })
local smeltingSpot1 = ProductionSpot:new({ _baseLocation = location1:getRelativeLocation(3, 3, -3), _isCraftingSpot = false })
local smeltingSpots1 = ObjArray:new({ _objClassName = productionSpotClassName, smeltingSpot1, })

function T_Factory.T_new()
    -- prepare test
    corelog.WriteToLog("* Factory:new() tests")
    local className = "Factory"
    local id = coreutils.NewId()

    -- test
    local obj = T_Factory.CreateFactory(location1, inputLocators1, outputLocators1, craftingSpots1, smeltingSpots1, id) if not obj then corelog.Error("failed obtaining Factory") return end
    assert(obj:getClassName() == className, "gotten className(="..obj:getClassName()..") not the same as expected(="..className..")")
    assert(obj:getId() == id, "gotten id(="..obj:getId()..") not the same as expected(="..id..")")
    assert(obj:getBaseLocation():isSame(location1), "gotten getBaseLocation(="..textutils.serialise(obj:getBaseLocation(), compact)..") not the same as expected(="..textutils.serialise(location1, compact)..")")
    assert(obj:getInputLocators()[1]:isSame(inputLocator1), "gotten getInputLocators()[1](="..textutils.serialise(obj:getInputLocators()[1], compact)..") not the same as expected(="..textutils.serialise(inputLocator1, compact)..")")
    assert(obj:getOutputLocators()[1]:isSame(outputLocator1), "gotten getOutputLocators()[1](="..textutils.serialise(obj:getOutputLocators()[1], compact)..") not the same as expected(="..textutils.serialise(outputLocator1, compact)..")")
    assert(obj:getCraftingSpots()[1]:isSame(craftingSpot1), "gotten getCraftingSpots()[1](="..textutils.serialise(obj:getCraftingSpots()[1], compact)..") not the same as expected(="..textutils.serialise(craftingSpot1, compact)..")")
    assert(obj:getSmeltingSpots()[1]:isSame(smeltingSpot1), "gotten getSmeltingSpots()[1](="..textutils.serialise(obj:getSmeltingSpots()[1], compact)..") not the same as expected(="..textutils.serialise(smeltingSpot1, compact)..")")

    -- cleanup test
end

function T_Factory.CreateFactory(baseLocation, inputLocators, outputLocators, craftingSpots, smeltingSpots, id)
    -- check input
    id = id or coreutils.NewId()
    baseLocation = baseLocation or location1

    inputLocators = inputLocators or inputLocators1
    outputLocators = outputLocators or outputLocators1

    craftingSpots = craftingSpots or craftingSpots1
    smeltingSpots = smeltingSpots or smeltingSpots1

    -- create Factory object
    local obj = Factory:new({
        _id             = id,

        _baseLocation   = baseLocation,

        _inputLocators  = inputLocators,
        _outputLocators = outputLocators,

        _craftingSpots  = craftingSpots,
        _smeltingSpots  = smeltingSpots,
    })

    -- end
    return obj
end

function T_Factory.T_isTypeOf()
    -- prepare test
    corelog.WriteToLog("* Factory:isTypeOf() tests")
    local obj = T_Factory.CreateFactory() if not obj then corelog.Error("failed obtaining Factory") return end

    -- test valid
    local isTypeOf = Factory:isTypeOf(obj)
    local expectedIsTypeOf = true
    assert(isTypeOf == expectedIsTypeOf, "gotten isTypeOf(="..tostring(isTypeOf)..") not the same as expected(="..tostring(expectedIsTypeOf)..")")

    -- test different object
    isTypeOf = Factory:isTypeOf("a atring")
    expectedIsTypeOf = false
    assert(isTypeOf == expectedIsTypeOf, "gotten isTypeOf(="..tostring(isTypeOf)..") not the same as expected(="..tostring(expectedIsTypeOf)..")")

    -- cleanup test
end

function T_Factory.T_isSame()
    -- prepare test
    corelog.WriteToLog("* Factory:isSame() tests")
    local id = coreutils.NewId()
    local obj = T_Factory.CreateFactory(location1, inputLocators1, outputLocators1, craftingSpots1, smeltingSpots1, id) if not obj then corelog.Error("failed obtaining Factory") return end
    local location2  = Location:new({_x= 100, _y= 0, _z= 100, _dx=1, _dy=0})
    local inputLocator2 = enterprise_chests:hostMObj_SSrv({className="Chest",constructParameters={ baseLocation = location2:getRelativeLocation(2, 5, 0), }}).mobjLocator if not inputLocator2 then corelog.Error("failed registering Chest") return end
    local inputLocators2 = ObjArray:new({ _objClassName = locatorClassName, inputLocator2, })
    local outputLocator2 = enterprise_chests:hostMObj_SSrv({className="Chest",constructParameters={ baseLocation = location2:getRelativeLocation(4, 5, 0), }}).mobjLocator if not inputLocator2 then corelog.Error("failed registering Chest") return end
    local outputLocators2 = ObjArray:new({ _objClassName = locatorClassName, outputLocator2, })
    local craftingSpot2 = ProductionSpot:new({ _baseLocation = location2:getRelativeLocation(3, 3, -4), _isCraftingSpot = true })
    local craftingSpots2 = ObjArray:new({ _objClassName = productionSpotClassName, craftingSpot2, })
    local smeltingSpot2 = ProductionSpot:new({ _baseLocation = location2:getRelativeLocation(3, 3, -3), _isCraftingSpot = false })
    local smeltingSpots2 = ObjArray:new({ _objClassName = productionSpotClassName, smeltingSpot2, })

    -- test same
    local obj1 = T_Factory.CreateFactory(location1, inputLocators1, outputLocators1, craftingSpots1, smeltingSpots1, id)
    local isSame = obj1:isSame(obj)
    local expectedIsSame = true
    assert(isSame == expectedIsSame, "gotten isSame(="..tostring(isSame)..") not the same as expected(="..tostring(expectedIsSame)..")")

    -- test different _baseLocation
    obj._baseLocation = location2
    isSame = obj1:isSame(obj)
    expectedIsSame = false
    assert(isSame == expectedIsSame, "gotten isSame(="..tostring(isSame)..") not the same as expected(="..tostring(expectedIsSame)..")")
    obj._baseLocation = location1

    -- test different _inputLocators
    obj._inputLocators = inputLocators2
    isSame = obj1:isSame(obj)
    expectedIsSame = false
    assert(isSame == expectedIsSame, "gotten isSame(="..tostring(isSame)..") not the same as expected(="..tostring(expectedIsSame)..")")
    obj._inputLocators = inputLocators1

    -- test different _outputLocators
    obj._outputLocators = outputLocators2
    isSame = obj1:isSame(obj)
    expectedIsSame = false
    assert(isSame == expectedIsSame, "gotten isSame(="..tostring(isSame)..") not the same as expected(="..tostring(expectedIsSame)..")")
    obj._outputLocators = outputLocators1

    -- test different _craftingSpots
    obj._craftingSpots = craftingSpots2
    isSame = obj1:isSame(obj)
    expectedIsSame = false
    assert(isSame == expectedIsSame, "gotten isSame(="..tostring(isSame)..") not the same as expected(="..tostring(expectedIsSame)..")")
    obj._craftingSpots = craftingSpots1

    -- test different _smeltingSpots
    obj._smeltingSpots = smeltingSpots2
    isSame = obj1:isSame(obj)
    expectedIsSame = false
    assert(isSame == expectedIsSame, "gotten isSame(="..tostring(isSame)..") not the same as expected(="..tostring(expectedIsSame)..")")
    obj._smeltingSpots = smeltingSpots1

    -- cleanup test
    return enterprise_chests:releaseMObj_SSrv({ mobjLocator = inputLocator2 }) and enterprise_chests:releaseMObj_SSrv({ mobjLocator = outputLocator2 })
end

function T_Factory.T_copy()
    -- prepare test
    corelog.WriteToLog("* Factory:copy() tests")
    local obj = T_Factory.CreateFactory() if not obj then corelog.Error("failed obtaining Factory") return end

    -- test
    local copy = obj:copy()
    assert(copy:isSame(obj), "gotten copy(="..textutils.serialize(copy, compact)..") not the same as expected(="..textutils.serialize(obj, compact)..")")

    -- cleanup test
end

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

function T_Factory.T_getAvailableInputLocator()
    -- prepare test
    corelog.WriteToLog("* Factory:getAvailableInputLocator() tests")
    local obj = T_Factory.CreateFactory() if not obj then corelog.Error("failed obtaining Factory") return end

    -- test
    local locator = obj:getAvailableInputLocator()
    assert(locator:isSame(inputLocator1), "gotten getAvailableInputLocator(="..textutils.serialise(locator, compact)..") not the same as expected(="..textutils.serialise(inputLocator1, compact)..")")

    -- cleanup test
end

function T_Factory.T_getAvailableOutputLocator()
    -- prepare test
    corelog.WriteToLog("* Factory:getAvailableOutputLocator() tests")
    local obj = T_Factory.CreateFactory() if not obj then corelog.Error("failed obtaining Factory") return end

    -- test
    local locator = obj:getAvailableOutputLocator()
    assert(locator:isSame(outputLocator1), "gotten getAvailableOutputLocator(="..textutils.serialise(locator, compact)..") not the same as expected(="..textutils.serialise(outputLocator1, compact)..")")

    -- cleanup test
end

function T_Factory.T_getAvailableCraftSpot()
    -- prepare test
    corelog.WriteToLog("* Factory:getAvailableCraftSpot() tests")
    local obj = T_Factory.CreateFactory() if not obj then corelog.Error("failed obtaining Factory") return end

    -- test
    local spot = obj:getAvailableCraftSpot()
    assert(spot:isSame(craftingSpot1), "gotten getAvailableCraftSpot(="..textutils.serialise(spot, compact)..") not the same as expected(="..textutils.serialise(craftingSpot1, compact)..")")

    -- cleanup test
end

function T_Factory.T_getAvailableSmeltSpot()
    -- prepare test
    corelog.WriteToLog("* Factory:getAvailableSmeltSpot() tests")
    local obj = T_Factory.CreateFactory() if not obj then corelog.Error("failed obtaining Factory") return end

    -- test
    local spot = obj:getAvailableSmeltSpot()
    assert(spot:isSame(smeltingSpot1), "gotten getAvailableSmeltSpot(="..textutils.serialise(spot, compact)..") not the same as expected(="..textutils.serialise(smeltingSpot1, compact)..")")

    -- cleanup test
end

--                        _                           _   _               _
--                       (_)                         | | | |             | |
--    ___  ___ _ ____   ___  ___ ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \  __/ |   \ V /| | (_|  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/\___|_|    \_/ |_|\___\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

function T_Factory.T_getFuelNeed_Production_Att()
    -- prepare test
    corelog.WriteToLog("* Factory:getFuelNeed_Production_Att() tests")
    local location2 = Location:new(coremove.GetLocation())
    local craftingSpot2 = ProductionSpot:new({ _baseLocation = location2:getRelativeLocation(3, 3, -4), _isCraftingSpot = true })
    local craftingSpots2 = ObjArray:new({ _objClassName = productionSpotClassName, craftingSpot2, })
    local smeltingSpot2 = ProductionSpot:new({ _baseLocation = location2:getRelativeLocation(3, 3, -3), _isCraftingSpot = false })
    local smeltingSpots2 = ObjArray:new({ _objClassName = productionSpotClassName, smeltingSpot2, })
    local obj = T_Factory.CreateFactory(location2, inputLocators1, outputLocators1, craftingSpots2, smeltingSpots2) if not obj then corelog.Error("failed obtaining Factory") return end

    -- test
    local items = { ["minecraft:birch_planks"] = 4 }
    local fuelNeed = obj:getFuelNeed_Production_Att(items)
    local expectedFuelNeed = 20
    assert(fuelNeed == expectedFuelNeed, "gotten fuelNeed(="..fuelNeed..") not the same as expected(="..expectedFuelNeed..")")

    -- cleanup test
end

function T_Factory.T_getProductionLocation_Att()
    -- prepare test
    corelog.WriteToLog("* Factory:getProductionLocation_Att() tests")
    local obj = T_Factory.CreateFactory() if not obj then corelog.Error("failed obtaining Factory") return end

    -- test craft
    local itemName = "minecraft:birch_planks"
    local itemCount = 10
    local productionLocation = obj:getProductionLocation_Att({ [itemName] = itemCount})
    local expectedLocation = craftingSpot1:getBaseLocation()
    assert(productionLocation:isSame(expectedLocation), "gotten getProductionLocation_Att(="..textutils.serialise(productionLocation, compact)..") not the same as expected(="..textutils.serialise(expectedLocation, compact)..")")

    -- test smelt
    itemName = "minecraft:charcoal"
    itemCount = 5
    productionLocation = obj:getProductionLocation_Att({ [itemName] = itemCount})
    expectedLocation = smeltingSpot1:getBaseLocation()
    assert(productionLocation:isSame(expectedLocation), "gotten getProductionLocation_Att(="..textutils.serialise(productionLocation, compact)..") not the same as expected(="..textutils.serialise(expectedLocation, compact)..")")

    -- cleanup test
end

function T_Factory.T_can_ProvideItems_QOSrv()
    -- prepare test
    corelog.WriteToLog("* Factory:can_ProvideItems_QOSrv() tests")
    local obj = T_Factory.CreateFactory() if not obj then corelog.Error("failed obtaining Factory") return end

    -- test can not produce item without recipe
    local itemName = "anItemWithNoRecipe"
    local itemCount = 2
    local serviceResults = obj:can_ProvideItems_QOSrv({ provideItems = { [itemName] = itemCount} })
    assert(not serviceResults.success, "can_ProvideItems_QOSrv incorrectly success for "..itemCount.." "..itemName.."'s")

    -- test can craft
    itemName = "minecraft:birch_planks"
    itemCount = 10
    serviceResults = obj:can_ProvideItems_QOSrv({ provideItems = { [itemName] = itemCount} })
    assert(serviceResults.success, "can_ProvideItems_QOSrv incorrectly failed for "..itemCount.." "..itemName.."'s")

    -- test can not craft without available craftingSpot
    -- ToDo: improve when a spot can be marked unavailable
    local craftingSpots2 = ObjArray:new({ _objClassName = productionSpotClassName, })
    obj._craftingSpots = craftingSpots2
    serviceResults = obj:can_ProvideItems_QOSrv({ provideItems = { [itemName] = itemCount} })
    assert(not serviceResults.success, "can_ProvideItems_QOSrv incorrectly failed for "..itemCount.." "..itemName.."'s")
    obj._craftingSpots = craftingSpots1

    -- test can smelt
    itemName = "minecraft:charcoal"
    itemCount = 5
    serviceResults = obj:can_ProvideItems_QOSrv({ provideItems = { [itemName] = itemCount} })
    assert(serviceResults.success, "can_ProvideItems_QOSrv incorrectly failed for "..itemCount.." "..itemName.."'s")

    -- test can not smelt without available smeltingSpot
    -- ToDo: improve when a spot can be marked unavailable
    local smeltingSpots2 = ObjArray:new({ _objClassName = productionSpotClassName, })
    obj._smeltingSpots = smeltingSpots2
    serviceResults = obj:can_ProvideItems_QOSrv({ provideItems = { [itemName] = itemCount} })
    assert(not serviceResults.success, "can_ProvideItems_QOSrv incorrectly failed for "..itemCount.." "..itemName.."'s")
    obj._smeltingSpots = smeltingSpots1

    -- test can not produce without available inputLocator
    -- ToDo: improve by changing the availability of the inputLocator
    local inputLocators2 = ObjArray:new({ _objClassName = locatorClassName, })
    obj._inputLocators = inputLocators2
    serviceResults = obj:can_ProvideItems_QOSrv({ provideItems = { [itemName] = itemCount} })
    assert(not serviceResults.success, "can_ProvideItems_QOSrv incorrectly success for "..itemCount.." "..itemName.."'s")
    obj._inputLocators = inputLocators1

    -- test can not produce without available outputLocator
    -- ToDo: improve by changing the availability of the _outputLocators
    local outputLocators2 = ObjArray:new({ _objClassName = locatorClassName, })
    obj._outputLocators = outputLocators2
    serviceResults = obj:can_ProvideItems_QOSrv({ provideItems = { [itemName] = itemCount} })
    assert(not serviceResults.success, "can_ProvideItems_QOSrv incorrectly success for "..itemCount.." "..itemName.."'s")
    obj._outputLocators = outputLocators1

    -- cleanup test
end

local function t_provideItemsTo_AOSrv(provideItems, productionMethod)
    -- prepare test
    corelog.WriteToLog("* Factory:provideItemsTo_AOSrv() tests ("..productionMethod..")")
    local obj = T_Factory.CreateFactory() if not obj then corelog.Error("failed obtaining Factory") return end
    local itemDepotLocator = t_turtle.GetCurrentTurtleLocator()
    local ingredientsItemSupplierLocator = t_turtle.GetCurrentTurtleLocator()

    local chest2 = T_Obj.newObj("Chest", T_Chest.NewOTable(location1:getRelativeLocation(0, 0, -1))) assert(chest2, "failed obtaining Chest 2")

    local wasteItemDepotLocator = enterprise_chests:saveObject(chest2)
--    local wasteItemDepotLocator = t_turtle.GetCurrentTurtleLocator()

    local expectedDestinationItemsLocator = itemDepotLocator:copy()
    expectedDestinationItemsLocator:setQuery(provideItems)
    local callback2 = Callback:new({
        _moduleName     = "T_Factory",
        _methodName     = "provideItemsTo_AOSrv_Callback",
        _data           = {
            ["expectedDestinationItemsLocator"] = expectedDestinationItemsLocator,
        },
    })

    -- test
    return obj:provideItemsTo_AOSrv({
        provideItems                    = provideItems,
        itemDepotLocator                = itemDepotLocator,
        ingredientsItemSupplierLocator  = ingredientsItemSupplierLocator,
        wasteItemDepotLocator           = wasteItemDepotLocator,
    }, callback2)
end

function T_Factory.T_provideItemsTo_AOSrv_Craft()
    -- prepare test
    local provideItems = { ["minecraft:birch_planks"] = 11 }

    -- test
    t_provideItemsTo_AOSrv(provideItems, "Craft")
end

function T_Factory.T_provideItemsTo_AOSrv_Smelt()
    -- prepare test
    local provideItems = { ["minecraft:charcoal"] = 1 }

    -- test
    t_provideItemsTo_AOSrv(provideItems, "Smelt")
end

function T_Factory.provideItemsTo_AOSrv_Callback(callbackData, serviceResults)
    -- test (cont)
    assert(serviceResults.success, "failed executing async service")

    local destinationItemsLocator = URL:new(serviceResults.destinationItemsLocator)
    local expectedDestinationItemsLocator = URL:new(callbackData["expectedDestinationItemsLocator"])
    assert(destinationItemsLocator:isSame(expectedDestinationItemsLocator), "gotten destinationItemsLocator(="..textutils.serialize(destinationItemsLocator, compact)..") not the same as expected(="..textutils.serialize(expectedDestinationItemsLocator, compact)..")")

    -- cleanup test

    -- end
    return true
end

return T_Factory
