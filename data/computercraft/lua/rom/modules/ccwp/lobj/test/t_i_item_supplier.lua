local T_IItemSupplier = {}
local corelog = require "corelog"

local MethodExecutor = require "method_executor"

local URL = require "obj_url"
local ObjHost = require "obj_host"

local compact = { compact = true }

--    _____ _____ _                  _____                   _ _
--   |_   _|_   _| |                / ____|                 | (_)
--     | |   | | | |_ ___ _ __ ___ | (___  _   _ _ __  _ __ | |_  ___ _ __
--     | |   | | | __/ _ \ '_ ` _ \ \___ \| | | | '_ \| '_ \| | |/ _ \ '__|
--    _| |_ _| |_| ||  __/ | | | | |____) | |_| | |_) | |_) | | |  __/ |
--   |_____|_____|\__\___|_| |_| |_|_____/ \__,_| .__/| .__/|_|_|\___|_|
--                                              | |   | |
--                                              |_|   |_|

function T_IItemSupplier.pt_provideItemsTo_AOSrv_Test(className, objLocator, provideItems, itemDepotLocator, ingredientsItemSupplierLocator, wasteItemDepotLocator, logOk)
    -- prepare test (cont)
    assert(className, "no className provided")
    assert(objLocator, "no objLocator provided")
    assert(provideItems, "no provideItems provided")
    assert(itemDepotLocator, "no itemDepotLocator provided")
    assert(ingredientsItemSupplierLocator, "no ingredientsItemSupplierLocator provided")
    assert(wasteItemDepotLocator, "no wasteItemDepotLocator provided")
    assert(type(logOk) == "boolean", "no logOk provided")
    corelog.WriteToLog("* "..className..":provideItemsTo_AOSrv() test ("..textutils.serialize(provideItems, compact).." to "..itemDepotLocator:getURI()..")")

    local lobj = ObjHost.GetObject(objLocator) assert(lobj, "Failed obtaining "..className.." from mobjLocator "..objLocator:getURI())

    -- test
    local serviceResults = MethodExecutor.DoASyncObjService_Sync(lobj, "provideItemsTo_AOSrv", {
        provideItems                    = provideItems,
        itemDepotLocator                = itemDepotLocator,
        ingredientsItemSupplierLocator  = ingredientsItemSupplierLocator,
        wasteItemDepotLocator           = wasteItemDepotLocator,
    })

    -- check: service success
    assert(serviceResults, "no serviceResults returned")
    assert(serviceResults.success, "failed executing service")

    -- check: items provided to destinationItemsLocator
    local expectedDestinationItemsLocator = itemDepotLocator:copy()
    expectedDestinationItemsLocator:setQuery(provideItems)
    local destinationItemsLocator = URL:new(serviceResults.destinationItemsLocator)
    assert(destinationItemsLocator:isEqual(expectedDestinationItemsLocator), "gotten destinationItemsLocator(="..textutils.serialize(destinationItemsLocator, compact)..") not the same as expected(="..textutils.serialize(expectedDestinationItemsLocator, compact)..")")

    -- cleanup test

    if logOk then corelog.WriteToLog(" ok") end
end

return T_IItemSupplier
