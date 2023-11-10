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

local enterprise_employment = require "enterprise_employment"
local enterprise_chests = require "enterprise_chests"
local enterprise_manufacturing = require "enterprise_manufacturing"

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
local T_ILObj = require "test.t_i_lobj"
local T_IMObj = require "test.t_i_mobj"
local T_IItemSupplier = require "test.t_i_item_supplier"

local T_Chest = require "test.t_mobj_chest"
local t_employment

function T_Factory.T_All()
    -- initialisation
    T_Factory.T__init()
    T_Factory.T_new()
    T_Factory.T_Getters()

    -- IObj
    T_Factory.T_IObj_All()

    -- ILObj
    T_Factory.T_ILObj_All()

    -- IMObj
    T_Factory.T_IMObj_All()

    -- specific
    T_Factory.T_getAvailableInputLocator()
    T_Factory.T_getAvailableOutputLocator()
    T_Factory.T_getAvailableCraftSpot()
    T_Factory.T_getAvailableSmeltSpot()

    -- service
    T_Factory.T_getFuelNeed_Production_Att()

    -- IItemSupplier
    T_Factory.T_IItemSupplier_All()
end

function T_Factory.T_AllPhysical()
    -- IItemSupplier
    T_Factory.T_provideItemsTo_AOSrv_Craft_ToTurtle()
    T_Factory.T_provideItemsTo_AOSrv_Smelt_ToTurtle()
end

local testClassName = "Factory"
local testObjName = "factory"
local testObjName0 = testObjName.."0"
local testObjName1 = testObjName.."1"
local testObjName2 = testObjName.."2"
local testHost = enterprise_manufacturing

local logOk = false

local level0 = 0
local level1 = 1
local level2 = 2

local baseLocation0 = Location:newInstance(12, 0, 1, 0, 1)

local inputLocator0 = enterprise_employment.GetAnyTurtleLocator()
local inputLocators0 = ObjArray:newInstance(URL:getClassName(), { inputLocator0, })

local outputLocator0 = enterprise_employment.GetAnyTurtleLocator()
local outputLocators0 = ObjArray:newInstance(URL:getClassName(), { outputLocator0, })

local craftingSpot0 = ProductionSpot:newInstance(baseLocation0:getRelativeLocation(0, 0, 0), true)
local productionSpotClassName = "ProductionSpot"
local craftingSpots0 = ObjArray:newInstance(productionSpotClassName, { craftingSpot0, })
local craftingSpot1 = ProductionSpot:newInstance(baseLocation0:getRelativeLocation(3, 3, -4), true)
local craftingSpots1 = ObjArray:newInstance(productionSpotClassName, { craftingSpot1, })

local smeltingSpots0 = ObjArray:newInstance(productionSpotClassName)
local smeltingSpot1 = ProductionSpot:newInstance(baseLocation0:getRelativeLocation(3, 3, -3), false)
local smeltingSpots1 = ObjArray:newInstance(productionSpotClassName, { smeltingSpot1, })

local constructParameters0 = {
    level           = level0,

    baseLocation    = baseLocation0,
}
local constructParameters1 = {
    level           = level1,

    baseLocation    = baseLocation0,
}
local constructParameters2 = {
    level           = level2,

    baseLocation    = baseLocation0,
}
local upgradeParametersTo2 = {
    level           = level2,
}

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_Factory.CreateTestObj(id, level, baseLocation, inputLocators, outputLocators, craftingSpots, smeltingSpots)
    -- check input
    id = id or coreutils.NewId()
    level = level or level1
    baseLocation = baseLocation or baseLocation0
    inputLocators = inputLocators or inputLocators0
    outputLocators = outputLocators or outputLocators0
    craftingSpots = craftingSpots or craftingSpots1
    smeltingSpots = smeltingSpots or smeltingSpots1

    -- create testObj
    local testObj = Factory:newInstance(id, level, baseLocation:copy(), inputLocators:copy(), outputLocators:copy(), craftingSpots:copy(), smeltingSpots:copy())

    -- end
    return testObj
end

