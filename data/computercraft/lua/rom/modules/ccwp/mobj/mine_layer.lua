-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local ILObj = require "i_lobj"
local IMObj = require "i_mobj"
local IItemSupplier = require "i_item_supplier"
local MineLayer = Class.NewClass(ObjBase, ILObj, IMObj, IItemSupplier)

--[[
    This module implements a MineLayer.

    A MineLayer is a layer for mining resources in the minecraft world.

    A MineLayer is 3 blocks high, contains a base, and gatheres the resources concentric around that base.
--]]

local corelog = require "corelog"
local coreutils = require "coreutils"

local InputChecker = require "input_checker"

local Callback = require "obj_callback"
local TaskCall = require "obj_task_call"
local ObjTable = require "obj_table"
local ObjHost = require "obj_host"
local Location = require "obj_location"
local Block = require "obj_block"
local CodeMap = require "obj_code_map"
local LayerRectangle = require "obj_layer_rectangle"
local ItemTable = require "obj_item_table"

local IItemDepot = require "i_item_depot"

local role_miner = require "role_miner"
local role_energizer = require "role_energizer"

local enterprise_projects = require "enterprise_projects"
local enterprise_gathering

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function MineLayer:_init(...)
    -- get & check input from description
    local checkSuccess, id, baseLocation, currentHalfRib = InputChecker.Check([[
        Initialise a MineLayer.

        Parameters:
            id                      + (string) id of the MineLayer
            baseLocation            + (Location) base location of the MineLayer
            currentHalfRib          + (number) with current halfRib of the MineLayer
    ]], ...)
    if not checkSuccess then corelog.Error("MineLayer:_init: Invalid input") return nil end

    -- initialisation
    ObjBase._init(self)
    self._id                    = id
    self._baseLocation          = baseLocation
    self._currentHalfRib        = currentHalfRib
end

-- ToDo: should be renamed to newFromTable at some point
function MineLayer:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a MineLayer.

        Parameters:
            o                           + (table, {}) with object fields
                _id                     - (string) id of the MineLayer
                _baseLocation           - (Location) base location of the MineLayer
                _currentHalfRib         - (number) with current halfRib of the MineLayer
    ]], ...)
    if not checkSuccess then corelog.Error("MineLayer:new: Invalid input") return nil end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- end
    return o
end

function MineLayer:getCurrentHalfRib()
    return self._currentHalfRib
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function MineLayer:getClassName()
    return "MineLayer"
end

--    _____ _      ____  _     _
--   |_   _| |    / __ \| |   (_)
--     | | | |   | |  | | |__  _
--     | | | |   | |  | | '_ \| |
--    _| |_| |___| |__| | |_) | |
--   |_____|______\____/|_.__/| |
--                           _/ |
--                          |__/

function MineLayer:construct(...)
    -- get & check input from description
    local checkSuccess, baseLocation = InputChecker.Check([[
        This method constructs a MineLayer instance from a table of parameters with all necessary fields (in an objectTable) and methods (by setmetatable) as defined in the class.

        The constructed MineLayer is not yet saved in the MObjHost.

        Return value:
                                        - (MineLayer) the constructed MineLayer

        Parameters:
            constructParameters         - (table) parameters for constructing the MineLayer
                baseLocation            + (Location) base location of the MineLayer
    ]], ...)
    if not checkSuccess then corelog.Error("MineLayer:construct: Invalid input") return nil end

    -- construct new MineLayer
    local id = coreutils.NewId()
    local startHalfRib = 3
    local obj = MineLayer:newInstance(id, baseLocation:copy(), startHalfRib)

    -- end
    return obj
end

function MineLayer:upgrade(...)
    -- get & check input from description
    local checkSuccess = InputChecker.Check([[
        This method upgrades a MineLayer instance from a table of parameters.

        The upgraded MineLayer is not yet saved in the MObjHost.

        Return value:
                                        - (boolean) whether the MineLayer was succesfully upgraded.

        Parameters:
            upgradeParameters           - (table) parameters for upgrading the MineLayer
    ]], ...)
    if not checkSuccess then corelog.Error("MineLayer:upgrade: Invalid input") return false end

    -- end
    return true
end

function MineLayer:destruct()
    --[[
        This method destructs a MineLayer instance.

        The MineLayer is not yet deleted from the MObjHost.

        Return value:
                                        - (boolean) whether the MineLayer was succesfully destructed.

        Parameters:
    ]]

    -- end
    return true
