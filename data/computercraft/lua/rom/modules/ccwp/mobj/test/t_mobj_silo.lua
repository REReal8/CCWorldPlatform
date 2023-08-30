local T_Silo = {}
local corelog = require "corelog"
local coreutils = require "coreutils"
local coredht = require "coredht"

local Callback = require "obj_callback"

local IObj = require "i_obj"
local IItemSupplier = require "i_item_supplier"
local IItemDepot = require "i_item_depot"
local ObjBase = require "obj_base"
local ObjArray = require "obj_array"
local Location = require "obj_location"
local URL = require "obj_url"

local IMObj = require "i_mobj"
local Silo = require "mobj_silo"

local enterprise_chests = require "enterprise_chests"
local enterprise_isp = require "enterprise_isp"
local enterprise_shop = require "enterprise_shop"
local enterprise_storage = require "enterprise_storage"

local TestArrayTest = require "test_array_test"
local FieldValueEqualTest = require "field_value_equal_test"
local FieldValueTypeTest = require "field_value_type_test"

local T_Class = require "test.t_class"
local T_IInterface = require "test.t_i_interface"
local T_IObj = require "test.t_i_obj"
local T_Obj = require "test.t_obj"
local T_IItemSupplier = require "test.t_i_item_supplier"
local T_IItemDepot = require "test.t_i_item_depot"

local t_turtle = require "test.t_turtle"

function T_Silo.T_All()
    -- initialisation
    T_Silo.T__init()
    T_Silo.T_new()

    -- IObj methods
    T_Silo.T_IObj_All()

    -- IMObj methods
    T_Silo.T_IsInstanceOf_IMObj()
    T_Silo.T_Implements_IMObj()
    T_Silo.T_destruct()
    T_Silo.T_construct()

    -- IItemSupplier methods
    T_Silo.T_IItemSupplier_All()

    -- IItemDepot methods
    T_Silo.T_IItemDepot_All()
end

local testClassName = "Silo"
local testObjName = "silo"
local logOk = false
local baseLocation1  = Location:newInstance(12, -12, 1, 0, 1)
local entryLocation1 = baseLocation1:getRelativeLocation(3, 3, 0)
local chestLocator1 = URL:newFromURI("ccwprp://enterprise_chests/objects/class=Chest/id="..coreutils.NewId())
local topChests1 = ObjArray:newInstance("URL", { chestLocator1 }) assert(topChests1, "Failed obtaining ObjArray")
local chestLocator2 = URL:newFromURI("ccwprp://enterprise_chests/objects/class=Chest/id="..coreutils.NewId())
local storageChests1 = ObjArray:newInstance("URL", { chestLocator2 }) assert(storageChests1, "Failed obtaining ObjArray")

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_Silo.CreateTestObj(id, baseLocation, entryLocation, topChests, storageChests)
    -- check input
    id = id or coreutils.NewId()
    baseLocation = baseLocation or baseLocation1
    entryLocation = entryLocation or entryLocation1
    topChests = topChests or topChests1
    storageChests = storageChests or storageChests1

    -- create testObj
    local testObj = Silo:newInstance(id, baseLocation:copy(), entryLocation:copy(), 0, 0, topChests:copy(), storageChests:copy())

    -- end
    return testObj
end

function T_Silo.CreateInitialisedTest(id, baseLocation, entryLocation, topChests, storageChests)
    -- check input

    -- create test
    local idTest = FieldValueTypeTest:newInstance("_id", "string") -- note: allow for testing only the type (instead of also the value)
    if id then idTest = FieldValueEqualTest:newInstance("_id", id) end
    local test = TestArrayTest:newInstance(
        idTest,
        FieldValueEqualTest:newInstance("_baseLocation", baseLocation),
        FieldValueEqualTest:newInstance("_entryLocation", entryLocation),
        FieldValueEqualTest:newInstance("_dropLocation", 0),
        FieldValueEqualTest:newInstance("_pickupLocation", 0),
        FieldValueEqualTest:newInstance("_topChests", topChests),
        FieldValueEqualTest:newInstance("_storageChests", storageChests)
    )

    -- end
    return test
end

