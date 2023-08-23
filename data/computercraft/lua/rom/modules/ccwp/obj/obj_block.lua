-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local Block = Class.NewClass(ObjBase)

--[[
    This module implements the class Block.

    A Block object represents a single block in the minecraft world.
--]]

local corelog = require "corelog"

local InputChecker = require "input_checker"
--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function Block:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Constructs a Block.

        Parameters:
            o               + (table, {}) table with object fields
                _dx         - (number, 0) block orientation in x
                _dy         - (number, 0) block orientation in y
                _name       - (string, "") block name (.e.g. "minecraft:oak_log")
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("Block:new: Invalid input") return {} end

    setmetatable(o, self)
    self.__index = self
    return o
end

function Block:getDx()
    return self._dx
end

function Block:setDx(dx)
    -- check input
    if type(dx) ~= "number" then corelog.Error("Block:setDx: invalid dx: "..type(dx)) return end

    self._dx = dx
end

function Block:getDy()
    return self._dy
end

function Block:setDy(dy)
    -- check input
    if type(dy) ~= "number" then corelog.Error("Block:setDy: invalid dy: "..type(dy)) return end

    self._dy = dy
end

function Block:getName()
    return self._name
end

function Block:setName(name)
    -- check input
    if type(name) ~= "string" then corelog.Error("Block:setName: invalid name: "..type(name)) return end

    self._name = name
end

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

function Block:getClassName()
    return "Block"
end

-- ToDo: consider making changes such that this can be removed
function Block.HasFieldsOfType(obj)
    -- check
    if type(obj) ~= "table" then return false end
    if type(obj._name) ~= "string" then return false end
    if type(obj._dx) ~= "number" or type(obj._dy) ~= "number" then return false end

    -- end
    return true
end

-- ToDo: consider making changes such that this can be removed
function Block.HasClassNameOfType(obj)
    -- check
    if not obj.getClassName or obj:getClassName() ~= Block:getClassName() then return false end

    -- end
    return true
end

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

function Block.IsMincecraftItemName(name)
    return name:find("^minecraft:") ~= nil
end

function Block:isMinecraftItem()
    return Block.IsMincecraftItemName(self._name)
end

function Block.AnyBlockName()
    return "ccwp:any"
end

function Block:isAnyBlock()
    return self._name == Block.AnyBlockName()
end

function Block.NoneBlockName()
    return "ccwp:none"
end

function Block:isNoneBlock()
    return self._name == Block.NoneBlockName()
end

function Block.IsComputercraftItemName(name)
    return name:find("^computercraft:") ~= nil
end

function Block:isComputercraftItem()
    return Block.IsComputercraftItemName(self._name)
end

function Block:hasValidDirection()
    --[[
        Returns if the Block has a valid direction.
    ]]

    -- determine if direction is valid
    local directionNotValid = self._dx * self._dy ~= 0 or math.abs( self._dx + self._dy ) ~= 1

    -- end
    return not directionNotValid
end

return Block
