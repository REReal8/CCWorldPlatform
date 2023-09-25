local t_forestry = {}
local corelog = require "corelog"

local InputChecker = require "input_checker"
local MethodExecutor = require "method_executor"

local URL = require "obj_url"
local Location = require "obj_location"

local enterprise_turtle = require "enterprise_turtle"
local enterprise_forestry = require "enterprise_forestry"

local TestArrayTest = require "test_array_test"
local FieldTest = require "field_test"
local FieldValueEqualTest = require "field_value_equal_test"
local ValueTypeTest = require "value_type_test"
local MethodResultEqualTest = require "method_result_equal_test"

local T_BirchForest = require "test.t_mobj_birchforest"
local T_MObjHost = require "test.t_eobj_mobj_host"

local t_turtle = require "test.t_turtle"

function t_forestry.T_All()
    -- MObjHost methods
    t_forestry.T_hostMObj_SSrv_BirchForest()
    t_forestry.T_upgradeMObj_SSrv_BirchForest()
    t_forestry.T_releaseMObj_SSrv_BirchForest()
end

function t_forestry.T_AllPhysical()
    -- IObj methods

    -- MObjHost methods
    local mobjLocator = t_forestry.T_hostAndBuildMObj_ASrv_BirchForest0()
    t_forestry.T_dismantleAndReleaseMObj_ASrv_BirchForest(mobjLocator)
    mobjLocator = t_forestry.T_hostAndBuildMObj_ASrv_BirchForest1()
    t_forestry.T_dismantleAndReleaseMObj_ASrv_BirchForest(mobjLocator)
    mobjLocator = t_forestry.T_hostAndBuildMObj_ASrv_BirchForest2()
    t_forestry.T_dismantleAndReleaseMObj_ASrv_BirchForest(mobjLocator)
end

local testMObjClassName = "BirchForest"
local testMObjName = "birchForest"
local testMObjName0 = testMObjName.."0"
local testMObjName1 = testMObjName.."1"
local testMObjName2 = testMObjName.."2"
local logOk = false

local levelm1 = -1
local level0 = 0
local level1 = 1
local level2 = 2
local baseLocation0 = Location:newInstance(0, 0, 1, 0, 1)
local nTrees1 = 1
local nTrees2 = 2
local nTrees3 = 3
local nTrees4 = 4
local localLogsLocator0 = enterprise_turtle.GetAnyTurtleLocator()
local localSaplingsLocator0 = enterprise_turtle.GetAnyTurtleLocator()
local localLogsLocatorTest0 = FieldValueEqualTest:newInstance("_localLogsLocator", localLogsLocator0)
local localSaplingsLocatorTest0 = FieldValueEqualTest:newInstance("_localSaplingsLocator", localSaplingsLocator0)

local constructParameters0 = {
    level           = level0,

    baseLocation    = baseLocation0,
    nTrees          = nTrees1,
}
local constructParameters1 = {
    level           = level1,

    baseLocation    = baseLocation0,
    nTrees          = nTrees2,
}
local constructParameters2 = {
    level           = level2,

    baseLocation    = baseLocation0,
    nTrees          = nTrees4,
}
local upgradeParametersTo2 = {
    level           = level2,

    nTrees          = nTrees4,
}

function t_forestry.T_AddNewSite_ASrv_Levelm1()
    AddNewSite_ASrv(levelm1, nTrees1)
end

function t_forestry.T_AddNewSite_ASrv_Level0()
    AddNewSite_ASrv(level0, nTrees1)
end

function t_forestry.T_AddNewSite_ASrv_Level2()
    AddNewSite_ASrv(level2, nTrees1)
end

function AddNewSite_ASrv(level, nTrees)
    -- prepare test
    corelog.WriteToLog("# AddNewSite_ASrv (L"..level..",trees"..nTrees..") test")
    local originalNForests = enterprise_forestry:getNumberOfObjects("BirchForest")

    -- test
    local serviceResults = MethodExecutor.DoASyncService_Sync("enterprise_forestry", "AddNewSite_ASrv", {
        baseLocation                = baseLocation0:copy(),
        forestLevel                 = level,
        nTrees                      = nTrees,
        materialsItemSupplierLocator= t_turtle.GetCurrentTurtleLocator(),
        wasteItemDepotLocator       = t_turtle.GetCurrentTurtleLocator(),
    })

    -- check: service success
    assert(serviceResults, "no serviceResults returned")
    assert(serviceResults.success, "failed executing service")

    -- check: Forest hosted on enterprise_forestry
    local mobjLocator = serviceResults.mobjLocator assert(mobjLocator, "no mobjLocator returned")
    local mobj = enterprise_forestry:getObject(mobjLocator)
    assert(mobj, "Forest(="..mobjLocator:getURI()..") not hosted by "..enterprise_forestry:getHostName())

    -- check: new forest added
    local nForests = enterprise_forestry:getNumberOfObjects("BirchForest")
    local expectedNForests = originalNForests + 1
    assert(nForests == expectedNForests, "gotten nForests(="..nForests..") not the same as expected(="..expectedNForests..")")

    -- cleanup test
    mobj:destruct()
    enterprise_forestry:deleteResource(mobjLocator)
