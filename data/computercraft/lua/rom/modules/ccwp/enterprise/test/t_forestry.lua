local t_forestry = {}
local corelog = require "corelog"

local InputChecker = require "input_checker"
local MethodExecutor = require "method_executor"

local Location = require "obj_location"

local enterprise_forestry = require "enterprise_forestry"

local t_turtle = require "test.t_turtle"

function t_forestry.T_All()
end

local levelm1 = -1
local level0 = 0
local level1 = 1
local level2 = 2
local location = Location:new({_x= 0, _y= 0, _z= 1, _dx=0, _dy=1})
local nTrees1 = 1
local nTrees2 = 2
local nTrees3 = 3

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
    enterprise_forestry.AddNewSite_ASrv({
        baseLocation                = location:copy(),
        forestLevel                 = level,
        nTrees                      = nTrees,
        materialsItemSupplierLocator= t_turtle.GetCurrentTurtleLocator(),
        wasteItemDepotLocator       = t_turtle.GetCurrentTurtleLocator(),
    }, "t_forestry.AddNewSite_ASrv_Callback", { originalNForests = originalNForests,})
end

function AddNewSite_ASrv_Callback(callbackData, serviceResults)
    -- test (cont))
    assert(serviceResults.success, "failed adding forest")
    local forestLocator = serviceResults.forestLocator
    assert(forestLocator ~= nil, "Failed obtaining forestLocator")
    local nForests = enterprise_forestry:getNumberOfObjects("BirchForest")
    local expectedNForests = callbackData.originalNForests + 1
    assert(nForests == expectedNForests, "gotten nForests(="..nForests..") not the same as expected(="..expectedNForests..")")

    -- cleanup test
    enterprise_forestry:deleteResource(forestLocator)
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

function ExtraCallback(...)
    -- get & check input
    local checkSuccess, levelWanted, treesWanted, forestLocator = InputChecker.Check([[
        Parameters:
            extraCallbackData           - (table) callback data
                levelWanted             + (number)
                treesWanted             + (number)
                forestLocator           + (URL) locating the forest
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("ExtraCallback: Invalid input") return end

    -- test
    enterprise_forestry.UpgradeSite_ASrv({
        forestLocator               = forestLocator:copy(),
        targetLevel                 = levelWanted,
        targetNTrees                = treesWanted,
        materialsItemSupplierLocator= t_turtle.GetCurrentTurtleLocator(),
        wasteItemDepotLocator       = t_turtle.GetCurrentTurtleLocator(),
    }, "t_forestry.UpgradeSite_ASrv_TestCallback", { forestLocator = forestLocator:copy(), levelWanted = levelWanted, treesWanted = treesWanted })
end

function UpgradeSite_ASrv(levelStart, treesStart, levelWanted, treesWanted, extraCallbackName, extraCallbackData)
    -- prepare test
    corelog.WriteToLog("# UpgradeSite_ASrv (L"..levelStart..",trees"..treesStart..") => (L"..levelWanted..",trees"..treesWanted..") test")
    enterprise_forestry.AddNewSite_ASrv({
        baseLocation                = location:copy(),
        forestLevel                 = levelStart,
        nTrees                      = treesStart,
        materialsItemSupplierLocator= t_turtle.GetCurrentTurtleLocator(),
        wasteItemDepotLocator       = t_turtle.GetCurrentTurtleLocator(),
    }, "t_forestry.UpgradeSite_ASrv_PrepCallback", { levelWanted = levelWanted, treesWanted = treesWanted, extraCallbackName = extraCallbackName, extraCallbackData = extraCallbackData})
end

function UpgradeSite_ASrv_PrepCallback(...)
    -- get & check input
    local checkSuccess, levelWanted, treesWanted, extraCallbackName, extraCallbackData, serviceSuccess, forestLocator = InputChecker.Check([[
        Parameters:
            callbackData                - (table) callback data
                levelWanted             + (number)
                treesWanted             + (number)
                extraCallbackName       + (string, "") extra callback method name
                extraCallbackData       + (table, {}) extra callback data
            serviceResults              - (table) results of the service
                success                 + (boolean)
                forestLocator           + (URL) locating the forest
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("UpgradeSite_ASrv_PrepCallback: Invalid input") return end

    -- prepare test (cont)
    assert(serviceSuccess, "failed preparing test")

    -- test
    enterprise_forestry.UpgradeSite_ASrv({
        forestLocator               = forestLocator:copy(),
        targetLevel                 = levelWanted,
        targetNTrees                = treesWanted,
        materialsItemSupplierLocator= t_turtle.GetCurrentTurtleLocator(),
        wasteItemDepotLocator       = t_turtle.GetCurrentTurtleLocator(),
    }, "t_forestry.UpgradeSite_ASrv_TestCallback", { forestLocator = forestLocator:copy(), levelWanted = levelWanted, treesWanted = treesWanted, extraCallbackName = extraCallbackName, extraCallbackData = extraCallbackData })
end

function UpgradeSite_ASrv_TestCallback(...)
    -- get & check input
    local checkSuccess, forestLocator, levelWanted, treesWanted, extraCallbackName, extraCallbackData, serviceSuccess = InputChecker.Check([[
        Parameters:
            callbackData                - (table) callback data
                forestLocator           + (URL) locating the forest
                levelWanted             + (number)
                treesWanted             + (number)
                extraCallbackName       + (string, "") extra callback method name
                extraCallbackData       + (table, {}) extra callback data
            serviceResults              - (table) results of the services
                success                 + (boolean)
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("UpgradeSite_ASrv_TestCallback: Invalid input") return end

    -- test result
    assert(serviceSuccess, "failed upgrading forest")
    local forest = enterprise_forestry:getObject(forestLocator)
    assert(forest:getLevel() == levelWanted, "gotten level(="..forest:getLevel()..") not the same as expected(="..levelWanted..")")
    assert(forest:getNTrees() == treesWanted, "gotten nTrees(="..forest:getNTrees()..") not the same as expected(="..treesWanted..")")

    -- extraCallback?
    if extraCallbackName == "" then
        -- cleanup test
        enterprise_forestry:deleteResource(forestLocator)
    else
        -- call extraCallback
        extraCallbackData.forestLocator = forestLocator
        local moduleName = "t_forestry"
        MethodExecutor.DoSyncService(moduleName, extraCallbackName, extraCallbackData)
    end
end

return t_forestry
