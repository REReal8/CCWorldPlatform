-- define class
local ObjBase = require "obj_base"
local LayerRectangle = ObjBase:new()

local corelog = require "corelog"

local InputChecker = require "input_checker"

local Block = require "obj_block"

--[[
    This module implements the class LayerRectangle.

    A LayerRectangle object represents a rectangular layer in the minecraft world.
--]]

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
                _codeArray              - (table, {}) array mapping _codeMap codes (characters) to Block's
                _codeMap                - (table, {}) map of codes of blocks within the layer
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("LayerRectangle:new: Invalid input") return nil end

    -- set class info
    setmetatable(o, self)
    self.__index = self

    -- check codeArray validity
    o._codeArray = LayerRectangle.TransformToCodeArray(o._codeArray)
    if not LayerRectangle.CodeArrayValid(o._codeArray, true) then corelog.Error("LayerRectangle:new: Invalid codeArray") return nil end

    -- check codeMap validity
    if not LayerRectangle.CodeMapValid(o._codeArray, o._codeMap, true) then corelog.Error("LayerRectangle:new: Invalid codeMap") return nil end

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
    local block = self._codeArray[code]

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

function LayerRectangle:setCodeMap(codeMap)
    -- check
    if not LayerRectangle.CodeMapValid(self._codeArray, codeMap, true) then corelog.Error("LayerRectangle:setCodeMap: Invalid codeMap") return end

    self._codeMap = codeMap -- note: no deep copy
end

function LayerRectangle:setCodeArray(codeArray)
    -- check
    if not LayerRectangle.CodeArrayValid(codeArray, true) then corelog.Error("LayerRectangle:setCodeArray: Invalid codeArray") return end

    self._codeArray = codeArray -- note: no deep copy
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

function LayerRectangle.HasFieldsOfType(obj)
    -- check
    if type(obj) ~= "table" then return false end
    if not LayerRectangle.IsCodeArray(obj._codeArray) or not LayerRectangle.IsCodeMap(obj._codeMap) then return false end

    -- end
    return true
end

function LayerRectangle.HasClassNameOfType(obj)
    -- check
    if not obj.getClassName or obj:getClassName() ~= LayerRectangle:getClassName() then return false end

    -- end
    return true
end

function LayerRectangle:isTypeOf(obj)
    local metatable = getmetatable(obj)
    while metatable do
        if metatable.__index == self or obj == self then
            return true
        end
        metatable = getmetatable(metatable.__index)
    end
    return false
end

-- temp helper function, can be removed if we replace LayerRectangle:isEqual by default behavior of ObjBase. Keep it for not to get T_IObj.pt_isEqual test working.
local function onlyHasLayerRectangleFields(obj)
    -- check only
    local codeArrayFound = false
    local codeMapFound = false
    for fieldName, fieldValue in pairs(obj) do
        if fieldName == "_codeArray" then
            codeArrayFound = true
        elseif fieldName == "_codeMap" then
            codeMapFound = true
        else
            return false
        end
    end

    -- end
    return codeArrayFound and codeMapFound
end

function LayerRectangle:isEqual(obj)
    -- check input
    if not LayerRectangle:isTypeOf(obj) then return false end

    -- check same object
    local isEqual =  LayerRectangle.IsEqualCodeArray(self._codeArray, obj._codeArray) and
                    LayerRectangle.IsEqualCodeMap(self._codeMap, obj._codeMap)

    -- has no other fields
    isEqual = isEqual and onlyHasLayerRectangleFields(self) and onlyHasLayerRectangleFields(obj)

    -- end
    return isEqual
end

