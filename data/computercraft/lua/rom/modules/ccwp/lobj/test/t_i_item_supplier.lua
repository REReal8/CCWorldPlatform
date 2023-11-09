local T_IItemSupplier = {}
local corelog = require "corelog"

local Callback = require "obj_callback"
local MethodExecutor = require "method_executor"

local URL = require "obj_url"
local Host = require "host"

local enterprise_chests = require "enterprise_chests"

local compact = { compact = true }

--    _____ _____ _                  _____                   _ _
--   |_   _|_   _| |                / ____|                 | (_)
--     | |   | | | |_ ___ _ __ ___ | (___  _   _ _ __  _ __ | |_  ___ _ __
--     | |   | | | __/ _ \ '_ ` _ \ \___ \| | | | '_ \| '_ \| | |/ _ \ '__|
--    _| |_ _| |_| ||  __/ | | | | |____) | |_| | |_) | |_) | | |  __/ |
--   |_____|_____|\__\___|_| |_| |_|_____/ \__,_| .__/| .__/|_|_|\___|_|
--                                              | |   | |
--                                              |_|   |_|

function T_IItemSupplier.pt_provideItemsTo_AOSrv_Test(mobjHostName, className, constructParameters, provideItems, itemDepotLocator)
    -- prepare test (cont)
    assert(mobjHostName, "no mobjHostName provided")
    assert(className, "no className provided")
    corelog.WriteToLog("* "..className..":provideItemsTo_AOSrv() test ("..textutils.serialize(provideItems, compact).." to "..itemDepotLocator:getURI()..")")

    local mobjHost = Host.GetHost(mobjHostName) assert(mobjHost, "Failed obtaining MObjHost "..mobjHostName)
    local mobjLocator = mobjHost:hostMObj_SSrv({ className = className, constructParameters = constructParameters }).mobjLocator assert(mobjLocator, "failed hosting "..className.." on "..mobjHostName)
    local mobj = mobjHost:getObject(mobjLocator) assert(mobj, "Failed obtaining "..className.." from mobjLocator "..mobjLocator:getURI())

    -- test
    local serviceResults = MethodExecutor.DoASyncObjService_Sync(mobj, "provideItemsTo_AOSrv", {
        provideItems    = provideItems,
        itemDepotLocator= itemDepotLocator,
    })

    -- check: service success
    assert(serviceResults, "no serviceResults returned")
    assert(serviceResults.success, "failed executing service")

    -- check: destinationItemsLocator
    local expectedDestinationItemsLocator = itemDepotLocator:copy()
    expectedDestinationItemsLocator:setQuery(provideItems)
    local destinationItemsLocator = URL:new(serviceResults.destinationItemsLocator)
    assert(destinationItemsLocator:isEqual(expectedDestinationItemsLocator), "gotten destinationItemsLocator(="..textutils.serialize(destinationItemsLocator, compact)..") not the same as expected(="..textutils.serialize(expectedDestinationItemsLocator, compact)..")")

    -- cleanup test
    mobjHost:releaseMObj_SSrv({ mobjLocator = mobjLocator})
end

return T_IItemSupplier
