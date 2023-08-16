local Host = require "obj_host"

local enterprise_manufacturing = Host:new({
    _hostName   = "enterprise_manufacturing",
})

local coreutils = require "coreutils"
local corelog = require "corelog"

local InputChecker = require "input_checker"
local Callback = require "obj_callback"

local Factory = require "mobj_factory"

local enterprise_projects = require "enterprise_projects"
local enterprise_construction = require "enterprise_construction"

local db = {
    -- turtle slots
    -- [ 1] [ 2] [ 3] [ 4]
    -- [ 5] [ 6] [ 7] [ 8]
    -- [ 9] [10] [11] [12]
    -- [13] [14] [15] [16]
    recipes        = {
        ["minecraft:stick"] = {
            crafting  = {
                  [6]    = { itemName = "minecraft:birch_planks",   itemCount = 1 },
                 [10]    = { itemName = "minecraft:birch_planks",   itemCount = 1 },
                yield   = 4
            },
        },
        ["minecraft:charcoal"] = { -- ToDo consider similar format to crafting to simpify code
            smelting  = {
                itemName    = "minecraft:birch_log",
                yield       = 1,
            },
        },
        ["minecraft:torch"] = {
            crafting  = {
                 [6]    = { itemName = "minecraft:charcoal",        itemCount = 1 },
                [10]    = { itemName = "minecraft:stick",           itemCount = 1 },
               yield   = 4
           },
        },
        ["minecraft:birch_planks"] = {
            crafting  = {
                 [6]    = { itemName = "minecraft:birch_log",       itemCount = 1 },
                yield   = 4
            },
        },
        ["minecraft:chest"] = {
            crafting  = {
                 [6]    = { itemName = "minecraft:birch_planks",    itemCount = 1 },
                 [7]    = { itemName = "minecraft:birch_planks",    itemCount = 1 },
                 [8]    = { itemName = "minecraft:birch_planks",    itemCount = 1 },
                [10]    = { itemName = "minecraft:birch_planks",    itemCount = 1 },
                [12]    = { itemName = "minecraft:birch_planks",    itemCount = 1 },
                [14]    = { itemName = "minecraft:birch_planks",    itemCount = 1 },
                [15]    = { itemName = "minecraft:birch_planks",    itemCount = 1 },
                [16]    = { itemName = "minecraft:birch_planks",    itemCount = 1 },
                yield   = 1
            },
        },
        ["minecraft:furnace"] = {
            crafting  = {
                 [6]    = { itemName = "minecraft:cobblestone",    itemCount = 1 },
                 [7]    = { itemName = "minecraft:cobblestone",    itemCount = 1 },
                 [8]    = { itemName = "minecraft:cobblestone",    itemCount = 1 },
                [10]    = { itemName = "minecraft:cobblestone",    itemCount = 1 },
                [12]    = { itemName = "minecraft:cobblestone",    itemCount = 1 },
                [14]    = { itemName = "minecraft:cobblestone",    itemCount = 1 },
                [15]    = { itemName = "minecraft:cobblestone",    itemCount = 1 },
                [16]    = { itemName = "minecraft:cobblestone",    itemCount = 1 },
                yield   = 1
            },
        },
    }
}

-- ToDo: consider refactoring and putting this elsewhere (a recipe book?)
function enterprise_manufacturing.GetRecipes()
    return db.recipes
end

--[[
    The enterprise_manufacturing is a Host. It hosts ItemSupplier's (i.e. Factory's) that can produce items.

    There are (currently) two recipe types for producing items.
        The crafting recipe uses the crafting production technique to produce an output item from a set of input items (ingredients).
        The smelting recipe uses the smelting production technique to produce an output item from an input item (ingredient).
--]]

