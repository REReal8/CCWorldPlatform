local T_Silo = {}
local corelog = require "corelog"
local coreutils = require "coreutils"
local coredht = require "coredht"

local Callback = require "obj_callback"

local IObj = require "i_obj"
local ObjBase = require "obj_base"
local ObjArray = require "obj_array"
local Location = require "obj_location"
local URL = require "obj_url"

local Silo = require "mobj_silo"

local enterprise_chests = require "enterprise_chests"
local enterprise_storage = require "enterprise_storage"

local T_Object = require "test.t_object"
local T_IObj = require "test.t_i_obj"
local T_Obj = require "test.t_obj"
local T_IItemSupplier = require "test.t_i_item_supplier"
local T_IItemDepot = require "test.t_i_item_depot"

local t_turtle = require "test.t_turtle"

function T_Silo.T_All()
    -- initialisation
    T_Silo.T_new()

    -- IObj methods
    T_Silo.T_IObj_All()

    -- IMObj methods
    T_Silo.T_ImplementsIMObj()
    T_Silo.T_destruct()
    T_Silo.T_construct()

    -- IItemSupplier methods
    T_Silo.T_ImplementsIItemSupplier()

    -- IItemDepot methods
    T_Silo.T_ImplementsIItemDepot()
end

local location1  = Location:new({_x= 12, _y= 12, _z= 1, _dx=0, _dy=1})

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

local testClassName = "Silo"

function T_Silo.NewOTable(baseLocation, topChests, storageChests, id)
    -- check input
    baseLocation = baseLocation or location1

    topChests = topChests or ObjArray:new({ _objClassName = "URL", })
    storageChests = storageChests or ObjArray:new({ _objClassName = "URL", })

    id = id or coreutils.NewId()

    -- create new oTable
    local oTable  = {
        _id             = id,

        _version        = 1,

        -- locations
        _baseLocation   = baseLocation:copy(),
        _entryLocation  = baseLocation:getRelativeLocation(3, 3, 0),

        -- pickup and drop
        _dropLocation   = 0,
        _pickupLocation = 0,

        -- chests
        _topChests      = topChests:copy(),
        _storageChests  = storageChests:copy(),

        -- is this silo accepting requests?
        _operational    = false,
    }

    -- end
    return oTable
end

function T_Silo.T_new()
    -- prepare test
    local oTable = T_Silo.NewOTable()

    -- test
    T_Obj.pt_new(testClassName, oTable)
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
    local chestLocator1 = URL:newFromURI("ccwprp://enterprise_chests/objects/class=Chest/id="..coreutils.NewId())
    local topChests1 = ObjArray:new({ _objClassName = "URL", chestLocator1 }) assert(topChests1, "failed obtaining ObjArray")

    local chestLocator2 = URL:newFromURI("ccwprp://enterprise_chests/objects/class=Chest/id="..coreutils.NewId())
    local storageChests1 = ObjArray:new({ _objClassName = "URL", chestLocator2 }) assert(storageChests1, "failed obtaining ObjArray")
    local obj = T_Obj.createObjFromTable(testClassName, T_Silo.NewOTable(location1, topChests1:copy(), storageChests1:copy(), id)) assert(obj, "failed obtaining "..testClassName)
    local otherObj = T_Obj.createObjFromTable(testClassName, T_Silo.NewOTable(location1, topChests1:copy(), storageChests1:copy(), id)) assert(otherObj, "failed obtaining "..testClassName)

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

function T_Silo.T_ImplementsIMObj()
    -- prepare test
    local obj = T_Obj.createObjFromTable(testClassName, T_Silo.NewOTable()) assert(obj, "failed obtaining "..testClassName)

    -- test
    T_Obj.pt_ImplementsInterface("IMObj", testClassName, obj)
end

function T_Silo.T_destruct()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":destruct() tests")
    local mobj = Silo:construct({
        baseLocation    = location1,
        topChests       = 0,
        layers          = 0,
    })

    -- test
    local destructSuccess = mobj:destruct()
    assert(destructSuccess, testClassName..":destruct not a success")
end

