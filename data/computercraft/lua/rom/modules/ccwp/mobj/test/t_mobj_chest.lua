local T_Chest = {}
local corelog = require "corelog"
local coreutils = require "coreutils"
local coremove = require "coremove"

local role_fuel_worker = require "role_fuel_worker"

local Callback = require "obj_callback"

local IObj = require "i_obj"
local ObjBase = require "obj_base"
local Location = require "obj_location"
local Inventory = require "obj_inventory"
local URL = require "obj_url"

local Chest = require "mobj_chest"

local enterprise_chests = require "enterprise_chests"

local T_Object = require "test.t_object"
local T_IObj = require "test.t_i_obj"
local T_Obj = require "test.t_obj"
local T_IItemSupplier = require "test.t_i_item_supplier"
local T_IItemDepot = require "test.t_i_item_depot"

local t_turtle = require "test.t_turtle"

function T_Chest.T_All()
    -- initialisation
    T_Chest.T_Getters()
    T_Chest.T_new()

    -- IObj methods
    T_Chest.T_IObj_All()

    -- IMObj methods
    T_Chest.T_ImplementsIMObj()
    T_Chest.T_destruct()
    T_Chest.T_construct()

    -- IItemSupplier methods
    T_Chest.T_ImplementsIItemSupplier()
    T_Chest.T_needsTo_ProvideItemsTo_SOSrv()
    T_Chest.T_can_ProvideItems_QOSrv()

    -- IItemDepot methods
    T_Chest.T_ImplementsIItemDepot()
end

local testClassName = "Chest"
local mobjHostName = "enterprise_chests"
local location1  = Location:new({_x= -6, _y= 0, _z= 1, _dx=0, _dy=1})
local location2  = Location:new({_x= -6, _y= 6, _z= 1, _dx=0, _dy=1})
local accessDirection1 = "top"
local emptyInventory = Inventory:new()
local inventory1 = Inventory:new() -- ToDo: add elements

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_Chest.NewOTable(baseLocation, accessDirection, inventory, id)
    -- check input
    baseLocation = baseLocation or location1
    id = id or coreutils.NewId()
    accessDirection = accessDirection or accessDirection1
    inventory = inventory or inventory1

    -- create new oTable
    local oTable = {
        _id                     = id,

        _baseLocation           = baseLocation:copy(),
        _accessDirection        = accessDirection,
        _inventory              = inventory:copy(),
    }

    -- end
    return oTable
end

function T_Chest.T_new()
    -- prepare test
    local oTable = T_Chest.NewOTable()

    -- test
    T_Obj.pt_new(testClassName, oTable)
end

function T_Chest.T_Getters()
    -- prepare test
    corelog.WriteToLog("* Chest getter tests")
    local id = coreutils.NewId()
    local obj = T_Obj.createObjFromTable(testClassName, T_Chest.NewOTable(location1, accessDirection1, inventory1, id)) assert(obj, "failed obtaining "..testClassName)

    -- test
    assert(obj:getId() == id, "gotten id(="..obj:getId()..") not the same as expected(="..id..")")
    assert(obj:getBaseLocation():isEqual(location1), "gotten getBaseLocation(="..textutils.serialize(obj:getBaseLocation())..") not the same as expected(="..textutils.serialize(location1)..")")
    assert(obj:getAccessDirection() == accessDirection1, "gotten getAccessDirection(="..obj:getAccessDirection()..") not the same as expected(="..accessDirection1..")")
    assert(obj:getInventory():isEqual(inventory1), "gotten getInventory(="..textutils.serialize(obj:getInventory(), compact)..") not the same as expected(="..textutils.serialize(inventory1, compact)..")")

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

function T_Chest.T_IObj_All()
    -- prepare test
    local id = coreutils.NewId()
    local obj = T_Obj.createObjFromTable(testClassName, T_Chest.NewOTable(location1, accessDirection1, inventory1, id)) assert(obj, "failed obtaining "..testClassName)
    local otherObj = T_Obj.createObjFromTable(testClassName, T_Chest.NewOTable(location1, accessDirection1, inventory1, id)) assert(otherObj, "failed obtaining "..testClassName)

    -- test
    T_Object.pt_IsInstanceOf(testClassName, obj, "IObj", IObj)
    T_Object.pt_IsInstanceOf(testClassName, obj, "ObjBase", ObjBase)
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

