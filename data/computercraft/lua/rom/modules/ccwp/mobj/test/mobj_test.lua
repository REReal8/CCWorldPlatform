-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local IMObj = require "i_mobj"
local TestMObj = Class.NewClass(ObjBase, IMObj)

local corelog = require "corelog"
local coreutils = require "coreutils"

local InputChecker = require "input_checker"

--[[
    This module implements the class TestMObj.

    A TestMObj object can be used for testing MObj related functionality.
--]]

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function TestMObj:_init(...)
    -- get & check input from description
    local checkSuccess, id, baseLocation, field1 = InputChecker.Check([[
        Initialise a TestMObj.

        Parameters:
            id                      + (string) id of the TestMObj
            baseLocation            + (Location) base location of the TestMObj
            field1                  + (string) field 1
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("TestMObj:_init: Invalid input") return nil end

    -- initialisation
    ObjBase._init(self)
    self._id            = id
    self._baseLocation  = baseLocation
    self._field1        = field1
end

-- ToDo: should be renamed to newFromTable at some point
function TestMObj:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a TestMObj.

        Parameters:
            o                           + (table, {}) with object fields
                _id                     - (string) id of the TestMObj
                _baseLocation           - (Location) base location of the TestMObj
                _field1                 - (string) field
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("TestMObj:new: Invalid input") return nil end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- end
    return o
end

function TestMObj:getField1()
    return self._field1
end

function TestMObj:setField1(strValue)
    -- check input
    if type(strValue) ~= "string" then corelog.Error("TestMObj:setField1: invalid strValue: "..type(strValue)) return end

    self._field1 = strValue
end

function TestMObj:getBaseLocation()
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

function TestMObj:getClassName()
    return "TestMObj"
end

--    _____ __  __  ____  _     _                  _   _               _
--   |_   _|  \/  |/ __ \| |   (_)                | | | |             | |
--     | | | \  / | |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | | | |\/| | |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| |_| |  | | |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____|_|  |_|\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                            _/ |
--                           |__/

function TestMObj:construct(...)
    -- get & check input from description
    local checkSuccess, baseLocation, field1Value = InputChecker.Check([[
        This method constructs a TestMObj instance from a table of parameters with all necessary fields (in an objectTable) and methods (by setmetatable) as defined in the class.

        It also registers all child MObj's the TestMObj spawns (by calling the RegisterMObj method on the appropriate MObjHost).

        The constructed TestMObj is not activated or saved in the Host.

        Return value:
                                        - (TestMObj) the constructed TestMObj

        Parameters:
            constructParameters         - (table) parameters for constructing the MObj
                baseLocation            + (Location) base location of the TestMObj
                field1Value             + (string) value to set field1 to
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("TestMObj:construct: Invalid input") return nil end

    -- determine TestMObj fields
    local id = coreutils.NewId()

    -- construct new TestMObj
    local obj = TestMObj:newInstance(id, baseLocation:copy(), field1Value)

    -- end
    return obj
end

function TestMObj:upgrade(...)
    -- get & check input from description
    local checkSuccess, field1 = InputChecker.Check([[
        This method upgrades a TestMObj instance from a table of parameters.

        The upgraded TestMObj is not yet saved in it's Host.

        Return value:
                                        - (boolean) whether the TestMObj was succesfully upgraded.

        Parameters:
            upgradeParameters           - (table) parameters for upgrading the TestMObj
                field1                  + (string) with field1 value to upgrade to
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("TestMObj:upgrade: Invalid input") return false end

    -- upgrade
    if self._field1 == field1 then corelog.Warning("TestMObj:upgrade: field1 is already equal to "..field1) end
    self._field1 = field1

    -- end
    return true
end

function TestMObj:destruct()
    --[[
        This method destructs a TestMObj instance.

        It (also) delists all child MObj's the TestMObj is the parent of (by calling the DelistMObj method on the appropriate MObjHost).

        The TestMObj is not yet deleted from the Host.

        Return value:
                                        - (boolean) whether the TestMObj was succesfully destructed.

        Parameters:
    ]]

    -- end
    return true
end

function TestMObj:getId()
    --[[
        Return a unique Id of the TestMObj.
    ]]

    return self._id
end

function TestMObj:getWIPId()
    --[[
        Returns the unique Id of the TestMObj used for administering WIP.
    ]]

    return self:getClassName().." "..self:getId()
end

function TestMObj:getBuildBlueprint()
    --[[
        This method returns a blueprint for building the TestMObj in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
    ]]

    -- construct layer list
    local layerList = {
        -- note: empty as we do not want to actually have the Turtle move for TestMObj
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

function TestMObj:getExtendBlueprint(...)
    -- get & check input from description
    local checkSuccess, field1 = InputChecker.Check([[
        This method returns a blueprint for extending the TestMObj in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
            upgradeParameters           - (table) parameters for upgrading the TestMObj
                field1                  + (string) with field1 value to upgrade to
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("TestMObj:getExtendBlueprint: Invalid input") return nil end

    -- determine layerList
    local layerList = {
        -- note: empty as we do not want to actually have the Turtle move for TestMObj
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


function TestMObj:getDismantleBlueprint()
    --[[
        This method returns a blueprint for dismantling the TestMObj in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
    ]]

    -- construct layer list
    local layerList = {
        -- note: empty as we do not want to actually have the Turtle move for TestMObj
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

return TestMObj