function T_Silo.T__init()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":_init() tests")
    local id = coreutils.NewId()

    -- test
    local obj = T_Silo.CreateTestObj(id, baseLocation1, entryLocation1, topChests1, storageChests1) assert(obj, "Failed obtaining "..testClassName)
    local test = T_Silo.CreateInitialisedTest(id, baseLocation1, entryLocation1, topChests1, storageChests1)
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
        _baseLocation   = baseLocation1:copy(),
        _entryLocation  = entryLocation1:copy(),

        -- pickup and drop
        _dropLocation   = 0,
        _pickupLocation = 0,

        -- chests
        _topChests      = topChests1:copy(),
        _storageChests  = storageChests1:copy(),
    })
    local test = T_Silo.CreateInitialisedTest(id, baseLocation1, entryLocation1, topChests1, storageChests1)
    test:test(obj, testObjName, "", logOk)
end

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
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

--    _____ __  __  ____  _     _                  _   _               _
--   |_   _|  \/  |/ __ \| |   (_)                | | | |             | |
--     | | | \  / | |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | | | |\/| | |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| |_| |  | | |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____|_|  |_|\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                            _/ |
--                           |__/

function T_Silo.T_IsInstanceOf_IMObj()
    -- prepare test
    local obj = T_Silo.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

    -- test
    T_Class.pt_IsInstanceOf(testClassName, obj, "IMObj", IMObj)
end

function T_Silo.T_Implements_IMObj()
    -- prepare test
    local obj = T_Silo.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

    -- test
    T_IInterface.pt_ImplementsInterface("IMObj", IMObj, testClassName, obj)
end

function T_Silo.T_destruct()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":destruct() tests")
    local obj = Silo:construct({
        baseLocation    = baseLocation1,
        topChests       = 0,
        layers          = 0,
    }) assert(obj, "Failed obtaining obj")

    -- test
    local destructSuccess = obj:destruct()
    assert(destructSuccess, testClassName..":destruct not a success")
end

function T_Silo.T_construct()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":construct() tests")
    local topChests1 = 4
    local layers1 = 3

    -- test
    local obj = Silo:construct({
        baseLocation    = baseLocation1,
        topChests       = topChests1,
        layers          = layers1,
    }) assert(obj, "Failed obtaining obj")
    assert(obj:getBaseLocation():isEqual(baseLocation1), "gotten getBaseLocation(="..textutils.serialize(obj:getBaseLocation(), compact)..") not the same as expected(="..textutils.serialize(baseLocation1, compact)..")")
    assert(obj._topChests:nObjs() == topChests1, " # topChests(="..obj._topChests:nObjs()..") not the same as expected(="..topChests1..")")
    assert(obj._storageChests:nObjs() == layers1*4, " # storageChests(="..obj._storageChests:nObjs()..") not the same as expected(="..4*layers1..")")
    obj:destruct()

    -- test default
    obj = Silo:construct({
        baseLocation    = baseLocation1,
    }) assert(obj, "Failed obtaining obj")
    assert(obj:getBaseLocation():isEqual(baseLocation1), "gotten getBaseLocation(="..textutils.serialize(obj:getBaseLocation(), compact)..") not the same as expected(="..textutils.serialize(baseLocation1, compact)..")")
    assert(obj._topChests:nObjs() == 2, " # topChests(="..obj._topChests:nObjs()..") not the same as expected(=2)")
    assert(obj._storageChests:nObjs() == 2*4, " # storageChests(="..obj._storageChests:nObjs()..") not the same as expected(=8)")
    obj:destruct()

    -- cleanup test
end

--                        _                           _   _               _
--                       (_)                         | | | |             | |
--    ___  ___ _ ____   ___  ___ ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \  __/ |   \ V /| | (_|  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/\___|_|    \_/ |_|\___\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

function T_Silo.T_integrity()
    -- do the new test
    corelog.WriteToLog("* Silo:construct() tests")
    local obj = Silo:construct({baseLocation=baseLocation1, topChests=2, layers=2}) assert(obj, "Failed obtaining "..testClassName)
    local siloLocator = enterprise_storage:saveObject(obj)

    obj:IntegretyCheck()
end

--    _____ _____ _                  _____                   _ _                            _   _               _
--   |_   _|_   _| |                / ____|                 | (_)                          | | | |             | |
--     | |   | | | |_ ___ _ __ ___ | (___  _   _ _ __  _ __ | |_  ___ _ __   _ __ ___   ___| |_| |__   ___   __| |___
--     | |   | | | __/ _ \ '_ ` _ \ \___ \| | | | '_ \| '_ \| | |/ _ \ '__| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| |_ _| |_| ||  __/ | | | | |____) | |_| | |_) | |_) | | |  __/ |    | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____|_____|\__\___|_| |_| |_|_____/ \__,_| .__/| .__/|_|_|\___|_|    |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                                              | |   | |
--                                              |_|   |_|

