-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local Location = Class.NewClass(ObjBase)

--[[
    This module implements the class Location.

    A Location is a position and a direction in the minecraft world.
--]]

local corelog = require "corelog"

local InputChecker = require "input_checker"

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function Location:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a Location from table.

        Parameters:
            o                       + (table, {}) table with object fields
                _x                  - (number, 0) x coordinate
                _y                  - (number, 0) y coordinate
                _z                  - (number, 0) z coordinate
                _dx                 - (number, 0) x direction (either -1,0,1)
                _dy                 - (number, 1) y direction (either -1,0,1)
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Location:new: Invalid input") return {} end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- end
    return o
end

function Location:getX()
    return self._x
end

function Location:setX(x)
    self._x = x
end

function Location:getY()
    return self._y
end

function Location:setY(y)
    self._y = y
end

function Location:getZ()
    return self._z
end

function Location:setZ(z)
    self._z = z
end

function Location:getDX()
    return self._dx
end

-- todo: controle of dx en dy samen een logisch geheel zijn
function Location:setDX(dx)
    self._dx = dx
end

function Location:getDY()
    return self._dy
end

-- todo: controle of dx en dy samen een logisch geheel zijn
function Location:setDY(dy)
    self._dy = dy
end

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

function Location:getClassName()
    return "Location"
end

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

function Location:reset()
    self._x = 0
    self._y = 0
    self._z	= 0
    self._dx = 0
    self._dy = 1
end

function Location:getLocationFront( c )
    c = c or 1
    return Location:new({
        _x = self._x + c * self._dx,
        _y = self._y + c * self._dy,
        _z = self._z,
        _dx = self._dx,
        _dy = self._dy,
    })
end

function Location:getLocationUp( c )
    c = c or 1
    return Location:new({
        _x = self._x,
        _y = self._y,
        _z = self._z + c,
        _dx = self._dx,
        _dy = self._dy,
    })
end

function Location:getLocationDown( c )
    c = c or 1
    return Location:new({
        _x = self._x,
        _y = self._y,
        _z = self._z - c,
        _dx = self._dx,
        _dy = self._dy,
    })
end

function Location:minLocation(o)
    return Location:new({
        _x	= math.min(self._x, o._x),
        _y 	= math.min(self._y, o._y),
        _z 	= math.min(self._z, o._z),
        _dx	= math.min(self._dx, o._dx),
        _dy = math.min(self._dy, o._dy),
    })
end

function Location:maxLocation(o)
    return Location:new({
        _x	= math.max(self._x, o._x),
        _y 	= math.max(self._y, o._y),
        _z 	= math.max(self._z, o._z),
        _dx = math.max(self._dx, o._dx),
        _dy = math.max(self._dy, o._dy),
    })
end

function Location:getDivergentDirection(dx, dy)
    return Location:new({
        _x	= self._x,
        _y 	= self._y,
        _z 	= self._z,
        _dx	= dx,
        _dy = dy,
    })
end

function Location:getRelativeLocation(addX, addY, addZ)
    return Location:new({
        _x	= self._x + addX,
        _y 	= self._y + addY,
        _z 	= self._z + addZ,
        _dx = self._dx,
        _dy = self._dy
    })
end

function Location:getRelativeLocationFront(steps)
    -- default
    steps	= steps or 1

    -- done before we started :-)
    return Location:new({
        _x  = self._x + steps * self._dx,
        _y  = self._y + steps * self._dy,
        _z	= self._z,
        _dx = self._dx,
        _dy = self._dy,
    })
end

function Location:getRelativeLocationUp(steps)
    -- default
    steps	= steps or 1

    -- done before we started :-)
    return Location:new({
        _x  = self._x,
        _y 	= self._y,
        _z  = self._z + steps,
        _dx = self._dx,
        _dy = self._dy,
    })
end

function Location:getRelativeLocationDown(steps)
    -- default
    steps	= steps or 1

    -- done before we started :-)
    return Location:new({
        _x	= self._x,
        _y	= self._y,
        _z 	= self._z - steps,
        _dx = self._dx,
        _dy = self._dy,
    })
end

function Location:getRelativeLocationLeft(steps)
    -- default
    steps	= steps or 1
    steps	= math.fmod(steps, 4)

    -- make a deep copy of the location
    local newLocation = self:copy()

    -- do as requested
    for turn=1, steps do
        -- don't forget those
        local oldX		= newLocation._dx
        local oldY		= newLocation._dy

        -- new direction
        newLocation._dx	= -1 * oldY
        newLocation._dy	= oldX
    end

    -- this is where we ended
    return newLocation
end

function Location:getRelativeLocationRight(steps)
    -- default
    steps	= steps or 1
    steps	= math.fmod(steps, 4)

    -- make a deep copy of the location
    local newLocation = self:copy()

    -- do as requested
    for turn=1, steps do
        -- don't forget those
        local oldX		= newLocation._dx
        local oldY		= newLocation._dy

        -- new direction
        newLocation._dx	= oldY
        newLocation._dy	= -1 * oldX
    end

    -- this is where we ended
    return newLocation
end

function Location:blockDistanceTo(o)
    -- check input
    if not Class.IsInstanceOf(o, Location) then corelog.Warning("Location:blockDistanceTo: object not a Location (type="..type(o)..")") return 9999 end

    return math.abs(o._x - self._x) + math.abs(o._y - self._y) + math.abs(o._z - self._z)
end

return Location
