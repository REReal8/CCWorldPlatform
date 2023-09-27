local T_BirchForest = {}

local corelog = require "corelog"
local coreutils = require "coreutils"

local Callback = require "obj_callback"
local MethodExecutor = require "method_executor"
local IObj = require "i_obj"
local IItemSupplier = require "i_item_supplier"
local ObjBase = require "obj_base"
local Location = require "obj_location"
local URL = require "obj_url"

local BirchForest = require "mobj_birchforest"

local role_forester = require "role_forester"

local enterprise_turtle = require "enterprise_turtle"
local enterprise_chests = require "enterprise_chests"
local enterprise_forestry = require "enterprise_forestry"

local TestArrayTest = require "test_array_test"
local FieldTest = require "field_test"
local FieldValueEqualTest = require "field_value_equal_test"
local ValueTypeTest = require "value_type_test"
local FieldValueTypeTest = require "field_value_type_test"
local MethodResultEqualTest = require "method_result_equal_test"
local IsBlueprintTest = require "test.is_blueprint_test"

local T_IInterface = require "test.t_i_interface"
local T_Class = require "test.t_class"
local T_IObj = require "test.t_i_obj"
local T_IMObj = require "test.t_i_mobj"

local t_turtle

function T_BirchForest.T_All()
    -- initialisation
    T_BirchForest.T__init()
    T_BirchForest.T_new()
    T_BirchForest.T_Getters()
    T_BirchForest.T_Setters()

    -- IObj methods
    T_BirchForest.T_IObj_All()

    -- IMObj methods
    T_BirchForest.T_IMObj_All()

    -- service methods
    T_BirchForest.T_getFuelNeed_Harvest_Att()
    T_BirchForest.T_getFuelNeedExtraTree_Att()

    -- IItemSupplier methods
    T_BirchForest.T_IItemSupplier_All()
    T_BirchForest.T_needsTo_ProvideItemsTo_SOSrv()
    T_BirchForest.T_can_ProvideItems_QOSrv()
end

local testClassName = "BirchForest"
local testObjName = "birchForest"
local logOk = false

local levelm1 = -1
local level0 = 0
local level1 = 1
local level2 = 2
local baseLocation0 = Location:newInstance(0, 0, 1, 0, 1)
local baseLocation2 = Location:newInstance(6, 12, 1, 0, 1)
local nTrees1 = 1
local nTrees2 = 2
local nTrees4 = 4
local localLogsLocator0 = enterprise_turtle.GetAnyTurtleLocator()
local localSaplingsLocator0 = enterprise_turtle.GetAnyTurtleLocator()
local localLogsLocatorTest0 = FieldValueEqualTest:newInstance("_localLogsLocator", localLogsLocator0)
local localSaplingsLocatorTest0 = FieldValueEqualTest:newInstance("_localSaplingsLocator", localSaplingsLocator0)

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_BirchForest.CreateTestObj(id, level, baseLocation, nTrees, localLogsLocator, localSaplingsLocator)
    -- check input
    id = id or coreutils.NewId()
    level = level or level0
    baseLocation = baseLocation or baseLocation0
    nTrees = nTrees or nTrees1
    localLogsLocator = localLogsLocator or localLogsLocator0
    localSaplingsLocator = localSaplingsLocator or localSaplingsLocator0

    -- create testObj
    local testObj = BirchForest:newInstance(id, level, baseLocation:copy(), nTrees, localLogsLocator, localSaplingsLocator)

    -- end
    return testObj
end

function T_BirchForest.CreateInitialisedTest(id, level, baseLocation, nTrees, localLogsLocatorTest, localSaplingsLocatorTest)
    -- check input

    -- create test
    local idTest = FieldValueTypeTest:newInstance("_id", "string") -- note: allow for testing only the type (instead of also the value)
    if id then idTest = FieldValueEqualTest:newInstance("_id", id) end
    local test = TestArrayTest:newInstance(
        idTest,
        FieldValueEqualTest:newInstance("_level", level),
        FieldValueEqualTest:newInstance("_baseLocation", baseLocation),
        FieldValueEqualTest:newInstance("_nTrees", nTrees),
        localLogsLocatorTest,
        localSaplingsLocatorTest
    )

    -- end
    return test
