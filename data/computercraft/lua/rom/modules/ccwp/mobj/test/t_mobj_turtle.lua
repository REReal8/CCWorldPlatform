local T_Turtle = {}

local corelog = require "corelog"
local coreutils = require "coreutils"

local IItemSupplier = require "i_item_supplier"
local IItemDepot = require "i_item_depot"
local IObj = require "i_obj"
local ObjBase = require "obj_base"
local Callback = require "obj_callback"
local Location = require "obj_location"
local URL = require "obj_url"

local Turtle = require "mobj_turtle"

local enterprise_turtle = require "enterprise_turtle"
local enterprise_chests = require "enterprise_chests"

local T_Class = require "test.t_class"
local T_IInterface = require "test.t_i_interface"
local T_IObj = require "test.t_i_obj"
local T_Chest = require "test.t_mobj_chest"

local t_turtle = require "test.t_turtle"

function T_Turtle.T_All()
    -- initialisation
    T_Turtle.T_Getters()

    -- IObj methods
    T_Turtle.T_IObj_All()

    -- IItemSupplier methods
    T_Turtle.T_IItemSupplier_All()
--    T_Turtle.T_needsTo_ProvideItemsTo_SOSrv()
--    T_Turtle.T_can_ProvideItems_QOSrv()

    -- IItemDepot methods
    T_Turtle.T_IItemDepot_All()
end

local testClassName = "Turtle"
local fuelPriorityKey1 = ""
local fuelPriorityKey2 = "99:111"
local location2  = Location:newInstance(-6, 6, 1, 0, 1)

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_Turtle.CreateTestObj(id, fuelPriorityKey)
    -- check input
    id = id or tostring(os.getComputerID())
    fuelPriorityKey = fuelPriorityKey or fuelPriorityKey1

    -- create Turtle object
    local turtle = Turtle:new({
        _id                     = id,
        _fuelPriorityKey        = fuelPriorityKey,
    })

    -- end
    return turtle
end

function T_Turtle.T_Getters()
    -- prepare test
    corelog.WriteToLog("* Turtle getter tests")
    local turtleId = 111
    local id = tostring(turtleId)
    local className = "Turtle"
    local objTurtle = T_Turtle.CreateTestObj(id, fuelPriorityKey2) if not objTurtle then corelog.Error("Failed obtaining Turtle") return end

    -- test
    assert(objTurtle:getClassName() == className, "gotten className(="..objTurtle:getClassName()..") not the same as expected(="..className..")")
    assert(objTurtle:getId() == id, "gotten getId(="..objTurtle:getId()..") not the same as expected(="..id..")")
    assert(objTurtle:getTurtleId() == turtleId, "gotten getTurtleId(="..objTurtle:getTurtleId()..") not the same as expected(="..turtleId..")")
    assert(objTurtle:getFuelPriorityKey() == fuelPriorityKey2, "gotten getFuelPriorityKey(="..objTurtle:getFuelPriorityKey() ..") not the same as expected(="..fuelPriorityKey2..")")
--    local expectedInventory = -- ToDo: consider testing the inventory is correctly obtained
--    assert(objTurtle:getInventory():isEqual(expectedInventory), "gotten getInventory(="..textutils.serialize(objTurtle:getInventory(), compact)..") not the same as expected(="..textutils.serialize(expectedInventory, compact)..")")

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

function T_Turtle.T_IObj_All()
    -- prepare test
    local id = coreutils.NewId()
    local obj = T_Turtle.CreateTestObj(id) assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_Turtle.CreateTestObj(id) assert(otherObj, "Failed obtaining "..testClassName)

    -- test
    T_Class.pt_IsInstanceOf(testClassName, obj, "IObj", IObj)
    T_Class.pt_IsInstanceOf(testClassName, obj, "ObjBase", ObjBase)
    T_IObj.pt_all(testClassName, obj, otherObj)
end

