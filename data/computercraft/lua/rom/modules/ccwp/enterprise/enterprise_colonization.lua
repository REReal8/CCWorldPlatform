-- define module
local enterprise_colonization = {}

--[[
    The enterprise_colonization provides basic functionality for colonizing the world.
--]]

local corelog = require "corelog"

local InputChecker = require "input_checker"
local Callback = require "obj_callback"
local TaskCall = require "obj_task_call"
local Location = require "obj_location"

local role_settler = require "role_settler"

local enterprise_projects = require "enterprise_projects"
local enterprise_turtle
local enterprise_shop = require "enterprise_shop"
local enterprise_manufacturing = require "enterprise_manufacturing"
local enterprise_forestry = require "enterprise_forestry"
local enterprise_storage = require "enterprise_storage"

--                _     _ _         __                  _   _
--               | |   | (_)       / _|                | | (_)
--    _ __  _   _| |__ | |_  ___  | |_ _   _ _ __   ___| |_ _  ___  _ __  ___
--   | '_ \| | | | '_ \| | |/ __| |  _| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
--   | |_) | |_| | |_) | | | (__  | | | |_| | | | | (__| |_| | (_) | | | \__ \
--   | .__/ \__,_|_.__/|_|_|\___| |_|  \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
--   | |
--   |_|

function enterprise_colonization.CreateNewWorld_ASrv(...)
    -- get & check input from description
    local checkSuccess, callback = InputChecker.Check([[
        This public async service creates a new CCWorldPlatform world.
            It bootstraps the world logic by building an initiating several enterprise (sites).

            The turtle should already have (either equiped or in it's inventory)
                one modem
                one diamon axe
                one crafting table
                one birchSapling
            It is not necessary for the turtle to have any energy. The turtle will start by placing the sapling in front of itself.

            The function also defines the coordinate system by assuming the turtle starts at the Location {_x= 3, _y= 2, _z= 1, _dx=0, _dy=1}. This
            allows for the initial BirchForest that is build to fit in the 6x6 grid that is used in layers with the lower left coordinate of the base
            of that BirchForest being Location {_x= 0, _y= 0, _z= 1, _dx=0, _dy=1}

        Return value:
                                - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                - (table)
                success         - (boolean) whether the service executed successfully

        Parameters:
            serviceData         - (table) data about the service
                <currently none>
            callback            + (Callback) to call once service is ready
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("enterprise_colonization.CreateNewWorld_ASrv: Invalid input") return Callback.ErrorCall(callback) end

    -- ToDo: Controle of aan de voorwaarden is voldaan, modem, axe, crafting table, birch sapling

    -- ToDo: instelling van de 3,2,1 coordianten bij start, lijkt nu niet meer te werken

    -- register current turtle in shop
    -- ToDo: figure out where/ how to register (other) turtles that get added
    enterprise_turtle = enterprise_turtle or require "enterprise_turtle"
    local currentTurtleLocator = enterprise_turtle:GetCurrentTurtleLocator() if not currentTurtleLocator then corelog.Error("enterprise_colonization.CreateNewWorld_ASrv: Failed obtaining current turtleLocator") return Callback.ErrorCall(callback) end
    local serviceResult = enterprise_shop.RegisterItemSupplier_SSrv({itemSupplierLocator = currentTurtleLocator}) if not serviceResult.success then corelog.Error("failed registering Turtle in Shop") return Callback.ErrorCall(callback) end

    -- construct arguments
    local startLocation             = Location:newInstance(3, 2, 1, 0, 1)
    local forestLocation            = Location:newInstance(0, 0, 1, 0, 1)
    local initialiseCoordinatesTaskData =  {
        startLocation               = startLocation:copy(),
    }
    local collectCobbleStoneTaskData =  {
        startLocation               = startLocation:copy(),
    }

    local factoryLocation           = Location:newInstance(12, 0, 1, 0, 1)
    local nTreeswanted = 6
    local settleData = {
        materialsItemSupplierLocator    = enterprise_shop.GetShopLocator(),
        wasteItemDepotLocator           = currentTurtleLocator:copy(), -- ToDo: at some point use obj_wastehandler here + somehow pass this to enterprise_turtle:TriggerRefuelIfNeeded

        startLocation                   = startLocation:copy(),

        initialiseCoordinatesMetaData   = role_settler.InitialiseCoordinates_MetaData(initialiseCoordinatesTaskData),
        initialiseCoordinatesTaskCall   = TaskCall:newInstance("role_settler", "InitialiseCoordinates_Task", initialiseCoordinatesTaskData),

        ingredientsItemSupplierLocator  = enterprise_shop.GetShopLocator(), -- ToDo: somehow pass this to enterprise_turtle:TriggerRefuelIfNeeded

        factoryHostLocator              = enterprise_manufacturing:getHostLocator(),
        factoryClassName                = "Factory",
        factoryConstructParameters0     = {
            level                           = 0,

            baseLocation                    = startLocation:copy(),
        },

        forestHostLocator               = enterprise_forestry:getHostLocator(),
        forestClassName                 = "BirchForest",
        forestConstructParameters_Lm1T1 = {
            level                           = -1,

            baseLocation                    = forestLocation:copy(),
            nTrees                          = 1,
        },

        upgradeParametersToForestL0T1   = {
            level                           = 0,

            nTrees                          = 1,
        },
        upgradeParametersToForestL1T1   = {
            level                           = 1,

            nTrees                          = 1,
        },
        upgradeParametersToForestL1T2   = {
            level                           = 1,

            nTrees                          = 2,
        },
        upgradeParametersToForestL1T4   = {
            level                           = 1,

            nTrees                          = 4,
        },
        upgradeParametersToForestL1T6   = {
            level                           = 1,

            nTrees                          = nTreeswanted,
        },
        upgradeParametersToForestL2T6   = {
            level                           = 2,

            nTrees                          = nTreeswanted,
        },

        energyL0                        = 0,
        energyL1                        = 1,
        energyL2                        = 2,
        energyL3                        = 3,

        collectCobbleStoneMetaData      = role_settler.CollectCobbleStone_MetaData(collectCobbleStoneTaskData),
        collectCobbleStoneTaskCall      = TaskCall:newInstance("role_settler", "CollectCobbleStone_Task", collectCobbleStoneTaskData),

        factoryConstructParameters1     = {
            level                           = 1,

            baseLocation                    = factoryLocation:copy(),
        },

        upgradeParametersToFactory2     = {
            level                           = 2,
        },

        siloHostLocator                 = enterprise_storage:getHostLocator(),
        siloClassName                   = "Silo",
        siloConstructParameters         = {
            baseLocation                    = Location:newInstance(12, -12, 1, 0, 1),
            nTopChests                      = 2,
            nLayers                         = 2,
        },
    }

    -- create project definition
    local createNewWorldProjectDef = {
        steps   = { -- ToDo: introduce enterprise_energy.UpgradeSite_ASrv and wrap create steps in it as documented here https://docs.google.com/spreadsheets/d/1yqShiBSVzldGMauvwqLkRrJOjc38RUuAtjk7L1cR7Uk/edit#gid=91593168
            -- initial (L0) enterprise_energy (refuelAmount = 0, fuelNeed_Refuel = 0)
            { stepType = "SSrv", stepTypeDef = { moduleName = "enterprise_energy", serviceName = "UpdateEnterprise_SSrv" }, stepDataDef = {
                { keyDef = "enterpriseLevel"            , sourceStep = 0, sourceKeyDef = "energyL0" },
            }},
            -- initialise coordinates
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_assignmentboard", serviceName = "DoAssignment_ASrv" }, stepDataDef = {
                { keyDef = "metaData"                   , sourceStep = 0, sourceKeyDef = "initialiseCoordinatesMetaData" },
                { keyDef = "taskCall"                   , sourceStep = 0, sourceKeyDef = "initialiseCoordinatesTaskCall" },
            }, description = "Setting coordinates"},
            -- host, build and register initial (L0) Factory (crafting spot, i.e. in place hole in the ground)
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "hostAndBuildMObj_ASrv", locatorStep = 0, locatorKeyDef = "factoryHostLocator" }, stepDataDef = {
                { keyDef = "className"                      , sourceStep = 0, sourceKeyDef = "factoryClassName" },
                { keyDef = "constructParameters"            , sourceStep = 0, sourceKeyDef = "factoryConstructParameters0" },
                { keyDef = "materialsItemSupplierLocator"   , sourceStep = 0, sourceKeyDef = "materialsItemSupplierLocator" },
                { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
            }, description = "Building first Factory"},
            { stepType = "SSrv", stepTypeDef = { moduleName = "enterprise_shop", serviceName = "RegisterItemSupplier_SSrv" }, stepDataDef = {
                { keyDef = "itemSupplierLocator"        , sourceStep = 3, sourceKeyDef = "mobjLocator" },
            }},
            -- host, build and register initial (L-1) BirchForest (1 sapling in front of turtle)
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "hostAndBuildMObj_ASrv", locatorStep = 0, locatorKeyDef = "forestHostLocator" }, stepDataDef = {
                { keyDef = "className"                      , sourceStep = 0, sourceKeyDef = "forestClassName" },
                { keyDef = "constructParameters"            , sourceStep = 0, sourceKeyDef = "forestConstructParameters_Lm1T1" },
                { keyDef = "materialsItemSupplierLocator"   , sourceStep = 0, sourceKeyDef = "materialsItemSupplierLocator" },
                { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
            }, description = "Building first BirchForest"},
            { stepType = "SSrv", stepTypeDef = { moduleName = "enterprise_shop", serviceName = "RegisterItemSupplier_SSrv" }, stepDataDef = {
                { keyDef = "itemSupplierLocator"        , sourceStep = 5, sourceKeyDef = "mobjLocator" },
            }},
            -- update enterprise_energy to L1 (refuelAmount = 1 log = 60, fuelNeed_Refuel = fuelNeed_Harvest + fuelNeed_Production + fuelNeed_ForestFactoryTravel)
            { stepType = "SSrv", stepTypeDef = { moduleName = "enterprise_energy", serviceName = "UpdateEnterprise_SSrv" }, stepDataDef = {
                { keyDef = "enterpriseLevel"            , sourceStep = 0, sourceKeyDef = "energyL1" },
                { keyDef = "forestLocator"              , sourceStep = 5, sourceKeyDef = "mobjLocator" },
                { keyDef = "factoryLocator"             , sourceStep = 3, sourceKeyDef = "mobjLocator" },
            }},
            -- upgrade BirchForest to L0 (1 tree/ sapling)
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "extendAndUpgradeMObj_ASrv", locatorStep = 0, locatorKeyDef = "forestHostLocator" }, stepDataDef = {
                { keyDef = "mobjLocator"                    , sourceStep = 5, sourceKeyDef = "mobjLocator" },
                { keyDef = "upgradeParameters"              , sourceStep = 0, sourceKeyDef = "upgradeParametersToForestL0T1" },
                { keyDef = "materialsItemSupplierLocator"   , sourceStep = 0, sourceKeyDef = "materialsItemSupplierLocator" },
                { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
                -- if "no OR low on fuel"
                --  => HarvestForest_Task ("Waiting for first tree" => chop first log) => refuel to 60
                -- if still "low on fuel"
                --  => HarvestForest_Task ("chop remainder of first tree")
            }, description = "Extending BirchForest to L0 and 1 tree"},
            -- update enterprise_energy to L2 (refuelAmount = 1 tree = 300, fuelNeed_Refuel = fuelNeed_Harvest + fuelNeed_ExtraTree + fuelNeed_Production + fuelNeed_ForestFactoryTravel)
            { stepType = "SSrv", stepTypeDef = { moduleName = "enterprise_energy", serviceName = "UpdateEnterprise_SSrv" }, stepDataDef = {
                { keyDef = "enterpriseLevel"            , sourceStep = 0, sourceKeyDef = "energyL2" },
                { keyDef = "forestLocator"              , sourceStep = 5, sourceKeyDef = "mobjLocator" },
                { keyDef = "factoryLocator"             , sourceStep = 3, sourceKeyDef = "mobjLocator" },
            }},
            -- collect some cobblestone for furnance
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_assignmentboard", serviceName = "DoAssignment_ASrv" }, stepDataDef = {
                { keyDef = "metaData"                   , sourceStep = 0, sourceKeyDef = "collectCobbleStoneMetaData" },
                { keyDef = "taskCall"                   , sourceStep = 0, sourceKeyDef = "collectCobbleStoneTaskCall" },
            }, description = "Getting cobblestone"},
            -- host, build and register new L1 Factory (crafting + smelting spot)
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "hostAndBuildMObj_ASrv", locatorStep = 0, locatorKeyDef = "factoryHostLocator" }, stepDataDef = {
                { keyDef = "className"                      , sourceStep = 0, sourceKeyDef = "factoryClassName" },
                { keyDef = "constructParameters"            , sourceStep = 0, sourceKeyDef = "factoryConstructParameters1" },
                { keyDef = "materialsItemSupplierLocator"   , sourceStep = 0, sourceKeyDef = "materialsItemSupplierLocator" },
                { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
            }, description = "Building a better Factory"},
            { stepType = "SSrv", stepTypeDef = { moduleName = "enterprise_shop", serviceName = "RegisterItemSupplier_SSrv" }, stepDataDef = {
                { keyDef = "itemSupplierLocator"        , sourceStep = 11, sourceKeyDef = "mobjLocator" },
            }},
            { stepType = "SSrv", stepTypeDef = { moduleName = "enterprise_energy", serviceName = "UpdateEnterprise_SSrv" }, stepDataDef = {
                { keyDef = "enterpriseLevel"            , sourceStep = 0, sourceKeyDef = "energyL3" }, -- ToDo: back to wanted energyL2
                -- ToDo: investigate how we can postpone L3 to later ... somehow this sometimes fails. Is this because we do not yet claim resources inside the turtle??
                { keyDef = "forestLocator"              , sourceStep = 5, sourceKeyDef = "mobjLocator" },
                { keyDef = "factoryLocator"             , sourceStep = 11, sourceKeyDef = "mobjLocator" },
            }},
            -- delist, dismantle and release initial crafting spot
            { stepType = "SSrv", stepTypeDef = { moduleName = "enterprise_shop", serviceName = "DelistItemSupplier_SSrv" }, stepDataDef = {
                { keyDef = "itemSupplierLocator"        , sourceStep = 3, sourceKeyDef = "mobjLocator" },
            }},
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "dismantleAndReleaseMObj_ASrv", locatorStep = 0, locatorKeyDef = "factoryHostLocator" }, stepDataDef = {
                { keyDef = "mobjLocator"                    , sourceStep = 3, sourceKeyDef = "mobjLocator" },
                { keyDef = "materialsItemSupplierLocator"   , sourceStep = 0, sourceKeyDef = "materialsItemSupplierLocator" },
                { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
            }, description = "Removing initial Factory"},
            -- upgrade BirchForest to L1 with 1 tree
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "extendAndUpgradeMObj_ASrv", locatorStep = 0, locatorKeyDef = "forestHostLocator" }, stepDataDef = {
                { keyDef = "mobjLocator"                    , sourceStep = 5, sourceKeyDef = "mobjLocator" },
                { keyDef = "upgradeParameters"              , sourceStep = 0, sourceKeyDef = "upgradeParametersToForestL1T1" },
                { keyDef = "materialsItemSupplierLocator"   , sourceStep = 0, sourceKeyDef = "materialsItemSupplierLocator" },
                { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
            }, description = "Extending BirchForest to L1 and 1 tree"},
            -- upgrade BirchForest to L1 with 2 trees
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "extendAndUpgradeMObj_ASrv", locatorStep = 0, locatorKeyDef = "forestHostLocator" }, stepDataDef = {
                { keyDef = "mobjLocator"                    , sourceStep = 5, sourceKeyDef = "mobjLocator" },
                { keyDef = "upgradeParameters"              , sourceStep = 0, sourceKeyDef = "upgradeParametersToForestL1T2" },
                { keyDef = "materialsItemSupplierLocator"   , sourceStep = 0, sourceKeyDef = "materialsItemSupplierLocator" },
                { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
            }, description = "Extending BirchForest to L1 and 2 trees"},
            -- upgrade BirchForest to L1 with 4 trees
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "extendAndUpgradeMObj_ASrv", locatorStep = 0, locatorKeyDef = "forestHostLocator" }, stepDataDef = {
                { keyDef = "mobjLocator"                    , sourceStep = 5, sourceKeyDef = "mobjLocator" },
                { keyDef = "upgradeParameters"              , sourceStep = 0, sourceKeyDef = "upgradeParametersToForestL1T4" },
                { keyDef = "materialsItemSupplierLocator"   , sourceStep = 0, sourceKeyDef = "materialsItemSupplierLocator" },
                { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
            }, description = "Extending BirchForest to L1 and 4 trees"},
            -- upgrade BirchForest to L1 with 6 trees
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "extendAndUpgradeMObj_ASrv", locatorStep = 0, locatorKeyDef = "forestHostLocator" }, stepDataDef = {
                { keyDef = "mobjLocator"                    , sourceStep = 5, sourceKeyDef = "mobjLocator" },
                { keyDef = "upgradeParameters"              , sourceStep = 0, sourceKeyDef = "upgradeParametersToForestL1T6" },
                { keyDef = "materialsItemSupplierLocator"   , sourceStep = 0, sourceKeyDef = "materialsItemSupplierLocator" },
                { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
            }, description = "Extending BirchForest to L1 and 6 trees"},
            -- upgrade BirchForest to L2 (in/out chests + 6 trees)
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "extendAndUpgradeMObj_ASrv", locatorStep = 0, locatorKeyDef = "forestHostLocator" }, stepDataDef = {
                { keyDef = "mobjLocator"                    , sourceStep = 5, sourceKeyDef = "mobjLocator" },
                { keyDef = "upgradeParameters"              , sourceStep = 0, sourceKeyDef = "upgradeParametersToForestL2T6" },
                { keyDef = "materialsItemSupplierLocator"   , sourceStep = 0, sourceKeyDef = "materialsItemSupplierLocator" },
                { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
            }, description = "Extending BirchForest to L2 and 6 trees"},
            -- upgrade/ replace existing L1 Factory to/ with L2 Factory (in/out chests, crafting + smelting spot)
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "extendAndUpgradeMObj_ASrv", locatorStep = 0, locatorKeyDef = "factoryHostLocator" }, stepDataDef = {
                { keyDef = "mobjLocator"                    , sourceStep = 11, sourceKeyDef = "mobjLocator" },
                { keyDef = "upgradeParameters"              , sourceStep = 0, sourceKeyDef = "upgradeParametersToFactory2" },
                { keyDef = "materialsItemSupplierLocator"   , sourceStep = 0, sourceKeyDef = "materialsItemSupplierLocator" },
                { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
            }, description = "Extending Factory to L2"},
            -- host, build and register Silo
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "hostAndBuildMObj_ASrv", locatorStep = 0, locatorKeyDef = "siloHostLocator" }, stepDataDef = {
                { keyDef = "className"                      , sourceStep = 0, sourceKeyDef = "siloClassName" },
                { keyDef = "constructParameters"            , sourceStep = 0, sourceKeyDef = "siloConstructParameters" },
                { keyDef = "materialsItemSupplierLocator"   , sourceStep = 0, sourceKeyDef = "materialsItemSupplierLocator" },
                { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
            }, description = "Building silo"},
            { stepType = "SSrv", stepTypeDef = { moduleName = "enterprise_shop", serviceName = "RegisterItemSupplier_SSrv" }, stepDataDef = {
                { keyDef = "itemSupplierLocator"            , sourceStep = 22, sourceKeyDef = "mobjLocator" },
            }},
            -- update enterprise_energy to L3 (refuelAmount = 6 trees = 1800, fuelNeed_Refuel = fuelNeed_Harvest + fuelNeed_ExtraTree + fuelNeed_Production + fuelNeed_ForestFactoryTravel)
            { stepType = "SSrv", stepTypeDef = { moduleName = "enterprise_energy", serviceName = "UpdateEnterprise_SSrv" }, stepDataDef = {
                { keyDef = "enterpriseLevel"            , sourceStep = 0, sourceKeyDef = "energyL3" },
                { keyDef = "forestLocator"              , sourceStep = 5, sourceKeyDef = "mobjLocator" },
                { keyDef = "factoryLocator"             , sourceStep = 11, sourceKeyDef = "mobjLocator" },
            }},
        },
        returnData  = {
        }
    }
    local projectServiceData = {
        projectDef  = createNewWorldProjectDef,
        projectData = settleData,
        projectMeta = { title = "Project colonize", description = "Creating a new world" },
    }

    -- start project
    return enterprise_projects.StartProject_ASrv(projectServiceData, callback)
end

--    _                 _    __                  _   _
--   | |               | |  / _|                | | (_)
--   | | ___   ___ __ _| | | |_ _   _ _ __   ___| |_ _  ___  _ __  ___
--   | |/ _ \ / __/ _` | | |  _| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
--   | | (_) | (_| (_| | | | | | |_| | | | | (__| |_| | (_) | | | \__ \
--   |_|\___/ \___\__,_|_| |_|  \__,_|_| |_|\___|\__|_|\___/|_| |_|___/

return enterprise_colonization