function T_Chest.T_ImplementsIMObj()
    -- prepare test
    local obj = T_Obj.createObjFromTable(testClassName, T_Chest.NewOTable()) assert(obj, "failed obtaining "..testClassName)

    -- test
    T_Obj.pt_ImplementsInterface("IMObj", testClassName, obj)
end

local constructParameters1 = {
    baseLocation    = location1,
    accessDirection = accessDirection1,
}

function T_Chest.T_construct()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":construct() tests")

    -- test
    local mobj = Chest:construct(constructParameters1)
    assert(mobj:getBaseLocation():isEqual(location1), "gotten getBaseLocation(="..textutils.serialize(mobj:getBaseLocation(), compact)..") not the same as expected(="..textutils.serialize(location1, compact)..")")
    assert(mobj:getAccessDirection() == accessDirection1, "gotten getAccessDirection(="..mobj:getAccessDirection()..") not the same as expected(="..accessDirection1..")")
    assert(mobj:getInventory():isEqual(emptyInventory), "gotten getInventory(="..textutils.serialize(mobj:getInventory(), compact)..") not the same as expected(="..textutils.serialize(emptyInventory, compact)..")")
end

function T_Chest.T_destruct()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":destruct() tests")
    local mobj = Chest:construct(constructParameters1)

    -- test
    local destructSuccess = mobj:destruct()
    assert(destructSuccess, testClassName..":destruct not a success")
end

--                        _                           _   _               _
--                       (_)                         | | | |             | |
--    ___  ___ _ ____   ___  ___ ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \  __/ |   \ V /| | (_|  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/\___|_|    \_/ |_|\___\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

function T_Chest.T_updateChestRecord_AOSrv()
    -- prepare test
    corelog.WriteToLog("* Chest:updateChestRecord_AOSrv test")
    local obj = T_Obj.createObjFromTable(testClassName, T_Chest.NewOTable(location1:getRelativeLocation(2, 5, 0))) assert(obj, "failed obtaining "..testClassName)
    local chestLocator = enterprise_chests:getObjectLocator(obj)

    local callback = Callback:new({
        _moduleName     = "T_Chest",
        _methodName     = "updateChestRecord_AOSrv_Callback",
        _data           = {
            ["chestLocator"]                    = chestLocator,
        },
    })

    -- test
    local scheduleResult = obj:updateChestRecord_AOSrv({}, callback)
    assert(scheduleResult == true, "failed to schedule async service")
end

function T_Chest.updateChestRecord_AOSrv_Callback(callbackData, serviceResults)
    -- test (cont)
    assert(serviceResults.success, "failed executing async service")
    local chestLocator = callbackData["chestLocator"]
    local updatedChest = enterprise_chests:getObject(chestLocator)
    assert (updatedChest, "Chest not saved")

    -- cleanup test
    enterprise_chests:deleteResource(chestLocator)

    -- end
    return true
end

--    _____ _____ _                  _____                   _ _                            _   _               _
--   |_   _|_   _| |                / ____|                 | (_)                          | | | |             | |
--     | |   | | | |_ ___ _ __ ___ | (___  _   _ _ __  _ __ | |_  ___ _ __   _ __ ___   ___| |_| |__   ___   __| |___
--     | |   | | | __/ _ \ '_ ` _ \ \___ \| | | | '_ \| '_ \| | |/ _ \ '__| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| |_ _| |_| ||  __/ | | | | |____) | |_| | |_) | |_) | | |  __/ |    | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____|_____|\__\___|_| |_| |_|_____/ \__,_| .__/| .__/|_|_|\___|_|    |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                                              | |   | |
--                                              |_|   |_|

function T_Chest.T_ImplementsIItemSupplier()
    -- prepare test
    local obj = T_Obj.createObjFromTable(testClassName, T_Chest.NewOTable()) assert(obj, "failed obtaining "..testClassName)

    -- test
    T_Obj.pt_ImplementsInterface("IItemSupplier", testClassName, obj)
end