function T_Factory.CreateInitialisedTest(id, level, baseLocation, inputLocatorsTest, outputLocatorsTest, craftingSpots, smeltingSpots)
    -- check input

    -- create test
    local idTest = FieldValueTypeTest:newInstance("_id", "string")
    if id then idTest = FieldValueEqualTest:newInstance("_id", id) end
    local test = TestArrayTest:newInstance(
        idTest,
        FieldValueEqualTest:newInstance("_level", level),
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
    local obj = T_Factory.CreateTestObj(id, level1, baseLocation0, inputLocators0, outputLocators0, craftingSpots1, smeltingSpots1) assert(obj, "Failed obtaining "..testClassName)
    local inputLocatorsTest = FieldValueEqualTest:newInstance("_inputLocators", inputLocators0)
    local outputLocatorsTest = FieldValueEqualTest:newInstance("_outputLocators", outputLocators0)
    local test = T_Factory.CreateInitialisedTest(id, level1, baseLocation0, inputLocatorsTest, outputLocatorsTest, craftingSpots1, smeltingSpots1)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_Factory.T_new()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() tests")
    local id = coreutils.NewId()

    -- test
    local obj = Factory:new({
        _id             = id,

        _level          = level1,

        _baseLocation   = baseLocation0:copy(),

        _inputLocators  = inputLocators0:copy(),
        _outputLocators = outputLocators0:copy(),

        _craftingSpots  = craftingSpots1:copy(),
        _smeltingSpots  = smeltingSpots1:copy(),
    })
    local inputLocatorsTest = FieldValueEqualTest:newInstance("_inputLocators", inputLocators0)
    local outputLocatorsTest = FieldValueEqualTest:newInstance("_outputLocators", outputLocators0)
    local test = T_Factory.CreateInitialisedTest(id, level1, baseLocation0, inputLocatorsTest, outputLocatorsTest, craftingSpots1, smeltingSpots1)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_Factory.T_Getters()
    -- prepare test
    corelog.WriteToLog("* "..testClassName.." base getter tests")
    local id = coreutils.NewId()
    local obj = T_Factory.CreateTestObj(id, level1, baseLocation0, inputLocators0, outputLocators0, craftingSpots1, smeltingSpots1) assert(obj, "Failed obtaining "..testClassName)

    -- test
    local test = TestArrayTest:newInstance(
        MethodResultEqualTest:newInstance("getLevel", level1),
        MethodResultEqualTest:newInstance("getInputLocators", inputLocators0),
        MethodResultEqualTest:newInstance("getOutputLocators", outputLocators0),
        MethodResultEqualTest:newInstance("getCraftingSpots", craftingSpots1),
        MethodResultEqualTest:newInstance("getSmeltingSpots", smeltingSpots1)
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

--    _____ _      ____  _     _
--   |_   _| |    / __ \| |   (_)
--     | | | |   | |  | | |__  _
--     | | | |   | |  | | '_ \| |
--    _| |_| |___| |__| | |_) | |
--   |_____|______\____/|_.__/| |
--                           _/ |
--                          |__/

function T_Factory.T_ILObj_All()
    -- prepare tests
    local topChestsDestructTest = FieldTest:newInstance("_inputLocators", TestArrayTest:newInstance(
        ValueTypeTest:newInstance("ObjArray"),
        MethodResultEqualTest:newInstance("getObjClassName", URL:getClassName()),
        MethodResultEqualTest:newInstance("nObjs", 0)
    ))
    local storageChestsDestructTest = FieldTest:newInstance("_outputLocators", TestArrayTest:newInstance(
        ValueTypeTest:newInstance("ObjArray"),
        MethodResultEqualTest:newInstance("getObjClassName", URL:getClassName()),
        MethodResultEqualTest:newInstance("nObjs", 0)
    ))
    local destructFieldsTest = TestArrayTest:newInstance(
        topChestsDestructTest,
        storageChestsDestructTest
    )

    local inputLocatorsTest0 = FieldValueEqualTest:newInstance("_inputLocators", inputLocators0)
    local outputLocatorsTest0 = FieldValueEqualTest:newInstance("_outputLocators", outputLocators0)
    local fieldsTest0 = T_Factory.CreateInitialisedTest(nil, level0, baseLocation0, inputLocatorsTest0, outputLocatorsTest0, craftingSpots0, smeltingSpots0)

    local fieldsTest1 = T_Factory.CreateInitialisedTest(nil, level1, baseLocation0, inputLocatorsTest0, outputLocatorsTest0, craftingSpots1, smeltingSpots1)

    local inputLocatorsTest2 = FieldTest:newInstance("_inputLocators", TestArrayTest:newInstance(
        ValueTypeTest:newInstance("ObjArray"),
        MethodResultEqualTest:newInstance("getObjClassName", URL:getClassName()),
        MethodResultEqualTest:newInstance("nObjs", 1)
    ))
    local outputLocatorsTest2 = FieldTest:newInstance("_outputLocators", TestArrayTest:newInstance(
        ValueTypeTest:newInstance("ObjArray"),
        MethodResultEqualTest:newInstance("getObjClassName", URL:getClassName()),
        MethodResultEqualTest:newInstance("nObjs", 1)
    ))
    local fieldsTest2 = T_Factory.CreateInitialisedTest(nil, level2, baseLocation0, inputLocatorsTest2, outputLocatorsTest2, craftingSpots1, smeltingSpots1)

    -- test cases
    T_ILObj.pt_all(testClassName, Factory, {
        {
            objName             = testObjName0,
            constructParameters = constructParameters0,
            constructFieldsTest = fieldsTest0,
            destructFieldsTest  = destructFieldsTest
        },
        {
            objName             = testObjName1,
            constructParameters = constructParameters1,
            constructFieldsTest = fieldsTest1,
            upgradeParameters   = upgradeParametersTo2,
            upgradeFieldsTest   = fieldsTest2,
        },
        {
            objName             = testObjName2,
            constructParameters = constructParameters2,
            constructFieldsTest = fieldsTest2,
        },
    }, logOk)

    -- cleanup test
end

--    _____ __  __  ____  _     _
--   |_   _|  \/  |/ __ \| |   (_)
--     | | | \  / | |  | | |__  _
--     | | | |\/| | |  | | '_ \| |
--    _| |_| |  | | |__| | |_) | |
--   |_____|_|  |_|\____/|_.__/| |
--                            _/ |
--                           |__/

