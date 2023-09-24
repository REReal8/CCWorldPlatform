local T_UtilStation = {}

local corelog = require "corelog"

local Callback = require "obj_callback"

local enterprise_construction   = require "enterprise_construction"
local enterprise_turtle         = require "enterprise_turtle"

local UtilStation = require "mobj_util_station"

function T_UtilStation.T_Build_Station()
    corelog.WriteToLog("About to build Util Station!")

    -- get turtle locator
    local currentTurtleLocator = enterprise_turtle:GetCurrentTurtleLocator() assert(currentTurtleLocator, "Failed obtaining current turtleLocator")

    local siteBuildData = UtilStation.GetV1SiteBuildData()
    siteBuildData.materialsItemSupplierLocator = currentTurtleLocator
    siteBuildData.wasteItemDepotLocator = currentTurtleLocator:copy()
    enterprise_construction.BuildBlueprint_ASrv(siteBuildData, Callback.GetNewDummyCallBack())
end

return T_UtilStation