--                        _                           _   _               _
--                       (_)                         | | | |             | |
--    ___  ___ _ ____   ___  ___ ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \  __/ |   \ V /| | (_|  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/\___|_|    \_/ |_|\___\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

--    _____ _____ _                  _____                   _ _                            _   _               _
--   |_   _|_   _| |                / ____|                 | (_)                          | | | |             | |
--     | |   | | | |_ ___ _ __ ___ | (___  _   _ _ __  _ __ | |_  ___ _ __   _ __ ___   ___| |_| |__   ___   __| |___
--     | |   | | | __/ _ \ '_ ` _ \ \___ \| | | | '_ \| '_ \| | |/ _ \ '__| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| |_ _| |_| ||  __/ | | | | |____) | |_| | |_) | |_) | | |  __/ |    | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____|_____|\__\___|_| |_| |_|_____/ \__,_| .__/| .__/|_|_|\___|_|    |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                                              | |   | |
--                                              |_|   |_|

function T_Turtle.T_IItemSupplier_All()
    -- prepare test
    local obj = T_Turtle.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

    -- test
    T_Class.pt_IsInstanceOf(testClassName, obj, "IItemSupplier", IItemSupplier)
    T_IInterface.pt_ImplementsInterface("IItemSupplier", IItemSupplier, testClassName, obj)
end

local function provideItemsTo_AOSrv_Test(itemDepotLocator, toStr)
    -- prepare test (cont)
    corelog.WriteToLog("* Turtle:provideItemsTo_AOSrv() test (to "..toStr..")")
    local objTurtle = T_Turtle.CreateTestObj() if not objTurtle then corelog.Error("Failed obtaining Turtle") return end
    local turtleLocator = enterprise_turtle:getTurtleLocator(tostring(objTurtle:getTurtleId()))

    local provideItems = {
        ["minecraft:birch_log"]  = 5,
    }
    local expectedDestinationItemsLocator = itemDepotLocator:copy()
    expectedDestinationItemsLocator:setQuery(provideItems)
    local callback = Callback:newInstance("T_Turtle", "provideItemsTo_AOSrv_Callback", {
        ["expectedDestinationItemsLocator"] = expectedDestinationItemsLocator,
        ["itemDepotLocator"]                = itemDepotLocator,
    })

    -- test
    local scheduleResult = objTurtle:provideItemsTo_AOSrv({
        provideItems    = provideItems,
        itemDepotLocator= itemDepotLocator,
    }, callback)
    assert(scheduleResult == true, "failed to schedule async service")
end

function T_Turtle.T_provideItemsTo_AOSrv_Turtle()
    -- prepare test
    local itemDepotLocator = t_turtle.GetCurrentTurtleLocator()

    -- test
    provideItemsTo_AOSrv_Test(itemDepotLocator, "Turtle")
end

function T_Turtle.T_provideItemsTo_AOSrv_Chest()
    -- prepare test
    local chest2 = T_Chest.CreateTestObj(nil, location2:getRelativeLocation(2, 5, 0)) assert(chest2, "Failed obtaining Chest 2")
    local itemDepotLocator = enterprise_chests:saveObject(chest2)

    -- test
    provideItemsTo_AOSrv_Test(itemDepotLocator, "Chest")
end

function T_Turtle.provideItemsTo_AOSrv_Callback(callbackData, serviceResults)
    -- test (cont)
    assert(serviceResults.success, "failed executing async service")

    local destinationItemsLocator = URL:new(serviceResults.destinationItemsLocator)
    local expectedDestinationItemsLocator = URL:new(callbackData["expectedDestinationItemsLocator"])
    assert(destinationItemsLocator:isEqual(expectedDestinationItemsLocator), "gotten destinationItemsLocator(="..textutils.serialize(destinationItemsLocator, compact)..") not the same as expected(="..textutils.serialize(expectedDestinationItemsLocator, compact)..")")

    -- cleanup test
    local itemDepotLocator = callbackData["itemDepotLocator"]
    if enterprise_chests:isLocatorFromHost(itemDepotLocator) then
        enterprise_chests:deleteResource(itemDepotLocator)
    end

    -- end
    return true
end