function T_Factory.T_IMObj_All()
    -- prepare tests
    local isBlueprintTest = IsBlueprintTest:newInstance(baseLocation0)

    -- test cases
    T_IMObj.pt_all(testClassName, Factory, {
        {
            objName                 = testObjName0,
            constructParameters     = constructParameters0,
            constructBlueprintTest  = isBlueprintTest,
            expectedBaseLocation    = baseLocation0:copy(),
            dismantleBlueprintTest  = isBlueprintTest,
        },
        {
            objName                 = testObjName1,
            constructParameters     = constructParameters1,
            constructBlueprintTest  = isBlueprintTest,
            upgradeParameters       = upgradeParametersTo2,
            upgradeBlueprintTest    = isBlueprintTest,
        },
        {
            objName                 = testObjName2,
            constructParameters     = constructParameters2,
            constructBlueprintTest  = isBlueprintTest,
        },
    }, logOk)
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

--                        _
--                       (_)
--    ___  ___ _ ____   ___  ___ ___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \
--   \__ \  __/ |   \ V /| | (_|  __/
--   |___/\___|_|    \_/ |_|\___\___|

function T_Factory.T_getFuelNeed_Production_Att()
    -- prepare test L1
    corelog.WriteToLog("* "..testClassName..":getFuelNeed_Production_Att() test (level 1 crafting)")
    local objL1 = T_Factory.CreateTestObj(nil, level1) assert(objL1, "Failed obtaining "..testClassName)
    local expectedFuelNeedCraftingSpot = 0
    local craftItems = { ["minecraft:birch_planks"] = 4 }

    -- test L1
    local fuelNeed = objL1:getFuelNeed_Production_Att(craftItems)
    local expectedFuelNeed = (3+3+4) + expectedFuelNeedCraftingSpot + (3+3+4)
    assert(fuelNeed == expectedFuelNeed, "gotten fuelNeed(="..fuelNeed..") not the same as expected(="..expectedFuelNeed..")")

    -- prepare test L2
    corelog.WriteToLog("* "..testClassName..":getFuelNeed_Production_Att() test (level 2 crafting)")
    local inputChestLocator = enterprise_chests:hostMObj_SSrv({ className = "Chest", constructParameters = {
        baseLocation    = baseLocation0:getRelativeLocation(2, 5, 0),
        accessDirection = "top",
    }}).mobjLocator assert(inputChestLocator, "Failed obtaining Chest")
    local inputLocators2 = ObjArray:newInstance(URL:getClassName(), { inputChestLocator, })
    local outputChestLocator = enterprise_chests:hostMObj_SSrv({ className = "Chest", constructParameters = {
        baseLocation    = baseLocation0:getRelativeLocation(4, 5, 0),
        accessDirection = "top",
    }}).mobjLocator assert(outputChestLocator, "Failed obtaining Chest")
    local outputLocators2 = ObjArray:newInstance(URL:getClassName(), { outputChestLocator, })
    local objL2 = T_Factory.CreateTestObj(nil, level2, baseLocation0, inputLocators2, outputLocators2) assert(objL2, "Failed obtaining "..testClassName)

    -- test L2
    fuelNeed = objL2:getFuelNeed_Production_Att(craftItems)
    expectedFuelNeed = (2+5+0) + (1+2+4) + expectedFuelNeedCraftingSpot + (1+2+4) + (4+5+0)
    assert(fuelNeed == expectedFuelNeed, "gotten fuelNeed(="..fuelNeed..") not the same as expected(="..expectedFuelNeed..")")

    -- cleanup test
    enterprise_chests:releaseMObj_SSrv({ mobjLocator = inputChestLocator })
    enterprise_chests:releaseMObj_SSrv({ mobjLocator = outputChestLocator })
end

--    _____ _____ _                  _____                   _ _
--   |_   _|_   _| |                / ____|                 | (_)
--     | |   | | | |_ ___ _ __ ___ | (___  _   _ _ __  _ __ | |_  ___ _ __
--     | |   | | | __/ _ \ '_ ` _ \ \___ \| | | | '_ \| '_ \| | |/ _ \ '__|
--    _| |_ _| |_| ||  __/ | | | | |____) | |_| | |_) | |_) | | |  __/ |
--   |_____|_____|\__\___|_| |_| |_|_____/ \__,_| .__/| .__/|_|_|\___|_|
--                                              | |   | |
--                                              |_|   |_|