function T_Chest.T_provideItemsTo_AOSrv_Turtle()
    -- prepare test
    local constructParameters = {
        baseLocation    = location1:getRelativeLocation(2, 5, 0),
        accessDirection = accessDirection1,
    }
    --note: as a test short cut we do not have to set the Inventory content here. We just assume the test Chest is present. FetchItemsFromChestIntoTurtle_Task should make sure the inventory is obtained

    local itemDepotLocator = t_turtle.GetCurrentTurtleLocator()

    local provideItems = {
        ["minecraft:birch_log"]  = 5,
    }

    -- test
    T_IItemSupplier.provideItemsTo_AOSrv_Test(mobjHostName, testClassName, constructParameters, provideItems, itemDepotLocator)
end

function T_Chest.T_provideItemsTo_AOSrv_Chest()
    -- prepare test
    local constructParameters = {
        baseLocation    = location1:getRelativeLocation(2, 5, 0),
        accessDirection = accessDirection1,
    }

    local obj2 = T_Obj.createObjFromTable(testClassName, T_Chest.NewOTable(location2:getRelativeLocation(2, 5, 0))) assert(obj2, "failed obtaining "..testClassName.." 2")
    local itemDepotLocator = enterprise_chests:saveObject(obj2)

    local provideItems = {
        ["minecraft:birch_log"]  = 5,
    }

    -- test
    T_IItemSupplier.provideItemsTo_AOSrv_Test(mobjHostName, testClassName, constructParameters, provideItems, itemDepotLocator)
end

function T_Chest.T_needsTo_ProvideItemsTo_SOSrv()
    -- prepare test
    corelog.WriteToLog("* Chest:needsTo_ProvideItemsTo_SOSrv() tests")
    local obj = T_Obj.createObjFromTable(testClassName, T_Chest.NewOTable()) assert(obj, "failed obtaining "..testClassName)
    local provideItems = {
        ["minecraft:birch_log"]  = 5,
    }
    local itemDepotLocator = t_turtle.GetCurrentTurtleLocator()
    local itemDepotLocation = Location:new(coremove.GetLocation())

    -- test
    local needsTo_Provide = obj:needsTo_ProvideItemsTo_SOSrv({
        provideItems    = provideItems,
        itemDepotLocator= itemDepotLocator,
    })
    local expectedFuelNeed = 1 * role_fuel_worker.NeededFuelToFrom(itemDepotLocation, obj:getBaseLocation())
    assert(needsTo_Provide.success, "needsTo_ProvideItemsTo_SOSrv failed")
    assert(needsTo_Provide.fuelNeed == expectedFuelNeed, "fuelNeed(="..needsTo_Provide.fuelNeed..") not the same as expected(="..expectedFuelNeed..")")
    assert(#needsTo_Provide.ingredientsNeed == 0, "ingredientsNeed(="..#needsTo_Provide.ingredientsNeed..") not the same as expected(=0)")

    -- cleanup test
end

function T_Chest.T_can_ProvideItems_QOSrv()
    -- prepare test
    corelog.WriteToLog("* Chest:can_ProvideItems_QOSrv() tests")
    local inventory = Inventory:new({
        _slotTable = {
            { name = "minecraft:dirt", count = 20 },
        }
    })
    local obj = T_Obj.createObjFromTable(testClassName, T_Chest.NewOTable(location1, accessDirection1, inventory)) assert(obj, "failed obtaining "..testClassName)

    -- test can
    local itemName = "minecraft:dirt"
    local itemCount = 10
    local serviceResults = obj:can_ProvideItems_QOSrv({ provideItems = { [itemName] = itemCount} })
    assert(serviceResults.success, "can_ProvideItems_QOSrv incorrectly failed for "..itemCount.." "..itemName.."'s")

    -- test can not
    itemName = "minecraft:furnace"
    itemCount = 1
    serviceResults = obj:can_ProvideItems_QOSrv({ provideItems = { [itemName] = itemCount} })
    assert(not serviceResults.success, "can_ProvideItems_QOSrv incorrectly success for "..itemCount.." "..itemName.."'s")

    -- cleanup test
end

--    _____ _____ _                 _____                   _                    _   _               _
--   |_   _|_   _| |               |  __ \                 | |                  | | | |             | |
--     | |   | | | |_ ___ _ __ ___ | |  | | ___ _ __   ___ | |_   _ __ ___   ___| |_| |__   ___   __| |___
--     | |   | | | __/ _ \ '_ ` _ \| |  | |/ _ \ '_ \ / _ \| __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| |_ _| |_| ||  __/ | | | | | |__| |  __/ |_) | (_) | |_  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____|_____|\__\___|_| |_| |_|_____/ \___| .__/ \___/ \__| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                                             | |
--                                             |_|

