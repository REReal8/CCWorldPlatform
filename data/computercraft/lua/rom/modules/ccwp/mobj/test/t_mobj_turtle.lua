local T_Turtle = {}
local corelog = require "corelog"

local Callback = require "obj_callback"
local ModuleRegistry = require "module_registry"
local moduleRegistry = ModuleRegistry:getInstance()

local Location = require "obj_location"
local URL = require "obj_url"

local Turtle = require "mobj_turtle"

local enterprise_turtle = require "enterprise_turtle"
local enterprise_chests = require "enterprise_chests"

local T_Obj = require "test.t_obj"
local T_Chest = require "test.t_mobj_chest"

local t_turtle = require "test.t_turtle"

function T_Turtle.T_All()
    -- initialisation
    T_Turtle.T_Getters()

    -- IObj methods
    T_Turtle.T_ImplementsIObj()
    T_Turtle.T_isTypeOf()
    T_Turtle.T_isEqual()
    T_Turtle.T_copy()

    -- IItemSupplier methods
    T_Turtle.T_ImplementsIItemSupplier()
--    T_Turtle.T_needsTo_ProvideItemsTo_SOSrv()
--    T_Turtle.T_can_ProvideItems_QOSrv()

    -- IItemDepot methods
    T_Turtle.T_ImplementsIItemDepot()
end

local fuelPriorityKey1 = ""
local fuelPriorityKey2 = "99:111"
local location2  = Location:new({_x= -6, _y= 6, _z= 1, _dx=0, _dy=1})

local compact = { compact = true }

