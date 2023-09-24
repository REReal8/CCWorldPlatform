-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local IMObj = require "i_mobj"
local IItemSupplier = require "i_item_supplier"
local BirchForest = Class.NewClass(ObjBase, IMObj, IItemSupplier)

--[[
    This module implements BirchForest.
--]]

local corelog = require "corelog"
local coreutils = require "coreutils"

local Callback = require "obj_callback"
local TaskCall = require "obj_task_call"
local InputChecker = require "input_checker"
local ObjTable = require "obj_table"
local URL = require "obj_url"
local Host = require "obj_host"
local Location = require "obj_location"
local Block = require "obj_block"
local CodeMap = require "obj_code_map"
local LayerRectangle = require "obj_layer_rectangle"

local role_forester = require "role_forester"

local enterprise_isp = require "enterprise_isp"
local enterprise_projects = require "enterprise_projects"
local enterprise_chests = require "enterprise_chests"
local enterprise_turtle

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function BirchForest:_init(...)
    -- get & check input from description
    local checkSuccess, id, level, baseLocation, nTrees, localLogsLocator, localSaplingsLocator = InputChecker.Check([[
        Initialise a BirchForest.

        Parameters:
            id                      + (string) id of the BirchForest
            level                   + (number) level of the BirchForest
            baseLocation            + (Location) base location of the BirchForest
            nTrees                  + (number) # trees in the BirchForest
            localLogsLocator        + (URL) locating the local ItemSupplier of logs (e.g. a chest)
            localSaplingsLocator    + (URL) locating the local ItemSupplier of saplings (e.g. a chest)
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("BirchForest:_init: Invalid input") return nil end

    -- initialisation
    ObjBase._init(self)
    self._id                    = id
    self._level                 = level
    self._baseLocation          = baseLocation
    self._nTrees                = nTrees
    self._localLogsLocator      = localLogsLocator
    self._localSaplingsLocator  = localSaplingsLocator
end

-- ToDo: should be renamed to newFromTable at some point
function BirchForest:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a BirchForest.

        Parameters:
            o                           + (table, {}) with object fields
                _id                     - (string) id of the BirchForest
                _level                  - (number) level of the BirchForest
                _baseLocation           - (Location) base location of the BirchForest
                _nTrees                 - (number) # trees in the BirchForest
                _localLogsLocator       - (URL) locating the local ItemSupplier of logs (e.g. a chest)
                _localSaplingsLocator   - (URL) locating the local ItemSupplier of saplings (e.g. a chest)
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("BirchForest:new: Invalid input") return nil end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- end
    return o
end

function BirchForest:getLevel()
    return self._level
end

function BirchForest:setLevel(level)
    -- check input
    if type(level) ~= "number" then corelog.Error("BirchForest:setLevel: invalid level: "..type(level)) return end

    self._level = level
end

function BirchForest:getBaseLocation()
    return self._baseLocation
end

function BirchForest:setLocation(location)
    -- check input
    if not Class.IsInstanceOf(location, Location) then corelog.Error("BirchForest:setLocation: invalid location: "..type(location)) return end

    self._baseLocation = location
end

function BirchForest:getNTrees()
    return self._nTrees
end

function BirchForest:setNTrees(nTrees)
    -- check input
    if type(nTrees) ~= "number" then corelog.Error("BirchForest:setNTrees: invalid # trees: "..type(nTrees)) return end

    self._nTrees = nTrees
end

function BirchForest:getLocalLogsLocator()
    return self._localLogsLocator
end

function BirchForest:setLocalLogsLocator(localLocator)
    -- check input
    if not Class.IsInstanceOf(localLocator, URL) then corelog.Error("BirchForest:setLocalLogsLocator: Invalid localLocator "..type(localLocator)) return end

    self._localLogsLocator = localLocator
end

function BirchForest:getLocalSaplingsLocator()
    return self._localSaplingsLocator
end

function BirchForest:setLocalSaplingsLocator(localLocator)
    -- check input
    if not Class.IsInstanceOf(localLocator, URL) then corelog.Error("BirchForest:setLocalSaplingsLocator: Invalid localLocator "..type(localLocator)) return end

    self._localSaplingsLocator = localLocator
end

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

function BirchForest:getClassName()
    return "BirchForest"
end

--    _____ __  __  ____  _     _                  _   _               _
--   |_   _|  \/  |/ __ \| |   (_)                | | | |             | |
--     | | | \  / | |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | | | |\/| | |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| |_| |  | | |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____|_|  |_|\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                            _/ |
--                           |__/

function BirchForest:construct(...)
    -- get & check input from description
    local checkSuccess, level, baseLocation, nTrees = InputChecker.Check([[
        This method constructs a BirchForest instance from a table of parameters with all necessary fields (in an objectTable) and methods (by setmetatable) as defined in the class.

        It also ensures all child MObj's the BirchForest spawns are hosted on the appropriate MObjHost (by calling hostMObj_SSrv).

        The constructed BirchForest is not yet saved in the Host.

        Return value:
                                        - (BirchForest) the constructed BirchForest

        Parameters:
            constructParameters         - (table) parameters for constructing the BirchForest
                level                   + (number) with BirchForest level
                baseLocation            + (Location) base location of the BirchForest
                nTrees                  + (number) number of trees
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("BirchForest:construct: Invalid input") return nil end

    -- determine BirchForest fields
    local id = coreutils.NewId()
    enterprise_turtle = enterprise_turtle or require "enterprise_turtle"
    local localLogsLocator = nil
    local localSaplingsLocator = nil
    if level == -1 or level == 0 or level == 1 then
        -- localLogsLocator
        localLogsLocator = enterprise_turtle.GetAnyTurtleLocator()

        -- localSaplingsLocator
        localSaplingsLocator = enterprise_turtle.GetAnyTurtleLocator()
    elseif level == 2 then
        -- localLogsLocator
        localLogsLocator = enterprise_chests:hostMObj_SSrv({ className = "Chest", constructParameters = {
            baseLocation    = baseLocation:getRelativeLocation(2, 1, 0),
            accessDirection = "front",
        }}).mobjLocator

        -- localSaplingsLocator
        localSaplingsLocator = enterprise_chests:hostMObj_SSrv({ className = "Chest", constructParameters = {
            baseLocation    = baseLocation:getRelativeLocation(4, 1, 0),
            accessDirection = "front",
        }}).mobjLocator
    else
        corelog.Error("BirchForest:construct: Don't know how to construct a BirchForest of level "..level) return nil
    end
    if not localLogsLocator then corelog.Error("BirchForest:construct: Failed obtaining localLogsLocator for level "..level) return nil end
    if not localSaplingsLocator then corelog.Error("BirchForest:construct: Failed obtaining localSaplingsLocator for level "..level) return nil end

    -- construct new BirchForest
    local obj = BirchForest:newInstance(id, level, baseLocation:copy(), nTrees, localLogsLocator:copy(), localSaplingsLocator:copy())

    -- end
    return obj
end

function BirchForest:upgrade(...)
    -- get & check input from description
    local checkSuccess, upgradeLevel, nTrees = InputChecker.Check([[
        This method upgrades a BirchForest instance from a table of parameters.

        The upgraded BirchForest is not yet saved in it's Host.

        Return value:
                                        - (boolean) whether the BirchForest was succesfully upgraded.

        Parameters:
            upgradeParameters           - (table) parameters for upgrading the BirchForest
                level                   + (number) with BirchForest level to upgrade to
                nTrees                  + (number) number of trees
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("BirchForest:upgrade: Invalid input") return false end

    -- upgrade if possible
    local level = self:getLevel()
    local baseLocation = self:getBaseLocation()
    if level == upgradeLevel then
    elseif level < 2 and upgradeLevel < 2 then
    elseif level < 2 and upgradeLevel == 2 then
        -- localLogsLocator
        local localLogsLocator = enterprise_chests:hostMObj_SSrv({ className = "Chest", constructParameters = {
            baseLocation    = baseLocation:getRelativeLocation(2, 1, 0),
            accessDirection = "front",
        }}).mobjLocator
        if not localLogsLocator then corelog.Error("BirchForest:upgrade: Failed obtaining localLogsLocator for level "..upgradeLevel) return false end
        self._localLogsLocator = localLogsLocator

        -- localSaplingsLocator
        local localSaplingsLocator = enterprise_chests:hostMObj_SSrv({ className = "Chest", constructParameters = {
            baseLocation    = baseLocation:getRelativeLocation(4, 1, 0),
            accessDirection = "front",
        }}).mobjLocator
        if not localSaplingsLocator then corelog.Error("BirchForest:upgrade: Failed obtaining localSaplingsLocator for level "..upgradeLevel) return false end
        self._localSaplingsLocator = localSaplingsLocator
    else
        corelog.Error("BirchForest:construct: Don't know how to upgrade a BirchForest from level "..level.." to "..upgradeLevel) return false
    end

    -- level
    self._level = upgradeLevel

    -- nTrees
    self._nTrees = nTrees

    -- end
    return true
end

function BirchForest:destruct()
    --[[
        This method destructs a BirchForest instance.

        It also ensures all child MObj's the BirchForest is the parent of are released from the appropriate MObjHost (by calling releaseMObj_SSrv).

        The BirchForest is not yet deleted from the Host.

        Return value:
                                        - (boolean) whether the BirchForest was succesfully destructed.

        Parameters:
    ]]

    -- release localLogsLocator
    local destructSuccess = true
    local localLogsLocator = self:getLocalLogsLocator()
    local hostName = localLogsLocator:getHost()
    if hostName == enterprise_chests:getHostName() then
        local releaseResult = enterprise_chests:releaseMObj_SSrv({ mobjLocator = localLogsLocator })
        if not releaseResult or not releaseResult.success then corelog.Warning("BirchForest:destruct(): failed releasing localLogsLocator "..localLogsLocator:getURI()) destructSuccess = false end
    end

    -- release localSaplingsLocator
    local localSaplingsLocator = self:getLocalSaplingsLocator()
    hostName = localSaplingsLocator:getHost()
    if hostName == enterprise_chests:getHostName() then
        local releaseResult = enterprise_chests:releaseMObj_SSrv({ mobjLocator = localSaplingsLocator })
        if not releaseResult or not releaseResult.success then corelog.Warning("BirchForest:destruct(): failed releasing localSaplingsLocator "..localSaplingsLocator:getURI()) destructSuccess = false end
    end

    -- end
    return destructSuccess
end

function BirchForest:getId()
    return self._id
end

function BirchForest:getWIPId()
    --[[
        Returns the unique Id of the BirchForest used for administering WIP.
    ]]

    return self:getClassName().." "..self:getId()
end

local blockClassName = "Block"
local function Tree_layerLm1()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(blockClassName, {
            ["S"]   = Block:newInstance("minecraft:birch_sapling"),
            ["?"]   = Block:newInstance(Block.AnyBlockName()),
        }),
        CodeMap:newInstance({
            [6] = "??????",
            [5] = "??????",
            [4] = "???S??",
            [3] = "??????",
            [2] = "??????",
            [1] = "??????",
        })
    )
end

local function Tree_layerL0()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(blockClassName, {
            ["S"]   = Block:newInstance("minecraft:birch_sapling"),
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        CodeMap:newInstance({
            [6] = "      ",
            [5] = "      ",
            [4] = "   S  ",
            [3] = "      ",
            [2] = "      ",
            [1] = "      ",
        })
    )
end

local function Tree_layerL1()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(blockClassName, {
            ["S"]   = Block:newInstance("minecraft:birch_sapling"),
            ["T"]   = Block:newInstance("minecraft:torch"),
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        CodeMap:newInstance({
            [6] = "      ",
            [5] = "      ",
            [4] = "T  S  ",
            [3] = "      ",
            [2] = "      ",
            [1] = "   T  ",
        })
    )
end

local function Base_layerL2()
    return LayerRectangle:newInstance(
        ObjTable:newInstance(blockClassName, {
            ["S"]   = Block:newInstance("minecraft:birch_sapling"),
            ["T"]   = Block:newInstance("minecraft:torch"),
            ["C"]   = Block:newInstance("minecraft:chest", -1, 0),
            ["D"]   = Block:newInstance("minecraft:chest", 1, 0),
            [" "]   = Block:newInstance(Block.NoneBlockName()),
        }),
        CodeMap:newInstance({
            [6] = "      ",
            [5] = "      ",
            [4] = "T  S  ",
            [3] = "     D",
            [2] = "  C D ",
            [1] = "   T  ",
        })
    )
end

function BirchForest:getBaseLayer(level)
    if level == -1 then     return Tree_layerLm1()
    elseif level == 0 then  return Tree_layerL0()
    elseif level == 1 then  return Tree_layerL1()
    elseif level == 2 then  return Base_layerL2()
    else                    corelog.Error("BirchForest:getBaseLayer: Don't know layer for level "..level) return nil end
end

function BirchForest:getTreeLayer(level)
    if level == -1 then     return Tree_layerLm1()
    elseif level == 0 then  return Tree_layerL0()
    elseif level == 1 then  return Tree_layerL1()
    elseif level == 2 then  return Tree_layerL1() -- same as L1
    else                    corelog.Error("BirchForest:getTreeLayer: Don't know layer for level "..level) return nil end
end

--                        _                           _   _               _
--                       (_)                         | | | |             | |
--    ___  ___ _ ____   ___  ___ ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \  __/ |   \ V /| | (_|  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/\___|_|    \_/ |_|\___\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

function BirchForest:getFuelNeed_Harvest_Att()
    --[[
        Forest attribute with the current fuelNeed to do one harvesting round.
    --]]

    -- determine fuelNeed
    local nTrees = self:getNTrees()
    local fuelNeed = role_forester.FuelNeededPerRound(nTrees)

    -- end
    return fuelNeed
end

function BirchForest:getFuelNeedExtraTree_Att()
    --[[
        Forest attribute with the fuelNeed for harvesting one extra tree.
        (i.e. it return the difference between the current getFuelNeed_Harvest_Att and the getFuelNeed_Harvest_Att if there would be 1 extra tree)
    --]]

    -- determine fuelNeed
    local nTrees = self:getNTrees()
    local fuelNeed_Current = role_forester.FuelNeededPerRound(nTrees)
    local fuelNeed_OneTreeExtra = role_forester.FuelNeededPerRound(nTrees + 1)

    -- end
    return fuelNeed_OneTreeExtra - fuelNeed_Current
end

--    _____ _____ _                  _____                   _ _                            _   _               _
--   |_   _|_   _| |                / ____|                 | (_)                          | | | |             | |
--     | |   | | | |_ ___ _ __ ___ | (___  _   _ _ __  _ __ | |_  ___ _ __   _ __ ___   ___| |_| |__   ___   __| |___
--     | |   | | | __/ _ \ '_ ` _ \ \___ \| | | | '_ \| '_ \| | |/ _ \ '__| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| |_ _| |_| ||  __/ | | | | |____) | |_| | |_) | |_) | | |  __/ |    | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____|_____|\__\___|_| |_| |_|_____/ \__,_| .__/| .__/|_|_|\___|_|    |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                                              | |   | |
--                                              |_|   |_|

function BirchForest:provideItemsTo_AOSrv(...)
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
                ingredientsItemSupplierLocator  + (URL) locating where the production ingredients can be retrieved
                wasteItemDepotLocator           + (URL) locating where waste material can be delivered
                assignmentsPriorityKey          + (string, "") priorityKey that should be set for all assignments triggered by this service
            callback                            + (Callback) to call once service is ready
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("BirchForest:provideItemsTo_AOSrv: Invalid input") return Callback.ErrorCall(callback) end

    -- loop on items
    local scheduleResult = true
    for itemName, itemCount in pairs(provideItems) do
        -- check
        if type(itemName) ~= "string" then corelog.Error("BirchForest:provideItemsTo_AOSrv: Invalid itemName (type="..type(itemName)..")") return Callback.ErrorCall(callback) end
        if type(itemCount) ~= "number" then corelog.Error("BirchForest:provideItemsTo_AOSrv: Invalid itemCount (type="..type(itemCount)..")") return Callback.ErrorCall(callback) end

        -- check for birchlog or sapling
        local localItemSupplierLocator = nil
        local localLogsLocator = self:getLocalLogsLocator()
        local localSaplingsLocator = self:getLocalSaplingsLocator()
        if itemName == "minecraft:birch_log" then
            localItemSupplierLocator = localLogsLocator
        elseif itemName == "minecraft:birch_sapling" then
            localItemSupplierLocator = localSaplingsLocator
        else
            corelog.Error("BirchForest:provideItemsTo_AOSrv: This is not a producer for item "..itemName) return Callback.ErrorCall(callback)
        end
        if not localItemSupplierLocator then corelog.Error("BirchForest:provideItemsTo_AOSrv: Invalid localItemSupplierLocator (type="..type(localItemSupplierLocator)..")") return {success = false} end

        -- check items already available in localItemSupplierLocator
        local localItemsLocator = localItemSupplierLocator:copy()
        local item = { [itemName] = itemCount }
        localItemsLocator:setQuery(item)
        if enterprise_isp.Can_ProvideItems_QSrv( { itemsLocator = localItemsLocator} ).success then
            -- yes: store items from local ItemSupplier to requested ItemDepot
            local serviceData = {
                itemsLocator                = localItemsLocator,
                itemDepotLocator            = itemDepotLocator,
                assignmentsPriorityKey      = assignmentsPriorityKey,
            }
--            corelog.WriteToLog(">Storing "..localItemsLocator:getURI().." from local ItemSupplier in Forest")
            scheduleResult = scheduleResult and enterprise_isp.StoreItemsFrom_ASrv(serviceData, callback)
        else
            -- construct new itemsLocator for this BirchForest
            local host = Host.GetHost("enterprise_forestry") if not host then corelog.Error("BirchForest:provideItemsTo_AOSrv: host not found") return Callback.ErrorCall(callback) end
            local mobjLocator = host:getObjectLocator(self)
            local itemsLocator = mobjLocator:copy()
            itemsLocator:setQuery(item)  -- ToDo: consider lower count with possible # items already present in localItemSupplierLocator

            -- construct taskData
            local harvestForestTaskData = {
                forestLevel         = self:getLevel(),
                firstTreeLocation   = self:getFirstTreeLocation(),
                nTrees              = self:getNTrees(),
                waitForFirstTree    = true,
--                waitForFirstTree    = (assignmentsPriorityKey ~= nil), -- energy efficient mode if assignmentsPriorityKey is set -- ToDo: consider change

                priorityKey         = assignmentsPriorityKey,
            }

            -- create project service data
            local projectDef = {
                steps = {
                    -- ToDo: consider retrieving birchSapling from it's local localItemSupplierLocator
                    --          (or will this be part of harvestForest?)
                    { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_assignmentboard", serviceName = "DoAssignment_ASrv" }, stepDataDef = {
                        { keyDef = "metaData"                       , sourceStep = 0, sourceKeyDef = "harvestForestMetaData" },
                        { keyDef = "taskCall"                       , sourceStep = 0, sourceKeyDef = "harvestForestTaskCall" },
                    }, description = "Harvesting "..textutils.serialise(item, {compact = true}).." task"},
                    -- store logs to localLogsLocator
                    { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_isp", serviceName = "StoreItemsFrom_ASrv" }, stepDataDef = {
                        { keyDef = "itemsLocator"           , sourceStep = 1, sourceKeyDef = "turtleOutputLogsLocator" },
                        { keyDef = "itemDepotLocator"       , sourceStep = 0, sourceKeyDef = "localLogsLocator" },
                        { keyDef = "assignmentsPriorityKey" , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
                    }},
                    -- store saplings to localSaplingsLocator
                    { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_isp", serviceName = "StoreItemsFrom_ASrv" }, stepDataDef = {
                        { keyDef = "itemsLocator"           , sourceStep = 1, sourceKeyDef = "turtleOutputSaplingsLocator" },
                        { keyDef = "itemDepotLocator"       , sourceStep = 0, sourceKeyDef = "localSaplingsLocator" },
                        { keyDef = "assignmentsPriorityKey" , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
                    }},
                    -- ToDo: consider storing rest/ waste materials (e.g. sticks)
                    -- recursive call to provide (remaining) items
                    { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_isp", serviceName = "ProvideItemsTo_ASrv" }, stepDataDef = {
                        { keyDef = "itemsLocator"                   , sourceStep = 0, sourceKeyDef = "itemsLocator" },
                        { keyDef = "itemDepotLocator"               , sourceStep = 0, sourceKeyDef = "itemDepotLocator" },
                        { keyDef = "ingredientsItemSupplierLocator" , sourceStep = 0, sourceKeyDef = "ingredientsItemSupplierLocator" },
                        { keyDef = "wasteItemDepotLocator"          , sourceStep = 0, sourceKeyDef = "wasteItemDepotLocator" },
                        { keyDef = "assignmentsPriorityKey"         , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
                    }, description = "Providing "..textutils.serialise(item, {compact = true}).." recursively"},
                },
                returnData  = {
                    { keyDef = "destinationItemsLocator"            , sourceStep = 4, sourceKeyDef = "destinationItemsLocator" },
                }
            }
            local projectData = {
                itemsLocator                    = itemsLocator,
                ingredientsItemSupplierLocator  = ingredientsItemSupplierLocator:copy(),
                wasteItemDepotLocator           = wasteItemDepotLocator:copy(),
                itemDepotLocator                = itemDepotLocator:copy(),

                localLogsLocator                = localLogsLocator,
                localSaplingsLocator            = localSaplingsLocator,
                harvestForestMetaData           = role_forester.HarvestForest_MetaData(harvestForestTaskData),
                harvestForestTaskCall           = TaskCall:newInstance("role_forester", "HarvestForest_Task", harvestForestTaskData),

                assignmentsPriorityKey          = assignmentsPriorityKey,
            }
            local projectServiceData = {
                projectDef  = projectDef,
                projectData = projectData,
                projectMeta = { title = "Harvesting BirchForest", description = "The most usefull task in the world", wipId = self:getWIPId() },
            }

            -- start project
--            corelog.WriteToLog(">Harvesting "..itemCount.." "..itemName.."'s from Forest")
            scheduleResult = scheduleResult and enterprise_projects.StartProject_ASrv(projectServiceData, callback)
        end
    end

    -- end
    return scheduleResult
end

function BirchForest:can_ProvideItems_QOSrv(...)
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
    if not checkSuccess then corelog.Error("BirchForest:can_ProvideItems_QOSrv: Invalid input") return {success = false} end

    -- loop on items
    for itemName, itemCount in pairs(provideItems) do
        -- check
        if type(itemName) ~= "string" then corelog.Error("BirchForest:can_ProvideItems_QOSrv: itemName of wrong type = "..type(itemName)..".") return {success = false} end

        -- check for birchlog or sapling
        if itemName == "minecraft:birch_log" then
        elseif itemName == "minecraft:birch_sapling" then
        else
            return {success = false}
        end
    end

    -- end
    return {
        success = true,
    }
end

function BirchForest:needsTo_ProvideItemsTo_SOSrv(...)
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
    if not checkSuccess then corelog.Error("BirchForest:needsTo_ProvideItemsTo_SOSrv: Invalid input") return {success = false} end

    -- loop on items
    local fuelNeed = 0
    local ingredientsNeed = {} -- ToDo ? should we add saplings for a harvest round here?
    local nTrees = self:getNTrees()
    for itemName, itemCount in pairs(provideItems) do
        -- check
        if type(itemName) ~= "string" then corelog.Error("BirchForest:needsTo_ProvideItemsTo_SOSrv: Invalid itemName (type="..type(itemName)..")") return {success = false} end
        if type(itemCount) ~= "number" then corelog.Error("BirchForest:needsTo_ProvideItemsTo_SOSrv: Invalid itemCount (type="..type(itemCount)..")") return {success = false} end

        -- check for birchlog or sapling
        local itemPerRound = 1
        local localItemSupplierLocator = nil
        if itemName == "minecraft:birch_log" then
            itemPerRound = 5 * nTrees -- using minimum birch_log per tree (based on data in birchgrow.xlsx)
            localItemSupplierLocator = self:getLocalLogsLocator()
        elseif itemName == "minecraft:birch_sapling" then
            itemPerRound = 1.4 * nTrees -- using average birch_sapling per tree (based on data in birchgrow.xlsx)
            -- ToDo: consider some safety margin for small forests as average ~= minimum (minimum = -1 in 9% of the cases)
            localItemSupplierLocator = self:getLocalSaplingsLocator()
        else
            corelog.Error("BirchForest:needsTo_ProvideItemsTo_SOSrv: Provider does not provide "..itemName.."'s") return {success = false}
        end
        if not localItemSupplierLocator then corelog.Error("BirchForest:needsTo_ProvideItemsTo_SOSrv: Invalid localItemSupplierLocator (type="..type(localItemSupplierLocator)..")") return {success = false} end

        -- fuelNeed per round
        local fuelPerRound = role_forester.FuelNeededPerRound(nTrees)
        local nRounds = math.ceil(itemCount / itemPerRound)
        local fuelNeed_Rounds = nRounds * fuelPerRound

        -- fuelNeed transfer
        local localItemsLocator = localItemSupplierLocator:copy()
        local items = { [itemName] = itemCount }
        localItemsLocator:setQuery(items)
        local transferData = {
            sourceItemsLocator          = localItemsLocator,
            destinationItemDepotLocator = itemDepotLocator,
        }
        local serviceResults = enterprise_isp.NeedsTo_TransferItems_SSrv(transferData)
        if not serviceResults.success then corelog.Error("BirchForest:needsTo_ProvideItemsTo_SOSrv: Failed obtaining transfer needs for "..itemCount.." "..itemName.."'s") return {success = false} end
        local fuelNeed_Transfer = serviceResults.fuelNeed

        -- add fuelNeed
--        corelog.WriteToLog("C  fuelNeed_Rounds="..fuelNeed_Rounds.." (nRounds="..nRounds..", fuelPerRound="..fuelPerRound.."), fuelNeed_Transfer="..fuelNeed_Transfer)
        fuelNeed = fuelNeed + fuelNeed_Rounds + fuelNeed_Transfer
    end

    -- end
    return {
        success         = true,
        fuelNeed        = fuelNeed,
        ingredientsNeed = ingredientsNeed,
    }
end

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

function BirchForest:getFirstTreeLocation()
    return self:getBaseLocation():getRelativeLocation(3, 2, 0)
end

return BirchForest
