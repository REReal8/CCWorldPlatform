local T_CodeMap = {}
local corelog = require "corelog"

local Class = require "class"
local IObj = require "i_obj"
local ObjBase = require "obj_base"
local CodeMap = require "obj_code_map"

local T_Class = require "test.t_class"
local T_IObj = require "test.t_i_obj"

function T_CodeMap.T_All()
    -- initialisation
    T_CodeMap.T_new()

    -- IObj methods
    T_CodeMap.T_IObj_All()

    -- specific methods
    T_CodeMap.T_transformToMap()
    T_CodeMap.T_removeRow()
    T_CodeMap.T_removeColumn()
    T_CodeMap.T_getCodeCol()
    T_CodeMap.T_removeBoundariesWithOnly()
end

local testClassName = "CodeMap"
local codeMap1 = {
    [6] = "CD   ?",
    [5] = "      ",
    [4] = "T  S  ",
    [3] = "  ?   ",
    [2] = "   K  ",
    [1] = "   T  ",
}
local map1 = CodeMap:new(codeMap1) assert(map1, "Failed obtaining CodeMap")

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_CodeMap.CreateTestObj(codeMap)
    -- check input
    codeMap = codeMap or {
        [6] = "CD   ?",
        [5] = "      ",
        [4] = "T  S  ",
        [3] = "  ?   ",
        [2] = "   K  ",
        [1] = "   T  ",
    }

    -- create testObj
    local testObj = CodeMap:new(codeMap)

    -- end
    return testObj
end

function T_CodeMap.T_new()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":new() tests")

    -- test full
    local map = CodeMap:new(codeMap1) assert(map, "Failed obtaining CodeMap")
    local expectedNColumns = 6
    assert(map:getNColumns() == expectedNColumns, "gotten getNColumns(="..map:getNColumns()..") not the same as expected(="..expectedNColumns..")")
    local expectedNRows = 6
    assert(map:getNRows() == expectedNRows, "gotten getNRows(="..map:getNRows()..") not the same as expected(="..expectedNRows..")")
    local code = map:getCode(4, 1)
    local expectedCode = "T"
    assert(code == expectedCode, "gotten code(="..code..") not the same as expected(="..expectedCode..")")
    code = map:getCode(1, 4)
    assert(code == expectedCode, "gotten code(="..code..") not the same as expected(="..expectedCode..")")
    code = map:getCode(4, 4)
    expectedCode = "S"
    assert(code == expectedCode, "gotten code(="..code..") not the same as expected(="..expectedCode..")")

    -- test default
    map = CodeMap:new() assert(map, "Failed obtaining CodeMap")
    expectedNColumns = 0
    assert(map:getNColumns() == expectedNColumns, "gotten getNColumns(="..map:getNColumns()..") not the same as expected(="..expectedNColumns..")")
    expectedNRows = 0
    assert(map:getNRows() == expectedNRows, "gotten getNRows(="..map:getNRows()..") not the same as expected(="..expectedNRows..")")

    -- cleanup test
end

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

function T_CodeMap.T_IObj_All()
    -- prepare test
    local obj = T_CodeMap.CreateTestObj() assert(obj, "failed obtaining "..testClassName)
    local otherObj = T_CodeMap.CreateTestObj() assert(obj, "failed obtaining "..testClassName) assert(otherObj, "failed obtaining "..testClassName)

    -- test
    T_Class.pt_IsInstanceOf(testClassName, obj, "IObj", IObj)
    T_Class.pt_IsInstanceOf(testClassName, obj, "ObjBase", ObjBase)
    T_IObj.pt_all(testClassName, obj, otherObj)
end

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

function T_CodeMap.T_transformToMap()
    -- prepare test
    corelog.WriteToLog("* CodeMap:transformToMap() tests")
    local fromMap = CodeMap:new({
        [6] = "   S  ",
        [5] = "      ",
        [4] = "   S  ",
        [3] = "   ?  ",
        [2] = "   ?  ",
        [1] = "   ?  ",
    }) assert(fromMap, "Failed obtaining CodeMap")
    local toMap = CodeMap:new({
        [6] = "   ?  ",
        [5] = "      ",
        [4] = "T  S  ",
        [3] = "      ",
        [2] = "   ?  ",
        [1] = "   T  ",
    }) assert(toMap, "Failed obtaining CodeMap")

    -- test
    local transformLayer = fromMap:transformToMap(toMap)
    local isInstanceOf = Class.IsInstanceOf(transformLayer, CodeMap)
    local expectedIsInstanceOf = true
    assert(isInstanceOf, "gotten isInstanceOf(="..tostring(isInstanceOf)..") not the same as expected(="..tostring(expectedIsInstanceOf)..")")
    local expectedMap = CodeMap:new({
        [6] = "??????",
        [5] = "??????",
        [4] = "T?????",
        [3] = "??? ??",
        [2] = "??????",
        [1] = "???T??",
    })
    assert(transformLayer:isEqual(expectedMap), "gotten transformToMap(="..textutils.serialize(transformLayer, compact)..") not the same as expected(="..textutils.serialize(expectedMap, compact)..")")

    -- test anyBlock added to _codeTable
    toMap = CodeMap:new({
        [6] = "      ",
        [5] = "      ",
        [4] = "T  S  ",
        [3] = "      ",
        [2] = "      ",
        [1] = "   T  ",
    })
    transformLayer = fromMap:transformToMap(toMap)
    isInstanceOf = Class.IsInstanceOf(transformLayer, CodeMap)
    expectedIsInstanceOf = true
    assert(isInstanceOf, "gotten isInstanceOf(="..tostring(isInstanceOf)..") not the same as expected(="..tostring(expectedIsInstanceOf)..")")
    expectedMap = CodeMap:new({
        [6] = "??? ??",
        [5] = "??????",
        [4] = "T?????",
        [3] = "??? ??",
        [2] = "??? ??",
        [1] = "???T??",
    })
    assert(transformLayer:isEqual(expectedMap), "gotten transformToMap(="..textutils.serialize(transformLayer, compact)..") not the same as expected(="..textutils.serialize(expectedMap, compact)..")")

    -- cleanup test