--    _       _             __
--   (_)     | |           / _|
--    _ _ __ | |_ ___ _ __| |_ __ _  ___ ___  ___
--   | | '_ \| __/ _ \ '__|  _/ _` |/ __/ _ \/ __|
--   | | | | | ||  __/ |  | || (_| | (_|  __/\__ \
--   |_|_| |_|\__\___|_|  |_| \__,_|\___\___||___/

local function ImplementsInterface(interfaceName)
    -- prepare test
    corelog.WriteToLog("* Turtle "..interfaceName.." interface test")
    local Interface = moduleRegistry:getModule(interfaceName)
    local obj = T_Turtle.CreateTurtle() if not obj then corelog.Error("failed obtaining Turtle") return end

    -- test
    local implementsInterface = Interface.ImplementsInterface(obj)
    assert(implementsInterface, "Turtle class does not (fully) implement "..interfaceName.." interface")

    -- cleanup test
end

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_Turtle.T_Getters()
    -- prepare test
    corelog.WriteToLog("* Turtle getter tests")
    local turtleId = 111
    local id = tostring(turtleId)
    local className = "Turtle"
    local objTurtle = T_Turtle.CreateTurtle(id, fuelPriorityKey2) if not objTurtle then corelog.Error("failed obtaining Turtle") return end

    -- test
    assert(objTurtle:getClassName() == className, "gotten className(="..objTurtle:getClassName()..") not the same as expected(="..className..")")
    assert(objTurtle:getId() == id, "gotten getId(="..objTurtle:getId()..") not the same as expected(="..id..")")
    assert(objTurtle:getTurtleId() == turtleId, "gotten getTurtleId(="..objTurtle:getTurtleId()..") not the same as expected(="..turtleId..")")
    assert(objTurtle:getFuelPriorityKey() == fuelPriorityKey2, "gotten getFuelPriorityKey(="..objTurtle:getFuelPriorityKey() ..") not the same as expected(="..fuelPriorityKey2..")")
--    local expectedInventory = -- ToDo: consider testing the inventory is correctly obtained
--    assert(objTurtle:getInventory():isEqual(expectedInventory), "gotten getInventory(="..textutils.serialize(objTurtle:getInventory(), compact)..") not the same as expected(="..textutils.serialize(expectedInventory, compact)..")")

    -- cleanup test
end

function T_Turtle.CreateTurtle(id, fuelPriorityKey)
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

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

function T_Turtle.T_ImplementsIObj()
    ImplementsInterface("IObj")
end

function T_Turtle.T_isTypeOf()
    -- prepare test
    corelog.WriteToLog("* Turtle:isTypeOf() tests")
    local obj = T_Turtle.CreateTurtle() if not obj then corelog.Error("failed obtaining Turtle") return end

    -- test valid
    local isTypeOf = Turtle:isTypeOf(obj)
    local expectedIsTypeOf = true
    assert(isTypeOf == expectedIsTypeOf, "gotten isTypeOf(="..tostring(isTypeOf)..") not the same as expected(="..tostring(expectedIsTypeOf)..")")

    -- test different object
    isTypeOf = Turtle:isTypeOf("a atring")
    expectedIsTypeOf = false
    assert(isTypeOf == expectedIsTypeOf, "gotten isTypeOf(="..tostring(isTypeOf)..") not the same as expected(="..tostring(expectedIsTypeOf)..")")

    -- cleanup test
end

function T_Turtle.T_isEqual()
    -- prepare test
    corelog.WriteToLog("* Turtle:isEqual() tests")
    local id = "333"
    local obj = T_Turtle.CreateTurtle(id) if not obj then corelog.Error("failed obtaining Turtle") return end

    -- test same
    local obj1 = T_Turtle.CreateTurtle(id)
    local isEqual = obj1:isEqual(obj)
    local expectedIsEqual = true
    assert(isEqual == expectedIsEqual, "gotten isEqual(="..tostring(isEqual)..") not the same as expected(="..tostring(expectedIsEqual)..")")

    -- test different _fuelPriorityKey
    obj._fuelPriorityKey = fuelPriorityKey2
    isEqual = obj1:isEqual(obj)
    expectedIsEqual = false
    assert(isEqual == expectedIsEqual, "gotten isEqual(="..tostring(isEqual)..") not the same as expected(="..tostring(expectedIsEqual)..")")
    obj._fuelPriorityKey = fuelPriorityKey1

    -- cleanup test
end

function T_Turtle.T_copy()
    -- prepare test
    corelog.WriteToLog("* Turtle:copy() tests")
    local objTurtle = T_Turtle.CreateTurtle() if not objTurtle then corelog.Error("failed obtaining Turtle") return end

    -- test
    local copy = objTurtle:copy()
    assert(copy:isEqual(objTurtle), "gotten copy(="..textutils.serialize(copy, compact)..") not the same as expected(="..textutils.serialize(objTurtle, compact)..")")

    -- cleanup test
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

function T_Turtle.T_ImplementsIItemSupplier()
    ImplementsInterface("IItemSupplier")
end

local function provideItemsTo_AOSrv_Test(itemDepotLocator, toStr)
    -- prepare test (cont)
    corelog.WriteToLog("* Turtle:provideItemsTo_AOSrv() test (to "..toStr..")")
    local objTurtle = T_Turtle.CreateTurtle() if not objTurtle then corelog.Error("failed obtaining Turtle") return end
    local turtleLocator = enterprise_turtle:getTurtleLocator(tostring(objTurtle:getTurtleId()))

    local provideItems = {
        ["minecraft:birch_log"]  = 5,
    }
    local expectedDestinationItemsLocator = itemDepotLocator:copy()
    expectedDestinationItemsLocator:setQuery(provideItems)
    local callback = Callback:new({
        _moduleName     = "T_Turtle",
        _methodName     = "provideItemsTo_AOSrv_Callback",
        _data           = {
            ["expectedDestinationItemsLocator"] = expectedDestinationItemsLocator,
            ["itemDepotLocator"]                = itemDepotLocator,
        },
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
    local chest2 = T_Obj.createObjFromTable("Chest", T_Chest.NewOTable(location2:getRelativeLocation(2, 5, 0))) assert(chest2, "failed obtaining Chest 2")
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

function T_Turtle.T_ImplementsIItemDepot()
    ImplementsInterface("IItemDepot")
end

local function storeItemsFrom_AOSrv_Test(itemsLocator, toStr)
    -- prepare test (cont)
    corelog.WriteToLog("* Turtle:storeItemsFrom_AOSrv() test (to "..toStr..")")
    local objTurtle = T_Turtle.CreateTurtle() if not objTurtle then corelog.Error("failed obtaining Turtle") return end
    local turtleLocator = enterprise_turtle:getTurtleLocator(tostring(objTurtle:getTurtleId()))

    local provideItems = {
        ["minecraft:birch_log"]  = 5,
    }
    itemsLocator:setQuery(provideItems)

    local expectedDestinationItemsLocator = turtleLocator:copy()
    expectedDestinationItemsLocator:setQuery(provideItems)
    local callback = Callback:new({
        _moduleName     = "T_Turtle",
        _methodName     = "storeItemsFrom_AOSrv_Callback",
        _data           = {
            ["expectedDestinationItemsLocator"] = expectedDestinationItemsLocator,
            ["itemsLocator"]                    = itemsLocator:copy(),
        },
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
    local chest2 = T_Obj.createObjFromTable("Chest", T_Chest.NewOTable(location2:getRelativeLocation(2, 5, 0))) assert(chest2, "failed obtaining Chest 2")
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