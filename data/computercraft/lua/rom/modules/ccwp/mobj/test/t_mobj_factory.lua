local T_Factory = {}

local corelog = require "corelog"
local coreutils = require "coreutils"

local Callback = require "obj_callback"
local IObj = require "i_obj"
local IItemSupplier = require "i_item_supplier"
local ObjBase = require "obj_base"
local ObjArray = require "obj_array"

local Location = require "obj_location"
local URL = require "obj_url"

local ProductionSpot = require "mobj_production_spot"
local Factory = require "mobj_factory"

local enterprise_turtle = require "enterprise_turtle"
local enterprise_chests = require "enterprise_chests"

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

local T_Turtle = require "test.t_mobj_turtle"
local T_Chest = require "test.t_mobj_chest"
local t_turtle = require "test.t_turtle"

function T_Factory.T_All()
    -- initialisation
    T_Factory.T__init()
    T_Factory.T_new()

    -- IObj methods
    T_Factory.T_IObj_All()

    -- IMObj methods
    T_Factory.T_IMObj_All()

    -- specific methods
    T_Factory.T_getAvailableInputLocator()
    T_Factory.T_getAvailableOutputLocator()
    T_Factory.T_getAvailableCraftSpot()
    T_Factory.T_getAvailableSmeltSpot()

    -- service methods
    T_Factory.T_getFuelNeed_Production_Att()
    T_Factory.T_getProductionLocation_Att()

    -- IItemSupplier methods
    T_Factory.T_IItemSupplier_All()
    T_Factory.T_can_ProvideItems_QOSrv()
end

local testClassName = "Factory"
local testObjName = "factory"
local logOk = false
local baseLocation1 = Location:newInstance(-12, 0, 1, 0, 1)
local inputLocator0 = enterprise_turtle.GetAnyTurtleLocator()
local locatorClassName = "URL"
local inputLocators0 = ObjArray:newInstance(locatorClassName, { inputLocator0, })
local outputLocator0 = enterprise_turtle.GetAnyTurtleLocator()
local outputLocators0 = ObjArray:newInstance(locatorClassName, { outputLocator0, })
local productionSpotClassName = "ProductionSpot"
local craftingSpot1 = ProductionSpot:newInstance(baseLocation1:getRelativeLocation(3, 3, -4), true)
local craftingSpots1 = ObjArray:newInstance(productionSpotClassName, { craftingSpot1, })
local smeltingSpot1 = ProductionSpot:newInstance(baseLocation1:getRelativeLocation(3, 3, -3), false)
local smeltingSpots1 = ObjArray:newInstance(productionSpotClassName, { smeltingSpot1, })

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_Factory.CreateTestObj(id, baseLocation, inputLocators, outputLocators, craftingSpots, smeltingSpots)
    -- check input
    id = id or coreutils.NewId()
    baseLocation = baseLocation or baseLocation1
    inputLocators = inputLocators or inputLocators0
    outputLocators = outputLocators or outputLocators0
    craftingSpots = craftingSpots or craftingSpots1
    smeltingSpots = smeltingSpots or smeltingSpots1

    -- create testObj
    local testObj = Factory:newInstance(id, baseLocation:copy(), inputLocators:copy(), outputLocators:copy(), craftingSpots:copy(), smeltingSpots:copy())

    -- end
    return testObj
end

function T_Factory.CreateInitialisedTest(id, baseLocation, inputLocatorsTest, outputLocatorsTest, craftingSpots, smeltingSpots)
    -- check input

    -- create test
    local idTest = FieldValueTypeTest:newInstance("_id", "string")
    if id then idTest = FieldValueEqualTest:newInstance("_id", id) end
    local test = TestArrayTest:newInstance(
        idTest,
        FieldValueEqualTest:newInstance("_baseLocation", baseLocation),
        inputLocatorsTest,
        outputLocatorsTest,
        FieldValueEqualTest:newInstance("_craftingSpots", craftingSpots),
        FieldValueEqualTest:newInstance("_smeltingSpots", smeltingSpots)
    )

    -- end
    return test
end

