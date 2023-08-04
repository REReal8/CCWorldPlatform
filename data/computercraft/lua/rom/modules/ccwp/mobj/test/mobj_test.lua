local TestMObj = {
    _id             = "",

    _baseLocation   = nil,
    _field1         = "",
}

local corelog = require "corelog"
local coreutils = require "coreutils"

local InputChecker = require "input_checker"

--[[
    This module implements the class TestMObj.

    A TestMObj object can be used for testing MObj related functionality.
--]]

--    _                                     _   _               _
--   | |                                   | | | |             | |
--   | |__   __ _ ___  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   | '_ \ / _` / __|/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   | |_) | (_| \__ \  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_.__/ \__,_|___/\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

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

function TestMObj:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a TestMObj.

        Parameters:
            o                           + (table, {}) table with object fields
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

function TestMObj:getClassName()
    return "TestMObj"
end

function TestMObj:isTypeOf(obj)
    local metatable = getmetatable(obj)
    while metatable do
        if metatable.__index == self or obj == self then
            return true
        end
        metatable = getmetatable(metatable.__index)
    end
    return false
end

function TestMObj:isSame(obj)
    -- check input
    if not TestMObj:isTypeOf(obj) then return false end

    -- check same
    local isSame = self._field1 == obj._field1

    -- end
    return isSame
end

function TestMObj:copy()
    local copy = TestMObj:new({
        _field1 = self._field1,
    })

    return copy
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

    -- make object table
    local oTable = {
        _id             = coreutils.NewId(),

        _baseLocation   = baseLocation,
        _field1         = field1Value,
    }

    -- create new TestMObj
    return TestMObj:new(oTable)
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
--        { startpoint = Location:new({ _x= 0, _y= 0, _z= -1}), buildFromAbove = true, layer = Shaft_layer()},
        -- note: empty as we currently do not want to actually have the Turtle move
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
        -- note: empty as we currently do not want to actually have the Turtle move
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