function LayerRectangle:copy()
    local copy = LayerRectangle:new({
        _codeArray      = LayerRectangle.CodeArrayCopy(self._codeArray),
        _codeMap        = LayerRectangle.CodeMapCopy(self._codeMap),
    })

    return copy
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
        local block = self._codeArray[code]

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

    -- construct transformCodeArray
    local transformCodeArray = {}
    for code, codeCount in pairs(toLayer:codesNeeded()) do
        transformCodeArray[code] = toLayer._codeArray[code]:copy()
    end
    if anyBlockInserted and not transformCodeArray[anyBlockCode] then
        transformCodeArray[anyBlockCode] = Block:new({ _name = Block.AnyBlockName() })
    end

    -- end
    local transformLayer = LayerRectangle:new({
        _codeArray  = transformCodeArray,
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

    -- clean codeArray
    self:cleanCodeArray()
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

    -- clean codeArray
    self:cleanCodeArray()
end

function LayerRectangle:cleanCodeArray()
    --[[
        Remove code's from codeArray that are not (anymore) in codeMap
    ]]

    -- get codeList
    local codeList = self:codesNeeded()

    -- check for unused codes
    for code, block in pairs(self._codeArray) do
        if not codeList[code] then
            -- remove code
            self._codeArray[code] = nil
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
    for code, block in pairs(self._codeArray) do
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

function LayerRectangle.IsCodeArray(codeArray)
    -- end
    return LayerRectangle.CodeArrayValid(codeArray, false)
end

function LayerRectangle.CodeArrayValid(codeArray, warn)
    -- check validity
    if type(codeArray) ~= "table" then if warn then corelog.Warning("LayerRectangle.CodeArrayValid: Invalid codeArray (type="..type(codeArray)..")") end return false end
    for code, block in pairs(codeArray) do
        if type(code) ~= "string" then if warn then corelog.Warning("LayerRectangle.CodeArrayValid: Invalid code (type="..type(code)..")") end return false end
        if not Block:isTypeOf(block) then if warn then corelog.Warning("LayerRectangle.CodeArrayValid: Invalid block (type="..type(block)..")") end return false end
    end

    -- end
    return true
end

function LayerRectangle.IsEqualCodeArray(codeArrayA, codeArrayB)
    -- check input
    if not LayerRectangle.IsCodeArray(codeArrayA) or not LayerRectangle.IsCodeArray(codeArrayB) then return false end

    -- check same elements as in A
    local sizeA = 0
    for codeA, blockA in pairs(codeArrayA) do
        sizeA = sizeA + 1
        -- check same blockName
        local blockB = codeArrayB[codeA]
        if not blockA:isEqual(blockB) then return false end
    end

    -- check no other elements in B
    local sizeB = 0
    for codeB, blockB in pairs(codeArrayB) do
        sizeB = sizeB + 1
    end
    if sizeA ~= sizeB then return false end

    -- end
	return true
end

function LayerRectangle.CodeArrayCopy(codeArray)
    -- check input
    if not LayerRectangle.IsCodeArray(codeArray) then corelog.Error("LayerRectangle.CodeArrayCopy: invalid codeArray: "..type(codeArray)) return end

    -- copy elements
    local codeArrayCopy = {}
    for code, block in pairs(codeArray) do
        codeArrayCopy[code] = block:copy()
    end

    -- end
	return codeArrayCopy
end

function LayerRectangle.TransformToCodeArray(...)
    -- get & check input from description
    local checkSuccess, codeArray = InputChecker.Check([[
        Transforms all block tables in the codeArray to Block objects.

        i.e. each block table like {
            _dx     = nil,
            _dy     = nil,
            _name   = "",
        }
        is transformed into a block object Block with the same fields

        Parameters:
            codeArray                   + (table, {}) array mapping _codeMap codes (characters) to Block's
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("LayerRectangle.TransformToCodeArray: Invalid input") return {} end

    local codeArrayTransform = {}
    -- copy elements
    for code, block in pairs(codeArray) do
        -- ToDo: consider doing this similair to, or using ObjArray:transformObjectTables => also making HasFieldsOfType and HasClassNameOfType methods obsolete (like was done for the other classes)
        if Block.HasFieldsOfType(block) then
            if Block.HasClassNameOfType(block) then
                codeArrayTransform[code] = block -- already a Block
            else
                codeArrayTransform[code] = Block:new(block) -- transform
            end
        else
            corelog.Warning("LayerRectangle.TransformToCodeArray: block(="..textutils.serialize(block)..") does not have all Block fields => skipped")
        end
    end

    -- end
	return codeArrayTransform
end

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

function LayerRectangle.CodeMapValid(codeArray, codeMap, warn)
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
            if not codeArray[code] then if warn then corelog.Warning("LayerRectangle.CodeMapValid: code(="..code..") at ("..iX..","..iY..") not in codeArray") end return false end
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
