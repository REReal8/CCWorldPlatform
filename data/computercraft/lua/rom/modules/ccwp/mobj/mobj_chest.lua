-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local IMObj = require "i_mobj"
local IItemSupplier = require "i_item_supplier"
local IItemDepot = require "i_item_depot"
local Chest = Class.NewClass(ObjBase, IMObj, IItemSupplier, IItemDepot)

--[[
    The Chest mobj represents a Chest in the minecraft world and provides services to operate on that Chest.

    The following design decisions are made
        - The actual Chest's should never be accessed directly but only via the services of this mobj.
--]]

local coreutils = require "coreutils"
local corelog = require "corelog"

local InputChecker = require "input_checker"
local Callback = require "obj_callback"
local TaskCall = require "obj_task_call"
local Host = require "obj_host"
local ObjTable = require "obj_table"
local Location = require "obj_location"
local Inventory = require "obj_inventory"
local Block = require "obj_block"
local CodeMap = require "obj_code_map"
local LayerRectangle = require "obj_layer_rectangle"

local role_fuel_worker = require "role_fuel_worker"
local role_chests_worker = require "role_chests_worker"

local enterprise_isp = require "enterprise_isp"
local enterprise_projects = require "enterprise_projects"
local enterprise_turtle
local enterprise_chests

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function Chest:_init(...)
    -- get & check input from description
    local checkSuccess, id, baseLocation, accessDirection, inventory = InputChecker.Check([[
        Initialise a Chest.

        Parameters:
            id                      + (string) id of the Chest
            baseLocation            + (Location) base location of the Chest
            accessDirection         + (string) whether to access Chest from "bottom", "top", "left", "right", "front" or "back" (relative to location)
            inventory               + (Inventory) inventory of Chest
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Chest:_init: Invalid input") return nil end

    -- initialisation
    ObjBase._init(self)
    self._id                = id
    self._baseLocation      = baseLocation
    self._accessDirection   = accessDirection
    self._inventory         = inventory
end

-- ToDo: should be renamed to newFromTable at some point
function Chest:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a Chest.

        Parameters:
            o                           + (table, {}) with object fields
                _id                     - (string) id of the Chest
                _baseLocation           - (Location) base location of the Chest
                _accessDirection        - (string) whether to access Chest from "bottom", "top", "left", "right", "front" or "back" (relative to location)
                _inventory              - (Inventory) inventory of Chest
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Chest:new: Invalid input") return nil end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- end
    return o
end

function Chest:getBaseLocation()
    return self._baseLocation
end

function Chest:getAccessDirection()
    return self._accessDirection
end

function Chest:getInventory()
    return self._inventory
end

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

function Chest:getClassName()
    return "Chest"
end

--    _____ __  __  ____  _     _
--   |_   _|  \/  |/ __ \| |   (_)
--     | | | \  / | |  | | |__  _
--     | | | |\/| | |  | | '_ \| |
--    _| |_| |  | | |__| | |_) | |
--   |_____|_|  |_|\____/|_.__/| |
--                            _/ |
--                           |__/

function Chest:construct(...)
    -- get & check input from description
    local checkSuccess, baseLocation, accessDirection = InputChecker.Check([[
        This method constructs a Chest instance from a table of parameters with all necessary fields (in an objectTable) and methods (by setmetatable) as defined in the class.

        The constructed Chest is not yet saved in the Host.

        Return value:
                                        - (Chest) the constructed Chest

        Parameters:
            constructParameters         - (table) parameters for constructing the Chest
                baseLocation            + (Location) base location of the Chest
                accessDirection         + (string, "top") whether to access chest from "bottom", "top", "left", "right", "front" or "back" (relative to location)
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Chest:construct: Invalid input") return nil end

    -- determine Chest fields
    local id = coreutils.NewId()
    local inventory = Inventory:newInstance() -- assumed to be empty

    -- construct new Chest
    local obj = Chest:newInstance(id, baseLocation:copy(), accessDirection, inventory)

    -- end
    return obj
end

function Chest:destruct()
    --[[
        This method destructs a Chest instance.

        The Chest is not yet deleted from the Host.

        Return value:
                                        - (boolean) whether the Chest was succesfully destructed.

        Parameters:
    ]]

    -- end
    return true
end

function Chest:getId()
    --[[
        Return the unique Id of the Chest.
    ]]

    return self._id
end

function Chest:getWIPId()
    --[[
        Returns the unique Id of the Chest used for administering WIP.
    ]]

    return self:getClassName().." "..self:getId()
end

local function Chest_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            ["C"]   = Block:newInstance("minecraft:chest"),
        }),
        CodeMap:newInstance({
            [1] = "C",
        })
    )
end

function Chest:getBuildBlueprint()
    --[[
        This method returns a blueprint for building the Chest in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
    ]]

    -- construct layer list
    local layerList = {
        { startpoint = Location:newInstance(0, 0, 0), buildDirection = "Down", layer = Chest_layer()},
    }

    -- construct blueprint
    local blueprint = {
        layerList = layerList,
        escapeSequence = {
        }
    }

    -- determine buildLocation
    local buildLocation = self._baseLocation:copy()

    -- end
    return buildLocation, blueprint
end

local function ChestDismantle_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        CodeMap:newInstance({
            [1] = " ",
        })
    )
end

function Chest:getDismantleBlueprint()
    --[[
        This method returns a blueprint for dismantling the Chest in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
    ]]

    -- construct layer list
    local layerList = {
        { startpoint = Location:newInstance(0, 0, 0), buildDirection = "Down", layer = ChestDismantle_layer()},
    }

    -- construct blueprint
    local blueprint = {
        layerList = layerList,
        escapeSequence = {
        }
    }

    -- determine buildLocation
    local buildLocation = self._baseLocation:copy()

    -- end
    return buildLocation, blueprint
end

--                        _
--                       (_)
--    ___  ___ _ ____   ___  ___ ___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \
--   \__ \  __/ |   \ V /| | (_|  __/
--   |___/\___|_|    \_/ |_|\___\___|

function Chest:updateChestRecord_AOSrv(...)
    -- get & check input from description
    local checkSuccess, callback = InputChecker.Check([[
        This async service brings the records of the chest up-to-date by fetching information and (re)setting the chest records.

        Using this method should normally not be needed as the records should be kept up-to-date by the various enterprise services. It could
        typically be used for development purposes or, if for some reason (e.g. after a turtle crash), the chest records could have been corrupted.

        Return value:
                                - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                - (table)
                success         - (boolean) whether the service executed successfully
                chest           - (table) the chest

        Parameters:
            serviceData         - (table) data about the service
            callback            + (Callback) to call once service is ready
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Chest:updateChestRecord_AOSrv: Invalid input") return Callback.ErrorCall(callback) end

    -- create project definition
    local taskData = {
        location = self:getBaseLocation():copy(),
        accessDirection = self:getAccessDirection(),
    }
    local projectData = {
        hostName        = "enterprise_chests",
        className       = "Chest",
        chest           = self:copy(),

        metaData        = role_chests_worker.FetchChestSlotsInventory_MetaData(taskData),
        taskCall        = TaskCall:newInstance("role_chests_worker", "FetchChestSlotsInventory_Task", taskData),
    }
    local projectDef = {
        steps   = {
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_assignmentboard", serviceName = "DoAssignment_ASrv" }, stepDataDef = {
                { keyDef = "metaData"               , sourceStep = 0, sourceKeyDef = "metaData" },
                { keyDef = "taskCall"               , sourceStep = 0, sourceKeyDef = "taskCall" },
            }, description = "Fetching chest inventory"},
            -- save chest
            { stepType = "SSrv", stepTypeDef = { moduleName = "enterprise_chests", serviceName = "SaveObject_SSrv" }, stepDataDef = {
                { keyDef = "hostName"               , sourceStep = 0, sourceKeyDef = "hostName" },
                { keyDef = "className"              , sourceStep = 0, sourceKeyDef = "className" },
                { keyDef = "objectTable"            , sourceStep = 0, sourceKeyDef = "chest" },
                { keyDef = "objectTable._inventory" , sourceStep = 1, sourceKeyDef = "inventory" },
            }},
        },
        returnData  = {
        }
    }
    local projectServiceData = {
        projectDef  = projectDef,
        projectData = projectData,
        projectMeta = { title = "Updating record "..self:getWIPId(), description = "Sit back and relax", wipId = self:getWIPId() },
    }

    -- start project
    return enterprise_projects.StartProject_ASrv(projectServiceData, callback)
end

--    _____ _____ _                  _____                   _ _
--   |_   _|_   _| |                / ____|                 | (_)
--     | |   | | | |_ ___ _ __ ___ | (___  _   _ _ __  _ __ | |_  ___ _ __
--     | |   | | | __/ _ \ '_ ` _ \ \___ \| | | | '_ \| '_ \| | |/ _ \ '__|
--    _| |_ _| |_| ||  __/ | | | | |____) | |_| | |_) | |_) | | |  __/ |
--   |_____|_____|\__\___|_| |_| |_|_____/ \__,_| .__/| .__/|_|_|\___|_|
--                                              | |   | |
--                                              |_|   |_|

function Chest:provideItemsTo_AOSrv(...)
    -- get & check input from description
    local checkSuccess, provideItems, itemDepotLocator, assignmentsPriorityKey, callback = InputChecker.Check([[
        This async public ItemSupplier service provides specific items to an ItemDepot.

        Return value:
                                                - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                                - (table)
                success                         - (boolean) whether the service executed correctly
                destinationItemsLocator         - (URL) locating the final ItemDepot and the items that where transferred to it
                                                    (upon service succes the "host" component of this URL should be equal to itemDepotLocator, and
                                                    the "query" should be equal to orderItems)

        Parameters:
            serviceData                         - (table) data for the service
                provideItems                    + (table) with one or more items (formatted as an array of [itemName] = itemCount key-value pairs) to provide
                itemDepotLocator                + (URL) locating the ItemDepot where the items need to be provided to
                assignmentsPriorityKey          + (string, "") priorityKey that should be set for all assignments triggered by this service
            callback                            + (Callback) to call once service is ready
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Chest:provideItemsTo_AOSrv: Invalid input") return Callback.ErrorCall(callback) end

    -- check if ItemDepot is a turtle
    enterprise_turtle = enterprise_turtle or require "enterprise_turtle"
    local workerId = -1
    if enterprise_turtle:isLocatorFromHost(itemDepotLocator) then
        local turtleObj = Host.GetObject(itemDepotLocator) if not turtleObj then corelog.Error("Chest:provideItemsTo_AOSrv: Failed obtaining turtle "..itemDepotLocator:getURI()) return Callback.ErrorCall(callback) end
        workerId = turtleObj:getWorkerId()
    end

    -- create project definition
    local taskData = {
        location        = self:getBaseLocation():copy(),
        accessDirection = self:getAccessDirection(),
        itemsQuery      = provideItems,

        turtleId        = workerId,
        priorityKey     = assignmentsPriorityKey,
    }
    local projectData = {
        hostName                = "enterprise_chests",
        className               = "Chest",
        chest                   = self:copy(),

        metaData                = role_chests_worker.FetchItemsFromChestIntoTurtle_MetaData(taskData),
        taskCall                = TaskCall:newInstance("role_chests_worker", "FetchItemsFromChestIntoTurtle_Task", taskData),

        itemDepotLocator        = itemDepotLocator,
        assignmentsPriorityKey  = assignmentsPriorityKey,
    }
    local projectDef = {
        steps   = {
            -- put items from chest
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_assignmentboard", serviceName = "DoAssignment_ASrv" }, stepDataDef = {
                { keyDef = "metaData"               , sourceStep = 0, sourceKeyDef = "metaData" },
                { keyDef = "taskCall"               , sourceStep = 0, sourceKeyDef = "taskCall" },
            }},
            -- save chest
            { stepType = "SSrv", stepTypeDef = { moduleName = "enterprise_chests", serviceName = "SaveObject_SSrv" }, stepDataDef = {
                { keyDef = "hostName"               , sourceStep = 0, sourceKeyDef = "hostName" },
                { keyDef = "className"              , sourceStep = 0, sourceKeyDef = "className" },
                { keyDef = "objectTable"            , sourceStep = 0, sourceKeyDef = "chest" },
                { keyDef = "objectTable._inventory" , sourceStep = 1, sourceKeyDef = "inventory" },
            }},
            -- store items to ItemDepot
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "storeItemsFrom_AOSrv", locatorStep = 0, locatorKeyDef = "itemDepotLocator" }, stepDataDef = {
                { keyDef = "itemsLocator"           , sourceStep = 1, sourceKeyDef = "turtleOutputItemsLocator" },
                { keyDef = "assignmentsPriorityKey" , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
            }},
        },
        returnData  = {
            { keyDef = "destinationItemsLocator"    , sourceStep = 3, sourceKeyDef = "destinationItemsLocator" },
        }
    }
    local projectServiceData = {
        projectDef  = projectDef,
        projectData = projectData,
        projectMeta = { title = "Providing items from "..self:getWIPId(), description = "The items will be deliverd", wipId = self:getWIPId() },
    }

    -- start project
    return enterprise_projects.StartProject_ASrv(projectServiceData, callback)
end

function Chest:can_ProvideItems_QOSrv(...)
    -- get & check input from description
    local checkSuccess, provideItems = InputChecker.Check([[
        This sync public query service answers the question whether the ItemSupplier can provide specific items.

        Return value:
                                    - (table)
                success             - (boolean) whether the answer to the question is true

        Parameters:
            serviceData             - (table) data to the query
                provideItems        + (table) with one or more items (formatted as an array of [itemName] = itemCount key-value pairs) to provide
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Chest:can_ProvideItems_QOSrv: Invalid input") return {success = false} end

    -- check items in inventory
    local hasItems = self:getInventory():hasItems(provideItems)

    -- end
    return {
        success = hasItems,
    }
end

function Chest:needsTo_ProvideItemsTo_SOSrv(...)
    -- get & check input from description
    local checkSuccess, provideItems, itemDepotLocator = InputChecker.Check([[
        This sync public service returns the needs for the ItemSupplier to provide specific items to an ItemDepot.

        Return value:
                                                - (table)
                success                         - (boolean) whether the service executed correctly
                fuelNeed                        - (number) amount of fuel needed to provide items
                ingredientsNeed                 - (table) ingredients needed to provide items

        Parameters:
            serviceData                         - (table) data to the query
                provideItems                    + (table) with one or more items (formatted as an array of [itemName] = itemCount key-value pairs) to provide
                itemDepotLocator                + (URL) locating the ItemDepot where the items need to be provided to
                ingredientsItemSupplierLocator  - (URL, nil) locating where ingredients can be retrieved
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Chest:needsTo_ProvideItemsTo_SOSrv: Invalid input") return {success = false} end

    -- get location
    local chestLocation = self:getBaseLocation()

    -- loop on items
    local fuelNeed = 0
    for itemName, itemCount in pairs(provideItems) do
        -- check
        if type(itemName) ~= "string" then corelog.Error("Chest:needsTo_ProvideItemsTo_SOSrv: Invalid itemName (type="..type(itemName)..")") return {success = false} end
        if type(itemCount) ~= "number" then corelog.Error("Chest:needsTo_ProvideItemsTo_SOSrv: Invalid itemCount (type="..type(itemCount)..")") return {success = false} end

        -- fuelNeed from chest to itemDepotLocator
        local serviceData = {
            itemDepotLocator = itemDepotLocator,
        }
        local serviceResults =  enterprise_isp.GetItemDepotLocation_SSrv(serviceData)
        if not serviceResults or not serviceResults.success then corelog.Error("Chest:needsTo_ProvideItemsTo_SOSrv: failed obtaining location for ItemDepot "..type(itemDepotLocator)..".") return {success = false} end
        -- ToDo: consider how to handle if path isn't the shortest route, should we maybe modify things to do something like GetTravelDistanceBetween
        local fuelNeed_FromChestToItemDepot = role_fuel_worker.NeededFuelToFrom(serviceResults.location, chestLocation)

        -- add fuelNeed
--        corelog.WriteToLog("C  fuelNeed_FromChestToItemDepot="..fuelNeed_FromChestToItemDepot)
        fuelNeed = fuelNeed + fuelNeed_FromChestToItemDepot
    end

    -- end
    local ingredientsNeed = {}
    return {
        success         = true,
        fuelNeed        = fuelNeed,
        ingredientsNeed = ingredientsNeed,
    }
end

--    _____ _____ _                 _____                   _
--   |_   _|_   _| |               |  __ \                 | |
--     | |   | | | |_ ___ _ __ ___ | |  | | ___ _ __   ___ | |_
--     | |   | | | __/ _ \ '_ ` _ \| |  | |/ _ \ '_ \ / _ \| __|
--    _| |_ _| |_| ||  __/ | | | | | |__| |  __/ |_) | (_) | |_
--   |_____|_____|\__\___|_| |_| |_|_____/ \___| .__/ \___/ \__|
--                                             | |
--                                             |_|

function Chest:storeItemsFrom_AOSrv(...)
    -- get & check input from description
    local checkSuccess, itemsLocator, assignmentsPriorityKey, callback = InputChecker.Check([[
        This async public ItemDepot service stores items from an ItemSupplier.

        An ItemDepot should take special care the transfer from the turtle inventory gets priority over other assignments to the turtle.

        Return value:
                                        - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                        - (table)
                success                 - (boolean) whether the service executed successfully
                destinationItemsLocator - (URL) stating the final ItemDepot and the items that where stored
                                            (upon service succes the "base" component of this URL should be equal to itemDepotLocator
                                            and the "query" should be equal to the "query" component of the itemsLocator)

        Parameters:
            serviceData                 - (table) data about the service
                itemsLocator            + (URL) locating the items to store
                                            (the "base" component of the URL specifies the ItemSupplier that provides the items)
                                            (the "query" component of the URL specifies the items)
                assignmentsPriorityKey  + (string, "") priorityKey that should be set for all assignments triggered by this service
            callback                    + (Callback) to call once service is ready
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Chest:storeItemsFrom_AOSrv: Invalid input") return Callback.ErrorCall(callback) end

    -- set (expected) destinationItemsLocator
    enterprise_chests = enterprise_chests or require "enterprise_chests"
    local destinationItemsLocator = enterprise_chests:getObjectLocator(self)
    destinationItemsLocator:setQueryURI(itemsLocator:getQueryURI())

    -- work around
    local itemsLocatorCopy = itemsLocator:copy()

    -- create project definition
    local taskData = {
        turtleId        = -1,
--        itemsQuery      = coreutils.DeepCopy(itemsLocator:getQuery()),
        itemsQuery      = itemsLocatorCopy:getQuery(),
        location        = self:getBaseLocation():copy(),
        accessDirection = self:getAccessDirection(),

        priorityKey     = assignmentsPriorityKey,
    }
    enterprise_turtle = enterprise_turtle or require "enterprise_turtle"
    local projectData = {
        hostName                = "enterprise_chests",
        className               = "Chest",
        chest                   = self:copy(),

        metaData                = role_chests_worker.PutItemsFromTurtleIntoChest_MetaData(taskData),
        taskCall                = TaskCall:newInstance("role_chests_worker", "PutItemsFromTurtleIntoChest_Task", taskData),

        itemsLocator            = itemsLocator,
        turtleLocator           = enterprise_turtle.GetAnyTurtleLocator(),

        destinationItemsLocator = destinationItemsLocator,

        assignmentsPriorityKey  = assignmentsPriorityKey,
    }
    local projectDef = {
        steps   = {
            -- get items into a turtle
            -- ToDo: consider using provideItemsTo_AOSrv here
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "storeItemsFrom_AOSrv", locatorStep = 0, locatorKeyDef = "turtleLocator" }, stepDataDef = {
                { keyDef = "itemsLocator"           , sourceStep = 0, sourceKeyDef = "itemsLocator" },
                { keyDef = "assignmentsPriorityKey" , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
            }},
            -- obtain workerId
            { stepType = "LSMtd", stepTypeDef = { methodName = "getWorkerId", locatorStep = 1, locatorKeyDef = "destinationItemsLocator" }, stepDataDef = {
            }},
            -- put items into chest
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_assignmentboard", serviceName = "DoAssignment_ASrv" }, stepDataDef = {
                { keyDef = "metaData"               , sourceStep = 0, sourceKeyDef = "metaData" },
                { keyDef = "metaData.needTurtleId"  , sourceStep = 2, sourceKeyDef = "methodResults" },
                { keyDef = "taskCall"               , sourceStep = 0, sourceKeyDef = "taskCall" },
                { keyDef = "taskCall._data.turtleId", sourceStep = 2, sourceKeyDef = "methodResults" },
            }},
            -- save chest
            { stepType = "SSrv", stepTypeDef = { moduleName = "enterprise_chests", serviceName = "SaveObject_SSrv" }, stepDataDef = {
                { keyDef = "hostName"               , sourceStep = 0, sourceKeyDef = "hostName" },
                { keyDef = "className"              , sourceStep = 0, sourceKeyDef = "className" },
                { keyDef = "objectTable"            , sourceStep = 0, sourceKeyDef = "chest" },
                { keyDef = "objectTable._inventory" , sourceStep = 3, sourceKeyDef = "inventory" },
            }},
        },
        returnData  = {
            { keyDef = "destinationItemsLocator"    , sourceStep = 0, sourceKeyDef = "destinationItemsLocator" },
        }
    }
    local projectServiceData = {
        projectDef  = projectDef,
        projectData = projectData,
        projectMeta = { title = "Storing items to "..self:getWIPId(), description = "Getting stuff off your hands", wipId = self:getWIPId() },
    }

    -- start project
    corelog.WriteToLog(">Store "..itemsLocator:getURI().." into Chest "..self:getId())
    return enterprise_projects.StartProject_ASrv(projectServiceData, callback)
end

function Chest:can_StoreItems_QOSrv(...)
    -- get & check input from description
    local checkSuccess, itemsLocator = InputChecker.Check([[
        This sync public query service answers the question whether the ItemDepot can store specific items.

        Return value:
                                    - (table)
                success             - (boolean) whether the answer to the question is true

        Parameters:
            serviceData             - (table) data to the query
                itemsLocator        + (URL) locating the items that need to be stored
                                        (the "base" component of the URL specifies the ItemDepot to store the items in)
                                        (the "query" component of the URL specifies the items to query for)
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Chest:can_StoreItems_QOSrv: Invalid input") return {success = false} end

    -- ToDo: implement
    corelog.Warning("Chest:can_StoreItems_QOSrv: not yet implemented")
    return {success = false}
end

function Chest:needsTo_StoreItemsFrom_SOSrv(...)
    -- get & check input from description
    local checkSuccess, itemsLocator = InputChecker.Check([[
        This sync public service returns the needs to store specific items from an ItemSupplier.

        Return value:
                                                - (table)
                success                         - (boolean) whether the service executed correctly
                fuelNeed                        - (number) amount of fuel needed to store items

        Parameters:
            serviceData                         - (table) data to the query
                itemsLocator                    + (URL) locating the items to store
                                                    (the "base" component of the URL specifies the ItemSupplier that provides the items)
                                                    (the "query" component of the URL specifies the items)
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Chest:needsTo_StoreItemsFrom_SOSrv: Invalid input") return {success = false} end

    -- ToDo: implement
    corelog.Warning("Chest:needsTo_StoreItemsFrom_SOSrv: not yet implemented")
    return {success = false}
end

return Chest
