local MObjHost = require "eobj_mobj_host"

local enterprise_storage = MObjHost:new({
    _hostName   = "enterprise_storage",
})

local corelog = require "corelog"

local InputChecker = require "input_checker"
local Callback = require "obj_callback"

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

function enterprise_storage:getClassName()
    return "enterprise_storage"
end

--                        _                           _   _               _
--                       (_)                         | | | |             | |
--    ___  ___ _ ____   ___  ___ ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \  __/ |   \ V /| | (_|  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/\___|_|    \_/ |_|\___\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

function enterprise_storage.RegisterStorage_SSrv(...)
    -- get & check input from description
    local checkSuccess, location = InputChecker.Check([[
        This sync public service registers ("adds") a storage to the enterprise.

        Note that the storage should already be present (constructed) in the world. It is however assumed the newly added storages are still empty.

        Return value:
                                    - (table)
                success             - (boolean) whether the service executed successfully
                storageLocator      - (URL) locating the created storage (in this enterprise)

        Parameters:
            storageData             - (table) data to the storage
            type                    + (stromg) type of the storage (e.g. "storage:silo")
            location                + (Location) location of the storage
            --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("enterprise_storage.RegisterStorage_SSrv: Invalid input") return {success = false} end

    -- ToDo:

    return {success = false}
end

function enterprise_storage.DelistStorage_ASrv(...)
    -- get & check input from description
    local checkSuccess, storageLocator, callback = InputChecker.Check([[
        This async public service delists ("removes") a storage from the enterprise. Delisting implies
            - the storage is immediatly no longer available for new business (e.g. adding/ removing items)
            - wait for all active work on storage to be ended
            - remove the storage from the enterprise

        Note that the storages (and it's possibly remaining items) are not removed from the world.

        Return value:
                                - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                - (table)
                success         - (boolean) whether the service executed successfully

        Parameters:
            serviceData         - (table) data about the service
                storageLocator  + (URL) locating the storage
            callback            + (Callback) to call once service is ready
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("enterprise_storage.DelistStorage_ASrv: Invalid input") return Callback.ErrorCall(callback) end

    -- ToDo

    return Callback.ErrorCall(callback)
end

return enterprise_storage
