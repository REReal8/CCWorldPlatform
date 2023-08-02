local Host = require "obj_host"

local enterprise_administration = Host:new({
    _hostName   = "enterprise_administration",
})

local corelog = require "corelog"

local ObjTable = require "obj_table"

local WIPAdministrator = require "obj_wip_administrator"

--[[
    The enterprise_administration is a Host. It hosts administration administrators.
--]]

--    _                                     _   _               _
--   | |                                   | | | |             | |
--   | |__   __ _ ___  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   | '_ \ / _` / __|/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   | |_) | (_| \__ \  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_.__/ \__,_|___/\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

function enterprise_administration:getWIPAdministrator()
    --[[
        This function returns the WIPAdministrator.

        Return value:
            wipHandler                  - (WIPAdministrator) the WIPAdministrator
    --]]

    local administrator = self:getObjects("WIPAdministrator")
    corelog.WriteToLog("administrator:")
    corelog.WriteToLog(administrator)

    if next(administrator) == nil then
        -- the WIPAdministrator is not there yet => create it
        administrator = self:createNewWIPAdministrator()
    else
        administrator = WIPAdministrator:new(administrator)
    end

    -- end
    return administrator
end

function enterprise_administration:getWIPAdministratorLocator()
    --[[
        This function returns the WIPAdministrator locator.

        Return value:
            administratorLocator              - (URL) locating the WIPAdministrator
    --]]

    -- get WIPAdministrator
    local administrator = enterprise_administration:getWIPAdministrator()

    -- get locator
    local administratorLocator = enterprise_administration:getObjectLocator(administrator)
    if not administratorLocator then corelog.Error("enterprise_administration.GetWIPAdministratorLocator: Failed getting administratorLocator") return nil end

    -- end
    return administratorLocator
end

function enterprise_administration:createNewWIPAdministrator()
    -- create WIPAdministrator
    local administrator = WIPAdministrator:new({
        _wipQueues  = ObjTable:new({
            _objClassName   = "WIPQueue",
        }),
    })

    -- save it
    local objLocator = self:saveObject(administrator)
    if not objLocator then corelog.Error("enterprise_administration:createNewWIPAdministrator: Failed saving WIPAdministrator") return nil end

    -- end
    return administrator
end

function enterprise_administration:reset()
    -- create (new) WIPAdministrator
    self:createNewWIPAdministrator()
end

--                        _                           _   _               _
--                       (_)                         | | | |             | |
--    ___  ___ _ ____   ___  ___ ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \  __/ |   \ V /| | (_|  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/\___|_|    \_/ |_|\___\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

return enterprise_administration
