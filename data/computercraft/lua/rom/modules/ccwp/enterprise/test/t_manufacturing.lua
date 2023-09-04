local t_manufacturing = {}

local corelog = require "corelog"

local Callback = require "obj_callback"

local Location = require "obj_location"

local enterprise_manufacturing = require "enterprise_manufacturing"

local t_turtle

function t_manufacturing.T_All()
end

local baseLocationV0 = Location:newInstance(6, 0, 1, 0, 1)
local baseLocationV1 = Location:newInstance(12, 0, 1, 0, 1)
local baseLocationV2 = baseLocationV1:copy()

local callback = Callback.GetNewDummyCallBack()

function t_manufacturing.T_BuildAndStartNewV1Site()
    local callbackBuildAndStartNewV1Site = Callback:newInstance("t_manufacturing", "BuildAndStartNewV1Site_CallBack")

    t_turtle = t_turtle or require "test.t_turtle"
    return enterprise_manufacturing.BuildAndStartNewSite_ASrv({
        baseLocation                = baseLocationV1,
        siteVersion                 = "v1",
        upgrade                     = false,
        siteLocator                 = nil,
        materialsItemSupplierLocator= t_turtle.GetCurrentTurtleLocator(),
        wasteItemDepotLocator       = t_turtle.GetCurrentTurtleLocator(),
    }, callbackBuildAndStartNewV1Site)
end

local siteLocatorV1

function t_manufacturing.BuildAndStartNewV1Site_CallBack(callbackData, serviceResults)
    -- test (cont)
    assert(serviceResults.success, "failed executing async service")
    siteLocatorV1 = serviceResults.siteLocator

    -- cleanup test

    -- end
    return true
end

function t_manufacturing.T_BuildAndStartNewV2Site()
    -- prepare test
    corelog.WriteToLog("* enterprise_manufacturing.BuildAndStartNewSite_ASrv tests")
    if not siteLocatorV1 then corelog.Error("siteLocatorV1 not yet set, first create v1 site as this test wants to upgrade") return false end
    t_turtle = t_turtle or require "test.t_turtle"

    -- test
    return enterprise_manufacturing.BuildAndStartNewSite_ASrv({
        baseLocation                = baseLocationV2,
        siteVersion                 = "v2",
        upgrade                     = true,
        siteLocator                 = siteLocatorV1,
        materialsItemSupplierLocator= t_turtle.GetCurrentTurtleLocator(),
        wasteItemDepotLocator       = t_turtle.GetCurrentTurtleLocator(),
    }, callback)
end

function t_manufacturing.T_StopAndDismantleV1Site()
    t_turtle = t_turtle or require "test.t_turtle"

    return enterprise_manufacturing.StopAndDismantleSite_ASrv({
        siteLocator                 = siteLocatorV1,
        baseLocation                = baseLocationV1,
        siteVersion                 = "v1",
        materialsItemSupplierLocator= t_turtle.GetCurrentTurtleLocator(),
        wasteItemDepotLocator       = t_turtle.GetCurrentTurtleLocator(),
    }, callback)
end

function t_manufacturing.T_BuildNewV0Site()
    t_turtle = t_turtle or require "test.t_turtle"

    return enterprise_manufacturing.BuildNewSite_ASrv({
        baseLocation                = baseLocationV0,
        siteVersion                 = "v0",
        upgrade                     = false,
        materialsItemSupplierLocator= t_turtle.GetCurrentTurtleLocator(),
        wasteItemDepotLocator       = t_turtle.GetCurrentTurtleLocator(),
    }, callback)
end

local siteLocatorV0

function t_manufacturing.T_StartNewV0Site()
    local result = t_manufacturing.StartNewSite(baseLocationV0) if not result.success then corelog.Error("failed starting Site") return end
    siteLocatorV0 = result.siteLocator
end

function t_manufacturing.StartNewSite(baseLocation, version)
    version = version or "v0"

    return enterprise_manufacturing.StartNewSite_SSrv({
        baseLocation        = baseLocation,
        siteVersion         = version,
    })
end

local function DismantleV0Site(baseLocation)
    t_turtle = t_turtle or require "test.t_turtle"

    return enterprise_manufacturing.DismantleSite_ASrv({
        baseLocation                = baseLocation,
        siteVersion                 = "v0",
        siteStopped                 = true,
        materialsItemSupplierLocator= t_turtle.GetCurrentTurtleLocator(),
        wasteItemDepotLocator       = t_turtle.GetCurrentTurtleLocator(),
    }, callback)
end

function t_manufacturing.T_DismantleV0Site()
    DismantleV0Site(baseLocationV0)
end

function t_manufacturing.T_StopV0Site()
    t_manufacturing.StopSite(siteLocatorV0)
end

function t_manufacturing.StopSite(siteLocator)
    return enterprise_manufacturing.StopSite_ASrv({
        siteLocator     = siteLocator
    }, callback)
end

function t_manufacturing.T_DeleteSites()
    enterprise_manufacturing:deleteObjects("Factory")
end

return t_manufacturing