function T_Chest.T_ImplementsIItemDepot()
    -- prepare test
    local obj = T_Obj.createObjFromTable(testClassName, T_Chest.NewOTable()) assert(obj, "failed obtaining "..testClassName)

    -- test
    T_Obj.pt_ImplementsInterface("IItemDepot", testClassName, obj)
end

local function storeItemsFrom_AOSrv_Test(itemsLocator, toStr)
    -- prepare test (cont)
    corelog.WriteToLog("* Chest:storeItemsFrom_AOSrv() test (to "..toStr..")")
    local obj = T_Obj.createObjFromTable(testClassName, T_Chest.NewOTable(location2:getRelativeLocation(2, 5, 0))) assert(obj, "failed obtaining "..testClassName)
    --note: as a test short cut we do not have to set the Inventory content here. We just assume the test Chest is present. FetchItemsFromChestIntoTurtle_Task should make sure the inventory is obtained
    local chestLocator = enterprise_chests:getObjectLocator(obj)

    local provideItems = {
        ["minecraft:birch_log"]  = 5,
    }
    itemsLocator:setQuery(provideItems)

    local expectedDestinationItemsLocator = chestLocator:copy()
    expectedDestinationItemsLocator:setQuery(provideItems)
    local callback = Callback:new({
        _moduleName     = "T_Chest",
        _methodName     = "storeItemsFrom_AOSrv_Callback",
        _data           = {
            ["expectedDestinationItemsLocator"] = expectedDestinationItemsLocator,
            ["chestLocator"]                    = chestLocator,
            ["itemsLocator"]                    = itemsLocator:copy(),
        },
    })

    -- test
    local scheduleResult = obj:storeItemsFrom_AOSrv({
        itemsLocator    = itemsLocator,
    }, callback)
    assert(scheduleResult == true, "failed to schedule async service")
end

function T_Chest.T_storeItemsFrom_AOSrv_Turtle()
    -- prepare test
    local itemsLocator = t_turtle.GetCurrentTurtleLocator()

    -- test
    storeItemsFrom_AOSrv_Test(itemsLocator, "Turtle")
end

function T_Chest.T_storeItemsFrom_AOSrv_Chest()
    -- prepare test
    local obj2 = T_Obj.createObjFromTable(testClassName, T_Chest.NewOTable(location2:getRelativeLocation(2, 5, 0))) assert(obj2, "failed obtaining "..testClassName.." 2")
    local itemsLocator = enterprise_chests:saveObject(obj2)

    -- test
    storeItemsFrom_AOSrv_Test(itemsLocator, "Chest")
end

function T_Chest.storeItemsFrom_AOSrv_Callback(callbackData, serviceResults)
    -- test (cont)
    assert(serviceResults.success, "failed executing async service")

    local destinationItemsLocator = URL:new(serviceResults.destinationItemsLocator)
    local expectedDestinationItemsLocator = URL:new(callbackData["expectedDestinationItemsLocator"])
    assert(destinationItemsLocator:isEqual(expectedDestinationItemsLocator), "gotten destinationItemsLocator(="..textutils.serialize(destinationItemsLocator, compact)..") not the same as expected(="..textutils.serialize(expectedDestinationItemsLocator, compact)..")")

    -- cleanup test
    local chestLocator = callbackData["chestLocator"]
    enterprise_chests:deleteResource(chestLocator)
    local itemsLocator = callbackData["itemsLocator"]
    if enterprise_chests:isLocatorFromHost(itemsLocator) then
        enterprise_chests:deleteResource(itemsLocator)
    end

    -- end
    return true
end

return T_Chest