function T_Silo.T_IItemSupplier_All()
    -- prepare test
    local obj = T_Silo.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

    -- test
    T_Class.pt_IsInstanceOf(testClassName, obj, "IItemSupplier", IItemSupplier)
    T_IInterface.pt_ImplementsInterface("IItemSupplier", IItemSupplier, testClassName, obj)
end

local function provideItemsTo_AOSrv_Test(provideItems)
    -- prepare test (cont)
    corelog.WriteToLog("* Silo:provideItemsTo_AOSrv() test (of "..textutils.serialize(provideItems, compact)..")")
    local obj = Silo:construct({baseLocation=baseLocation1, topChests=2, layers=2}) assert(obj, "Failed obtaining "..testClassName)

    -- activate the silo
    obj:Activate()

    local siloLocator = enterprise_storage:getObjectLocator(obj)
    local itemDepotLocator = t_turtle.GetCurrentTurtleLocator() assert(itemDepotLocator, "Failed obtaining itemDepotLocator")

    local expectedDestinationItemsLocator = itemDepotLocator:copy()
    expectedDestinationItemsLocator:setQuery(provideItems)
    local callback = Callback:newInstance("T_Silo", "provideItemsTo_AOSrv_Callback", {
        ["expectedDestinationItemsLocator"] = expectedDestinationItemsLocator,
        ["siloLocator"]                     = siloLocator,
    })

    -- test
    local scheduleResult = obj:provideItemsTo_AOSrv({
        provideItems                    = provideItems,
        itemDepotLocator                = itemDepotLocator,
    }, callback)
    assert(scheduleResult == true, "failed to schedule async service")
end

function T_Silo.provideItemsTo_AOSrv_Callback(callbackData, serviceResults)
    -- test (cont)
    assert(serviceResults.success, "failed executing async service")

    local destinationItemsLocator = URL:new(serviceResults.destinationItemsLocator)
    local expectedDestinationItemsLocator = URL:new(callbackData["expectedDestinationItemsLocator"])
    assert(destinationItemsLocator:isEqual(expectedDestinationItemsLocator), "gotten destinationItemsLocator(="..textutils.serialize(destinationItemsLocator, compact)..") not the same as expected(="..textutils.serialize(expectedDestinationItemsLocator, compact)..")")

    -- cleanup test
    local siloLocator = callbackData["siloLocator"]
    enterprise_storage:deleteResource(siloLocator)

    -- end
    return true
end

function T_Silo.T_ProvideMultipleItems()
    -- prepare test
    local provideItems = {
        ["minecraft:birch_planks"]  = 5,
        ["minecraft:birch_log"]     = 3,
        ["minecraft:coal"]          = 7,
    }

    -- test
    provideItemsTo_AOSrv_Test(provideItems)
end

--    _____ _____ _                 _____                   _                    _   _               _
--   |_   _|_   _| |               |  __ \                 | |                  | | | |             | |
--     | |   | | | |_ ___ _ __ ___ | |  | | ___ _ __   ___ | |_   _ __ ___   ___| |_| |__   ___   __| |___
--     | |   | | | __/ _ \ '_ ` _ \| |  | |/ _ \ '_ \ / _ \| __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| |_ _| |_| ||  __/ | | | | | |__| |  __/ |_) | (_) | |_  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____|_____|\__\___|_| |_| |_|_____/ \___| .__/ \___/ \__| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
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
    local itemsLocator = t_turtle.GetCurrentTurtleLocator() assert(itemsLocator, "Failed obtaining itemsLocator")
    local obj = Silo:construct({baseLocation=baseLocation1, topChests=2, layers=2}) assert(obj, "Failed obtaining "..testClassName)
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
--    silo:IntegretyCheck()

    -- usefull if this silo is active
    silo:Activate()

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
    silo:provideItemsTo_AOSrv({provideItems = provideItems, itemDepotLocator = t_turtle.GetCurrentTurtleLocator()}, Callback.GetNewDummyCallBack())
 ]]
--[[
    -- da silo
    local daSilo    = silo:getObjectLocator()

    -- da shop
    local daShop = enterprise_shop.GetShopLocator()             assert(daShop, "Oops")
    local daTurtle = t_turtle.GetCurrentTurtleLocator()         assert(daTurtle, "Oops")
    local turtleLocator = daTurtle.GetCurrentTurtleLocator()
    local daCallback = Callback.GetNewDummyCallBack()

    -- da command
    --enterprise_isp.ProvideItemsTo_ASrv(...)

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
