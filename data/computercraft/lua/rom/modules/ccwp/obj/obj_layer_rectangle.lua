-- define class
local Class = require "class"
local ObjBase = require "obj_base"
local LayerRectangle = Class.NewClass(ObjBase)

--[[
    This module implements the class LayerRectangle.

    A LayerRectangle object represents a rectangular layer in the minecraft world.
--]]

local corelog = require "corelog"

local InputChecker = require "input_checker"
local ObjTable = require "obj_table"
local Block = require "obj_block"

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function LayerRectangle:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        Construct a LayerRectangle.

        Parameters:
            o                           + (table, {}) table with object fields
                _codeTable              - (ObjTable) with mapping _codeMap codes (characters) to Block's
                _codeMap                - (table, {}) map of codes of Block's within the layer
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("LayerRectangle:new: Invalid input") return nil end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- check codeMap validity
    if not LayerRectangle.CodeMapValid(o._codeTable, o._codeMap, true) then corelog.Error("LayerRectangle:new: Invalid codeMap") return nil end

    -- end
    return o
end

function LayerRectangle:getCode(iColumn, iRow)
    -- check
    if iColumn < 1 or iColumn > self:getNColumns() then corelog.Error("LayerRectangle:getCode: iColumn(="..iColumn..") not within range i.e. between 1 and "..self:getNColumns()) return "" end

    -- end
    return self:getCodeRow(iRow):sub(iColumn, iColumn)
end

function LayerRectangle:getBlock(iColumn, iRow)
    -- get code
    local code = self:getCode(iColumn, iRow)
    if code:len() ~= 1 then corelog.Error("LayerRectangle:getBlock: code of incorrect length(="..code:len()..")") return nil end

    -- get block
    local block = self._codeTable[code]

    -- end
    return block
end

function LayerRectangle:getNColumns()
    -- check not empty
    if self:getNRows() == 0 then return 0 end

    -- end
    return self:getCodeRow(1):len()
end

function LayerRectangle:getNRows()
    return #self._codeMap
end

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

function LayerRectangle:getClassName()
    return "LayerRectangle"
end

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

function LayerRectangle:codesNeeded()
    -- determine code list
    local codeList = {}

    -- loop on rows
    local nCol = self:getNColumns()
    for iRow, row in ipairs(self._codeMap) do
        -- loop on columns
        for iCol = 1, nCol do
            -- get code
            local code = row:sub(iCol, iCol)

            -- increment counter
            codeList[code] = (codeList[code] or 0) + 1
        end
    end

    -- end
    return codeList
end

function LayerRectangle:itemsNeeded()
    -- get code list
    local codeList = self:codesNeeded()

    -- determine item list
    local itemList = {}
    for code, codeCount in pairs(codeList) do
        -- get block
        local block = self._codeTable[code]

        -- check is an actual item
        if block:isMinecraftItem() or block:isComputercraftItem() then
            -- set counter
            itemList[block:getName()] = (itemList[block:getName()] or 0) + codeCount
        end
    end

    -- end
    return itemList
end