end

function T_CodeMap.T_removeRow()
    -- prepare test
    corelog.WriteToLog("* CodeMap:removeRow() tests")

    -- test top
    local map = map1:copy()
    map:removeRow(6)
    local expectedMap = CodeMap:new({
        [5] = "      ",
        [4] = "T  S  ",
        [3] = "  ?   ",
        [2] = "   K  ",
        [1] = "   T  ",
    })
    assert(map:isEqual(expectedMap), "result map(="..textutils.serialize(map, compact)..") not the same as expected(="..textutils.serialize(expectedMap, compact)..")")

    -- test a mid
    map = map1:copy()
    map:removeRow(4)
    expectedMap = CodeMap:new({
        [5] = "CD   ?",
        [4] = "      ",
        [3] = "  ?   ",
        [2] = "   K  ",
        [1] = "   T  ",
    })
    assert(map:isEqual(expectedMap), "result map(="..textutils.serialize(map, compact)..") not the same as expected(="..textutils.serialize(expectedMap, compact)..")")

    -- test bottom
    map = map1:copy()
    map:removeRow(1)
    expectedMap = CodeMap:new({
        [5] = "CD   ?",
        [4] = "      ",
        [3] = "T  S  ",
        [2] = "  ?   ",
        [1] = "   K  ",
    })
    assert(map:isEqual(expectedMap), "result map(="..textutils.serialize(map, compact)..") not the same as expected(="..textutils.serialize(expectedMap, compact)..")")

    -- cleanup test
end

function T_CodeMap.T_getCodeCol()
    -- prepare test
    corelog.WriteToLog("* CodeMap:getCodeCol() tests")

    -- test
    local column = map1:getCodeCol(4)
    local expectedColumn = "TK S  "
    assert(column == expectedColumn, "gotten column(="..column..") not the same as expected(="..expectedColumn..")")

    -- cleanup test
end

function T_CodeMap.T_removeColumn()
    -- prepare test
    corelog.WriteToLog("* CodeMap:removeColumn() tests")

    -- test right
    local map = map1:copy()
    map:removeColumn(6)
    local expectedMap = CodeMap:new({
        [6] = "CD   ",
        [5] = "     ",
        [4] = "T  S ",
        [3] = "  ?  ",
        [2] = "   K ",
        [1] = "   T ",
    })
    assert(map:isEqual(expectedMap), "result map(="..textutils.serialize(map, compact)..") not the same as expected(="..textutils.serialize(expectedMap, compact)..")")

    -- test mid
    map = map1:copy()
    map:removeColumn(4)
    expectedMap = CodeMap:new({
        [6] = "CD  ?",
        [5] = "     ",
        [4] = "T    ",
        [3] = "  ?  ",
        [2] = "     ",
        [1] = "     ",
    })
    assert(map:isEqual(expectedMap), "result map(="..textutils.serialize(map, compact)..") not the same as expected(="..textutils.serialize(expectedMap, compact)..")")

    -- test left
    map = map1:copy()
    map:removeColumn(1)
    expectedMap = CodeMap:new({
        [6] = "D   ?",
        [5] = "     ",
        [4] = "  S  ",
        [3] = " ?   ",
        [2] = "  K  ",
        [1] = "  T  ",
    })
    assert(map:isEqual(expectedMap), "result map(="..textutils.serialize(map, compact)..") not the same as expected(="..textutils.serialize(expectedMap, compact)..")")

    -- cleanup test
end

function T_CodeMap.T_removeBoundariesWithOnly()
    -- prepare test
    corelog.WriteToLog("* CodeMap:removeBoundariesWithOnly() tests")

    -- test right
    local map = CodeMap:new({
        [6] = "??????",
        [5] = "??????",
        [4] = "??TC ?",
        [3] = "?? C??",
        [2] = "??? T?",
        [1] = "??????",
    }) assert(map, "Failed obtaining CodeMap")
    local code = "?"
    local colOffset, rowOffset = map:removeBoundariesWithOnly(code)
    local expectedOffset = 1
    assert(rowOffset == expectedOffset, "gotten rowOffset(="..tostring(colOffset)..") for code "..code.." not the same as expected(="..tostring(expectedOffset)..")")
    expectedOffset = 2
    assert(colOffset == expectedOffset, "gotten colOffset(="..tostring(colOffset)..") for code "..code.." not the same as expected(="..tostring(expectedOffset)..")")
    local expectedMap = CodeMap:new({
        [3] = "TC ",
        [2] = " C?",
        [1] = "? T",
    })
    assert(map:isEqual(expectedMap), "result map(="..textutils.serialize(map, compact)..") for code "..code.." not the same as expected(="..textutils.serialize(expectedMap, compact)..")")

    -- cleanup test
end

return T_CodeMap
