local T_BirchForest = {}
local corelog = require "corelog"
local coreutils = require "coreutils"

local Callback = require "obj_callback"
local ModuleRegistry = require "module_registry"
local moduleRegistry = ModuleRegistry:getInstance()

local Location = require "obj_location"
local URL = require "obj_url"

local IObj = require "i_obj"
local ObjBase = require "obj_base"
local BirchForest = require "mobj_birchforest"

local role_forester = require "role_forester"

local enterprise_turtle = require "enterprise_turtle"
local enterprise_chests = require "enterprise_chests"
local enterprise_forestry = require "enterprise_forestry"

local T_Obj = require "test.t_obj" -- should be gone at some point
local T_Object = require "test.t_object"
local T_IObj = require "test.t_i_obj"

local t_turtle

function T_BirchForest.T_All()
    -- initialisation
    T_BirchForest.T_Getters()
    T_BirchForest.T_Setters()

    -- IObj methods
    T_BirchForest.T_IObj_All()

    -- service methods
    T_BirchForest.T_getFuelNeed_Harvest_Att()
    T_BirchForest.T_getFuelNeedExtraTree_Att()

    -- IItemSupplier methods
    T_BirchForest.T_ImplementsIItemSupplier()
    T_BirchForest.T_needsTo_ProvideItemsTo_SOSrv()
    T_BirchForest.T_can_ProvideItems_QOSrv()
end

local level0 = 0
local location1 = Location:new({_x= 0, _y= 0, _z= 1, _dx=0, _dy=1})
local nTrees = 1
local level2 = 1
local location2 = Location:new({_x= 6, _y= 12, _z= 1, _dx=0, _dy=1})
local nTrees2 = 2
local localLogsLocator
local localSaplingsLocator