end

function t_forestry.T_UpgradeSite_ASrv_Levelm1_Level0Trees1()
    UpgradeSite_ASrv(levelm1, nTrees1, level0, nTrees1)
end

function t_forestry.T_UpgradeSite_ASrv_Level1Trees1()
    UpgradeSite_ASrv(level0, nTrees1, level1, nTrees1)
end

function t_forestry.T_UpgradeSite_ASrv_Level1Trees3()
    UpgradeSite_ASrv(level0, nTrees1, level1, nTrees3)
end

function t_forestry.T_UpgradeSite_ASrv_Level2Trees1()
    UpgradeSite_ASrv(level0, nTrees1, level2, nTrees1)
end

function t_forestry.T_UpgradeSite_ASrv_Level2Trees2()
    UpgradeSite_ASrv(level0, nTrees1, level2, nTrees2)
end

function t_forestry.T_UpgradeSite_ASrv_Level1Trees3_Level2Trees3()
    UpgradeSite_ASrv(level1, nTrees1, level1, nTrees3, "ExtraCallback", { levelWanted = level2, treesWanted = nTrees3 })
end

function t_forestry.ExtraCallback(...)
    -- get & check input
    local checkSuccess, levelWanted, treesWanted, mobjLocator = InputChecker.Check([[
        Parameters:
            extraCallbackData           - (table) callback data
                levelWanted             + (number)
                treesWanted             + (number)
                mobjLocator             + (URL) locating the forest
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("ExtraCallback: Invalid input") return end

    -- call and test
    CallAndTest_UpgradeSite_ASrv(mobjLocator, levelWanted, treesWanted, "", {})

    -- end
    return {success = true}
end

function UpgradeSite_ASrv(...)
    -- get & check input
    local checkSuccess, levelStart, treesStart, levelWanted, treesWanted, extraCallbackName, extraCallbackData = InputChecker.Check([[
        Parameters:
            levelStart              + (number)
            treesStart              + (number)
            levelWanted             + (number)
            treesWanted             + (number)
            extraCallbackName       + (string, "") extra callback method name
            extraCallbackData       + (table, {}) extra callback data
    --]], table.unpack(arg))
    assert(checkSuccess, "UpgradeSite_ASrv: Invalid input")

    -- prepare test
    corelog.WriteToLog("# UpgradeSite_ASrv (L"..levelStart..",trees"..treesStart..") => (L"..levelWanted..",trees"..treesWanted..") test")
    local serviceResults = MethodExecutor.DoASyncService_Sync("enterprise_forestry", "AddNewSite_ASrv", {
        baseLocation                = baseLocation0:copy(),
        forestLevel                 = levelStart,
        nTrees                      = treesStart,
        materialsItemSupplierLocator= t_turtle.GetCurrentTurtleLocator(),
        wasteItemDepotLocator       = t_turtle.GetCurrentTurtleLocator(),
    })
    assert(serviceResults, "failed preparing test")
    assert(serviceResults.success, "failed executing service")
    local mobjLocator = URL:new(serviceResults.mobjLocator) assert(mobjLocator, "no mobjLocator returned")

    -- call and test
    CallAndTest_UpgradeSite_ASrv(mobjLocator, levelWanted, treesWanted, extraCallbackName, extraCallbackData)
end

function CallAndTest_UpgradeSite_ASrv(mobjLocator, levelWanted, treesWanted, extraCallbackName, extraCallbackData)
    -- test
    local serviceResults = MethodExecutor.DoASyncService_Sync("enterprise_forestry", "UpgradeSite_ASrv", {
        mobjLocator                 = mobjLocator:copy(),
        targetLevel                 = levelWanted,
        targetNTrees                = treesWanted,
        materialsItemSupplierLocator= t_turtle.GetCurrentTurtleLocator(),
        wasteItemDepotLocator       = t_turtle.GetCurrentTurtleLocator(),
    })

    -- check: service success
    assert(serviceResults, "failed upgrading Forest")
    assert(serviceResults.success, "failed executing service")

    -- check: Forest
    local forest = enterprise_forestry:getObject(mobjLocator)
    assert(forest:getLevel() == levelWanted, "gotten level(="..forest:getLevel()..") not the same as expected(="..levelWanted..")")
    assert(forest:getNTrees() == treesWanted, "gotten nTrees(="..forest:getNTrees()..") not the same as expected(="..treesWanted..")")

    -- extraCallback?
    if extraCallbackName == "" then
        -- cleanup test
        local mobj = enterprise_forestry:getObject(mobjLocator) assert(mobj, "Forest(="..mobjLocator:getURI()..") not hosted by "..enterprise_forestry:getHostName())
        mobj:destruct()
        enterprise_forestry:deleteResource(mobjLocator)
    else
        -- call extraCallback
        extraCallbackData.mobjLocator = mobjLocator
        local moduleName = "t_forestry"
        MethodExecutor.DoSyncService(moduleName, extraCallbackName, extraCallbackData)
    end
end

--    __  __  ____  _     _ _    _           _                    _   _               _
--   |  \/  |/ __ \| |   (_) |  | |         | |                  | | | |             | |
--   | \  / | |  | | |__  _| |__| | ___  ___| |_   _ __ ___   ___| |_| |__   ___   __| |___
--   | |\/| | |  | | '_ \| |  __  |/ _ \/ __| __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   | |  | | |__| | |_) | | |  | | (_) \__ \ |_  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_|  |_|\____/|_.__/| |_|  |_|\___/|___/\__| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                      _/ |
--                     |__/

function t_forestry.T_hostMObj_SSrv_BirchForest()
    -- prepare test
    local fieldsTest0 = T_BirchForest.CreateInitialisedTest(nil, level0, baseLocation0, nTrees1, localLogsLocatorTest0, localSaplingsLocatorTest0)

    -- test
    local serviceResults = T_MObjHost.pt_hostMObj_SSrv(enterprise_forestry, testMObjClassName, constructParameters0, testMObjName0, fieldsTest0, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

local mobjLocator_BirchForest = nil

function t_forestry.T_hostAndBuildMObj_ASrv_BirchForest0()
    -- prepare test

    -- test
    local serviceResults = T_MObjHost.pt_hostAndBuildMObj_ASrv(enterprise_forestry, testMObjClassName, constructParameters0, testMObjName0, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    mobjLocator_BirchForest = serviceResults.mobjLocator

    -- return mobjLocator
    return serviceResults.mobjLocator
end

function t_forestry.T_hostAndBuildMObj_ASrv_BirchForest1()
    -- prepare test

    -- test
    local serviceResults = T_MObjHost.pt_hostAndBuildMObj_ASrv(enterprise_forestry, testMObjClassName, constructParameters1, testMObjName1, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    mobjLocator_BirchForest = serviceResults.mobjLocator

    -- return mobjLocator
    return serviceResults.mobjLocator
end

function t_forestry.T_hostAndBuildMObj_ASrv_BirchForest2()
    -- prepare test

    -- test
    local serviceResults = T_MObjHost.pt_hostAndBuildMObj_ASrv(enterprise_forestry, testMObjClassName, constructParameters2, testMObjName2, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    mobjLocator_BirchForest = serviceResults.mobjLocator

    -- return mobjLocator
    return serviceResults.mobjLocator
end

function t_forestry.T_upgradeMObj_SSrv_BirchForest()
    -- prepare test
    local localLogsLocatorTest2 = FieldTest:newInstance("_localLogsLocator", TestArrayTest:newInstance(
        ValueTypeTest:newInstance("URL"),
        MethodResultEqualTest:newInstance("getHost", "enterprise_chests")
    ))
    local localSaplingsLocatorTest2 = FieldTest:newInstance("_localSaplingsLocator", TestArrayTest:newInstance(
        ValueTypeTest:newInstance("URL"),
        MethodResultEqualTest:newInstance("getHost", "enterprise_chests")
    ))
    local fieldsTest2 = T_BirchForest.CreateInitialisedTest(nil, level2, baseLocation0, nTrees4, localLogsLocatorTest2, localSaplingsLocatorTest2)

    -- test
    local serviceResults = T_MObjHost.pt_upgradeMObj_SSrv(enterprise_forestry, testMObjClassName, constructParameters1, upgradeParametersTo2, testMObjName1, fieldsTest2, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

function t_forestry.T_releaseMObj_SSrv_BirchForest()
    -- prepare test

    -- test
    local serviceResults = T_MObjHost.pt_releaseMObj_SSrv(enterprise_forestry, testMObjClassName, constructParameters1, testMObjName1, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
end

function t_forestry.T_dismantleAndReleaseMObj_ASrv_BirchForest(mobjLocator)
    -- prepare test
    if not mobjLocator then
        -- see if we locally remembered a mobjLocator
        assert(mobjLocator_BirchForest, "no mobjLocator to operate on")
        mobjLocator = mobjLocator_BirchForest
    end

    -- test
    local serviceResults = T_MObjHost.pt_dismantleAndReleaseMObj_ASrv(enterprise_forestry, mobjLocator, logOk)
    assert(serviceResults, "no serviceResults returned")

    -- cleanup test
    mobjLocator_BirchForest = nil
end

return t_forestry
