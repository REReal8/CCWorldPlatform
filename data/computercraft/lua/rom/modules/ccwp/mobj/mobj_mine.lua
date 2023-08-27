-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local IItemSupplier = require "i_item_supplier"
local IMObj = require "i_mobj"
local Mine = Class.NewClass(ObjBase, IItemSupplier, IMObj)

--[[
    The following design decisions are made
        - The mine has full control of all area with z coordinate -32 and lower.
--]]

local coreutils = require "coreutils"
local corelog = require "corelog"

local InputChecker = require "input_checker"
local Callback = require "obj_callback"
local ObjArray = require "obj_array"
local Block = require "obj_block"
local LayerRectangle = require "obj_layer_rectangle"
local Location = require "obj_location"

local enterprise_chests = require "enterprise_chests"

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function Mine:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a Mine.

        Parameters:
            o                           + (table) with object fields
                _id                     - (string) id of the Mine
                _version                - (number) version of the Mine
                _baseLocation           - (Location) base location of the Mine
                _topChests              - (ObjArray) with top chests
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Mine:new: Invalid input") return {} end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- end
    return o
end

function Mine:NewMine(...)
    -- get & check input from description
    local checkSuccess, baseLocation, topChests = InputChecker.Check([[
        Construct a mine.

        Parameters:
            siteData                    - (table) data about this silo, like type and layout
                baseLocation            + (Location) base location of Mine
                topChests               + (number, 2) # of top chests
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Silo:new: Invalid input") return {} end

    -- better safe then sorry, maybe flexible one day
--    location:setDX(0)
--    location:setDY(1)

    -- main var
    local siteData  = {
        _id             = coreutils.NewId(),

        -- might be userfull later
        _version        = 1,

        -- locations
        _baseLocation   = baseLocation,

        -- chests
        _topChests      = ObjArray:new({
            _objClassName = "URL",
        }),

        -- is this silo accepting requests?
        _operational    = false,
    }

    -- what kind of new silo is this?
    corelog.WriteToLog(">Starting mine at "..textutils.serialise(baseLocation, { compact = true }))

    -- add our top chests, depending how many we have
    if topChests >= 1 then table.insert(siteData._topChests, enterprise_chests:hostMObj_SSrv({className="Chest",constructParameters={baseLocation=baseLocation:getRelativeLocation(2, 5, 0), accessDirection="back"}}).mobjLocator) end
    if topChests >= 2 then table.insert(siteData._topChests, enterprise_chests:hostMObj_SSrv({className="Chest",constructParameters={baseLocation=baseLocation:getRelativeLocation(4, 5, 0), accessDirection="back"}}).mobjLocator) end
    if topChests >= 3 then table.insert(siteData._topChests, enterprise_chests:hostMObj_SSrv({className="Chest",constructParameters={baseLocation=baseLocation:getRelativeLocation(5, 4, 0), accessDirection="left"}}).mobjLocator) end
    if topChests >= 4 then table.insert(siteData._topChests, enterprise_chests:hostMObj_SSrv({className="Chest",constructParameters={baseLocation=baseLocation:getRelativeLocation(5, 2, 0), accessDirection="left"}}).mobjLocator) end
    if topChests >= 5 then table.insert(siteData._topChests, enterprise_chests:hostMObj_SSrv({className="Chest",constructParameters={baseLocation=baseLocation:getRelativeLocation(4, 1, 0), accessDirection="front"}}).mobjLocator) end
    if topChests >= 6 then table.insert(siteData._topChests, enterprise_chests:hostMObj_SSrv({className="Chest",constructParameters={baseLocation=baseLocation:getRelativeLocation(2, 1, 0), accessDirection="front"}}).mobjLocator) end
    if topChests >= 7 then table.insert(siteData._topChests, enterprise_chests:hostMObj_SSrv({className="Chest",constructParameters={baseLocation=baseLocation:getRelativeLocation(1, 2, 0), accessDirection="right"}}).mobjLocator) end
    if topChests >= 8 then table.insert(siteData._topChests, enterprise_chests:hostMObj_SSrv({className="Chest",constructParameters={baseLocation=baseLocation:getRelativeLocation(1, 4, 0), accessDirection="right"}}).mobjLocator) end

    -- set class info
    setmetatable(siteData, self)
    self.__index = self

    -- end
    return siteData
end

function Mine:Activate()
    self._operational = true
--    self:update() -- note: does not exist, so removed for now
end

function Mine:Deactivate()
    self._operational = false
    self:update()
end

function Mine:getId()
    return self._id
end

function Mine:getBaseLocation()
    return self._baseLocation
end

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

function Mine:getClassName()
    return "Mine"
end

--    _____ _____ _                  _____                   _ _                            _   _               _
--   |_   _|_   _| |                / ____|                 | (_)                          | | | |             | |
--     | |   | | | |_ ___ _ __ ___ | (___  _   _ _ __  _ __ | |_  ___ _ __   _ __ ___   ___| |_| |__   ___   __| |___
--     | |   | | | __/ _ \ '_ ` _ \ \___ \| | | | '_ \| '_ \| | |/ _ \ '__| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| |_ _| |_| ||  __/ | | | | |____) | |_| | |_) | |_) | | |  __/ |    | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____|_____|\__\___|_| |_| |_|_____/ \__,_| .__/| .__/|_|_|\___|_|    |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                                              | |   | |
--                                              |_|   |_|

function Mine:provideItemsTo_AOSrv(...)
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
                wasteItemDepotLocator           - (URL) locating where waste material can be delivered
                assignmentsPriorityKey          + (string, "") priorityKey that should be set for all assignments triggered by this service
            callback                            + (Callback) to call once service is ready
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Mine:provideItemsTo_AOSrv: Invalid input") return Callback.ErrorCall(callback) end

    -- start project
    corelog.WriteToLog(">Retrieve "..textutils.serialise(provideItems).." from Mine (!!NOT IMPLEMENTEND!!)")
    return Callback.ErrorCall(callback)
end

function Mine:can_ProvideItems_QOSrv(...)
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
    if not checkSuccess then corelog.Error("Mine:can_ProvideItems_QOSrv: Invalid input") return {success = false} end

    -- no trouble if we are not (or no longer) operational
    if not self._operational then
        -- weird
        corelog.WriteToLog("inactive mine queried (self._operational = "..tostring(self._operational)..")")

        -- ignore this error for now
    --    return {success = false, message = "mine not operational"}
    end

    -- check if all items are underground findable
    local available = {
        ["minecraft:coal"]          = true,
        ["minecraft:cobblestone"]   = true,
        ["minecraft:copper_ore"]    = true,
        ["minecraft:diamond"]       = true,
        ["minecraft:dirt"]          = true,
        ["minecraft:emerald_ore"]   = true,
        ["minecraft:iron_ore"]      = true,
        ["minecraft:redstone"]      = true,
    }

    coreutils.WriteToLog("provideItems:")
    coreutils.WriteToLog(provideItems)

    -- guess we did not find anything
    return {success = false, message = "items not available"}
end

function Mine:needsTo_ProvideItemsTo_SOSrv(...)
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
    if not checkSuccess then corelog.Error("Mine:needsTo_ProvideItemsTo_SOSrv: Invalid input") return {success = false, fuelNeed = 20000} end

    -- ToDo: better estimate, probebly based on earlier experience
    return {success = true, fuelNeed = 1000}
end

local function TopLayerlayer()
    return LayerRectangle:new({
        _codeArray  = {
            ["T"]   = Block:newInstance("minecraft:torch"),
            ["C"]   = Block:newInstance("minecraft:chest"),
            [" "]   = Block:newInstance(Block.NoneBlockName()),
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

function Mine.GetV1SiteBuildData(serviceData)
    -- construct layer list
    local layerList = {
        { startpoint = Location:newInstance(0, 0, 0), buildFromAbove = true,    layer = TopLayerlayer()},
    }

    -- construct blueprint
    local blueprint = {
        layerList = layerList,
        escapeSequence = {Location:newInstance(0, 0, 1)}
    }

    -- construct build data
    local siteBuildData = {
        blueprintStartpoint = serviceData.baseLocation:copy(),
        blueprint = blueprint
    }

    return siteBuildData
end

return Mine