end

function T_BirchForest.T__init()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":_init() tests")
    local id = coreutils.NewId()

    -- test
    local obj = T_BirchForest.CreateTestObj(id, level0, baseLocation0, nTrees1, localLogsLocator0, localSaplingsLocator0) assert(obj, "Failed obtaining "..testClassName)
    local test = T_BirchForest.CreateInitialisedTest(id, level0, baseLocation0, nTrees1, localLogsLocatorTest0, localSaplingsLocatorTest0)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_BirchForest.T_new()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() tests")
    local id = coreutils.NewId()

    -- test
    local obj = BirchForest:new({
        _id                     = id,
        _level                  = level0,

        _baseLocation           = baseLocation0:copy(),
        _nTrees                 = nTrees1,

        _localLogsLocator       = localLogsLocator0,
        _localSaplingsLocator   = localSaplingsLocator0,
    })
    local test = T_BirchForest.CreateInitialisedTest(id, level0, baseLocation0, nTrees1, localLogsLocatorTest0, localSaplingsLocatorTest0)
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_BirchForest.T_Getters()
    -- prepare test
    corelog.WriteToLog("* "..testClassName.." getter tests")
    local id = coreutils.NewId()
    local className = "BirchForest"
    local localLogsLocator = enterprise_turtle.GetAnyTurtleLocator() assert(localLogsLocator, "Failed obtaining localLogsLocator")
    local localSaplingsLocator = enterprise_turtle.GetAnyTurtleLocator() assert(localSaplingsLocator, "Failed obtaining localLogsLocator")
    local obj = T_BirchForest.CreateTestObj(id, level0, baseLocation0, nTrees1, localLogsLocator0, localSaplingsLocator0) assert(obj, "Failed obtaining "..testClassName)

    -- test
    local test = TestArrayTest:newInstance(
        MethodResultEqualTest:newInstance("getLevel", level0),
        MethodResultEqualTest:newInstance("getBaseLocation", baseLocation0),
        MethodResultEqualTest:newInstance("getNTrees", nTrees1),
        MethodResultEqualTest:newInstance("getLocalLogsLocator", localLogsLocator0),
        MethodResultEqualTest:newInstance("getLocalSaplingsLocator", localSaplingsLocator0)
    )
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
end

function T_BirchForest.T_Setters()
    -- prepare test
    corelog.WriteToLog("* "..testClassName.." setter tests")
    local obj = T_BirchForest.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)
    local localLogsLocator2 = enterprise_chests:hostMObj_SSrv({className="Chest",constructParameters={ baseLocation = baseLocation2:getRelativeLocation(2, 2, 0), }}).mobjLocator if not localLogsLocator2 then corelog.Error("failed registering Chest") return end
    local localSaplingsLocator2 = enterprise_chests:hostMObj_SSrv({className="Chest",constructParameters={ baseLocation = baseLocation2:getRelativeLocation(4, 2, 0), }}).mobjLocator if not localSaplingsLocator2 then corelog.Error("failed registering Chest") return end

    -- test
    obj:setLevel(level2)
    obj:setLocation(baseLocation2)
    obj:setNTrees(nTrees2)
    obj:setLocalLogsLocator(localLogsLocator2)
    obj:setLocalSaplingsLocator(localSaplingsLocator2)
    local test = TestArrayTest:newInstance(
        MethodResultEqualTest:newInstance("getLevel", level2),
        MethodResultEqualTest:newInstance("getBaseLocation", baseLocation2),
        MethodResultEqualTest:newInstance("getNTrees", nTrees2),
        MethodResultEqualTest:newInstance("getLocalLogsLocator", localLogsLocator2),
        MethodResultEqualTest:newInstance("getLocalSaplingsLocator", localSaplingsLocator2)
    )
    test:test(obj, testObjName, "", logOk)

    -- cleanup test
    return enterprise_chests:releaseMObj_SSrv({ mobjLocator = localLogsLocator2 }) and enterprise_chests:releaseMObj_SSrv({ mobjLocator = localSaplingsLocator2 })