function T_Factory.T__init()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":_init() tests")
    local id = coreutils.NewId()

    -- test
    local obj = T_Factory.CreateTestObj(id, baseLocation1, inputLocators0, outputLocators0, craftingSpots1, smeltingSpots1) assert(obj, "Failed obtaining "..testClassName)
    local inputLocatorsTest = FieldValueEqualTest:newInstance("_inputLocators", inputLocators0)
    local outputLocatorsTest = FieldValueEqualTest:newInstance("_outputLocators", outputLocators0)
    local test = T_Factory.CreateInitialisedTest(id, baseLocation1, inputLocatorsTest, outputLocatorsTest, craftingSpots1, smeltingSpots1)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_Factory.T_new()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() tests")
    local id = coreutils.NewId()

    -- test
    local obj = Factory:new({
        _id                     = id,

        _baseLocation   = baseLocation1:copy(),

        _inputLocators  = inputLocators0:copy(),
        _outputLocators = outputLocators0:copy(),

        _craftingSpots  = craftingSpots1:copy(),
        _smeltingSpots  = smeltingSpots1:copy(),
    })
    local inputLocatorsTest = FieldValueEqualTest:newInstance("_inputLocators", inputLocators0)
    local outputLocatorsTest = FieldValueEqualTest:newInstance("_outputLocators", outputLocators0)
    local test = T_Factory.CreateInitialisedTest(id, baseLocation1, inputLocatorsTest, outputLocatorsTest, craftingSpots1, smeltingSpots1)
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

function T_Factory.T_IObj_All()
    -- prepare test
    local id = coreutils.NewId()
    local obj = T_Factory.CreateTestObj(id) assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_Factory.CreateTestObj(id) assert(otherObj, "Failed obtaining "..testClassName)

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

local factoryVersion0 = "v0"
local factoryVersion1 = "v1"
local factoryVersion2 = "v2"
local constructParameters0 = {
    version         = factoryVersion0,

    baseLocation    = baseLocation1,
}
local constructParameters1 = {
    version         = factoryVersion1,

    baseLocation    = baseLocation1,
}
local constructParameters2 = {
    version         = factoryVersion2,

    baseLocation    = baseLocation1,
}
local craftingSpot0 = ProductionSpot:newInstance(baseLocation1:getRelativeLocation(0, 0, 0), true)
local craftingSpots0 = ObjArray:newInstance(productionSpotClassName, { craftingSpot0, })
local smeltingSpots0 = ObjArray:newInstance(productionSpotClassName)


function T_Factory.T_IMObj_All()
    -- prepare test
    local id = coreutils.NewId()
    local obj = T_Factory.CreateTestObj(id, baseLocation1, inputLocators0, outputLocators0, craftingSpots1, smeltingSpots1) assert(obj, "Failed obtaining "..testClassName)

    local topChestsDestructTest = FieldTest:newInstance("_inputLocators", TestArrayTest:newInstance(
        ValueTypeTest:newInstance("ObjArray"),
        MethodResultEqualTest:newInstance("getObjClassName", locatorClassName),
        MethodResultEqualTest:newInstance("nObjs", 0)
    ))
    local storageChestsDestructTest = FieldTest:newInstance("_outputLocators", TestArrayTest:newInstance(
        ValueTypeTest:newInstance("ObjArray"),
        MethodResultEqualTest:newInstance("getObjClassName", locatorClassName),
        MethodResultEqualTest:newInstance("nObjs", 0)
    ))
    local destructFieldsTest = TestArrayTest:newInstance(
        topChestsDestructTest,
        storageChestsDestructTest
    )

    local inputLocatorsTest0 = FieldValueEqualTest:newInstance("_inputLocators", inputLocators0)
    local outputLocatorsTest0 = FieldValueEqualTest:newInstance("_outputLocators", outputLocators0)
    local constructFieldsTest0 = T_Factory.CreateInitialisedTest(nil, baseLocation1, inputLocatorsTest0, outputLocatorsTest0, craftingSpots0, smeltingSpots0)

    local constructFieldsTest1 = T_Factory.CreateInitialisedTest(nil, baseLocation1, inputLocatorsTest0, outputLocatorsTest0, craftingSpots1, smeltingSpots1)

    local inputLocatorsTest2 = FieldTest:newInstance("_inputLocators", TestArrayTest:newInstance(
        ValueTypeTest:newInstance("ObjArray"),
        MethodResultEqualTest:newInstance("getObjClassName", locatorClassName),
        MethodResultEqualTest:newInstance("nObjs", 1)
    ))
    local outputLocatorsTest2 = FieldTest:newInstance("_outputLocators", TestArrayTest:newInstance(
        ValueTypeTest:newInstance("ObjArray"),
        MethodResultEqualTest:newInstance("getObjClassName", locatorClassName),
        MethodResultEqualTest:newInstance("nObjs", 1)
    ))
    local constructFieldsTest2 = T_Factory.CreateInitialisedTest(nil, baseLocation1, inputLocatorsTest2, outputLocatorsTest2, craftingSpots1, smeltingSpots1)

    local isBlueprintTest = IsBlueprintTest:newInstance(baseLocation1)

    -- test
    T_IMObj.pt_IsInstanceOf_IMObj(testClassName, obj)
    T_IMObj.pt_destruct(testClassName, Factory, constructParameters0, testObjName, destructFieldsTest, logOk)
    T_IMObj.pt_construct(testClassName, Factory, constructParameters0, testObjName, constructFieldsTest0, logOk)
    T_IMObj.pt_construct(testClassName, Factory, constructParameters1, testObjName, constructFieldsTest1, logOk)
    T_IMObj.pt_construct(testClassName, Factory, constructParameters2, testObjName, constructFieldsTest2, logOk)
    T_IMObj.pt_getId(testClassName, obj, testObjName, logOk)
    T_IMObj.pt_getWIPId(testClassName, obj, testObjName, logOk)
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
    corelog.WriteToLog("* "..testClassName..":getAvailableInputLocator() tests")
    local obj = T_Factory.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

    -- test
    local locator = obj:getAvailableInputLocator()
    assert(locator:isEqual(inputLocator0), "gotten getAvailableInputLocator(="..textutils.serialise(locator, compact)..") not the same as expected(="..textutils.serialise(inputLocator0, compact)..")")

    -- cleanup test