--    _____ _____ _                 _____                   _                    _   _               _
--   |_   _|_   _| |               |  __ \                 | |                  | | | |             | |
--     | |   | | | |_ ___ _ __ ___ | |  | | ___ _ __   ___ | |_   _ __ ___   ___| |_| |__   ___   __| |___
--     | |   | | | __/ _ \ '_ ` _ \| |  | |/ _ \ '_ \ / _ \| __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| |_ _| |_| ||  __/ | | | | | |__| |  __/ |_) | (_) | |_  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____|_____|\__\___|_| |_| |_|_____/ \___| .__/ \___/ \__| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                                             | |
--                                             |_|

function T_Turtle.T_IItemDepot_All()
    -- prepare test
    local obj = T_Turtle.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)

    -- test
    T_Class.pt_IsInstanceOf(testClassName, obj, "IItemDepot", IItemDepot)
    T_IInterface.pt_ImplementsInterface("IItemDepot", IItemDepot, testClassName, obj)
end

local function storeItemsFrom_AOSrv_Test(itemsLocator, toStr)
    -- prepare test (cont)
    corelog.WriteToLog("* Turtle:storeItemsFrom_AOSrv() test (to "..toStr..")")
    local objTurtle = T_Turtle.CreateTestObj() if not objTurtle then corelog.Error("Failed obtaining Turtle") return end
    local turtleLocator = enterprise_turtle:getTurtleLocator(tostring(objTurtle:getTurtleId())) assert(turtleLocator, "Failed obtaining locator for "..testClassName)

    local provideItems = {
        ["minecraft:birch_log"]  = 5,
    }
    itemsLocator:setQuery(provideItems)

    local expectedDestinationItemsLocator = turtleLocator:copy()
    expectedDestinationItemsLocator:setQuery(provideItems)
    local callback = Callback:newInstance("T_Turtle", "storeItemsFrom_AOSrv_Callback", {
        ["expectedDestinationItemsLocator"] = expectedDestinationItemsLocator,
        ["itemsLocator"]                    = itemsLocator:copy(),
    })

    -- test
    local scheduleResult = objTurtle:storeItemsFrom_AOSrv({
        itemsLocator    = itemsLocator,
    }, callback)
    assert(scheduleResult == true, "failed to schedule async service")
end

function T_Turtle.T_storeItemsFrom_AOSrv_Turtle()
    -- prepare test
    local itemsLocator = t_turtle.GetCurrentTurtleLocator()

    -- test
    storeItemsFrom_AOSrv_Test(itemsLocator, "Turtle")
end

function T_Turtle.T_storeItemsFrom_AOSrv_Chest()
    -- prepare test
    local chest2 = T_Chest.CreateTestObj(nil, location2:getRelativeLocation(2, 5, 0)) assert(chest2, "Failed obtaining Chest 2")
    local itemsLocator = enterprise_chests:saveObject(chest2)

    -- test
    storeItemsFrom_AOSrv_Test(itemsLocator, "Chest")
end

function T_Turtle.storeItemsFrom_AOSrv_Callback(callbackData, serviceResults)
    -- test (cont)
    assert(serviceResults.success, "failed executing async service")

    local destinationItemsLocator = URL:new(serviceResults.destinationItemsLocator)
    local expectedDestinationItemsLocator = URL:new(callbackData["expectedDestinationItemsLocator"])
    assert(destinationItemsLocator:isEqual(expectedDestinationItemsLocator), "gotten destinationItemsLocator(="..textutils.serialize(destinationItemsLocator, compact)..") not the same as expected(="..textutils.serialize(expectedDestinationItemsLocator, compact)..")")

    -- cleanup test
    local itemsLocator = callbackData["itemsLocator"]
    if enterprise_chests:isLocatorFromHost(itemsLocator) then
        enterprise_chests:deleteResource(itemsLocator)
    end

    -- end
    return true
end

function T_Turtle.T_needsTo_ProvideItemsTo_SOSrv()
    -- ToDo: consider implementing later similair to Chest tests. Now left out because Turtle inventory dependends on... well the Turtle
    -- prepare test

    -- test

    -- cleanup test
end

function T_Turtle.T_can_ProvideItems_QOSrv()
    -- ToDo: consider implementing later similair to Chest tests. Now left out because Turtle inventory dependends on... well the Turtle
    -- prepare test

    -- test

    -- cleanup test
end

return T_Turtle