end

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

function T_BirchForest.T_IObj_All()
    -- prepare test
    local id = coreutils.NewId()
    local obj = T_BirchForest.CreateTestObj(id) assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_BirchForest.CreateTestObj(id) assert(otherObj, "Failed obtaining "..testClassName)

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

function T_BirchForest.T_IMObj_All()
    -- prepare test
    local id = coreutils.NewId()
    local objm1 = T_BirchForest.CreateTestObj(id, levelm1, baseLocation0, nTrees1, localLogsLocator0, localSaplingsLocator0) assert(objm1, "Failed obtaining "..testClassName)
    local testObjNamem1 = testObjName.."-1"
    local obj0 = T_BirchForest.CreateTestObj(id, level0, baseLocation0, nTrees1, localLogsLocator0, localSaplingsLocator0) assert(obj0, "Failed obtaining "..testClassName)
    local testObjName0 = testObjName.."0"
    local obj1 = T_BirchForest.CreateTestObj(id, level1, baseLocation0, nTrees2, localLogsLocator0, localSaplingsLocator0) assert(obj0, "Failed obtaining "..testClassName)
    local testObjName1 = testObjName.."1"
    local testObjName2 = testObjName.."2"

    local constructParameters_Lm1T1 = {
        level           = levelm1,

        baseLocation    = baseLocation0,
        nTrees          = nTrees1,
    }
    local constructParameters_L0T1 = {
        level           = level0,

        baseLocation    = baseLocation0,
        nTrees          = nTrees1,
    }
    local constructParameters_L1T2 = {
        level           = level1,

        baseLocation    = baseLocation0,
        nTrees          = nTrees2,
    }
    local constructParameters_L2T4 = {
        level           = level2,

        baseLocation    = baseLocation0,
        nTrees          = nTrees4,
    }

    local destructFieldsTest0 = TestArrayTest:newInstance()

    local upgradeParametersTo_L1T2 = {
        level           = level1,

        nTrees          = nTrees2,
    }
    local upgradeParametersTo_L2T4 = {
        level           = level2,

        nTrees          = nTrees4,
    }

    local localLogsLocatorTest2 = FieldTest:newInstance("_localLogsLocator", TestArrayTest:newInstance(
        ValueTypeTest:newInstance("URL"),
        MethodResultEqualTest:newInstance("getHost", "enterprise_chests")
    ))
    local localSaplingsLocatorTest2 = FieldTest:newInstance("_localSaplingsLocator", TestArrayTest:newInstance(
        ValueTypeTest:newInstance("URL"),
        MethodResultEqualTest:newInstance("getHost", "enterprise_chests")
    ))

    local fieldsTestm1 = T_BirchForest.CreateInitialisedTest(nil, levelm1, baseLocation0, nTrees1, localLogsLocatorTest0, localSaplingsLocatorTest0)
    local fieldsTest0 = T_BirchForest.CreateInitialisedTest(nil, level0, baseLocation0, nTrees1, localLogsLocatorTest0, localSaplingsLocatorTest0)
    local fieldsTest1 = T_BirchForest.CreateInitialisedTest(nil, level1, baseLocation0, nTrees2, localLogsLocatorTest0, localSaplingsLocatorTest0)
    local fieldsTest2 = T_BirchForest.CreateInitialisedTest(nil, level2, baseLocation0, nTrees4, localLogsLocatorTest2, localSaplingsLocatorTest2)

    local isBlueprintTest = IsBlueprintTest:newInstance(baseLocation0)
    local buildLocation_FromL1T2_ToL2T4 = baseLocation0:getRelativeLocation(0, 1, 0) -- note: offset because row 1 is already build
    local isBlueprintTest_FromL1T2_ToL2T4 = IsBlueprintTest:newInstance(buildLocation_FromL1T2_ToL2T4)

    -- test type
    T_IMObj.pt_IsInstanceOf_IMObj(testClassName, obj0)
    T_IMObj.pt_Implements_IMObj(testClassName, obj0)

    -- test construct/ upgrade/ destruct
    T_IMObj.pt_destruct(testClassName, BirchForest, constructParameters_L0T1, testObjName0, destructFieldsTest0, logOk)
    T_IMObj.pt_construct(testClassName, BirchForest, constructParameters_Lm1T1, testObjNamem1, fieldsTestm1, logOk)
    T_IMObj.pt_construct(testClassName, BirchForest, constructParameters_L0T1, testObjName0, fieldsTest0, logOk)
    T_IMObj.pt_construct(testClassName, BirchForest, constructParameters_L1T2, testObjName1, fieldsTest1, logOk)
    T_IMObj.pt_construct(testClassName, BirchForest, constructParameters_L2T4, testObjName2, fieldsTest2, logOk)
    T_IMObj.pt_upgrade(testClassName, BirchForest, constructParameters_L0T1, testObjName0, upgradeParametersTo_L1T2, fieldsTest1, logOk)
    T_IMObj.pt_upgrade(testClassName, BirchForest, constructParameters_L1T2, testObjName1, upgradeParametersTo_L2T4, fieldsTest2, logOk)

    -- test getters
    T_IMObj.pt_getId(testClassName, obj0, testObjName0, logOk)
    T_IMObj.pt_getWIPId(testClassName, obj0, testObjName0, logOk)

    -- test blueprints
    T_IMObj.pt_getBuildBlueprint(testClassName, objm1, testObjNamem1, isBlueprintTest, logOk)
    T_IMObj.pt_getBuildBlueprint(testClassName, obj0, testObjName0, isBlueprintTest, logOk)
    T_IMObj.pt_getExtendBlueprint(testClassName, obj0, testObjName0, upgradeParametersTo_L1T2, isBlueprintTest, logOk)
    T_IMObj.pt_getExtendBlueprint(testClassName, obj1, testObjName1, upgradeParametersTo_L2T4, isBlueprintTest_FromL1T2_ToL2T4, logOk)
    T_IMObj.pt_getDismantleBlueprint(testClassName, obj0, testObjName0, isBlueprintTest, logOk)

    -- cleanup test
