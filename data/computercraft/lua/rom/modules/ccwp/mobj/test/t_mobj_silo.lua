local T_Silo = {}
local corelog = require "corelog"
local coreutils = require "coreutils"
local coredht = require "coredht"

local Callback = require "obj_callback"
local MethodExecutor = require "method_executor"

local IObj = require "i_obj"
local IItemSupplier = require "i_item_supplier"
local IItemDepot = require "i_item_depot"
local ObjBase = require "obj_base"
local ObjArray = require "obj_array"
local Location = require "obj_location"
local URL = require "obj_url"
local Inventory = require "obj_inventory"

local Silo = require "mobj_silo"

local enterprise_chests = require "enterprise_chests"
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
local T_ILObj = require "test.t_i_lobj"
local T_IMObj = require "test.t_i_mobj"
local T_IItemSupplier = require "test.t_i_item_supplier"
local T_IItemDepot = require "test.t_i_item_depot"

local T_Chest = require "test.t_mobj_chest"

local t_employment = require "test.t_employment"

function T_Silo.T_All()
    -- initialisation
    T_Silo.T__init()
    T_Silo.T_new()

    -- IObj
    T_Silo.T_IObj_All()

    -- ILObj
    T_Silo.T_ILObj_All()

    -- IMObj
    T_Silo.T_IMObj_All()

    -- IItemSupplier
    T_Silo.T_IItemSupplier_All()

    -- IItemDepot
    T_Silo.T_IItemDepot_All()
end

function T_Silo.T_AllPhysical()
    -- IItemSupplier
    T_Silo.T_provideItemsTo_AOSrv_MultipleItems_ToTurtle()
end

local testClassName = "Silo"
local testObjName = "silo"
local testHost = enterprise_storage

local logOk = false

local baseLocation0  = Location:newInstance(12, -12, 1, 0, 1)
local entryLocation0 = baseLocation0:getRelativeLocation(3, 3, 0)
local dropLocation0 = 0
local pickupLocation0 = 0
local topChests0 = ObjArray:newInstance(URL:getClassName()) assert(topChests0, "Failed obtaining ObjArray")
local storageChests0 = ObjArray:newInstance(URL:getClassName()) assert(storageChests0, "Failed obtaining ObjArray")
local nTopChests0 = 2
local nLayers0 = 2

local constructParameters0 = {
    baseLocation    = baseLocation0,
    nTopChests      = nTopChests0,
    nLayers         = nLayers0,
}

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
    baseLocation = baseLocation or baseLocation0
    entryLocation = entryLocation or entryLocation0
    dropLocation = dropLocation or dropLocation0
    pickupLocation = pickupLocation or pickupLocation0
    topChests = topChests or topChests0
    storageChests = storageChests or storageChests0

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
    local obj = T_Silo.CreateTestObj(id, baseLocation0, entryLocation0, dropLocation0, pickupLocation0, topChests0, storageChests0) assert(obj, "Failed obtaining "..testClassName)
    local topChestsTest = FieldValueEqualTest:newInstance("_topChests", topChests0)
    local storageChestsTest = FieldValueEqualTest:newInstance("_storageChests", storageChests0)
    local test = T_Silo.CreateInitialisedTest(id, baseLocation0, entryLocation0, dropLocation0, pickupLocation0, topChestsTest, storageChestsTest)
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
        _baseLocation   = baseLocation0:copy(),
        _entryLocation  = entryLocation0:copy(),

        -- pickup and drop
        _dropLocation   = dropLocation0,
        _pickupLocation = pickupLocation0,

        -- chests
        _topChests      = topChests0:copy(),
        _storageChests  = storageChests0:copy(),
    })
    local topChestsTest = FieldValueEqualTest:newInstance("_topChests", topChests0)
    local storageChestsTest = FieldValueEqualTest:newInstance("_storageChests", storageChests0)
    local test = T_Silo.CreateInitialisedTest(id, baseLocation0, entryLocation0, dropLocation0, pickupLocation0, topChestsTest, storageChestsTest)
    test:test(obj, testObjName, "", logOk)
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
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

--    _____ _      ____  _     _
--   |_   _| |    / __ \| |   (_)
--     | | | |   | |  | | |__  _
--     | | | |   | |  | | '_ \| |
--    _| |_| |___| |__| | |_) | |
--   |_____|______\____/|_.__/| |
--                           _/ |
--                          |__/