--                        _                           _   _               _
--                       (_)                         | | | |             | |
--    ___  ___ _ ____   ___  ___ ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \  __/ |   \ V /| | (_|  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/\___|_|    \_/ |_|\___\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

function enterprise_manufacturing.BuildAndStartNewSite_ASrv(...)
    -- get & check input from description
    local checkSuccess, serviceData, upgrade, callback = InputChecker.Check([[
        This async public service builds a new factory site and ensures it's ready for use.

        Return value:
                                                - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                                - (table)
                success                         - (boolean) whether the site was successfully build and is ready for use.
                siteLocator                     - (URL) locating the created site (in this enterprise)

        Parameters:
            serviceData                         + (table) data about this site
                baseLocation                    - (Location) world location of the base (lower left corner) of this site
                siteVersion                     - (string) version string of the site
                upgrade                         + (boolean, false) if site should (only) be updated from a previous version
                siteLocator                     - (URL, nil) locating the to be upgraded site
                materialsItemSupplierLocator    - (URL) locating the host of the building materials
                wasteItemDepotLocator           - (URL) locating where waste material can be delivered
            callback                            + (Callback) to call once service is ready
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("enterprise_manufacturing.BuildAndStartNewSite_ASrv: Invalid input") return Callback.ErrorCall(callback) end

    -- determine projectSteps
    local projectSteps = { }
    local iStep = 0
    table.insert(projectSteps,
        { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_manufacturing", serviceName = "BuildNewSite_ASrv" }, stepDataDef = {
            { keyDef = "baseLocation"                   , sourceStep = 0, sourceKeyDef = "baseLocation" },
            { keyDef = "siteVersion"                    , sourceStep = 0, sourceKeyDef = "siteVersion" },
            { keyDef = "upgrade"                        , sourceStep = 0, sourceKeyDef = "upgrade" },
            { keyDef = "materialsItemSupplierLocator"   , sourceStep = 0, sourceKeyDef = "materialsItemSupplierLocator" },
            { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
        }}
    )
    iStep = iStep + 1

    -- only when upgrading a site
    if upgrade then
        table.insert(projectSteps,
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_manufacturing", serviceName = "StopSite_ASrv" }, stepDataDef = {
                { keyDef = "siteLocator"        , sourceStep = 0, sourceKeyDef = "siteLocator" },
            }}
        )
        iStep = iStep + 1
    end

    -- continue
    table.insert(projectSteps,
        { stepType = "SSrv", stepTypeDef = { moduleName = "enterprise_manufacturing", serviceName = "StartNewSite_SSrv" }, stepDataDef = {
            { keyDef = "baseLocation"           , sourceStep = 0, sourceKeyDef = "baseLocation" },
            { keyDef = "siteVersion"            , sourceStep = 0, sourceKeyDef = "siteVersion" },
            { keyDef = "siteAlreadyBuild"       , sourceStep = iStep, sourceKeyDef = "success" }
        }}
    )
    iStep = iStep + 1

    -- create project definition
    local buildAndStartNewSiteProjectDef = {
        steps = projectSteps,
        returnData  = {
            { keyDef = "siteLocator"            , sourceStep = iStep, sourceKeyDef = "siteLocator" },
        }
    }
    local projectServiceData = {
        projectDef  = buildAndStartNewSiteProjectDef,
        projectData = serviceData,
        projectMeta = { title = "Building new factory", description = "Crafting the world for you!" },
    }

    -- start project
--    corelog.WriteToLog(">Building and starting factory site version "..siteVersion.." at "..textutils.serialise(baseLocation))
    return enterprise_projects.StartProject_ASrv(projectServiceData, callback)
end

function enterprise_manufacturing.BuildNewSite_ASrv(...)
    -- get & check input from description
    local checkSuccess, serviceData, baseLocation, siteVersion, upgrade, materialsItemSupplierLocator, wasteItemDepotLocator, callback = InputChecker.Check([[
        This async public service builds a new factory site.

        Return value:
                                                - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                                - (table)
                success                         - (boolean) whether the site was successfully build

        Parameters:
            serviceData                         + (table) data about this service
                baseLocation                    + (Location) world location of the base (lower left corner) of this site
                siteVersion                     + (string) version string of the site
                upgrade                         + (boolean, false) if site should (only) be updated from a previous version
                materialsItemSupplierLocator    + (URL) locating the host of the building materials
                wasteItemDepotLocator           + (URL) locating where waste material can be delivered
            callback                            + (Callback) to call once service is ready
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("enterprise_manufacturing.BuildNewSite_ASrv: Invalid input") return Callback.ErrorCall(callback) end

    -- get site build data
    local siteBuildData = nil
    if siteVersion == "v0" then
        siteBuildData = Factory.GetV0SiteBuildData(serviceData)
    elseif siteVersion == "v1" then
        siteBuildData = Factory.GetV1SiteBuildData(serviceData)
    elseif siteVersion == "v2" then
        siteBuildData = Factory.GetV2SiteBuildData(serviceData)
    else
        corelog.Error("enterprise_manufacturing.BuildNewSite_ASrv: Don't know how to build a factory site of version "..siteVersion)
        return Callback.ErrorCall(callback)
    end
    siteBuildData.materialsItemSupplierLocator = materialsItemSupplierLocator
    siteBuildData.wasteItemDepotLocator = wasteItemDepotLocator

    -- let construction enterprise build the site
    if upgrade then
        corelog.WriteToLog(">Upgrading factory site at "..textutils.serialise(baseLocation, { compact = true }).." to version "..siteVersion)
    else
        corelog.WriteToLog(">Building factory site version "..siteVersion.." at "..textutils.serialise(baseLocation, { compact = true }))
    end
    return enterprise_construction.BuildBlueprint_ASrv(siteBuildData, callback)
end

function enterprise_manufacturing.StartNewSite_SSrv(...)
    -- get & check input from description
    local checkSuccess, serviceData, siteVersion, siteAlreadyBuild = InputChecker.Check([[
        This sync public service ensures a new site is ready for use.

        Return value:
                                    - (table)
                success             - (boolean) whether the site is ready for business
                siteLocator         - (URL) locating the created site (in this enterprise)

        Parameters:
            serviceData             + (table) data about this service
                baseLocation        - (Location) world location of the base (lower left corner) of this site
                siteVersion         + (string) version string of the site
                siteAlreadyBuild    + (boolean) confirmation that the site was already physically build
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("enterprise_manufacturing.StartNewSite_SSrv: Invalid input") return {success = false} end
    if not siteAlreadyBuild then corelog.Warning("enterprise_manufacturing.StartNewSite_SSrv: Site not (yet) successfully build => we will not start it") return {success = false} end

    -- get site start data
    local siteStartData = nil
    if siteVersion == "v0" then
        siteStartData = Factory.GetV0SiteStartData(serviceData)
    elseif siteVersion == "v1" then
        siteStartData = Factory.GetV1SiteStartData(serviceData)
    elseif siteVersion == "v2" then
        siteStartData = Factory.GetV2SiteStartData(serviceData)
    else
        corelog.Error("enterprise_manufacturing.StartNewSite_SSrv: Don't know how to start a factory site of version "..siteVersion)
        return {success = false}
    end

    -- create new Factory
    local factory = Factory:new({
--        _version        = siteStartData.version,
        _id             = coreutils.NewId(),

        _baseLocation   = siteStartData.baseLocation,
--        _entryLocation   = siteStartData.location:getRelativeLocation(3, 3, 1), -- ToDo: consider adding and using (before moving to workingLocation)

        _inputLocators  = siteStartData.inputLocators,
        _outputLocators = siteStartData.outputLocators,

        _craftingSpots  = siteStartData.craftingSpots,
        _smeltingSpots  = siteStartData.smeltingSpots,
    })

    -- ToDo: initialise possible other data (like e.g. open for business, availability of spots)

    -- save the Factory
    corelog.WriteToLog(">Adding Factory "..factory:getId()..".")
    local siteLocator = enterprise_manufacturing:saveObject(factory)
    if not siteLocator then corelog.Error("enterprise_manufacturing.StartNewSite_SSrv: Failed starting site from start data "..textutils.serialize(siteStartData)) return {success = false} end

    -- end
    return {
        success     = true,
        siteLocator = siteLocator,
    }
end

-- ToDo: retrieve baseLocation via siteLocator (+ also siteVersion?)
function enterprise_manufacturing.StopAndDismantleSite_ASrv(...)
    -- get & check input from description
    local checkSuccess, serviceData, siteVersion, callback = InputChecker.Check([[
        This async public service stops and dismantles a site.

        Return value:
                                                - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                                - (table)
                success                         - (boolean) whether the site was successfully stopped and dismantled.

        Parameters:
            serviceData                         + (table) data about this service
                siteLocator                     - (URL) locating the site
                baseLocation                    - (Location) world location of the base (lower left corner) of this site
                siteVersion                     + (string) version string of the site
                materialsItemSupplierLocator    - (URL) locating the host of the building materials
                wasteItemDepotLocator           - (URL) locating where waste material can be delivered
            callback                            + (Callback) to call once service is ready
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("enterprise_manufacturing.StopAndDismantleSite_ASrv: Invalid input") return Callback.ErrorCall(callback) end

    -- create project definition
    local stopAndDismantleSiteProjectDef = {
        steps = {
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_manufacturing", serviceName = "StopSite_ASrv" }, stepDataDef = {
                { keyDef = "siteLocator"            , sourceStep = 0, sourceKeyDef = "siteLocator" },
            }},
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_manufacturing", serviceName = "DismantleSite_ASrv" }, stepDataDef = {
                { keyDef = "baseLocation"                   , sourceStep = 0, sourceKeyDef = "baseLocation" },
                { keyDef = "siteVersion"                    , sourceStep = 0, sourceKeyDef = "siteVersion" },
                { keyDef = "siteStopped"                    , sourceStep = 1, sourceKeyDef = "success" },
                { keyDef = "materialsItemSupplierLocator"   , sourceStep = 0, sourceKeyDef = "materialsItemSupplierLocator" },
                { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
            }},
        },
        returnData  = {
        }
    }
    local projectServiceData = {
        projectDef  = stopAndDismantleSiteProjectDef,
        projectData = serviceData,
        projectMeta = { title = "Removing factory", description = "We regred though respect your choice" },
    }

    -- start project
    corelog.WriteToLog(">Stopping and dismantling factory site version "..siteVersion)
    return enterprise_projects.StartProject_ASrv(projectServiceData, callback)
end

function enterprise_manufacturing.DismantleSite_ASrv(...)
    -- get & check input from description
    local checkSuccess, serviceData, siteVersion, siteStopped, materialsItemSupplierLocator, wasteItemDepotLocator, callback = InputChecker.Check([[
        This async public service dismantles a factory site. Dismantling means the site is physically removed from minecraft world.
        Possibly part of the world is restored to a neutral (e.g. flat) state.

        Return value:
                                                - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                                - (table)
                success                         - (boolean) whether the site was successfully dismantled

        Parameters:
            serviceData                         + (table) data about this service
                baseLocation                    - (Location) world location of the base (lower left corner) of the site
                siteVersion                     + (string) version string of the site
                siteStopped                     + (boolean) confirmation that the site was already stopped
                materialsItemSupplierLocator    + (URL) locating the host of the building materials
                wasteItemDepotLocator           + (URL) locating where waste material can be delivered
            callback                            + (Callback) to call once service is ready
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("enterprise_manufacturing.DismantleSite_ASrv: Invalid input") return Callback.ErrorCall(callback) end

    -- check input
    if not siteStopped then corelog.Warning("enterprise_manufacturing.DismantleSite_ASrv: Site not (yet) stopped => we will not dismantle it") return Callback.ErrorCall(callback) end

    -- get site dismantal data
    local siteDismantleBuildData = nil
    if siteVersion == "v0" then
        siteDismantleBuildData = Factory.GetV0SiteDismantleBuildData(serviceData)
-- ToDo implement for v1 and v2
--    elseif siteVersion == "v1" then
--        siteDismantleBuildData = Factory.GetV1SiteDismantleBuildData(serviceData)
--    elseif siteVersion == "v2" then
--        siteDismantleBuildData = Factory.GetV2SiteDismantleBuildData(serviceData)
    else
        corelog.Error("enterprise_manufacturing.DismantleSite_ASrv: Don't know how to dismantle a factory site of version "..siteVersion)
        return Callback.ErrorCall(callback)
    end
    siteDismantleBuildData.materialsItemSupplierLocator = materialsItemSupplierLocator
    siteDismantleBuildData.wasteItemDepotLocator = wasteItemDepotLocator

    -- let construction enterprise dismantle the site
    return enterprise_construction.BuildBlueprint_ASrv(siteDismantleBuildData, callback)
end

function enterprise_manufacturing.StopSite_ASrv(...)
    -- get & check input from description
    local checkSuccess, siteLocator, callback = InputChecker.Check([[
        This async public service stops a factory site. Stopping implies
          - the site is immediatly no longer available for new business
          - wait for all active work (production) on site to be ended
          - remove the site from the factory

        Return value:
                                - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                - (table)
                success         - (boolean) when the site was successfully stopped

        Parameters:
            serviceData         - (table) data about this service
                siteLocator     + (URL) locating the site
            callback            + (Callback) to call once service is ready
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("enterprise_manufacturing.StopSite_ASrv: Invalid input") return Callback.ErrorCall(callback) end

    -- get the site
    local site = enterprise_manufacturing:getObject(siteLocator)
    if type(site) ~="table" then corelog.Error("enterprise_manufacturing.StopSite_ASrv: Failed retrieving site "..siteLocator:getURI()) return Callback.ErrorCall(callback) end

    -- stop doing business for this site
    -- ToDo: implement

    -- wait for active work done
    -- ToDo: implement

    -- remove site from enterprise
    corelog.WriteToLog(">Removing site "..site:getId())
    enterprise_manufacturing:deleteResource(siteLocator)

    -- do callback
    return callback:call({success = true})
end

return enterprise_manufacturing