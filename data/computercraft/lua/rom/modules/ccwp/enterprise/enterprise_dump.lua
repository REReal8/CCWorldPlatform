-- define class
local Class             = require "class"
local Host              = require "obj_host"
local enterprise_dump   = Class.NewClass(Host)

--[[
    The enterprise_dump is a Host. It hosts one waste processer (dump) to store items (hopefully for later use).
--]]

-- basics
local coredht       = require "coredht"
local corelog       = require "corelog"
local coreutils     = require "coreutils"
local InputChecker  = require "input_checker"

local ObjArray      = require "obj_array"
local URL           = require "obj_url"

-- mobj specific of the dump (no plans to have somehting physical yet)
local Dump          = require "mobj_dump"

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

-- note: currently enterprise is treated like a singleton, but by directly using the name of the module
-- ToDo: consider making changes to enterprise to
--          - explicitly make it a singleton (by construction with :newInstance(hostName) and using the singleton pattern)
--          - properly initialise it (by adding and implementing the _init method)
--          - adopt other classes to these changes
enterprise_dump._hostName   = "enterprise_dump"

-- setup code
function enterprise_dump.Setup()
    coredht.DHTReadyFunction(DHTReadySetup)
end

function DHTReadySetup()
    local dump
    local nDumps = enterprise_dump:getNumberOfObjects("Dump")
    corelog.WriteToLog("nDumps = ")
    corelog.WriteToLog(nDumps)
    if nDumps == 0 then
        -- the Dump is not there yet => create it
        dump = Dump:newInstance(coreutils.NewId(), ObjArray:newInstance(URL:getClassName()))
        corelog.WriteToLog("dump = ")
        corelog.WriteToLog(dump)

        -- save it
        local objLocator = enterprise_dump:saveObject(dump)
        corelog.WriteToLog("objLocator = ")
        corelog.WriteToLog(objLocator)
        if not objLocator then corelog.Error("enterprise_dump:DHTReadySetup: Failed saving Dump") return nil end
    end
end

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

function enterprise_dump:getClassName()
    return "enterprise_dump"
end

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

-- ToDo: consider allowing multiple Dump's in the future, and hence do this and it's usage different.
function enterprise_dump:getDump()
    --[[
        This function returns the dump object.

        In the current implementation there should be only 1 dump in the world.

        Return value:
            dump                    - (Dump) the Dump
    --]]

    -- there is a Dump unless someone has alters our way of living

    -- get list of Dumps
    local tableOfDumps = self:getObjects("Dump")
    if type(tableOfDumps) ~= "table" then corelog.Error("enterprise_dump:getDump: Failed obtaining Dump's") return nil end

    -- use a random Dump (probebly just 1 present so who cares)
    local _, objTable   = next(tableOfDumps)
    if type(objTable) ~= "table" then corelog.Error("enterprise_dump:getDump: Failed obtaining Dump from the tableOfDumps") return nil end

    -- this is what the user requested
    local dump          = Dump:new(objTable)

    -- end
    return dump
end

function enterprise_dump.GetDumpLocator()
    --[[
        This function returns the Dump locator.

        Return value:
            dumpLocator             - (URL) locating the Dump
    --]]

    -- get Dump
    local dump = enterprise_dump:getDump()

    -- get locator
    local dumpLocator = enterprise_dump:getObjectLocator(dump)
    if not dumpLocator then corelog.Error("enterprise_dump.GetDumpLocator: Failed getting dumpLocator") return nil end

    -- end
    return dumpLocator
end

function enterprise_dump:deleteDump()
    enterprise_dump:deleteObjects("Dump")
end

function enterprise_dump:reset()
    -- get Dump
    local dump = enterprise_dump:getDump()
    if not dump then corelog.Error("enterprise_dump:reset: Failed getting Dump") return nil end

    -- delist Suppliers
    dump:delistAllItemStores()
end

--                        _                           _   _               _
--                       (_)                         | | | |             | |
--    ___  ___ _ ____   ___  ___ ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \  __/ |   \ V /| | (_|  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/\___|_|    \_/ |_|\___\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

function enterprise_dump.RegisterItemSupplier_SSrv(...)
    -- get & check input from description
    local checkSuccess, itemSupplierLocator = InputChecker.Check([[
        This sync public service registers ("adds") an ItemSupplier to the enterprise.

        Note that the ItemSupplier should already be available in the world.

        Return value:
                                    - (table)
                success             - (boolean) whether the service executed successfully

        Parameters:
            serviceData             - (table) data for the service
                itemSupplierLocator + (URL) locating the ItemSupplier
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("enterprise_dump.RegisterItemSupplier_SSrv: Invalid input") return {success = false} end

    -- get Obj
    local dumpLocator = enterprise_dump.GetDumpLocator()
    local obj = enterprise_dump:getObject(dumpLocator)
    if type(obj) ~="table" then corelog.Error("enterprise_dump.RegisterItemSupplier_SSrv: Dump not found.") return {success = false} end

    -- have Obj register ItemSupplier
    return obj:registerItemSupplier_SOSrv({
        itemSupplierLocator = itemSupplierLocator,
    })
end

function enterprise_dump.DelistItemSupplier_SSrv(...)
    -- get & check input from description
    local checkSuccess, itemSupplierLocator = InputChecker.Check([[
        This sync public service delists ("removes") an ItemSupplier from the enterprise.

        Note that the ItemSupplier is not removed from the world.

        Return value:
            success                 - (boolean) whether the service executed successfully

        Parameters:
            serviceData             - (table) data for the service
                itemSupplierLocator + (URL) locating the ItemSupplier
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("enterprise_dump.DelistItemSupplier_SSrv: Invalid input") return {success = false} end

    -- get Obj
    local dumpLocator = enterprise_dump.GetDumpLocator()
    local obj = enterprise_dump:getObject(dumpLocator)
    if type(obj) ~="table" then corelog.Error("enterprise_dump.DelistItemSupplier_SSrv: Dump not found.") return {success = false} end

    -- have Obj register ItemSupplier
    return obj:delistItemSupplier_SOSrv({
        itemSupplierLocator = itemSupplierLocator,
    })
end

return enterprise_dump
