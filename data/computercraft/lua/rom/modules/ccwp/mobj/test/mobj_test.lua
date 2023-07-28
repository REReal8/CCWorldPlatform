local TestMObj = {
    _id             = "",
    _isActive       = false,

    _baseLocation   = nil,
    _field1         = "",
}

local corelog = require "corelog"
local coreutils = require "coreutils"

local InputChecker = require "input_checker"
local Callback = require "obj_callback"

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
                _isActive               - (boolean) if the TestMObj is active
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

function TestMObj.HasFieldsOfType(obj)
    -- check
    if type(obj) ~= "table" then return false end
    if type(obj._field1) ~= "string" then return false end

    -- end
    return true
end

function TestMObj.HasClassNameOfType(obj)
    -- check
    if not obj.getClassName or obj:getClassName() ~= TestMObj:getClassName() then return false end

    -- end
    return true
end

function TestMObj:isTypeOf(obj)
    -- check
    local isTypeOf = TestMObj.HasFieldsOfType(obj) and TestMObj.HasClassNameOfType(obj)

    -- end
    return isTypeOf
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
        _isActive       = false,

        _baseLocation   = baseLocation,
        _field1         = field1Value,
    }

    -- create new TestMObj
    return TestMObj:new(oTable)
end

function TestMObj:destruct()
    --[[
        This method destructs a TestMObj instance.

        It also delists all child MObj's the TestMObj is the parent of (by calling the DelistMObj method on the appropriate MObjHost).

        The TestMObj is not yet deleted from the Host.

        Return value:
                                        - (boolean) whether the TestMObj was succesfully destructed.

        Parameters:
    ]]

    corelog.Error("Method destruct() not yet implemented.")
    return false
end

function TestMObj:getId()
    --[[
        Return a unique Id of the TestMObj.
    ]]

    return self._id
end

function TestMObj:activate()
    --[[
        Activates the TestMObj. This implies it is ready for accepting new business.

        It also activates all child MObj's it is the parent of.

        Return value:
                                        - (boolean) whether the TestMObj was succesfully activated.
    ]]

    -- set active
    self._isActive = true

    -- end
    return true
end

function TestMObj:deactivate()
    --[[
        Deactivates the TestMObj. This implies it should no longer accept new business. It still continue's completing
        possible (async) active business.

        It also deactivates all child MObj's it is the parent of.

        Return value:
                                - (boolean) whether the TestMObj was succesfully deactivate.
    ]]

    -- set inactive
    self._isActive = false

    -- end
    return true
end

function TestMObj:isActive()
    --[[
        Return value:
                                        - (boolean) if TestMObj is active, i.e. accepting new business.
    ]]

    return self._isActive
end

function TestMObj:completeRunningBusiness_AOSrv(...)
    -- get & check input from description
    local checkSuccess, callback = InputChecker.Check([[
        This method ensures all running business is completed.

        Return value:
                                        - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                        - (table)
                success                 - (boolean) whether all business was successfully completed

        Parameters:
            serviceData                 - (table) data for this service
            callback                    + (Callback) to call once service is ready
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("TestMObj:completeRunningBusiness_AOSrv: Invalid input") return Callback.ErrorCall(callback) end

    corelog.Error("Service completeRunningBusiness_AOSrv() not yet implemented.")
    return Callback.ErrorCall(callback)
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

    corelog.Error("Method getDismantleBlueprint() not yet implemented.")
end

return TestMObj