end

--                        _                           _   _               _
--                       (_)                         | | | |             | |
--    ___  ___ _ ____   ___  ___ ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \  __/ |   \ V /| | (_|  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/\___|_|    \_/ |_|\___\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

function T_BirchForest.T_getFuelNeed_Harvest_Att()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":getFuelNeed_Harvest_Att() tests")
    local obj = T_BirchForest.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

    -- test
    local fuelNeed = obj:getFuelNeed_Harvest_Att()
    local expectedFuelNeed = 36
    assert(fuelNeed == expectedFuelNeed, "gotten fuelNeed(="..fuelNeed..") for "..nTrees1.."trees not the same as expected(="..expectedFuelNeed..")")

    obj:setNTrees(nTrees2)
    fuelNeed = obj:getFuelNeed_Harvest_Att()
    expectedFuelNeed = 2*36 + 2 * 6
    assert(fuelNeed == expectedFuelNeed, "gotten fuelNeed(="..fuelNeed..") for "..nTrees2.."trees not the same as expected(="..expectedFuelNeed..")")

    -- cleanup test
end

function T_BirchForest.T_getFuelNeedExtraTree_Att()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":getFuelNeedExtraTree_Att() tests")
    local obj = T_BirchForest.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

    -- test
    local fuelNeed = obj:getFuelNeedExtraTree_Att()
    local expectedFuelNeed = 36 + 2*6
    assert(fuelNeed == expectedFuelNeed, "gotten fuelNeed(="..fuelNeed..") for "..nTrees1.."trees not the same as expected(="..expectedFuelNeed..")")

    obj:setNTrees(nTrees2)
    fuelNeed = obj:getFuelNeedExtraTree_Att()
    expectedFuelNeed = 36 + 2*6
    assert(fuelNeed == expectedFuelNeed, "gotten fuelNeed(="..fuelNeed..") for "..nTrees2.."trees not the same as expected(="..expectedFuelNeed..")")

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

function T_BirchForest.T_IItemSupplier_All()
    -- prepare test
    local obj = T_BirchForest.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

    -- test
    T_Class.pt_IsInstanceOf(testClassName, obj, "IItemSupplier", IItemSupplier)
    T_IInterface.pt_ImplementsInterface("IItemSupplier", IItemSupplier, testClassName, obj)