end

function MineLayer:getId()
    return self._id
end

function MineLayer:getWIPId()
    --[[
        Returns the unique Id of the MineLayer used for administering WIP.
    ]]

    return self:getClassName().." "..self:getId()
end

--    _____ __  __  ____  _     _
--   |_   _|  \/  |/ __ \| |   (_)
--     | | | \  / | |  | | |__  _
--     | | | |\/| | |  | | '_ \| |
--    _| |_| |  | | |__| | |_) | |
--   |_____|_|  |_|\____/|_.__/| |
--                            _/ |
--                           |__/

function MineLayer:getBaseLocation()
    return self._baseLocation
end

local function Bottom_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            ["L"]   = Block:newInstance("minecraft:birch_log"),
            ["P"]   = Block:newInstance("minecraft:birch_planks"),
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        CodeMap:newInstance({
            [7] = "LLLLLLL",
            [6] = "LPPPPPL",
            [5] = "LPPPPPL",
            [4] = "LP P PL",
            [3] = "LPPPPPL",
            [2] = "LPPPPPL",
            [1] = "LLLLLLL",
        })
    )
end

local function Mid_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            ["T"]   = Block:newInstance("minecraft:torch"),
            ["C"]   = Block:newInstance("minecraft:chest"),
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        CodeMap:newInstance({
            [7] = "   T   ",
            [6] = "  C C  ",
            [5] = "       ",
            [4] = "T     T",
            [3] = "       ",
            [2] = "       ",
            [1] = "   T   ",
        })
    )
end

local function Top_layer()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(Block:getClassName(), {
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        CodeMap:newInstance({
            [7] = "       ",
            [6] = "       ",
            [5] = "       ",
            [4] = "       ",
            [3] = "       ",
            [2] = "       ",
            [1] = "       ",
        })
    )
end

function MineLayer.GetBuildBlueprint(...)
    -- get & check input from description
    local checkSuccess, baseLocation = InputChecker.Check([[
        This method returns a blueprint for building a MineLayer in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
            constructParameters         - (table) parameters for constructing the MineLayer
                baseLocation            + (Location) base location of the MineLayer
    ]], ...)
    if not checkSuccess then corelog.Error("MineLayer.GetBuildBlueprint: Invalid input") return nil, nil end

    -- buildLocation
    local offsetX = 1
    local buildLocation = baseLocation:getRelativeLocation(1, 0, 0)

    -- layerList
    local layerList = {}
    local buildLayerLocation = Location:newInstance(-3 - offsetX, -3, -1)
    table.insert(layerList, { startpoint = buildLayerLocation, buildDirection = "Down", layer = Bottom_layer()})
    buildLayerLocation = Location:newInstance(-3 - offsetX, -3, 1)
    table.insert(layerList, { startpoint = buildLayerLocation, buildDirection = "Up", layer = Top_layer()})
    buildLayerLocation = Location:newInstance(-3 - offsetX, -3, 0)
    table.insert(layerList, { startpoint = buildLayerLocation, buildDirection = "Down", layer = Mid_layer()})

    -- escapeSequence
    local escapeSequence = {}
    table.insert(escapeSequence, baseLocation:getRelativeLocation(-1, 0, 0))
    table.insert(escapeSequence, baseLocation:getRelativeLocation(-1, 0, baseLocation:getZ() + 2))

    -- blueprint
    local blueprint = {
        layerList = layerList,
        escapeSequence = escapeSequence,
    }

    -- end
    return buildLocation, blueprint
end

function MineLayer:getExtendBlueprint(...)
    -- get & check input from description
    local checkSuccess = InputChecker.Check([[
        This method returns a blueprint for extending the MineLayer in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
            upgradeParameters           - (table) parameters for upgrading the current MineLayer
    ]], ...)
    if not checkSuccess then corelog.Error("MineLayer:getExtendBlueprint: Invalid input") return nil end

    -- layerList
    local layerList = {}

    -- escapeSequence
    local escapeSequence = {}

    -- blueprint
    local blueprint = {
        layerList = layerList,
        escapeSequence = escapeSequence,
    }

    -- buildLocation
    local baseLocation = self:getBaseLocation()
    local buildLocation = baseLocation:copy()

    -- end
    return buildLocation, blueprint
end

function MineLayer:getDismantleBlueprint()
    --[[
        This method returns a blueprint for dismantling the MineLayer in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
    ]]


    -- layerList
    local layerList = {}

    -- escapeSequence
    local escapeSequence = {}

    -- blueprint
    local blueprint = {
        layerList = layerList,
        escapeSequence = escapeSequence
    }

    -- buildLocation
    local buildLocation = self._baseLocation:copy()

    -- end
    return buildLocation, blueprint
end

--    _____ _____ _                  _____                   _ _
--   |_   _|_   _| |                / ____|                 | (_)
--     | |   | | | |_ ___ _ __ ___ | (___  _   _ _ __  _ __ | |_  ___ _ __
--     | |   | | | __/ _ \ '_ ` _ \ \___ \| | | | '_ \| '_ \| | |/ _ \ '__|
--    _| |_ _| |_| ||  __/ | | | | |____) | |_| | |_) | |_) | | |  __/ |
--   |_____|_____|\__\___|_| |_| |_|_____/ \__,_| .__/| .__/|_|_|\___|_|
--                                              | |   | |
--                                              |_|   |_|

