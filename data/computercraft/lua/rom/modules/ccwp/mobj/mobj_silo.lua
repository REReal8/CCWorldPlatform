-- define class
local ObjBase = require "obj_base"
local Silo = ObjBase:new()

local coreutils = require "coreutils"
local corelog = require "corelog"

local InputChecker = require "input_checker"
local Callback = require "obj_callback"

local ObjArray = require "obj_array"
local Host = require "obj_host"

local Location = require "obj_location"
local Block = require "obj_block"
local LayerRectangle = require "obj_layer_rectangle"

local enterprise_projects = require "enterprise_projects"
local enterprise_turtle
local enterprise_chests = require "enterprise_chests"
local enterprise_storage


--[[
    The following design decisions are made
        - The actual Silo's should never be accessed directly but only via the services of this mobj.
--]]

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function Silo:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a Silo.

        Parameters:
            o                           + (table, {}) with object fields
                _id                     - (string) id of the Silo
                _version                - (number) version of the Silo
                _baseLocation           - (Location) base location of the Silo
                _entryLocation          - (Location) entry location of the Silo
                _dropLocation           - (number) top chest index
                _pickupLocation         - (number) top chest index
                _topChests              - (ObjArray) with top chests
                _storageChests          - (ObjArray) with storage chests
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Silo:new: Invalid input") return {} end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- end
    return o
end

function Silo:Activate()
    self._operational = true
    self:update()
end

function Silo:Deactivate()
    self._operational = false
    self:update()
end

function Silo:getBaseLocation()
    return self._baseLocation
end

function Silo:getNTopChests()
    --[[
        Returns the # top Chest's in the Silo.
    ]]

    -- end
    return #(self._topChests)
end

function Silo:getNStorageLayers()
    --[[
        Returns the # storage layers in the Silo.
    ]]

    -- end
    return #(self._storageChests)/ 4
end

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

function Silo:getClassName()
    return "Silo"
end

--    _____ __  __  ____  _     _                  _   _               _
--   |_   _|  \/  |/ __ \| |   (_)                | | | |             | |
--     | | | \  / | |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | | | |\/| | |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| |_| |  | | |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____|_|  |_|\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                            _/ |
--                           |__/