function T_Silo.T_construct()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":construct() tests")
    local topChests1 = 4
    local layers1 = 3

    -- test
    local mobj = Silo:construct({
        baseLocation    = location1,
        topChests       = topChests1,
        layers          = layers1,
    })
    assert(mobj:getBaseLocation():isEqual(location1), "gotten getBaseLocation(="..textutils.serialize(mobj:getBaseLocation(), compact)..") not the same as expected(="..textutils.serialize(location1, compact)..")")
    assert(mobj._topChests:nObjs() == topChests1, " # topChests(="..mobj._topChests:nObjs()..") not the same as expected(="..topChests1..")")
    assert(mobj._storageChests:nObjs() == layers1*4, " # storageChests(="..mobj._storageChests:nObjs()..") not the same as expected(="..4*layers1..")")
    mobj:destruct()

    -- test default
    mobj = Silo:construct({
        baseLocation    = location1,
    })
    assert(mobj:getBaseLocation():isEqual(location1), "gotten getBaseLocation(="..textutils.serialize(mobj:getBaseLocation(), compact)..") not the same as expected(="..textutils.serialize(location1, compact)..")")
    assert(mobj._topChests:nObjs() == 2, " # topChests(="..mobj._topChests:nObjs()..") not the same as expected(=2)")
    assert(mobj._storageChests:nObjs() == 2*4, " # storageChests(="..mobj._storageChests:nObjs()..") not the same as expected(=8)")
    mobj:destruct()

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
    local obj = Silo:construct({baseLocation=location1, topChests=2, layers=2}) if not obj then corelog.Error("failed constructing Silo") return end
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

function T_Silo.T_ImplementsIItemSupplier()
    -- prepare test
    local obj = T_Obj.createObjFromTable(testClassName, T_Silo.NewOTable()) assert(obj, "failed obtaining "..testClassName)

    -- test
    T_Obj.pt_ImplementsInterface("IItemSupplier", testClassName, obj)
end

local function provideItemsTo_AOSrv_Test(provideItems)
    -- prepare test (cont)
    corelog.WriteToLog("* Silo:provideItemsTo_AOSrv() test (of "..textutils.serialize(provideItems, compact)..")")
    local obj = Silo:construct({baseLocation=location1, topChests=2, layers=2}) if not obj then corelog.Error("failed constructing Silo") return end

    -- activate the silo
    obj:Activate()

    local siloLocator = enterprise_storage:getObjectLocator(obj)
    local itemDepotLocator = t_turtle.GetCurrentTurtleLocator()

    local expectedDestinationItemsLocator = itemDepotLocator:copy()
    expectedDestinationItemsLocator:setQuery(provideItems)
    local callback2 = Callback:new({
        _moduleName     = "T_Silo",
        _methodName     = "provideItemsTo_AOSrv_Callback",
        _data           = {
            ["expectedDestinationItemsLocator"] = expectedDestinationItemsLocator,
            ["siloLocator"]                     = siloLocator,
        },
    })

    -- test
    local scheduleResult = obj:provideItemsTo_AOSrv({
        provideItems                    = provideItems,
        itemDepotLocator                = itemDepotLocator,
    }, callback2)
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

function T_Silo.T_ImplementsIItemDepot()
    -- prepare test
    local obj = T_Obj.createObjFromTable(testClassName, T_Silo.NewOTable()) assert(obj, "failed obtaining "..testClassName)

    -- test
    T_Obj.pt_ImplementsInterface("IItemDepot", testClassName, obj)
end

function T_Silo.T_storeItemsFrom_AOSrv()
    -- prepare test
    corelog.WriteToLog("* Silo:storeItemsFrom_AOSrv() test")
    local itemsLocator = t_turtle.GetCurrentTurtleLocator()
    local obj = Silo:construct({baseLocation=location1, topChests=2, layers=2}) if not obj then corelog.Error("failed constructing Silo") return end
    local siloLocator = enterprise_storage:saveObject(obj)

    local provideItems = {
        ["minecraft:birch_log"]  = 5,
        ["minecraft:birch_planks"]  = 2,
    }
    itemsLocator:setQuery(provideItems)

    local expectedDestinationItemsLocator = siloLocator:copy()
    expectedDestinationItemsLocator:setQuery(provideItems)
    local callback = Callback:new({
        _moduleName     = "T_Silo",
        _methodName     = "storeItemsFrom_AOSrv_Callback",
        _data           = {
            ["expectedDestinationItemsLocator"] = expectedDestinationItemsLocator,
            ["siloLocator"]                     = siloLocator,
            ["itemsLocator"]                    = itemsLocator:copy(),
        },
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
    if not data then return nil end
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

    -- prepare test
    local provideItems = {
        ["minecraft:birch_planks"]  = 5,
        ["minecraft:birch_log"]     = 3,
        ["minecraft:coal"]          = 7,
    }

    -- test
    silo:provideItemsTo_AOSrv({provideItems = provideItems, itemDepotLocator = t_turtle.GetCurrentTurtleLocator()}, Callback.GetNewDummyCallBack())
end

return T_Silo