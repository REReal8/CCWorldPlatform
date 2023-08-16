local Host = require "obj_host"

local enterprise_gathering = Host:new({
    _hostName   = "enterprise_gathering",
})

local coreutils = require "coreutils"
local corelog = require "corelog"

local Callback = require "obj_callback"
local TaskCall = require "obj_task_call"
local InputChecker = require "input_checker"

local mobj_mine = require "mobj_mine"

local enterprise_projects = require "enterprise_projects"
local enterprise_turtle
local enterprise_construction = require "enterprise_construction"

--[[
    The gathering enterprise provides services for building and using sites where materials can be gathered, like mines and on the surface.
--]]

--                        _                           _   _               _
--                       (_)                         | | | |             | |
--    ___  ___ _ ____   ___  ___ ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \  __/ |   \ V /| | (_|  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/\___|_|    \_/ |_|\___\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

function enterprise_gathering.AddNewMine_ASrv(...)
    -- get & check input from description
    local checkSuccess, baseLocation, forestLevel, nTrees, materialsItemSupplierLocator, callback = InputChecker.Check([[
        This async public service builds a new mine site and ensures it's ready for use.

        Return value:
                                                - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                                - (table)
                success                         - (boolean) whether the service executed successfully
                mineLocator                     - (URL) locating the site

        Parameters:
            serviceData                         - (table) data about this site
                baseLocation                    + (Location) base location of the Mine
                materialsItemSupplierLocator    + (URL) locating the host of the building materials
            callback                            + (Callback) to call once service is ready
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("enterprise_gathering.AddNewMine_ASrv: Invalid input") return Callback.ErrorCall(callback) end

    -- create new mine
    enterprise_turtle = enterprise_turtle or require "enterprise_turtle"
    local mine = mobj_mine:NewMine({
        _baseLocation           = baseLocation:copy(),
        _topChests              = 2,
    })

    -- save the mine
    corelog.WriteToLog(">Adding mine, id: "..mine:getId()..".")
    local mineLocator = enterprise_gathering:saveObject(mine)
    if not mineLocator then corelog.Error("enterprise_gathering.AddNewMine_ASrv: Failed adding mine") return Callback.ErrorCall(callback) end

    -- create projectDef and projectData
    local projectData = {
        forestLocator           = mineLocator,
        topChests               = 2,
    }

    -- insert buildingn project here
    -- :-(
    -- insert buildingn project here

    -- start project
--    return enterprise_projects.StartProject_ASrv(projectServiceData, callback)
    corelog.Error("enterprise_gathering.AddNewMine_ASrv: not yet fully implemented")
    return Callback.ErrorCall(callback) -- ToDo: implement
end

--    _       _                        _                       _                                _   _               _
--   (_)     | |                      | |                     (_)                              | | | |             | |
--    _ _ __ | |_ ___ _ __ _ __   __ _| |  ___  ___ _ ____   ___  ___ ___  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   | | '_ \| __/ _ \ '__| '_ \ / _` | | / __|/ _ \ '__\ \ / / |/ __/ _ \/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   | | | | | ||  __/ |  | | | | (_| | | \__ \  __/ |   \ V /| | (_|  __/\__ \ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_|_| |_|\__\___|_|  |_| |_|\__,_|_| |___/\___|_|    \_/ |_|\___\___||___/ |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

function enterprise_gathering.BuildNewMine_ASrv(...)
    -- get & check input from description
    local checkSuccess, serviceData, baseLocation, siteVersion, materialsItemSupplierLocator, callback = InputChecker.Check([[
        This async public service builds a new factory site.

        Return value:
                                                - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                                - (table)
                success                         - (boolean) whether the site was successfully build

        Parameters:
            serviceData                         + (table) data about this service
                baseLocation                    + (Location) world location of the base (lower left corner) of this site
                siteVersion                     + (string) v0, v1, v2, depending on which mine you want
                materialsItemSupplierLocator    + (URL) locating the host of the building materials
            callback                            + (Callback) to call once service is ready
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("enterprise_gathering.BuildNewMine_ASrv: Invalid input") return Callback.ErrorCall(callback) end

    -- get site build data
    local siteBuildData = nil

    -- check the version
    if siteVersion == "v1"  then siteBuildData = mobj_mine.GetV1SiteBuildData(serviceData)
                            else
                                corelog.Error("enterprise_gathering.BuildNewMine_ASrv: Don't know how to build a mine site of version "..siteVersion)
                                return Callback.ErrorCall(callback)
    end
    siteBuildData.materialsItemSupplierLocator = materialsItemSupplierLocator

    -- let construction enterprise build the site
    corelog.WriteToLog(">Building mine at "..textutils.serialise(baseLocation, { compact = true }))
    return enterprise_construction.BuildBlueprint_ASrv(siteBuildData, callback)
end