end

function T_BirchForest.T_needsTo_ProvideItemsTo_SOSrv()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":needsTo_ProvideItemsTo_SOSrv() tests")
    local obj = T_BirchForest.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)
    local provideItems = {
        ["minecraft:birch_log"]  = 5,
    }
    t_turtle = t_turtle or require "test.t_turtle"
    local itemDepotLocator = t_turtle.GetCurrentTurtleLocator()

    -- test
    local needsTo_Provide = obj:needsTo_ProvideItemsTo_SOSrv({
        provideItems    = provideItems,
        itemDepotLocator= itemDepotLocator,
    })
    local storeFuelPerRound = 1 + 1
    local expectedFuelNeed = role_forester.FuelNeededPerRound(nTrees1) + storeFuelPerRound
    assert(needsTo_Provide.success, "needsTo_ProvideItemsTo_SOSrv failed")
    assert(needsTo_Provide.fuelNeed == expectedFuelNeed, "fuelNeed(="..needsTo_Provide.fuelNeed..") not the same as expected(="..expectedFuelNeed..")")
    assert(#needsTo_Provide.ingredientsNeed == 0, "ingredientsNeed(="..#needsTo_Provide.ingredientsNeed..") not the same as expected(=0)")

    -- cleanup test
end

function T_BirchForest.T_can_ProvideItems_QOSrv()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":can_ProvideItems_QOSrv() tests")
    local obj = T_BirchForest.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

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
end

local function t_provideItemsTo_AOSrv(provideItems)
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":provideItemsTo_AOSrv() tests ("..next(provideItems)..")")
    local obj = T_BirchForest.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)
    local objLocator = enterprise_forestry:saveObject(obj)
    t_turtle = t_turtle or require "test.t_turtle"
    local itemDepotLocator = t_turtle.GetCurrentTurtleLocator() assert(itemDepotLocator, "Failed obtaining itemDepotLocator")
    local ingredientsItemSupplierLocator = t_turtle.GetCurrentTurtleLocator()

    local T_Chest = require "test.t_mobj_chest"
    local chest2 = T_Chest.CreateTestObj(nil, baseLocation0:getRelativeLocation(0, 0, -1)) assert(chest2, "Failed obtaining Chest 2")
    local wasteItemDepotLocator = enterprise_chests:saveObject(chest2)

    local expectedDestinationItemsLocator = itemDepotLocator:copy()
    expectedDestinationItemsLocator:setQuery(provideItems)

    -- test
    local serviceResults = MethodExecutor.DoASyncObjService_Sync(obj, "provideItemsTo_AOSrv", {
        provideItems                    = provideItems,
        itemDepotLocator                = itemDepotLocator,
        ingredientsItemSupplierLocator  = ingredientsItemSupplierLocator,
        wasteItemDepotLocator           = wasteItemDepotLocator,
    })
    assert(serviceResults, "no serviceResults returned")
    assert(serviceResults.success, "failed executing service")

    -- check: destinationItemsLocator
    local destinationItemsLocator = URL:new(serviceResults.destinationItemsLocator)
    assert(destinationItemsLocator:isEqual(expectedDestinationItemsLocator), "gotten destinationItemsLocator(="..textutils.serialize(destinationItemsLocator, compact)..") not the same as expected(="..textutils.serialize(expectedDestinationItemsLocator, compact)..")")

    -- cleanup test
    enterprise_forestry:deleteResource(objLocator)
    enterprise_chests:deleteResource(wasteItemDepotLocator)
end

function T_BirchForest.T_provideItemsTo_AOSrv_Log()
    -- prepare test
    local provideItems = { ["minecraft:birch_log"] = 10 }

    -- test
    t_provideItemsTo_AOSrv(provideItems)
end

function T_BirchForest.T_provideItemsTo_AOSrv_Sapling()
    -- prepare test
    local provideItems = { ["minecraft:birch_sapling"] = 1 }

    -- test
    t_provideItemsTo_AOSrv(provideItems)
end

return T_BirchForest
