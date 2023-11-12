local T_IItemDepot = {}

local corelog = require "corelog"

local MethodExecutor = require "method_executor"

local URL = require "obj_url"
local ObjHost = require "obj_host"

local compact = { compact = true }

--    _____ _____ _                 _____                   _
--   |_   _|_   _| |               |  __ \                 | |
--     | |   | | | |_ ___ _ __ ___ | |  | | ___ _ __   ___ | |_
--     | |   | | | __/ _ \ '_ ` _ \| |  | |/ _ \ '_ \ / _ \| __|
--    _| |_ _| |_| ||  __/ | | | | | |__| |  __/ |_) | (_) | |_
--   |_____|_____|\__\___|_| |_| |_|_____/ \___| .__/ \___/ \__|
--                                             | |
--                                             |_|

function T_IItemDepot.pt_storeItemsFrom_AOSrv(className, objLocator, itemsLocator, logOk)
    -- prepare test
    assert(type(className) == "string", "no valid className provided")
    assert(type(objLocator) == "table", "no  valid objLocator provided")
    assert(type(itemsLocator) == "table", "no valid itemsLocator provided")
    assert(type(logOk) == "boolean", "no valid logOk provided")
    corelog.WriteToLog("* "..className..":storeItemsFrom_AOSrv() test (from "..itemsLocator:getURI()..")")

    local obj = ObjHost.GetObject(objLocator) assert(obj, "Failed obtaining "..className.." from objLocator "..objLocator:getURI())

    local expectedDestinationItemsLocator = objLocator:copy()
    expectedDestinationItemsLocator:setQueryURI(itemsLocator:getQueryURI())

    -- test
    local serviceResults = MethodExecutor.DoASyncObjService_Sync(obj, "storeItemsFrom_AOSrv", {
        itemsLocator                    = itemsLocator,
    })

    -- check: service success
    assert(serviceResults, "no serviceResults returned")
    assert(serviceResults.success, "failed executing service")

    -- check: items stored in destinationItemsLocator
    local destinationItemsLocator = URL:new(serviceResults.destinationItemsLocator)
    assert(destinationItemsLocator:isEqual(expectedDestinationItemsLocator), "gotten destinationItemsLocator(="..textutils.serialize(destinationItemsLocator, compact)..") not the same as expected(="..textutils.serialize(expectedDestinationItemsLocator, compact)..")")

    -- cleanup test
    if logOk then corelog.WriteToLog(" ok") end
end

return T_IItemDepot