function T_Silo.T_ILObj_All()
    -- prepare test
    local topChestsDestructTest = FieldTest:newInstance("_topChests", TestArrayTest:newInstance(
        ValueTypeTest:newInstance("ObjArray"),
        MethodResultEqualTest:newInstance("getObjClassName", URL:getClassName()),
        MethodResultEqualTest:newInstance("nObjs", 0)
    ))
    local storageChestsDestructTest = FieldTest:newInstance("_storageChests", TestArrayTest:newInstance(
        ValueTypeTest:newInstance("ObjArray"),
        MethodResultEqualTest:newInstance("getObjClassName", URL:getClassName()),
        MethodResultEqualTest:newInstance("nObjs", 0)
    ))
    local destructFieldsTest = TestArrayTest:newInstance(
        topChestsDestructTest,
        storageChestsDestructTest
    )

    local dropLocation = 1
    local pickupLocation = 2
    local topChestsConstructTest = FieldTest:newInstance("_topChests", TestArrayTest:newInstance(
        ValueTypeTest:newInstance("ObjArray"),
        MethodResultEqualTest:newInstance("getObjClassName", URL:getClassName()),
        MethodResultEqualTest:newInstance("nObjs", nTopChests0)
    ))
    local storageChestsConstructTest = FieldTest:newInstance("_storageChests", TestArrayTest:newInstance(
        ValueTypeTest:newInstance("ObjArray"),
        MethodResultEqualTest:newInstance("getObjClassName", URL:getClassName()),
        MethodResultEqualTest:newInstance("nObjs", nLayers0*4)
    ))
    local constructFieldsTest = T_Silo.CreateInitialisedTest(nil, baseLocation0, entryLocation0, dropLocation, pickupLocation, topChestsConstructTest, storageChestsConstructTest)

    -- test cases
    T_ILObj.pt_all(testClassName, Silo, {
        {
            objName             = testObjName,
            constructParameters = constructParameters0,
            constructFieldsTest = constructFieldsTest,
            destructFieldsTest  = destructFieldsTest
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

function T_Silo.T_IMObj_All()
    -- prepare test
    local isBlueprintTest = IsBlueprintTest:newInstance(baseLocation0)

    -- test cases
    T_IMObj.pt_all(testClassName, Silo, {
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

function T_Silo.T_integrityCheck_AOSrv()
    -- prepare test
    corelog.WriteToLog("* Silo:integrityCheck_AOSrv() tests")
    local obj = Silo:construct({baseLocation=baseLocation0, nTopChests=2, nLayers=2}) assert(obj, "Failed obtaining "..testClassName)
    local siloLocator = testHost:saveObject(obj)

    -- test
    obj:integrityCheck_AOSrv({}, Callback.GetNewDummyCallBack())

    -- cleanup test
    testHost:releaseMObj_SSrv({ mobjLocator = siloLocator})
end

--    _____ _____ _                  _____                   _ _
--   |_   _|_   _| |                / ____|                 | (_)
--     | |   | | | |_ ___ _ __ ___ | (___  _   _ _ __  _ __ | |_  ___ _ __
--     | |   | | | __/ _ \ '_ ` _ \ \___ \| | | | '_ \| '_ \| | |/ _ \ '__|
--    _| |_ _| |_| ||  __/ | | | | |____) | |_| | |_) | |_) | | |  __/ |
--   |_____|_____|\__\___|_| |_| |_|_____/ \__,_| .__/| .__/|_|_|\___|_|
--                                              | |   | |
--                                              |_|   |_|

function T_Silo.T_IItemSupplier_All()
    -- prepare test
    local obj = T_Silo.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

    -- test type
    T_Class.pt_IsInstanceOf(testClassName, obj, "IItemSupplier", IItemSupplier)
    T_IInterface.pt_ImplementsInterface("IItemSupplier", IItemSupplier, testClassName, obj)

    -- test
    T_Silo.T_needsTo_ProvideItemsTo_SOSrv()
    T_Silo.T_can_ProvideItems_QOSrv()
end

function T_Silo.T_provideItemsTo_AOSrv_MultipleItems_ToTurtle()
    -- prepare test
    local objLocator = testHost:hostMObj_SSrv({ className = testClassName, constructParameters = constructParameters0 }).mobjLocator assert(objLocator, "failed hosting "..testClassName.." on "..testHost:getHostName())
    local lobj = testHost:getObject(objLocator) assert(lobj, "Failed obtaining "..testClassName.." from objLocator "..objLocator:getURI())
    local serviceResults = MethodExecutor.DoASyncObjService_Sync(lobj, "integrityCheck_AOSrv", {
    })
    assert(serviceResults, "no serviceResults returned")
    assert(serviceResults.success, "failed executing service")

    local provideItems = {
        ["minecraft:birch_planks"]  = 5,
        ["minecraft:birch_log"]     = 3,
        ["minecraft:coal"]          = 7,
    }

    t_employment = t_employment or require "test.t_employment"
    local itemDepotLocator = t_employment.GetCurrentTurtleLocator() assert(itemDepotLocator, "Failed obtaining itemDepotLocator")
    local ingredientsItemSupplierLocator = t_employment.GetCurrentTurtleLocator() assert(ingredientsItemSupplierLocator, "Failed obtaining ingredientsItemSupplierLocator")
    local wasteItemDepotLocator = ingredientsItemSupplierLocator:copy()

    -- test
    T_IItemSupplier.pt_provideItemsTo_AOSrv(testClassName, objLocator, provideItems, itemDepotLocator, ingredientsItemSupplierLocator, wasteItemDepotLocator, logOk)

    -- cleanup test
    testHost:releaseMObj_SSrv({ mobjLocator = objLocator})
end

-- ToDo: implement
function T_Silo.T_needsTo_ProvideItemsTo_SOSrv()
    -- prepare test

    -- test

    -- cleanup test
end

function T_Silo.T_can_ProvideItems_QOSrv()
    -- prepare test
    local inventory = Inventory:newInstance({
        { name = "minecraft:dirt", count = 20 },
    })
    local chest = T_Chest.CreateTestObj(nil, nil, nil, inventory) assert(chest, "Failed obtaining Chest")
    local chestLocator = enterprise_chests:saveObject(chest)
    local topChests = ObjArray:newInstance(URL:getClassName()) assert(topChests, "Failed obtaining topChests")
    table.insert(topChests, chestLocator) -- note: fake Chest with specific items

    local obj = T_Silo.CreateTestObj(nil, nil, nil, nil, nil, nil, topChests) assert(obj, "Failed obtaining "..testClassName)

    -- tests
    T_IItemSupplier.pt_can_ProvideItems_QOSrv(testClassName, obj, testObjName, { ["minecraft:dirt"] = 10}, true, logOk)
    T_IItemSupplier.pt_can_ProvideItems_QOSrv(testClassName, obj, testObjName, { ["minecraft:furnace"] = 1}, false, logOk)

    -- cleanup test
    enterprise_chests:deleteResource(chestLocator)
end

--    _____ _____ _                 _____                   _
--   |_   _|_   _| |               |  __ \                 | |
--     | |   | | | |_ ___ _ __ ___ | |  | | ___ _ __   ___ | |_
--     | |   | | | __/ _ \ '_ ` _ \| |  | |/ _ \ '_ \ / _ \| __|
--    _| |_ _| |_| ||  __/ | | | | | |__| |  __/ |_) | (_) | |_
--   |_____|_____|\__\___|_| |_| |_|_____/ \___| .__/ \___/ \__|
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
    local itemsLocator = t_employment.GetCurrentTurtleLocator() assert(itemsLocator, "Failed obtaining itemsLocator")
    local obj = Silo:construct({baseLocation=baseLocation0, nTopChests=2, nLayers=2}) assert(obj, "Failed obtaining "..testClassName)
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
    silo:integrityCheck_AOSrv({}, Callback.GetNewDummyCallBack())

    -- usefull if this silo is active
--    silo:Activate()

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
    silo:provideItemsTo_AOSrv({provideItems = provideItems, itemDepotLocator = t_employment.GetCurrentTurtleLocator()}, Callback.GetNewDummyCallBack())
 ]]
--[[
    -- da silo
    local daSilo    = silo:getObjectLocator()

    -- da shop
    local daShop = enterprise_shop.GetShopLocator()             assert(daShop, "Oops")
    local daTurtle = t_employment.GetCurrentTurtleLocator()         assert(daTurtle, "Oops")
    local turtleLocator = daTurtle.GetCurrentTurtleLocator()
    local daCallback = Callback.GetNewDummyCallBack()

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