function LayerRectangle:transformToLayer(...)
    -- get & check input from description
    local checkSuccess, toLayer = InputChecker.Check([[
        This method returns the layer that is needed to transform this layer into toLayer.

        Parameters:
            toLayer                     + (LayerRectangle) table with
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("LayerRectangle:transformToLayer: Invalid input") return nil end

    -- check size
    local fromLayer = self
    if fromLayer:getNRows() ~= toLayer:getNRows() then corelog.Error("LayerRectangle:transformToLayer: # rows in fromLayer(="..fromLayer:getNRows()..") not equal to that in toLayer(="..toLayer:getNRows()..")") return nil end
    if fromLayer:getNColumns() ~= toLayer:getNColumns() then corelog.Error("LayerRectangle:transformToLayer: # columns in fromLayer(="..fromLayer:getNColumns()..") not equal to that in toLayer(="..toLayer:getNColumns()..")") return nil end

    -- construct transformCodeMap
    local transformCodeMap = {}
    local nCol = fromLayer:getNColumns()
    local anyBlockCode = "?"

    -- loop on rows
    local anyBlockInserted = false
    for iRow, fromRow in ipairs(fromLayer._codeMap) do
        -- construct transformRow
        local transformRow = ""

        -- loop on columns
        for iCol = 1, nCol do
            -- get code's
            local fromCode = fromRow:sub(iCol, iCol)
            local toCode = toLayer:getCode(iCol, iRow)

            -- check code's
            if fromCode == toCode then
                transformRow = transformRow..anyBlockCode
                anyBlockInserted = true
            else
                transformRow = transformRow..toCode
            end
        end

        -- save row
        transformCodeMap[iRow] = transformRow
    end

    -- construct transformCodeTable
    local blockClassName = "Block"
    local transformCodeTable = ObjTable:newInstance(blockClassName)
    for code, codeCount in pairs(toLayer:codesNeeded()) do
        transformCodeTable[code] = toLayer._codeTable[code]:copy()
    end
    if anyBlockInserted and not transformCodeTable[anyBlockCode] then
        transformCodeTable[anyBlockCode] = Block:newInstance(Block.AnyBlockName())
    end

    -- end
    local transformLayer = LayerRectangle:new({
        _codeTable  = transformCodeTable,
        _codeMap    = transformCodeMap,
    })
    return transformLayer
end

function LayerRectangle:removeRow(...)
    -- get & check input from description
    local checkSuccess, iRow = InputChecker.Check([[
        Remove a row from the LayerRectangle.

        Parameters:
            iRow                        + (number) index of row to remove
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("LayerRectangle:removeRow: Invalid input") return nil end

    -- check range
    if iRow < 1 or iRow > self:getNRows() then corelog.Error("LayerRectangle:removeRow: iRow(="..iRow..") not within range i.e. between 1 and "..self:getNRows()) return end

    -- remove row
    table.remove(self._codeMap, iRow)

    -- clean codeTable
    self:cleanCodeTable()
end

function LayerRectangle:removeColumn(...)
    -- get & check input from description
    local checkSuccess, iCol = InputChecker.Check([[
        Remove a column from the LayerRectangle.

        Parameters:
            iCol                        + (number) index of column to remove
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("LayerRectangle:removeColumn: Invalid input") return nil end

    -- check range
    local nCol = self:getNColumns()
    if iCol < 1 or iCol > nCol then corelog.Error("LayerRectangle:removeColumn: iCol(="..iCol..") not within range i.e. between 1 and "..nCol) return end

    -- loop on rows
    for iRow, row in ipairs(self._codeMap) do
        -- remove column
        self._codeMap[iRow] = row:sub(1, iCol - 1)..row:sub(iCol + 1, nCol)
    end

    -- clean codeTable
    self:cleanCodeTable()
end

function LayerRectangle:cleanCodeTable()
    --[[
        Remove code's from codeTable that are not (anymore) in codeMap
    ]]

    -- get codeList
    local codeList = self:codesNeeded()

    -- check for unused codes
    for code, block in self._codeTable:objs() do
        if not codeList[code] then
            -- remove code
            self._codeTable[code] = nil
        end
    end
end

function LayerRectangle:removeBoundariesWithOnly(...)
    -- get & check input from description
    local checkSuccess, code = InputChecker.Check([[
        Remove boundary rows and columns that only contain a given code.

        Return value:
            col_offset                  - (number) column offset relative to original LayerRectangle
            row_offset                  - (number) row offset relative to original LayerRectangle

        Parameters:
            code                        + (string) off which rows and columns should be removed
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("LayerRectangle:removeBoundariesWithOnly: Invalid input") return nil end

    --
    local col_offset = 0
    local row_offset = 0

    -- ...
    local nCol = self:getNColumns()

    -- loop from top row
    for iRow = self:getNRows(), 1, -1 do
        -- check only code's
        local row = self._codeMap[iRow]
        local _, nBlocks = row:gsub(code, "")
        if nBlocks == nCol then
            -- remove row
            self:removeRow(iRow)
        else
            break
        end
    end

    -- loop from bottom row
    local iRow = 1
    while iRow < self:getNRows() do
        -- check only code's
        local row = self._codeMap[iRow]
        local _, nBlocks = row:gsub(code, "")
        if nBlocks == nCol then
            -- remove row
            self:removeRow(iRow)
            row_offset = row_offset + 1
        else
            break
        end
    end
    nCol = self:getNColumns() -- just in case we have no rows left it should be updated to 0

    -- loop from right column
    local nRow = self:getNRows()
    for iCol = nCol, 1, -1 do
        -- check only code's
        local col = self:getCodeCol(iCol)
        local _, nBlocks = col:gsub(code, "")
        if nBlocks == nRow then
            -- remove row
            self:removeColumn(iCol)
        else
            break
        end
    end

    -- loop from left column
    local iCol = 1
    while iCol < self:getNColumns() do
        -- check only code's
        local col = self:getCodeCol(iCol)
        local _, nBlocks = col:gsub(code, "")
        if nBlocks == nRow then
            -- remove row
            self:removeColumn(iCol)
            col_offset = col_offset + 1
        else
            break
        end
    end

    -- end
    return col_offset, row_offset
end

function LayerRectangle:buildData()
    --[[
        Obtain data to build this LayerRectangle.

        The build data is a LayerRectangle with no AnyBlock's at the boundaries and the column and row offsets relative to this LayerRectangle.

        Return value:
            col_offset                  - (number) column offset relative to original LayerRectangle
            row_offset                  - (number) row offset relative to original LayerRectangle
            buildLayer                  - (LayerRectangle) with layer to build
    ]]

    -- get AnyBlock code
    local anyBlockCode = "?" -- default, but allowed to be different
    for code, block in self._codeTable:objs() do
        if block:isAnyBlock() then
            anyBlockCode = code
            break
        end
    end

    -- get build data
    local buildLayer = self:copy()
---@diagnostic disable-next-line: need-check-nil
    local col_offset, row_offset = buildLayer:removeBoundariesWithOnly(anyBlockCode)

    -- end
    return col_offset, row_offset, buildLayer
end

--    _          _                    __                  _   _
--   | |        | |                  / _|                | | (_)
--   | |__   ___| |_ __   ___ _ __  | |_ _   _ _ __   ___| |_ _  ___  _ __  ___
--   | '_ \ / _ \ | '_ \ / _ \ '__| |  _| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
--   | | | |  __/ | |_) |  __/ |    | | | |_| | | | | (__| |_| | (_) | | | \__ \
--   |_| |_|\___|_| .__/ \___|_|    |_|  \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
--                | |
--                |_|

function LayerRectangle.IsCodeMap(codeMap)
    -- check is codeMap
    if type(codeMap) ~= "table" then return false end
    local size_x = 0
    for iY, codeRow in ipairs(codeMap) do
        -- check row is string
        if type(codeRow) ~= "string" then return false end

        -- check row length
        local rowLen = codeRow:len()
        if iY == 1 then
            size_x = rowLen
        else
            if rowLen ~= size_x then return false end
        end
    end

    -- end
    return true
end

function LayerRectangle.CodeMapValid(codeTable, codeMap, warn)
    -- check codeMap validity
    local size_x = 0
    for iY, codeRow in ipairs(codeMap) do
        -- check row is string
        if type(codeRow) ~= "string" then if warn then corelog.Warning("LayerRectangle.CodeMapValid: Invalid codeRow (type="..type(codeRow)..")") end return false end

        -- check row length
        local rowLen = codeRow:len()
        if iY == 1 then
            size_x = rowLen
        else
            if rowLen ~= size_x then if warn then corelog.Warning("LayerRectangle.CodeMapValid: Invalid length(="..rowLen..") different from size_x(="..size_x..")") end return false end
        end

        -- check row elements
        for iX = 1, codeRow:len() do
            -- check code validity
            local code = codeRow:sub(iX, iX)
            if not codeTable[code] then if warn then corelog.Warning("LayerRectangle.CodeMapValid: code(="..code..") at ("..iX..","..iY..") not in codeTable") end return false end
        end
    end

    -- end
    return true
end

function LayerRectangle.IsEqualCodeMap(codeMapA, codeMapB)
    -- check input
    if not LayerRectangle.IsCodeMap(codeMapA) or not LayerRectangle.IsCodeMap(codeMapB) then return false end

    -- end
	return LayerRectangle.IsEqualMap(codeMapA, codeMapB)
end

function LayerRectangle.IsEqualMap(mapA, mapB)
    -- check same elements as in A
    local sizeA = 0
    for iRow, rowA in ipairs(mapA) do
        sizeA = sizeA + 1
        -- check same row
        local rowB = mapB[iRow]
        if rowA ~= rowB then return false end
    end

    -- check no other elements in B
    local sizeB = 0
    for iRow, rowB in ipairs(mapB) do
        sizeB = sizeB + 1
    end
    if sizeA ~= sizeB then return false end

    -- end
	return true
end

function LayerRectangle.CodeMapCopy(codeMap)
    -- check input
    if not LayerRectangle.IsCodeMap(codeMap) then corelog.Error("LayerRectangle.CodeMapCopy: invalid codeMap: "..type(codeMap)) return end

    -- end
	return LayerRectangle.MapCopy(codeMap)
end

function LayerRectangle.MapCopy(map)
    -- copy elements
    local mapCopy = {}
    for iRow, row in ipairs(map) do
        mapCopy[iRow] = row
    end

    -- end
	return mapCopy
end

function LayerRectangle:getCodeRow(iRow)
    -- check
    if iRow < 1 or iRow > self:getNRows() then corelog.Error("LayerRectangle:getCodeRow: iRow(="..iRow..") not within range i.e. between 1 and "..self:getNRows()) return "" end

    -- end
    return self._codeMap[iRow]
end

function LayerRectangle:getCodeCol(iColumn)
    -- check
    local nCol = self:getNColumns()
    if iColumn < 1 or iColumn > nCol then corelog.Error("LayerRectangle:getCodeCol: iColumn(="..iColumn..") not within range i.e. between 1 and "..nCol) return "" end

    -- construct column
    local column = ""
    for iRow = 1, self:getNRows() do
        column = column..self:getCodeRow(iRow):sub(iColumn, iColumn)
    end

    -- end
    return column
end

return LayerRectangle
