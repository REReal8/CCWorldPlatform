-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local ILObj = require "i_lobj"
local IMObj = require "i_mobj"
local MObjTest = Class.NewClass(ObjBase, ILObj, IMObj)

local corelog = require "corelog"
local coreutils = require "coreutils"

local InputChecker = require "input_checker"

--[[
    This module implements the class MObjTest.

    A MObjTest object can be used for testing MObj related functionality.
--]]

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function MObjTest:_init(...)
    -- get & check input from description
    local checkSuccess, id, baseLocation, field1 = InputChecker.Check([[
        Initialise a MObjTest.

        Parameters:
            id                      + (string) id of the MObjTest
            baseLocation            + (Location) base location of the MObjTest
            field1                  + (string) field 1
    ]], ...)
    if not checkSuccess then corelog.Error("MObjTest:_init: Invalid input") return nil end

    -- initialisation
    ObjBase._init(self)
    self._id            = id
    self._baseLocation  = baseLocation
    self._field1        = field1
end

-- ToDo: should be renamed to newFromTable at some point
function MObjTest:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a MObjTest.

        Parameters:
            o                           + (table, {}) with object fields
                _id                     - (string) id of the MObjTest
                _baseLocation           - (Location) base location of the MObjTest
                _field1                 - (string) field
    ]], ...)
    if not checkSuccess then corelog.Error("MObjTest:new: Invalid input") return nil end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- end
    return o
end

function MObjTest:getField1()
    return self._field1
end

function MObjTest:setField1(strValue)
    -- check input
    if type(strValue) ~= "string" then corelog.Error("MObjTest:setField1: invalid strValue: "..type(strValue)) return end

    self._field1 = strValue
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function MObjTest:getClassName()
    return "MObjTest"
end

--    _____ _      ____  _     _
--   |_   _| |    / __ \| |   (_)
--     | | | |   | |  | | |__  _
--     | | | |   | |  | | '_ \| |
--    _| |_| |___| |__| | |_) | |
--   |_____|______\____/|_.__/| |
--                           _/ |
--                          |__/

function MObjTest:construct(...)
    -- get & check input from description
    local checkSuccess, baseLocation, field1Value = InputChecker.Check([[
        This method constructs a MObjTest instance from a table of parameters with all necessary fields (in an objectTable) and methods (by setmetatable) as defined in the class.

        It also ensures all child MObj's the MObjTest spawns are hosted on the appropriate MObjHost (by calling hostMObj_SSrv).

        The constructed MObjTest is not yet saved in the MObjHost.

        Return value:
                                        - (MObjTest) the constructed MObjTest

        Parameters:
            constructParameters         - (table) parameters for constructing the MObj
                baseLocation            + (Location) base location of the MObjTest
                field1Value             + (string) value to set field1 to
    ]], ...)
    if not checkSuccess then corelog.Error("MObjTest:construct: Invalid input") return nil end

    -- determine MObjTest fields
    local id = coreutils.NewId()

    -- construct new MObjTest
    local obj = MObjTest:newInstance(id, baseLocation:copy(), field1Value)

    -- end
    return obj
end

function MObjTest:upgrade(...)
    -- get & check input from description
    local checkSuccess, field1 = InputChecker.Check([[
        This method upgrades a MObjTest instance from a table of parameters.

        The upgraded MObjTest is not yet saved in the MObjHost.

        Return value:
                                        - (boolean) whether the MObjTest was succesfully upgraded.

        Parameters:
            upgradeParameters           - (table) parameters for upgrading the MObjTest
                field1                  + (string) with field1 value to upgrade to
    ]], ...)
    if not checkSuccess then corelog.Error("MObjTest:upgrade: Invalid input") return false end

    -- upgrade
    if self._field1 == field1 then corelog.Warning("MObjTest:upgrade: field1 is already equal to "..field1) end
    self._field1 = field1

    -- end
    return true
end

function MObjTest:destruct()
    --[[
        This method destructs a MObjTest instance.

        It also ensures all child MObj's the MObjTest is the parent of are released from the appropriate MObjHost (by calling releaseMObj_SSrv).

        The MObjTest is not yet deleted from the MObjHost.

        Return value:
                                        - (boolean) whether the MObjTest was succesfully destructed.

        Parameters:
    ]]

    -- end
    return true
end

function MObjTest:getId()
    --[[
        Return a unique Id of the MObjTest.
    ]]

    return self._id
end

function MObjTest:getWIPId()
    --[[
        Returns the unique Id of the MObjTest used for administering WIP.
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

function MObjTest:getBaseLocation()
    return self._baseLocation
end

function MObjTest.GetBuildBlueprint(...)
    -- get & check input from description
    local checkSuccess, baseLocation = InputChecker.Check([[
        This method returns a blueprint for building a MObjTest in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
            constructParameters         - (table) parameters for constructing the MObjTest
                baseLocation            + (Location) base location of the MObjTest
    ]], ...)
    if not checkSuccess then corelog.Error("MObjTest.GetBuildBlueprint: Invalid input") return nil, nil end

    -- construct layer list
    local layerList = {
        -- note: empty as we do not want to actually have the Turtle move for MObjTest
    }

    -- construct blueprint
    local blueprint = {
        layerList = layerList,
        escapeSequence = {
        }
    }

    -- determine buildLocation
    local buildLocation = baseLocation:copy()

    -- end
    return buildLocation, blueprint
end

function MObjTest:getExtendBlueprint(...)
    -- get & check input from description
    local checkSuccess, field1 = InputChecker.Check([[
        This method returns a blueprint for extending the MObjTest in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
            upgradeParameters           - (table) parameters for upgrading the MObjTest
                field1                  + (string) with field1 value to upgrade to
    ]], ...)
    if not checkSuccess then corelog.Error("MObjTest:getExtendBlueprint: Invalid input") return nil end

    -- determine layerList
    local layerList = {
        -- note: empty as we do not want to actually have the Turtle move for MObjTest
    }

    -- determine escapeSequence
    local escapeSequence = {}

    -- determine blueprint
    local blueprint = {
        layerList = layerList,
        escapeSequence = escapeSequence,
    }

    -- determine buildLocation
    local buildLocation = self._baseLocation:copy()

    -- end
    return buildLocation, blueprint
end

function MObjTest:getDismantleBlueprint()
    --[[
        This method returns a blueprint for dismantling the MObjTest in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
    ]]

    -- construct layer list
    local layerList = {
        -- note: empty as we do not want to actually have the Turtle move for MObjTest
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

return MObjTest