function Silo:construct(...)
    -- get & check input from description
    local checkSuccess, baseLocation, topChests, layers = InputChecker.Check([[
        This method constructs a Silo instance from a table of parameters with all necessary fields (in an objectTable) and methods (by setmetatable) as defined in the class.

        It also ensures all child MObj's the Silo spawns are hosted on the appropriate MObjHost (by calling hostMObj_SSrv).

        The constructed Silo is not yet saved in the Host.

        Return value:
                                        - (Silo) the constructed Silo

        Parameters:
            constructParameters         - (table) parameters for constructing the Silo
                baseLocation            + (Location) base location of the Silo
                topChests               + (number, 2) # of top chests
                layers                  + (number, 2) # of layers
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Silo:construct: Invalid input") return nil end

    -- better safe then sorry, maybe flexible one day
    baseLocation:setDX(0)
    baseLocation:setDY(1)

    -- make object table
    local oTable  = {
        _id             = coreutils.NewId(),

        -- might be userfull later
        _version        = 1,

        -- locations
        _baseLocation   = baseLocation:copy(),
        _entryLocation  = baseLocation:getRelativeLocation(3, 3, 0),

        -- pickup and drop
        _dropLocation   = 0,
        _pickupLocation = 0,

        -- chests
        _topChests      = ObjArray:new({
            _objClassName = "URL",
        }),
        _storageChests  = ObjArray:new({
            _objClassName = "URL",
        }),

        -- is this silo accepting requests?
        _operational    = false,
    }

    -- log
--    corelog.WriteToLog(">Starting Silo at "..textutils.serialise(baseLocation, { compact = true }))

    -- add our top chests, depending how many we have
    if topChests >= 1 then table.insert(oTable._topChests, enterprise_chests:hostMObj_SSrv({className="Chest",constructParameters={baseLocation=baseLocation:getRelativeLocation(2, 5, 0), accessDirection="back"}}).mobjLocator) end
    if topChests >= 2 then table.insert(oTable._topChests, enterprise_chests:hostMObj_SSrv({className="Chest",constructParameters={baseLocation=baseLocation:getRelativeLocation(4, 5, 0), accessDirection="back"}}).mobjLocator) end
    if topChests >= 3 then table.insert(oTable._topChests, enterprise_chests:hostMObj_SSrv({className="Chest",constructParameters={baseLocation=baseLocation:getRelativeLocation(5, 4, 0), accessDirection="left"}}).mobjLocator) end
    if topChests >= 4 then table.insert(oTable._topChests, enterprise_chests:hostMObj_SSrv({className="Chest",constructParameters={baseLocation=baseLocation:getRelativeLocation(5, 2, 0), accessDirection="left"}}).mobjLocator) end
    if topChests >= 5 then table.insert(oTable._topChests, enterprise_chests:hostMObj_SSrv({className="Chest",constructParameters={baseLocation=baseLocation:getRelativeLocation(4, 1, 0), accessDirection="front"}}).mobjLocator) end
    if topChests >= 6 then table.insert(oTable._topChests, enterprise_chests:hostMObj_SSrv({className="Chest",constructParameters={baseLocation=baseLocation:getRelativeLocation(2, 1, 0), accessDirection="front"}}).mobjLocator) end
    if topChests >= 7 then table.insert(oTable._topChests, enterprise_chests:hostMObj_SSrv({className="Chest",constructParameters={baseLocation=baseLocation:getRelativeLocation(1, 2, 0), accessDirection="right"}}).mobjLocator) end
    if topChests >= 8 then table.insert(oTable._topChests, enterprise_chests:hostMObj_SSrv({className="Chest",constructParameters={baseLocation=baseLocation:getRelativeLocation(1, 4, 0), accessDirection="right"}}).mobjLocator) end

    -- set the defaults (basic setup)
    if topChests >= 1 then oTable._dropLocation   = 1 end
    if topChests >= 2 then oTable._pickupLocation = 2 end

    -- loop the layers
    for i=1, layers, 1 do

        -- do the floor
        local shaft = oTable._entryLocation:getRelativeLocation(0, 0, -1 - i)
        table.insert(oTable._storageChests, enterprise_chests:hostMObj_SSrv({className="Chest",constructParameters={baseLocation=shaft:getDivergentDirection( 0,  1):getLocationFront(), accessDirection="back"}}).mobjLocator)
        table.insert(oTable._storageChests, enterprise_chests:hostMObj_SSrv({className="Chest",constructParameters={baseLocation=shaft:getDivergentDirection( 1,  0):getLocationFront(), accessDirection="back"}}).mobjLocator)
        table.insert(oTable._storageChests, enterprise_chests:hostMObj_SSrv({className="Chest",constructParameters={baseLocation=shaft:getDivergentDirection( 0, -1):getLocationFront(), accessDirection="back"}}).mobjLocator)
        table.insert(oTable._storageChests, enterprise_chests:hostMObj_SSrv({className="Chest",constructParameters={baseLocation=shaft:getDivergentDirection(-1,  0):getLocationFront(), accessDirection="back"}}).mobjLocator)
    end

    -- create new Silo
    return Silo:new(oTable)
end

function Silo:destruct()
    --[[
        This method destructs a Silo instance.

        It also ensures all child MObj's the Silo is the parent of are released from the appropriate MObjHost (by calling releaseMObj_SSrv).

        The Silo is not yet deleted from the Host.

        Return value:
                                        - (boolean) whether the Silo was succesfully destructed.

        Parameters:
    ]]

    -- for debugging only
--    corelog.WriteToLog("Oh no, someone is deleting a Silo!!!")

    -- Why would you ever want to delete such a magnificent structure.
    local childsSuccesfullyReleased = true
    for i, mobjLocator in ipairs(self._topChests) do
        local releaseResult = enterprise_chests:releaseMObj_SSrv({ mobjLocator = mobjLocator })
        if not releaseResult or not releaseResult.success then corelog.Warning("Silo:destruct(): failed releasing top Chest "..mobjLocator:getURI()) childsSuccesfullyReleased = false end
    end
    for i, mobjLocator in ipairs(self._storageChests) do
        local releaseResult = enterprise_chests:releaseMObj_SSrv({ mobjLocator = mobjLocator })
        if not releaseResult or not releaseResult.success then corelog.Warning("Silo:destruct(): failed releasing storage Chest "..mobjLocator:getURI()) childsSuccesfullyReleased = false end
    end

    -- end
    return childsSuccesfullyReleased
end

function Silo:getId()
    --[[
        Return the unique Id of the Silo.
    ]]

    return self._id
end

function Silo:getWIPId()
    --[[
        Returns the unique Id of the Silo used for administering WIP.
    ]]

    return self:getClassName().." "..self:getId()
end

local function TopL0_layer()
    return LayerRectangle:new({
        _codeArray  = {
            ["T"]   = Block:new({ _name = "minecraft:torch" }),
            ["C"]   = Block:new({ _name = "minecraft:chest", _dx =0, _dy = 1 }),
            [" "]   = Block:new({ _name = Block.NoneBlockName() }),
        },
        _codeMap    = {
            [6] = "  C C ",
            [5] = "      ",
            [4] = "T     ",
            [3] = "      ",
            [2] = "      ",
            [1] = "   T  ",
        },
    })
end

local function Shaft_layer()
    return LayerRectangle:new({
        _codeArray  = {
            [" "]   = Block:new({ _name = Block.NoneBlockName() }),
        },
        _codeMap    = {
            [1] = " ",
        },
    })
end

local function Storage_layer()
    return LayerRectangle:new({
        _codeArray  = {
            ["C"]   = Block:new({ _name = "minecraft:chest", _dx =-1, _dy = 0 }),
            ["D"]   = Block:new({ _name = "minecraft:chest", _dx = 0, _dy = 1 }),
            ["E"]   = Block:new({ _name = "minecraft:chest", _dx = 0, _dy =-1 }),
            ["F"]   = Block:new({ _name = "minecraft:chest", _dx = 1, _dy = 0 }),
            [" "]   = Block:new({ _name = Block.NoneBlockName() }),
        },
        _codeMap    = {
            [3] = "DDF",
            [2] = "C F",
            [1] = "CEE",
        },
    })
end

function Silo:getBuildBlueprint()
    --[[
        This method returns a blueprint for building the Silo in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
    ]]

    -- construct layer list
    local nTopChests = self:getNTopChests()
    if nTopChests ~= 2 then corelog.Warning("Silo:getBuildBlueprint: Not yet implemented for other (="..nTopChests..") than 2 top chests") end
    local layerList = {
        { startpoint = Location:new({ _x= 0, _y= 0, _z=  0}), buildFromAbove = true, layer = TopL0_layer()}, -- ToDo: use nTopChests
        { startpoint = Location:new({ _x= 3, _y= 3, _z= -1}), buildFromAbove = false, layer = Shaft_layer()},
    }
    local nLayers = self:getNStorageLayers()
    for i=1, nLayers, 1 do
        table.insert(layerList, { startpoint = Location:new({ _x= 2, _y= 2, _z= -1-i}), buildFromAbove = false, layer = Storage_layer()})
    end

    -- construct blueprint
    local blueprint = {
        layerList = layerList,
        escapeSequence = {
            Location:new({ _x= 3, _y= 3, _z=  1}),
        }
    }

    -- determine buildLocation
    local buildLocation = self._baseLocation:copy()

    -- end
    return buildLocation, blueprint
end

local function StorageDismantle_layer()
    return LayerRectangle:new({
        _codeArray  = {
            ["D"]   = Block:new({ _name = "minecraft:dirt" }),
            ["?"]   = Block:new({ _name = Block.AnyBlockName() }),
        },
        _codeMap    = {
            [3] = "DDD",
            [2] = "D?D",
            [1] = "DDD",
        },
    })
end

local function ShaftDismantle_layer()
    return LayerRectangle:new({
        _codeArray  = {
            ["D"]   = Block:new({ _name = "minecraft:dirt" }),
        },
        _codeMap    = {
            [1] = "D",
        },
    })
end

local function TopDismantle_layer()
    return LayerRectangle:new({
        _codeArray  = {
            [" "]   = Block:new({ _name = Block.NoneBlockName() }),
        },
        _codeMap    = {
            [6] = "      ",
            [5] = "      ",
            [4] = "      ",
            [3] = "      ",
            [2] = "      ",
            [1] = "      ",
        },
    })
end

function Silo:getDismantleBlueprint()
    --[[
        This method returns a blueprint for dismantling the Silo in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
    ]]

    -- construct layer list
    local layerList = {
        -- dismantle top layer
        { startpoint = Location:new({ _x= 0, _y= 0, _z=  0}), buildFromAbove = true, layer = TopDismantle_layer()},
        -- position in shaft of first storage layer
        { startpoint = Location:new({ _x= 3, _y= 3, _z= -1}), buildFromAbove = false, layer = Shaft_layer()},
    }
    local nLayers = self:getNStorageLayers()
    for i=1, nLayers, 1 do
        -- dismantle storage layer i
        table.insert(layerList, { startpoint = Location:new({ _x= 2, _y= 2, _z= -1-i}), buildFromAbove = false, layer = StorageDismantle_layer()})
    end
    -- position in shaft below last storage layer
    table.insert(layerList, { startpoint = Location:new({ _x= 3, _y= 3, _z= -1-nLayers}), buildFromAbove = false, layer = Shaft_layer()})
    for i=1, nLayers+1, 1 do
        -- dismantle shaft layer i
        table.insert(layerList, { startpoint = Location:new({ _x= 3, _y= 3, _z= -2-nLayers+i}), buildFromAbove = true, layer = ShaftDismantle_layer()})
    end

    -- note: this dismantle blueprint does not restore the layer below the last storage layer

    -- construct blueprint
    local blueprint = {
        layerList = layerList,
        escapeSequence = {
            Location:new({ _x= 3, _y= 3, _z=  1}),
        }
    }

    -- determine buildLocation
    local buildLocation = self._baseLocation:copy()

    -- end
    return buildLocation, blueprint
end

--    _____ _____ _                  _____                   _ _                            _   _               _
--   |_   _|_   _| |                / ____|                 | (_)                          | | | |             | |
--     | |   | | | |_ ___ _ __ ___ | (___  _   _ _ __  _ __ | |_  ___ _ __   _ __ ___   ___| |_| |__   ___   __| |___
--     | |   | | | __/ _ \ '_ ` _ \ \___ \| | | | '_ \| '_ \| | |/ _ \ '__| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| |_ _| |_| ||  __/ | | | | |____) | |_| | |_) | |_) | | |  __/ |    | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____|_____|\__\___|_| |_| |_|_____/ \__,_| .__/| .__/|_|_|\___|_|    |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                                              | |   | |
--                                              |_|   |_|

function Silo:provideItemsTo_AOSrv(...)
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
    if not checkSuccess then corelog.Error("Silo:provideItemsTo_AOSrv: Invalid input") return Callback.ErrorCall(callback) end

    -- create project definition
    enterprise_turtle = enterprise_turtle or require "enterprise_turtle"
    local projectData = {
        provideItems            = provideItems,
        pickupLocator           = self:getPickupLocation(),

        itemDepotLocator        = itemDepotLocator,

        assignmentsPriorityKey  = assignmentsPriorityKey,
        silo                    = self:copy(),
    }
    local projectDef = {
        steps   = {
            -- roept functie aan die goederen uit de silo naar de top chest brengt
            { stepType = "AOSrv", stepTypeDef = { className = "Silo", serviceName = "fromSiloIntoTopchest_AOSrv", objStep = 0, objKeyDef = "silo" }, stepDataDef = {
                { keyDef = "provideItems"           , sourceStep = 0, sourceKeyDef = "provideItems" },
                { keyDef = "pickupLocator"          , sourceStep = 0, sourceKeyDef = "pickupLocator" },
                { keyDef = "assignmentsPriorityKey" , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
            }},
            -- roept functie aan die goederen van top chest naar destination brengt
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_isp", serviceName = "StoreItemsFrom_ASrv" }, stepDataDef = {
                { keyDef = "itemsLocator"                   , sourceStep = 1, sourceKeyDef = "destinationItemsLocator" },
                { keyDef = "itemDepotLocator"               , sourceStep = 0, sourceKeyDef = "itemDepotLocator" },
                { keyDef = "assignmentsPriorityKey"         , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
            }},
        },
        returnData  = {
            { keyDef = "destinationItemsLocator"    , sourceStep = 2, sourceKeyDef = "destinationItemsLocator" },
        }
    }
    local projectServiceData = {
        projectDef  = projectDef,
        projectData = projectData,
        projectMeta = { title = "Retrieving from a silo", description = "Underground magic" },
    }

    -- start project
    corelog.WriteToLog(">Retrieve "..textutils.serialise(provideItems).." from Silo")
    return enterprise_projects.StartProject_ASrv(projectServiceData, callback)
end

function Silo:can_ProvideItems_QOSrv(...)
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
    if not checkSuccess then corelog.Error("Silo:can_ProvideItems_QOSrv: Invalid input") return {success = false} end

    -- no trouble if we are not (or no longer) operational
    if not self._operational then
        -- weird
        corelog.WriteToLog("inactive silo queried (self._operational = "..tostring(self._operational)..")")

        -- ignore this for now
    --    return {success = false, message = "silo not operational"}
    end

    -- loop all storage chests to see if we can deliver
    -- version 0.2, only intersted if 1 chest can fully deliver (no partial deliveries yet)
    for i, chestLocator in ipairs(self._storageChests) do
        -- get the chest
        local chest     = Host.GetObject(chestLocator)

        -- valid opbject?
        if chest then

            -- get the inventory of this chest
            local inventory = chest:getInventory()

            -- valid object?
            if inventory then

                -- can we deliver from this one?
                if inventory:hasItems(provideItems) then

                    -- nice, we found it!
                    return {
                        success = true,
                        pickupList = {
                            {
                                chestLocator = chestLocator:copy(),
                                itemList     = provideItems,
                            },
                        },
                    }
                end
            end
        end
    end

    -- guess we did not find anything
    return {success = false, message = "items not available"}
end

function Silo:needsTo_ProvideItemsTo_SOSrv(...)
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
    if not checkSuccess then corelog.Error("Silo:needsTo_ProvideItemsTo_SOSrv: Invalid input") return {success = false} end

    -- ToDo: implement
    corelog.Warning("Silo:needsTo_ProvideItemsTo_SOSrv: not yet implemented")
    return {success = true, fuelNeed = 10 + #self._storageChests}
end

--    _____ _____ _                 _____                   _                    _   _               _
--   |_   _|_   _| |               |  __ \                 | |                  | | | |             | |
--     | |   | | | |_ ___ _ __ ___ | |  | | ___ _ __   ___ | |_   _ __ ___   ___| |_| |__   ___   __| |___
--     | |   | | | __/ _ \ '_ ` _ \| |  | |/ _ \ '_ \ / _ \| __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| |_ _| |_| ||  __/ | | | | | |__| |  __/ |_) | (_) | |_  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____|_____|\__\___|_| |_| |_|_____/ \___| .__/ \___/ \__| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                                             | |
--                                             |_|

function Silo:storeItemsFrom_AOSrv(...)
    -- get & check input from description
    local checkSuccess, itemsLocator, assignmentsPriorityKey, callback = InputChecker.Check([[
        This async public ItemDepot service stores items from from an ItemSupplier.

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
    if not checkSuccess then corelog.Error("Silo:storeItemsFrom_AOSrv: Invalid input") return Callback.ErrorCall(callback) end

    -- set (expected) destinationItemsLocator
    enterprise_storage = enterprise_storage or require "enterprise_storage"
    local destinationItemsLocator = enterprise_storage:getObjectLocator(self)
    destinationItemsLocator:setQuery(coreutils.DeepCopy(itemsLocator:getQuery()))

    -- create project definition
    enterprise_turtle = enterprise_turtle or require "enterprise_turtle"
    local projectData = {
        itemsLocator            = itemsLocator,
        dropLocator             = self:getDropLocation(),
        assignmentsPriorityKey  = assignmentsPriorityKey,

        destinationItemsLocator = destinationItemsLocator,

        silo                    = self:copy(),
    }
    local projectDef = {
        steps   = {
            -- roept functie aan die goederen van pickup locati enaar silo topchest
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_isp", serviceName = "StoreItemsFrom_ASrv" }, stepDataDef = {
                { keyDef = "itemsLocator"           , sourceStep = 0, sourceKeyDef = "itemsLocator" },
                { keyDef = "itemDepotLocator"       , sourceStep = 0, sourceKeyDef = "dropLocator" },
                { keyDef = "assignmentsPriorityKey" , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
            }},
            -- roept functie aan die goederen van topchest opslaat in de silo
                -- roept functie aan die bepalen welke items naar welke chjests moeten
                    -- indien geen ruimte, eerst enterprise inschakelen voor uitbreiding
                -- per goederen type opslaan
            { stepType = "AOSrv", stepTypeDef = { className = "Silo", serviceName = "fromTopchestIntoSilo_AOSrv", objStep = 0, objKeyDef = "silo" }, stepDataDef = {
                { keyDef = "itemsLocator"           , sourceStep = 1, sourceKeyDef = "destinationItemsLocator" },
                { keyDef = "assignmentsPriorityKey" , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
            }},
        },
        returnData  = {
            { keyDef = "destinationItemsLocator"    , sourceStep = 0, sourceKeyDef = "destinationItemsLocator" },
        }
    }
    local projectServiceData = {
        projectDef  = projectDef,
        projectData = projectData,
        projectMeta = { title = "The silo is for storing", description = "Free your inventory and the rest will follow" },
    }

    -- start project
    corelog.WriteToLog(">Store "..itemsLocator:getURI().." into Silo")
    return enterprise_projects.StartProject_ASrv(projectServiceData, callback)
end

function Silo:can_StoreItems_QOSrv(...)
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
    if not checkSuccess then corelog.Error("Silo:can_StoreItems_QOSrv: Invalid input") return {success = false} end

    -- ToDo: implement
    corelog.Warning("Silo:can_StoreItems_QOSrv: not yet implemented")
    return {success = self._operational} -- we can always store (at least that is what we pretent as long as we are in operation)
end

function Silo:needsTo_StoreItemsFrom_SOSrv(...)
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
    if not checkSuccess then corelog.Error("Silo:needsTo_StoreItemsFrom_SOSrv: Invalid input") return {success = false} end

    -- ToDo: implement
    corelog.Warning("Silo:needsTo_StoreItemsFrom_SOSrv: not yet implemented")
    return {success = true, fuelNeed = 10 + #self._storageChests} -- we can fix anything with that much fuel
end

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

function Silo:getDropLocation()
    -- easy
    return self._topChests[self._dropLocation]
end

function Silo:getPickupLocation()
    -- easy
    return self._topChests[self._pickupLocation]
end

--                        _                           _   _               _
--                       (_)                         | | | |             | |
--    ___  ___ _ ____   ___  ___ ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \  __/ |   \ V /| | (_|  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/\___|_|    \_/ |_|\___\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

-- private methods

function Silo:fromSiloIntoTopchest_AOSrv(...)
    -- get & check input from description
    local checkSuccess, provideItems, pickupLocator, assignmentsPriorityKey, callback = InputChecker.Check([[
        Todo betere omschrijving
            -- roept functie aan die bepalen welke items naar welke chjests moeten
            -- indien geen ruimte, eerst enterprise inschakelen voor uitbreiding
            -- per goederen type opslaan

        Return value:
                                        - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                        - (table)
                success                 - (boolean) whether the service executed successfully
                destinationItemsLocator - (URL) locating the final ItemDepot and the items that where transferred to it
                                            (upon service succes the "host" component of this URL should be equal to itemDepotLocator, and
                                            the "query" should be equal to orderItems)

        Parameters:
            serviceData                 - (table) data about the service
                provideItems            + (table) with one or more items (formatted as an array of [itemName] = itemCount key-value pairs) to provide
                pickupLocator           + (URL) locating the pickupLocator where the items need to be provided to
                assignmentsPriorityKey  + (string, "") priorityKey that should be set for all assignments triggered by this service
            callback                    + (Callback) to call once service is ready
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Silo:fromSiloIntoTopchest_AOSrv: Invalid input") return Callback.ErrorCall(callback) end

    -- check if we can provide the requested items
    local answer    = self:can_ProvideItems_QOSrv({provideItems = provideItems})

    -- check if we can!
    if not answer or not answer.success then
        corelog.Error("Silo:fromSiloIntoTopchest_AOSrv(...): don't know where to get the requested items")
        corelog.WriteToLog("answer:")
        corelog.WriteToLog(answer)
        return nil
    end

    -- create the project data
    local projectData   = {
        pickupLocator           = pickupLocator,
        assignmentsPriorityKey  = assignmentsPriorityKey,
    }

    -- for the steps
    local projectSteps  = {}

    -- loop the pickup list
    for i, value in ipairs(answer.pickupList) do
        -- make the data
        local chestLocator = value.chestLocator
        chestLocator:setQuery(value.itemList)

        -- add to project data
        projectData[ "sourceChestLocator" .. i ] = chestLocator

        -- add new project step
        table.insert(projectSteps,
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_isp", serviceName = "StoreItemsFrom_ASrv" }, stepDataDef = {
                { keyDef = "itemsLocator"                   , sourceStep = 0, sourceKeyDef = "sourceChestLocator" .. i },
                { keyDef = "itemDepotLocator"               , sourceStep = 0, sourceKeyDef = "pickupLocator" },
                { keyDef = "assignmentsPriorityKey"         , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
            }}
        )
    end

    -- create URL where the items are with item list
--    local chestOneItemsLocator = self._storageChests[ 1 ]:copy() -- to improve!
--    local sourceChestLocator = answer.pickupList[1].chestLocator
--    sourceChestLocator:setQuery(answer.pickupList[1].itemList)

    -- the project definition
    local projectServiceData = {
        projectData = projectData,
        projectDef  = {
            steps   = projectSteps,
--            {
                -- roept functie aan die goederen van pickup locatie naar silo topchest
--                { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_isp", serviceName = "StoreItemsFrom_ASrv" }, stepDataDef = {
--                    { keyDef = "itemsLocator"                   , sourceStep = 0, sourceKeyDef = "sourceChestLocator" },
--                    { keyDef = "itemDepotLocator"               , sourceStep = 0, sourceKeyDef = "pickupLocator" },
--                    { keyDef = "assignmentsPriorityKey"         , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
--                }},
            returnData  = {
                { keyDef = "destinationItemsLocator"    , sourceStep = 1, sourceKeyDef = "destinationItemsLocator" }, -- todo: merge different URLs when items came from different chests, see enterprise_isp.AddItemsLocators_SSrv
            }
        },
        projectMeta = { title = "Internal silo project", description = "None of your business" },
    }

    -- start project
    corelog.WriteToLog(">fromSiloIntoTopchest_AOSrv(...)")
    return enterprise_projects.StartProject_ASrv(projectServiceData, callback)
end

function Silo:fromTopchestIntoSilo_AOSrv(...)
    -- get & check input from description
    local checkSuccess, itemsLocator, assignmentsPriorityKey, callback = InputChecker.Check([[
        Todo betere omschrijving
            -- roept functie aan die bepalen welke items naar welke chjests moeten
            -- indien geen ruimte, eerst enterprise inschakelen voor uitbreiding
            -- per goederen type opslaan

        Return value:
                                        - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                        - (table)
                success                 - (boolean) whether the service executed successfully

        Parameters:
            serviceData                 - (table) data about the service
                itemsLocator            + (URL) locating the items to store
                                            (the "base" component of the URL specifies the ItemSupplier that provides the items)
                                            (the "query" component of the URL specifies the items)
                assignmentsPriorityKey  + (string, "") priorityKey that should be set for all assignments triggered by this service
            callback                    + (Callback) to call once service is ready
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Silo:fromTopchestIntoSilo_AOSrv: Invalid input") return Callback.ErrorCall(callback) end

    corelog.WriteToLog("fromTopchestIntoSilo_AOSrv begin")

    local projectData = {
        itemsLocator            = itemsLocator,
        chestOneLocator         = self._storageChests[ math.random( #self._storageChests ) ],
        assignmentsPriorityKey  = assignmentsPriorityKey,
    }
    local projectDef = {
        steps   = {
            -- roept functie aan die goederen van pickup locati enaar silo topchest
            { stepType = "ASrv", stepTypeDef = { moduleName = "enterprise_isp", serviceName = "StoreItemsFrom_ASrv" }, stepDataDef = {
                { keyDef = "itemsLocator"           , sourceStep = 0, sourceKeyDef = "itemsLocator" },
                { keyDef = "itemDepotLocator"       , sourceStep = 0, sourceKeyDef = "chestOneLocator" },
                { keyDef = "assignmentsPriorityKey" , sourceStep = 0, sourceKeyDef = "assignmentsPriorityKey" },
            }},
        },
        returnData  = {
        }
    }
    local projectServiceData = {
        projectDef  = projectDef,
        projectData = projectData,
        projectMeta = { title = "Internal silo project", description = "None of your business" },
    }

    -- start project
    corelog.WriteToLog(">fromTopchestIntoSilo_AOSrv(...)")
    return enterprise_projects.StartProject_ASrv(projectServiceData, callback)
end

function Silo:update()
    -- one host at this time NOT WORKING
--    enterprise_storage:saveObject(self)
end

--[[
             _            _
            (_)          | |
  _ __  _ __ ___   ____ _| |_ ___
 | '_ \| '__| \ \ / / _` | __/ _ \
 | |_) | |  | |\ V / (_| | ||  __/
 | .__/|_|  |_| \_/ \__,_|\__\___|
 | |
 |_|
--]]

function Silo:IntegretyCheck(...)
    -- check all top chests
    for i, chestLocator in ipairs(self._topChests) do
        local chest = Host.GetObject(chestLocator)
        if chest then chest:updateChestRecord_AOSrv({}, Callback.GetNewDummyCallBack()) end
    end

    -- check all storage chests
    for i, chestLocator in ipairs(self._storageChests) do
        local chest = Host.GetObject(chestLocator)
        if chest then chest:updateChestRecord_AOSrv({}, Callback.GetNewDummyCallBack()) end
    end
end

function Silo:GetChestInventory(chestLocator)
    local chest = Host.GetObject(chestLocator)
    if chest then corelog.WriteToLog("Getting chest inventory") return chest:getInventory() end
end

return Silo