end

function T_Factory.T_getAvailableOutputLocator()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":getAvailableOutputLocator() tests")
    local obj = T_Factory.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

    -- test
    local locator = obj:getAvailableOutputLocator()
    assert(locator:isEqual(outputLocator0), "gotten getAvailableOutputLocator(="..textutils.serialise(locator, compact)..") not the same as expected(="..textutils.serialise(outputLocator0, compact)..")")

    -- cleanup test
end

function T_Factory.T_getAvailableCraftSpot()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":getAvailableCraftSpot() tests")
    local obj = T_Factory.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

    -- test
    local spot = obj:getAvailableCraftSpot()
    assert(spot:isEqual(craftingSpot1), "gotten getAvailableCraftSpot(="..textutils.serialise(spot, compact)..") not the same as expected(="..textutils.serialise(craftingSpot1, compact)..")")

    -- cleanup test
end

function T_Factory.T_getAvailableSmeltSpot()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":getAvailableSmeltSpot() tests")
    local obj = T_Factory.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

    -- test
    local spot = obj:getAvailableSmeltSpot()
    assert(spot:isEqual(smeltingSpot1), "gotten getAvailableSmeltSpot(="..textutils.serialise(spot, compact)..") not the same as expected(="..textutils.serialise(smeltingSpot1, compact)..")")

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
    corelog.WriteToLog("* "..testClassName..":getFuelNeed_Production_Att() tests")
    local turtleObj = T_Turtle.CreateTestObj() assert (turtleObj, "Failed obtaining Turtle")
    local location2 = turtleObj:getLocation()
    local craftingSpot2 = ProductionSpot:newInstance(location2:getRelativeLocation(3, 3, -4), true)
    local craftingSpots2 = ObjArray:newInstance(productionSpotClassName, { craftingSpot2, })
    local smeltingSpot2 = ProductionSpot:newInstance(location2:getRelativeLocation(3, 3, -3), false)
    local smeltingSpots2 = ObjArray:newInstance(productionSpotClassName, { smeltingSpot2, })
    local obj = T_Factory.CreateTestObj(nil, location2, inputLocators0, outputLocators0, craftingSpots2, smeltingSpots2) assert(obj, "Failed obtaining "..testClassName)

    -- test
    local items = { ["minecraft:birch_planks"] = 4 }
    local fuelNeed = obj:getFuelNeed_Production_Att(items)
    local expectedFuelNeed = 20
    assert(fuelNeed == expectedFuelNeed, "gotten fuelNeed(="..fuelNeed..") not the same as expected(="..expectedFuelNeed..")")

    -- cleanup test
end

