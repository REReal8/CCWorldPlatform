local T_IItemSupplier = {}
local corelog = require "corelog"

local Callback = require "obj_callback"

local URL = require "obj_url"
local Host = require "obj_host"

local enterprise_chests = require "enterprise_chests"

local compact = { compact = true }

--    _____ _____ _                  _____                   _ _                            _   _               _
--   |_   _|_   _| |                / ____|                 | (_)                          | | | |             | |
--     | |   | | | |_ ___ _ __ ___ | (___  _   _ _ __  _ __ | |_  ___ _ __   _ __ ___   ___| |_| |__   ___   __| |___
--     | |   | | | __/ _ \ '_ ` _ \ \___ \| | | | '_ \| '_ \| | |/ _ \ '__| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| |_ _| |_| ||  __/ | | | | |____) | |_| | |_) | |_) | | |  __/ |    | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____|_____|\__\___|_| |_| |_|_____/ \__,_| .__/| .__/|_|_|\___|_|    |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
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

    local expectedDestinationItemsLocator = itemDepotLocator:copy()
    expectedDestinationItemsLocator:setQuery(provideItems)
    local callback = Callback:new({
        _moduleName     = "T_IItemSupplier",
        _methodName     = "provideItemsTo_AOSrv_Callback",
        _data           = {
            ["expectedDestinationItemsLocator"] = expectedDestinationItemsLocator,
            ["mobjHostName"]                    = mobjHostName,
            ["mobjLocator"]                     = mobjLocator,
            ["itemDepotLocator"]                = itemDepotLocator,
        },
    })

    -- test
    local scheduleResult = mobj:provideItemsTo_AOSrv({
        provideItems    = provideItems,
        itemDepotLocator= itemDepotLocator,
    }, callback)
    assert(scheduleResult == true, "failed to schedule async service")
end

function T_IItemSupplier.provideItemsTo_AOSrv_Callback(callbackData, serviceResults)
    -- test (cont)
    assert(serviceResults.success, "failed executing async service")

    local destinationItemsLocator = URL:new(serviceResults.destinationItemsLocator)
    local expectedDestinationItemsLocator = URL:new(callbackData["expectedDestinationItemsLocator"])
    assert(destinationItemsLocator:isEqual(expectedDestinationItemsLocator), "gotten destinationItemsLocator(="..textutils.serialize(destinationItemsLocator, compact)..") not the same as expected(="..textutils.serialize(expectedDestinationItemsLocator, compact)..")")

    -- cleanup test
    local mobjHostName = callbackData["mobjHostName"]
    local mobjHost = Host.GetHost(mobjHostName) assert(mobjHost, "Failed obtaining MObjHost "..mobjHostName)
    local mobjLocator = callbackData["mobjLocator"]
    mobjHost:releaseMObj_SSrv({ mobjLocator = mobjLocator})

    local itemDepotLocator = callbackData["itemDepotLocator"]
    if enterprise_chests:isLocatorFromHost(itemDepotLocator) then
        enterprise_chests:deleteResource(itemDepotLocator)
    end

    -- end
    return true
end

return T_IItemSupplier