function MineLayer:provideItemsTo_AOSrv(...)
    -- get & check input from description
    local checkSuccess, provideItems, itemDepotLocator, ingredientsItemSupplierLocator, wasteItemDepotLocator, assignmentsPriorityKey, callback = InputChecker.Check([[
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
                ingredientsItemSupplierLocator  + (URL) locating where possible ingredients needed to provide can be retrieved
                wasteItemDepotLocator           + (URL) locating where waste material can be delivered
                assignmentsPriorityKey          + (string, "") priorityKey that should be set for all assignments triggered by this service
            callback                            + (Callback) to call once service is ready
    ]], ...)
    if not checkSuccess then corelog.Error("MineLayer:provideItemsTo_AOSrv: Invalid input") return Callback.ErrorCall(callback) end

    -- check MineLayer can "in principal" provide the requested items
    local canProvideResult = self:can_ProvideItems_QOSrv({ provideItems = provideItems, })
    if not canProvideResult or not canProvideResult.success then
        corelog.Error("MineLayer:provideItemsTo_AOSrv: the MineLayer can not provide (all) items from "..textutils.serialise(provideItems, {compact = true}))
        return Callback.ErrorCall(callback)
    end

    -- construct taskData
    local taskData = {
        baseLocation        = self:getBaseLocation(),
        startHalfRib        = self:getCurrentHalfRib()+1,

        provideItems        = ItemTable:newInstance(provideItems),
        escape              = true,

        priorityKey         = assignmentsPriorityKey,
    }

    -- create project service data
    local projectDef = {
        steps = {
            -- mine MineLayer
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_assignmentboard", serviceName = "DoAssignment_ASrv" }, stepDataDef = {
                { keyDef = "metaData"                       , sourceStep = 0, sourceKeyDef = "mineLayerMetaData" },
                { keyDef = "taskCall"                       , sourceStep = 0, sourceKeyDef = "mineLayerTaskCall" },
            }, description = "Mining "..textutils.serialise(provideItems, {compact = true}).." from MineLayer task"},
            -- save MineLayer
            { stepType = "SSrv", stepTypeDef = { moduleName = "enterprise_gathering", serviceName = "SaveObject_SSrv" }, stepDataDef = {
                { keyDef = "hostName"                       , sourceStep = 0, sourceKeyDef = "hostName" },
                { keyDef = "className"                      , sourceStep = 0, sourceKeyDef = "className" },
                { keyDef = "objectTable"                    , sourceStep = 0, sourceKeyDef = "MineLayer" },
                { keyDef = "objectTable._currentHalfRib"    , sourceStep = 1, sourceKeyDef = "endHalfRib" },
            }},
            -- deliver mined items
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "storeItemsFrom_AOSrv", locatorStep = 0, locatorKeyDef = "itemDepotLocator" }, stepDataDef = {
                { keyDef = "itemsLocator"                   , sourceStep = 1, sourceKeyDef = "turtleOutputItemsLocator" },
                { keyDef = "assignmentsPriorityKey"         , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
            }},
            -- store waste items
            { stepType = "LAOSrv", stepTypeDef = { serviceName = "storeItemsFrom_AOSrv", locatorStep = 0, locatorKeyDef = "wasteItemDepotLocator" }, stepDataDef = {
                { keyDef = "itemsLocator"                   , sourceStep = 1, sourceKeyDef = "turtleWasteItemsLocator" },
                { keyDef = "assignmentsPriorityKey"         , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
            }},
        },
        returnData  = {
            { keyDef = "destinationItemsLocator"            , sourceStep = 3, sourceKeyDef = "destinationItemsLocator" },
        }
    }
    local projectData = {
        hostName                        = "enterprise_gathering",
        className                       = "MineLayer",
        MineLayer                       = self:copy(),

        wasteItemDepotLocator           = wasteItemDepotLocator:copy(),
        itemDepotLocator                = itemDepotLocator:copy(),

        mineLayerMetaData               = role_miner.MineLayer_MetaData(taskData),
        mineLayerTaskCall               = TaskCall:newInstance("role_miner", "MineLayer_Task", taskData),

        assignmentsPriorityKey          = assignmentsPriorityKey,
    }
    local projectServiceData = {
        projectDef  = projectDef,
        projectData = projectData,
        projectMeta = { title = "Mining MineLayer", description = "Mining! What this game is made for!", wipId = self:getWIPId() },
    }

    -- start project
    local scheduleResult = enterprise_projects.StartProject_ASrv(projectServiceData, callback)

    -- end
    return scheduleResult