function T_Factory.T_getProductionLocation_Att()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":getProductionLocation_Att() tests")
    local obj = T_Factory.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

    -- test craft
    local itemName = "minecraft:birch_planks"
    local itemCount = 10
    local productionLocation = obj:getProductionLocation_Att({ [itemName] = itemCount})
    local expectedLocation = craftingSpot1:getBaseLocation()
    assert(productionLocation:isEqual(expectedLocation), "gotten getProductionLocation_Att(="..textutils.serialise(productionLocation, compact)..") not the same as expected(="..textutils.serialise(expectedLocation, compact)..")")

    -- test smelt
    itemName = "minecraft:charcoal"
    itemCount = 5
    productionLocation = obj:getProductionLocation_Att({ [itemName] = itemCount})
    expectedLocation = smeltingSpot1:getBaseLocation()
    assert(productionLocation:isEqual(expectedLocation), "gotten getProductionLocation_Att(="..textutils.serialise(productionLocation, compact)..") not the same as expected(="..textutils.serialise(expectedLocation, compact)..")")

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

function T_Factory.T_IItemSupplier_All()
    -- prepare test
    local obj = T_Factory.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

    -- test
    T_Class.pt_IsInstanceOf(testClassName, obj, "IItemSupplier", IItemSupplier)
    T_IInterface.pt_ImplementsInterface("IItemSupplier", IItemSupplier, testClassName, obj)
end

function T_Factory.T_can_ProvideItems_QOSrv()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":can_ProvideItems_QOSrv() tests")
    local obj = T_Factory.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

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
    local craftingSpots2 = ObjArray:newInstance(productionSpotClassName, { })
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
    local smeltingSpots2 = ObjArray:newInstance(productionSpotClassName, { })
    obj._smeltingSpots = smeltingSpots2
    serviceResults = obj:can_ProvideItems_QOSrv({ provideItems = { [itemName] = itemCount} })
    assert(not serviceResults.success, "can_ProvideItems_QOSrv incorrectly failed for "..itemCount.." "..itemName.."'s")
    obj._smeltingSpots = smeltingSpots1

    -- test can not produce without available inputLocator
    -- ToDo: improve by changing the availability of the inputLocator
    local inputLocators2 = ObjArray:newInstance(locatorClassName, { })
    obj._inputLocators = inputLocators2
    serviceResults = obj:can_ProvideItems_QOSrv({ provideItems = { [itemName] = itemCount} })
    assert(not serviceResults.success, "can_ProvideItems_QOSrv incorrectly success for "..itemCount.." "..itemName.."'s")
    obj._inputLocators = inputLocators0

    -- test can not produce without available outputLocator
    -- ToDo: improve by changing the availability of the _outputLocators
    local outputLocators2 = ObjArray:newInstance(locatorClassName, { })
    obj._outputLocators = outputLocators2
    serviceResults = obj:can_ProvideItems_QOSrv({ provideItems = { [itemName] = itemCount} })
    assert(not serviceResults.success, "can_ProvideItems_QOSrv incorrectly success for "..itemCount.." "..itemName.."'s")
    obj._outputLocators = outputLocators0

    -- cleanup test
end

local function t_provideItemsTo_AOSrv(provideItems, productionMethod)
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":provideItemsTo_AOSrv() tests ("..productionMethod..")")
    local obj = T_Factory.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)
    local itemDepotLocator = t_turtle.GetCurrentTurtleLocator() assert(itemDepotLocator, "Failed obtaining itemDepotLocator")
    local ingredientsItemSupplierLocator = t_turtle.GetCurrentTurtleLocator()

    local chest2 = T_Chest.CreateTestObj(nil, baseLocation1:getRelativeLocation(0, 0, -1)) assert(chest2, "Failed obtaining Chest 2")

    local wasteItemDepotLocator = enterprise_chests:saveObject(chest2)
--    local wasteItemDepotLocator = t_turtle.GetCurrentTurtleLocator()

    local expectedDestinationItemsLocator = itemDepotLocator:copy()
    expectedDestinationItemsLocator:setQuery(provideItems)
    local callback2 = Callback:newInstance("T_Factory", "provideItemsTo_AOSrv_Callback", {
        ["expectedDestinationItemsLocator"] = expectedDestinationItemsLocator,
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
    assert(destinationItemsLocator:isEqual(expectedDestinationItemsLocator), "gotten destinationItemsLocator(="..textutils.serialize(destinationItemsLocator, compact)..") not the same as expected(="..textutils.serialize(expectedDestinationItemsLocator, compact)..")")

    -- cleanup test

    -- end
    return true
end

return T_Factory