function T_Factory.T_IItemSupplier_All()
    -- prepare test
    local obj = T_Factory.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

    -- test type
    T_Class.pt_IsInstanceOf(testClassName, obj, "IItemSupplier", IItemSupplier)
    T_IInterface.pt_ImplementsInterface("IItemSupplier", IItemSupplier, testClassName, obj)

    -- test
    -- T_Factory.T_needsTo_ProvideItemsTo_SOSrv()
    T_Factory.T_can_ProvideItems_QOSrv()
end

function T_Factory.T_provideItemsTo_AOSrv_Craft_ToTurtle()
    -- prepare test
    local objLocator = testHost:hostMObj_SSrv({ className = testClassName, constructParameters = constructParameters2 }).mobjLocator assert(objLocator, "failed hosting "..testClassName.." on "..testHost:getHostName())

    local provideItems = { ["minecraft:birch_planks"] = 11 }

    t_employment = t_employment or require "test.t_employment"
    local itemDepotLocator = t_employment.GetCurrentTurtleLocator() assert(itemDepotLocator, "Failed obtaining itemDepotLocator")
    local ingredientsItemSupplierLocator = t_employment.GetCurrentTurtleLocator() assert(ingredientsItemSupplierLocator, "Failed obtaining ingredientsItemSupplierLocator")
    local wasteItemDepotLocator = ingredientsItemSupplierLocator:copy()

    -- test
    T_IItemSupplier.pt_provideItemsTo_AOSrv_Test(testClassName, objLocator, provideItems, itemDepotLocator, ingredientsItemSupplierLocator, wasteItemDepotLocator, logOk)

    -- cleanup test
    testHost:releaseMObj_SSrv({ mobjLocator = objLocator})
end

function T_Factory.T_provideItemsTo_AOSrv_Smelt_ToTurtle()
    -- prepare test
    local objLocator = testHost:hostMObj_SSrv({ className = testClassName, constructParameters = constructParameters2 }).mobjLocator assert(objLocator, "failed hosting "..testClassName.." on "..testHost:getHostName())

    local provideItems = { ["minecraft:charcoal"] = 1 }

    t_employment = t_employment or require "test.t_employment"
    local itemDepotLocator = t_employment.GetCurrentTurtleLocator() assert(itemDepotLocator, "Failed obtaining itemDepotLocator")
    local ingredientsItemSupplierLocator = t_employment.GetCurrentTurtleLocator() assert(ingredientsItemSupplierLocator, "Failed obtaining ingredientsItemSupplierLocator")
    local wasteItemDepotLocator = ingredientsItemSupplierLocator:copy()

    -- test
    T_IItemSupplier.pt_provideItemsTo_AOSrv_Test(testClassName, objLocator, provideItems, itemDepotLocator, ingredientsItemSupplierLocator, wasteItemDepotLocator, logOk)

    -- test
    testHost:releaseMObj_SSrv({ mobjLocator = objLocator})
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
    local inputLocators2 = ObjArray:newInstance(URL:getClassName(), { })
    obj._inputLocators = inputLocators2
    serviceResults = obj:can_ProvideItems_QOSrv({ provideItems = { [itemName] = itemCount} })
    assert(not serviceResults.success, "can_ProvideItems_QOSrv incorrectly success for "..itemCount.." "..itemName.."'s")
    obj._inputLocators = inputLocators0

    -- test can not produce without available outputLocator
    -- ToDo: improve by changing the availability of the _outputLocators
    local outputLocators2 = ObjArray:newInstance(URL:getClassName(), { })
    obj._outputLocators = outputLocators2
    serviceResults = obj:can_ProvideItems_QOSrv({ provideItems = { [itemName] = itemCount} })
    assert(not serviceResults.success, "can_ProvideItems_QOSrv incorrectly success for "..itemCount.." "..itemName.."'s")
    obj._outputLocators = outputLocators0

    -- cleanup test
end

return T_Factory