--    _       _             __
--   (_)     | |           / _|
--    _ _ __ | |_ ___ _ __| |_ __ _  ___ ___  ___
--   | | '_ \| __/ _ \ '__|  _/ _` |/ __/ _ \/ __|
--   | | | | | ||  __/ |  | || (_| | (_|  __/\__ \
--   |_|_| |_|\__\___|_|  |_| \__,_|\___\___||___/

local function ImplementsInterface(interfaceName)
    -- prepare test
    corelog.WriteToLog("* BirchForest "..interfaceName.." interface test")
    local Interface = moduleRegistry:getModule(interfaceName)
    local obj = T_BirchForest.CreateForest() if not obj then corelog.Error("failed obtaining BirchForest") return end

    -- test
    local implementsInterface = Interface.ImplementsInterface(obj)
    assert(implementsInterface, "BirchForest class does not (fully) implement "..interfaceName.." interface")

    -- cleanup test
end

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

local testClassName = "BirchForest"
local function createTestObj(id)
    id = id or coreutils.NewId()
    local level = level0
    local localLogsLocator = enterprise_turtle.GetAnyTurtleLocator()
    local localSaplingsLocator = enterprise_turtle.GetAnyTurtleLocator()

    local testObj = BirchForest:new({
        _id                     = id,
        _level                  = level,

        _baseLocation           = location1:copy(),
        _nTrees                 = nTrees,

        _localLogsLocator       = localLogsLocator,
        _localSaplingsLocator   = localSaplingsLocator,
    })

    return testObj
end

function T_BirchForest.T_Getters()
    -- prepare test
    corelog.WriteToLog("* BirchForest getter tests")
    local id = coreutils.NewId()
    local className = "BirchForest"
    local forest = T_BirchForest.CreateForest(level0, location1, id) if not forest then corelog.Error("failed obtaining BirchForest") return end

    -- test
    assert(forest:getClassName() == className, "gotten className(="..forest:getClassName()..") not the same as expected(="..className..")")
    assert(forest:getId() == id, "gotten id(="..forest:getId()..") not the same as expected(="..id..")")
    assert(forest:getLevel() == level0, "gotten level(="..forest:getLevel()..") not the same as expected(="..level0..")")
    assert(forest:getBaseLocation():isEqual(location1), "gotten getBaseLocation(="..textutils.serialize(forest:getBaseLocation())..") not the same as expected(="..textutils.serialize(location1)..")")
    assert(forest:getNTrees() == nTrees, "gotten nTrees(="..forest:getNTrees()..") not the same as expected(="..nTrees..")")
    assert(forest:getLocalLogsLocator():isEqual(localLogsLocator), "gotten localLogsLocator(="..forest:getLocalLogsLocator():getURI()..") not the same as expected(="..localLogsLocator:getURI()..")")
    assert(forest:getLocalSaplingsLocator():isEqual(localSaplingsLocator), "gotten localSaplingsLocator(="..forest:getLocalSaplingsLocator():getURI()..") not the same as expected(="..localSaplingsLocator:getURI()..")")

    -- cleanup test
end

function T_BirchForest.CreateForest(level, baseLocation, id)
    -- check input
    level = level or level0
    baseLocation = baseLocation or location1
    id = id or coreutils.NewId()
    localLogsLocator = localLogsLocator or enterprise_turtle.GetAnyTurtleLocator()
    localSaplingsLocator = localSaplingsLocator or enterprise_turtle.GetAnyTurtleLocator()

    -- create forest object
    local forest = BirchForest:new({
        _id                     = id,
        _level                  = level,

        _baseLocation           = baseLocation:copy(),
        _nTrees                 = nTrees,

        _localLogsLocator       = localLogsLocator,
        _localSaplingsLocator   = localSaplingsLocator,
    })

    -- end
    return forest
end

function T_BirchForest.T_Setters()
    -- prepare test
    corelog.WriteToLog("* BirchForest setter tests")
    local forest = T_BirchForest.CreateForest() if not forest then corelog.Error("failed obtaining BirchForest") return end
    local localLogsLocator2 = enterprise_chests:hostMObj_SSrv({className="Chest",constructParameters={ baseLocation = location2:getRelativeLocation(2, 2, 0), }}).mobjLocator if not localLogsLocator2 then corelog.Error("failed registering Chest") return end
    local localSaplingsLocator2 = enterprise_chests:hostMObj_SSrv({className="Chest",constructParameters={ baseLocation = location2:getRelativeLocation(4, 2, 0), }}).mobjLocator if not localSaplingsLocator2 then corelog.Error("failed registering Chest") return end

    -- test
    forest:setLevel(level2)
    assert(forest:getLevel() == level2, "gotten level(="..forest:getLevel()..") not the same as expected(="..level2..")")
    forest:setLocation(location2)
    assert(forest:getBaseLocation():isEqual(location2), "gotten getBaseLocation(="..textutils.serialize(forest:getBaseLocation())..") not the same as expected(="..textutils.serialize(location2)..")")
    forest:setNTrees(nTrees2)
    assert(forest:getNTrees() == nTrees2, "gotten nTrees(="..forest:getNTrees()..") not the same as expected(="..nTrees2..")")
    forest:setLocalLogsLocator(localLogsLocator2)
    assert(forest:getLocalLogsLocator():isEqual(localLogsLocator2), "gotten localLogsLocator(="..forest:getLocalLogsLocator():getURI()..") not the same as expected(="..localLogsLocator2:getURI()..")")
    forest:setLocalSaplingsLocator(localSaplingsLocator2)
    assert(forest:getLocalSaplingsLocator():isEqual(localSaplingsLocator2), "gotten localLogsLocator(="..forest:getLocalSaplingsLocator():getURI()..") not the same as expected(="..localSaplingsLocator2:getURI()..")")

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
    local obj = createTestObj(id) assert(obj, "failed obtaining "..testClassName)
    local otherObj = createTestObj(id) assert(obj, "failed obtaining "..testClassName) assert(otherObj, "failed obtaining "..testClassName)

    -- test
    T_Object.pt_IsInstanceOf(testClassName, obj, "IObj", IObj)
    T_Object.pt_IsInstanceOf(testClassName, obj, "ObjBase", ObjBase)
    T_IObj.pt_all(testClassName, obj, otherObj)
end

local compact = { compact = true }

--                        _                           _   _               _
--                       (_)                         | | | |             | |
--    ___  ___ _ ____   ___  ___ ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \  __/ |   \ V /| | (_|  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/\___|_|    \_/ |_|\___\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

function T_BirchForest.T_getFuelNeed_Harvest_Att()
    -- prepare test
    corelog.WriteToLog("* BirchForest:getFuelNeed_Harvest_Att() tests")
    local forest = T_BirchForest.CreateForest() if not forest then corelog.Error("failed obtaining forest") return end

    -- test
    local fuelNeed = forest:getFuelNeed_Harvest_Att()
    local expectedFuelNeed = 36
    assert(fuelNeed == expectedFuelNeed, "gotten fuelNeed(="..fuelNeed..") for "..nTrees.."trees not the same as expected(="..expectedFuelNeed..")")

    forest:setNTrees(nTrees2)
    fuelNeed = forest:getFuelNeed_Harvest_Att()
    expectedFuelNeed = 2*36 + 2 * 6
    assert(fuelNeed == expectedFuelNeed, "gotten fuelNeed(="..fuelNeed..") for "..nTrees2.."trees not the same as expected(="..expectedFuelNeed..")")

    -- cleanup test
end

function T_BirchForest.T_getFuelNeedExtraTree_Att()
    -- prepare test
    corelog.WriteToLog("* BirchForest:getFuelNeedExtraTree_Att() tests")
    local forest = T_BirchForest.CreateForest() if not forest then corelog.Error("failed obtaining forest") return end

    -- test
    local fuelNeed = forest:getFuelNeedExtraTree_Att()
    local expectedFuelNeed = 36 + 2*6
    assert(fuelNeed == expectedFuelNeed, "gotten fuelNeed(="..fuelNeed..") for "..nTrees.."trees not the same as expected(="..expectedFuelNeed..")")

    forest:setNTrees(nTrees2)
    fuelNeed = forest:getFuelNeedExtraTree_Att()
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

function T_BirchForest.T_ImplementsIItemSupplier()
    ImplementsInterface("IItemSupplier")
end

function T_BirchForest.T_needsTo_ProvideItemsTo_SOSrv()
    -- prepare test
    corelog.WriteToLog("* BirchForest:needsTo_ProvideItemsTo_SOSrv() tests")
    local forest = T_BirchForest.CreateForest() if not forest then corelog.Error("failed obtaining forest") return end
    local provideItems = {
        ["minecraft:birch_log"]  = 5,
    }
    t_turtle = t_turtle or require "test.t_turtle"
    local itemDepotLocator = t_turtle.GetCurrentTurtleLocator()

    -- test
    local needsTo_Provide = forest:needsTo_ProvideItemsTo_SOSrv({
        provideItems    = provideItems,
        itemDepotLocator= itemDepotLocator,
    })
    local expectedFuelNeed = role_forester.FuelNeededPerRound(nTrees)
    assert(needsTo_Provide.success, "needsTo_ProvideItemsTo_SOSrv failed")
    assert(needsTo_Provide.fuelNeed == expectedFuelNeed, "fuelNeed(="..needsTo_Provide.fuelNeed..") not the same as expected(="..expectedFuelNeed..")")
    assert(#needsTo_Provide.ingredientsNeed == 0, "ingredientsNeed(="..#needsTo_Provide.ingredientsNeed..") not the same as expected(=0)")

    -- cleanup test
end

function T_BirchForest.T_can_ProvideItems_QOSrv()
    -- prepare test
    corelog.WriteToLog("* BirchForest:can_ProvideItems_QOSrv() tests")
    local forest = T_BirchForest.CreateForest() if not forest then corelog.Error("failed obtaining forest") return end

    -- test
    local itemName = "minecraft:birch_log"
    local itemCount = 20
    local serviceResults = forest:can_ProvideItems_QOSrv({ provideItems = { [itemName] = itemCount} })
    assert(serviceResults.success, "can_ProvideItems_QOSrv incorrectly failed for "..itemCount.." "..itemName.."'s")

    itemName = "minecraft:birch_sapling"
    itemCount = 2
    serviceResults = forest:can_ProvideItems_QOSrv({ provideItems = { [itemName] = itemCount} })
    assert(serviceResults.success, "can_ProvideItems_QOSrv incorrectly failed for "..itemCount.." "..itemName.."'s")

    itemName = "minecraft:dirt"
    itemCount = 10
    serviceResults = forest:can_ProvideItems_QOSrv({ provideItems = { [itemName] = itemCount} })
    assert(not serviceResults.success, "can_ProvideItems_QOSrv incorrectly success for "..itemCount.." "..itemName.."'s")

    -- cleanup test
end

local function t_provideItemsTo_AOSrv(provideItems)
    -- prepare test
    corelog.WriteToLog("* BirchForest:provideItemsTo_AOSrv() tests ("..next(provideItems)..")")
    local obj = T_BirchForest.CreateForest() if not obj then corelog.Error("failed obtaining BirchForest") return end
    local objLocator = enterprise_forestry:saveObject(obj)
    t_turtle = t_turtle or require "test.t_turtle"
    local itemDepotLocator = t_turtle.GetCurrentTurtleLocator() assert(itemDepotLocator, "failed obtaining itemDepotLocator")
    local ingredientsItemSupplierLocator = t_turtle.GetCurrentTurtleLocator()

    local T_Chest = require "test.t_mobj_chest"
    local chest2 = T_Obj.createObjFromTable("Chest", T_Chest.NewOTable(location1:getRelativeLocation(0, 0, -1))) assert(chest2, "failed obtaining Chest 2")

    local wasteItemDepotLocator = enterprise_chests:saveObject(chest2)
--    local wasteItemDepotLocator = t_turtle.GetCurrentTurtleLocator()

    local expectedDestinationItemsLocator = itemDepotLocator:copy()
    expectedDestinationItemsLocator:setQuery(provideItems)
    local callback2 = Callback:new({
        _moduleName     = "T_BirchForest",
        _methodName     = "provideItemsTo_AOSrv_Callback",
        _data           = {
            ["expectedDestinationItemsLocator"] = expectedDestinationItemsLocator,
            ["objLocator"] = objLocator,
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

function T_BirchForest.provideItemsTo_AOSrv_Callback(callbackData, serviceResults)
    -- test (cont)
    corelog.WriteToLog(callbackData)
    corelog.WriteToLog(serviceResults)
    assert(serviceResults.success, "failed executing async service")

    local destinationItemsLocator = URL:new(serviceResults.destinationItemsLocator)
    local expectedDestinationItemsLocator = URL:new(callbackData["expectedDestinationItemsLocator"])
    assert(destinationItemsLocator:isEqual(expectedDestinationItemsLocator), "gotten destinationItemsLocator(="..textutils.serialize(destinationItemsLocator, compact)..") not the same as expected(="..textutils.serialize(expectedDestinationItemsLocator, compact)..")")

    -- cleanup test
    local objLocator = URL:new(callbackData["objLocator"])
    enterprise_forestry:deleteResource(objLocator)

    -- end
    return true
end


return T_BirchForest