end

function MineLayer:can_ProvideItems_QOSrv(...)
    -- get & check input from description
    local checkSuccess, provideItems = InputChecker.Check([[
        This sync public query service answers the question whether the ItemSupplier can provide specific items.

        Return value:
                                    - (table)
                success             - (boolean) whether the answer to the question is true

        Parameters:
            serviceData             - (table) data to the query
                provideItems        + (table) with one or more items (formatted as an array of [itemName] = itemCount key-value pairs) to provide
    --]], ...)
    if not checkSuccess then corelog.Error("MineLayer:can_ProvideItems_QOSrv: Invalid input") return {success = false} end

    enterprise_gathering = enterprise_gathering or require "enterprise_gathering"
    local minableItems = enterprise_gathering.GetMinableItems()

    -- loop on items
    for itemName, itemCount in pairs(provideItems) do
        -- check
        if type(itemName) ~= "string" then corelog.Error("MineLayer:can_ProvideItems_QOSrv: itemName of wrong type = "..type(itemName)..".") return {success = false} end

        -- check it's a mineable item
        local isMineableItem = false
        for _, mineItemName in ipairs(minableItems) do
            if itemName == mineItemName then
                isMineableItem = true
            end
        end
        if not isMineableItem then return {success = false} end
    end
    -- note: the MineLayer ItemSupplier implementation returns if "in principle" the items could be provided. In reality we of course only know once we start mining.

    -- end
    return {
        success = true,
    }
end

function MineLayer:needsTo_ProvideItemsTo_SOSrv(...)
    -- get & check input from description
    local checkSuccess, provideItems, destinationItemDepotLocator = InputChecker.Check([[
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
    --]], ...)
    if not checkSuccess then corelog.Error("MineLayer:needsTo_ProvideItemsTo_SOSrv: Invalid input") return {success = false} end

    -- fuelNeed_Mining
    local fuelNeed_Mining = 2*4*(self:getCurrentHalfRib() + 1) -- note: we return the fuelNeed for mining the next square

    -- get destinationItemDepot
    local destinationItemDepot = ObjHost.GetObject(destinationItemDepotLocator)
    if not destinationItemDepot or not Class.IsInstanceOf(destinationItemDepot, IItemDepot) then corelog.Error("MineLayer:needsTo_ProvideItemsTo_SOSrv: Failed obtaining an IItemDepot from destinationItemDepotLocator "..destinationItemDepotLocator:getURI()) return {success = false} end

    -- get locations
    local destinationLocation = destinationItemDepot:getItemDepotLocation()
    local localLocation = self:getBaseLocation()

    -- fuelNeed output transfer
    local fuelNeed_Transfer = role_energizer.NeededFuelToFrom(destinationLocation, localLocation)

    --
    local fuelNeedEntry = self:getCurrentHalfRib() + 1 -- to go from base to next square
    local fuelNeedExit = self:getCurrentHalfRib() + 1 -- to go back to base
    local fuelNeed = fuelNeedEntry + fuelNeed_Mining + fuelNeedExit + fuelNeed_Transfer
    local ingredientsNeed = {}

    -- end
    return {
        success         = true,
        fuelNeed        = fuelNeed,
        ingredientsNeed = ingredientsNeed,
    }
end

return MineLayer
