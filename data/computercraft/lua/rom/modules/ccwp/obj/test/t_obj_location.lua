local T_Location = {}

local corelog = require "corelog"

local IObj = require "i_obj"
local ObjBase = require "obj_base"
local Location = require "obj_location"

local FieldsTest = require "fields_test"
local FieldValueEqualTest = require "field_value_equal_test"

local T_Class = require "test.t_class"
local T_IObj = require "test.t_i_obj"

function T_Location.T_All()
    -- initialisation
    T_Location.T__init()
    T_Location.T_new()

    -- IObj methods
    T_Location.T_IObj_All()

    -- specific methods
    T_Location.T_reset()
    T_Location.T_minLocation()
    T_Location.T_maxLocation()
    T_Location.T_getRelativeLocation()
    T_Location.T_getRelativeLocationFront()
    T_Location.T_getRelativeLocationUp()
    T_Location.T_getRelativeLocationDown()
    T_Location.T_getRelativeLocationLeft()
    T_Location.T_getRelativeLocationRight()
    T_Location.T_blockDistanceTo()
end

local testClassName = "Location"
local logOk = false
local x0 = 0
local y0 = 0
local z0 = 0
local dx0 = 0
local dy0 = 1
local x1 = 1
local y1 = 10
local z1 = -10
local dx1 = 0
local dy1 = -1
local x2 = 2
local y2 = 20
local z2 = -20
local dx2 = -1
local dy2 = 0

local compact = { compact = true }

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

function T_Location.CreateTestObj(x, y, z, dx, dy)
    -- check input
    x = x or x1
    y = y or y1
    z = z or z1
    dx = dx or dx1
    dy = dy or dy1

    -- create testObj
    local testObj = Location:newInstance(x, y, z, dx, dy)

    -- end
    return testObj
end

function T_Location.CreateInitialisedTest(x, y, z, dx, dy)
    -- check input

    -- create test
    local initialisedTest = FieldsTest:newInstance(
        FieldValueEqualTest:newInstance("_x", x),
        FieldValueEqualTest:newInstance("_y", y),
        FieldValueEqualTest:newInstance("_z", z),
        FieldValueEqualTest:newInstance("_dx", dx),
        FieldValueEqualTest:newInstance("_dy", dy)
    )

    -- end
    return initialisedTest
end

function T_Location.T__init()
    -- prepare test
    corelog.WriteToLog("* "..testClassName..":_init() tests")

    -- test
    local obj = T_Location.CreateTestObj(x1, y1, z1, dx1, dy1) assert(obj, "Failed obtaining "..testClassName)
    local initialisedTest = T_Location.CreateInitialisedTest(x1, y1, z1, dx1, dy1)
    initialisedTest:test(obj, "location", "", logOk)

    -- cleanup test
end

function T_Location.T_new()
    -- prepare test
    corelog.WriteToLog("* Location:new() tests")

    -- test full
    local obj = Location:new({
        _x  = x1,
        _y  = y1,
        _z  = z1,
        _dx = dx1,
        _dy = dy1,
    })
    local initialisedTest = T_Location.CreateInitialisedTest(x1, y1, z1, dx1, dy1)
    initialisedTest:test(obj, "location", "", logOk)

    -- test default
    obj = Location:new()
    initialisedTest = T_Location.CreateInitialisedTest(0, 0, 0, 0, 1)
    initialisedTest:test(obj, "location", "", logOk)

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

function T_Location.T_IObj_All()
    -- prepare test
    local obj = T_Location.CreateTestObj() assert(obj, "Failed obtaining "..testClassName)
    local otherObj = T_Location.CreateTestObj() assert(otherObj, "Failed obtaining "..testClassName)

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

function T_Location.T_reset()
    -- prepare test
    corelog.WriteToLog("* Location:reset() tests")
    local location1 = Location:new({
        _x  = x1,
        _y  = y1,
        _z  = z1,
        _dx = dx1,
        _dy = dy1,
    })

    -- test
    location1:reset()
    assert(location1:getX() == x0, "gotten getX(="..location1:getX()..") not the same as expected(="..x0..")")
    assert(location1:getY() == y0, "gotten getY(="..location1:getY()..") not the same as expected(="..y0..")")
    assert(location1:getZ() == z0, "gotten getY(="..location1:getZ()..") not the same as expected(="..z0..")")
    assert(location1:getDX() == dx0, "gotten getDX(="..location1:getDX()..") not the same as expected(="..dx0..")")
    assert(location1:getDY() == dy0, "gotten getDY(="..location1:getDY()..") not the same as expected(="..dy0..")")

    -- cleanup test
end

function T_Location.T_minLocation()
    -- prepare test
    corelog.WriteToLog("* Location:minLocation() tests")
    local location1 = Location:new({
        _x  = x1,
        _y  = y1,
        _z  = z1,
        _dx = dx1,
        _dy = dy1,
    })
    local location2 = Location:new({
        _x  = x2,
        _y  = y2,
        _z  = z2,
        _dx = dx2,
        _dy = dy2,
    })

    -- test
    local minLocation = location1:minLocation(location2)
    local expectedX = math.min(x1, x2)
    local expectedY = math.min(y1, y2)
    local expectedZ = math.min(z1, z2)
    local expectedDx = math.min(dx1, dx2)
    local expectedDy = math.min(dy1, dy2)
    assert(minLocation:getX() == expectedX, "gotten getX(="..minLocation:getX()..") not the same as expected(="..expectedX..")")
    assert(minLocation:getY() == expectedY, "gotten getY(="..minLocation:getY()..") not the same as expected(="..expectedY..")")
    assert(minLocation:getZ() == expectedZ, "gotten getY(="..minLocation:getZ()..") not the same as expected(="..expectedZ..")")
    assert(minLocation:getDX() == expectedDx, "gotten getDX(="..minLocation:getDX()..") not the same as expected(="..expectedDx..")")
    assert(minLocation:getDY() == expectedDy, "gotten getDY(="..minLocation:getDY()..") not the same as expected(="..expectedDy..")")

    -- cleanup test
end

function T_Location.T_maxLocation()
    -- prepare test
    corelog.WriteToLog("* Location:maxLocation() tests")
    local location1 = Location:new({
        _x  = x1,
        _y  = y1,
        _z  = z1,
        _dx = dx1,
        _dy = dy1,
    })
    local location2 = Location:new({
        _x  = x2,
        _y  = y2,
        _z  = z2,
        _dx = dx2,
        _dy = dy2,
    })

    -- test
    local maxLocation = location1:maxLocation(location2)
    local expectedX = math.max(x1, x2)
    local expectedY = math.max(y1, y2)
    local expectedZ = math.max(z1, z2)
    local expectedDx = math.max(dx1, dx2)
    local expectedDy = math.max(dy1, dy2)
    assert(maxLocation:getX() == expectedX, "gotten getX(="..maxLocation:getX()..") not the same as expected(="..expectedX..")")
    assert(maxLocation:getY() == expectedY, "gotten getY(="..maxLocation:getY()..") not the same as expected(="..expectedY..")")
    assert(maxLocation:getZ() == expectedZ, "gotten getY(="..maxLocation:getZ()..") not the same as expected(="..expectedZ..")")
    assert(maxLocation:getDX() == expectedDx, "gotten getDX(="..maxLocation:getDX()..") not the same as expected(="..expectedDx..")")
    assert(maxLocation:getDY() == expectedDy, "gotten getDY(="..maxLocation:getDY()..") not the same as expected(="..expectedDy..")")

    -- cleanup test
end

function T_Location.T_getRelativeLocation()
    -- prepare test
    corelog.WriteToLog("* Location:getRelativeLocation() tests")
    local location1 = Location:new({
        _x  = x1,
        _y  = y1,
        _z  = z1,
        _dx = dx1,
        _dy = dy1,
    })

    -- test
    local addX = 105
    local addY = 15
    local addZ = 5
    local relativeLocation = location1:getRelativeLocation(addX, addY, addZ)
    local expectedX = x1 + addX
    local expectedY = y1 + addY
    local expectedZ = z1 + addZ
    local expectedDx = dx1
    local expectedDy = dy1
    assert(relativeLocation:getX() == expectedX, "gotten getX(="..relativeLocation:getX()..") not the same as expected(="..expectedX..")")
    assert(relativeLocation:getY() == expectedY, "gotten getY(="..relativeLocation:getY()..") not the same as expected(="..expectedY..")")
    assert(relativeLocation:getZ() == expectedZ, "gotten getY(="..relativeLocation:getZ()..") not the same as expected(="..expectedZ..")")
    assert(relativeLocation:getDX() == expectedDx, "gotten getDX(="..relativeLocation:getDX()..") not the same as expected(="..expectedDx..")")
    assert(relativeLocation:getDY() == expectedDy, "gotten getDY(="..relativeLocation:getDY()..") not the same as expected(="..expectedDy..")")

    -- cleanup test
end

function T_Location.T_getRelativeLocationFront()
    -- prepare test
    corelog.WriteToLog("* Location:getRelativeLocationFront() tests")
    local location1 = Location:new({
        _x  = x1,
        _y  = y1,
        _z  = z1,
        _dx = dx1,
        _dy = dy1,
    })

    -- test forward 2
    local steps = 2
    local relativeLocation = location1:getRelativeLocationFront(steps)
    local expectedX = x1 + steps * dx1
    local expectedY = y1 + steps * dy1
    local expectedZ = z1
    local expectedDx = dx1
    local expectedDy = dy1
    assert(relativeLocation:getX() == expectedX, "gotten getX(="..relativeLocation:getX()..") not the same as expected(="..expectedX..")")
    assert(relativeLocation:getY() == expectedY, "gotten getY(="..relativeLocation:getY()..") not the same as expected(="..expectedY..")")
    assert(relativeLocation:getZ() == expectedZ, "gotten getY(="..relativeLocation:getZ()..") not the same as expected(="..expectedZ..")")
    assert(relativeLocation:getDX() == expectedDx, "gotten getDX(="..relativeLocation:getDX()..") not the same as expected(="..expectedDx..")")
    assert(relativeLocation:getDY() == expectedDy, "gotten getDY(="..relativeLocation:getDY()..") not the same as expected(="..expectedDy..")")

    -- test backward 1
    steps = -1
    relativeLocation = location1:getRelativeLocationFront(steps)
    expectedX = x1 + steps * dx1
    expectedY = y1 + steps * dy1
    expectedZ = z1
    expectedDx = dx1
    expectedDy = dx2
    assert(relativeLocation:getX() == expectedX, "gotten getX(="..relativeLocation:getX()..") not the same as expected(="..expectedX..")")
    assert(relativeLocation:getY() == expectedY, "gotten getY(="..relativeLocation:getY()..") not the same as expected(="..expectedY..")")
    assert(relativeLocation:getZ() == expectedZ, "gotten getY(="..relativeLocation:getZ()..") not the same as expected(="..expectedZ..")")
    assert(relativeLocation:getDX() == expectedDx, "gotten getDX(="..relativeLocation:getDX()..") not the same as expected(="..expectedDx..")")
    assert(relativeLocation:getDY() == expectedDy, "gotten getDY(="..relativeLocation:getDY()..") not the same as expected(="..expectedDy..")")

    -- cleanup test
end

function T_Location.T_getRelativeLocationUp()
    -- prepare test
    corelog.WriteToLog("* Location:getRelativeLocationUp() tests")
    local location1 = Location:new({
        _x  = x1,
        _y  = y1,
        _z  = z1,
        _dx = dx1,
        _dy = dy1,
    })

    -- test up 2
    local steps = 2
    local relativeLocation = location1:getRelativeLocationUp(steps)
    local expectedX = x1
    local expectedY = y1
    local expectedZ = z1 + steps
    local expectedDx = dx1
    local expectedDy = dy1
    assert(relativeLocation:getX() == expectedX, "gotten getX(="..relativeLocation:getX()..") not the same as expected(="..expectedX..")")
    assert(relativeLocation:getY() == expectedY, "gotten getY(="..relativeLocation:getY()..") not the same as expected(="..expectedY..")")
    assert(relativeLocation:getZ() == expectedZ, "gotten getY(="..relativeLocation:getZ()..") not the same as expected(="..expectedZ..")")
    assert(relativeLocation:getDX() == expectedDx, "gotten getDX(="..relativeLocation:getDX()..") not the same as expected(="..expectedDx..")")
    assert(relativeLocation:getDY() == expectedDy, "gotten getDY(="..relativeLocation:getDY()..") not the same as expected(="..expectedDy..")")

    -- cleanup test
end

function T_Location.T_getRelativeLocationDown()
    -- prepare test
    corelog.WriteToLog("* Location:getRelativeLocationDown() tests")
    local location1 = Location:new({
        _x  = x1,
        _y  = y1,
        _z  = z1,
        _dx = dx1,
        _dy = dy1,
    })

    -- test down 2
    local steps = 2
    local relativeLocation = location1:getRelativeLocationDown(steps)
    local expectedX = x1
    local expectedY = y1
    local expectedZ = z1 - steps
    local expectedDx = dx1
    local expectedDy = dy1
    assert(relativeLocation:getX() == expectedX, "gotten getX(="..relativeLocation:getX()..") not the same as expected(="..expectedX..")")
    assert(relativeLocation:getY() == expectedY, "gotten getY(="..relativeLocation:getY()..") not the same as expected(="..expectedY..")")
    assert(relativeLocation:getZ() == expectedZ, "gotten getY(="..relativeLocation:getZ()..") not the same as expected(="..expectedZ..")")
    assert(relativeLocation:getDX() == expectedDx, "gotten getDX(="..relativeLocation:getDX()..") not the same as expected(="..expectedDx..")")
    assert(relativeLocation:getDY() == expectedDy, "gotten getDY(="..relativeLocation:getDY()..") not the same as expected(="..expectedDy..")")

    -- cleanup test
end

function T_Location.T_getRelativeLocationLeft()
    -- prepare test
    corelog.WriteToLog("* Location:getRelativeLocationLeft() tests")
    local location1 = Location:new({
        _x  = x1,
        _y  = y1,
        _z  = z1,
        _dx = dx1,
        _dy = dy1,
    })

    -- test left 1
    local steps = 1
    local relativeLocation = location1:getRelativeLocationLeft(steps)
    local expectedX = x1
    local expectedY = y1
    local expectedZ = z1
    local expectedDx = -dy1
    local expectedDy = dx1
    assert(relativeLocation:getX() == expectedX, "gotten getX(="..relativeLocation:getX()..") not the same as expected(="..expectedX..")")
    assert(relativeLocation:getY() == expectedY, "gotten getY(="..relativeLocation:getY()..") not the same as expected(="..expectedY..")")
    assert(relativeLocation:getZ() == expectedZ, "gotten getY(="..relativeLocation:getZ()..") not the same as expected(="..expectedZ..")")
    assert(relativeLocation:getDX() == expectedDx, "gotten getDX(="..relativeLocation:getDX()..") not the same as expected(="..expectedDx..")")
    assert(relativeLocation:getDY() == expectedDy, "gotten getDY(="..relativeLocation:getDY()..") not the same as expected(="..expectedDy..")")

    -- test left 3
    steps = 3
    relativeLocation = location1:getRelativeLocationLeft(steps)
    expectedX = x1
    expectedY = y1
    expectedZ = z1
    expectedDx = dy1
    expectedDy = -dx1
    assert(relativeLocation:getX() == expectedX, "gotten getX(="..relativeLocation:getX()..") not the same as expected(="..expectedX..")")
    assert(relativeLocation:getY() == expectedY, "gotten getY(="..relativeLocation:getY()..") not the same as expected(="..expectedY..")")
    assert(relativeLocation:getZ() == expectedZ, "gotten getY(="..relativeLocation:getZ()..") not the same as expected(="..expectedZ..")")
    assert(relativeLocation:getDX() == expectedDx, "gotten getDX(="..relativeLocation:getDX()..") not the same as expected(="..expectedDx..")")
    assert(relativeLocation:getDY() == expectedDy, "gotten getDY(="..relativeLocation:getDY()..") not the same as expected(="..expectedDy..")")

    -- cleanup test
end

function T_Location.T_getRelativeLocationRight()
    -- prepare test
    corelog.WriteToLog("* Location:getRelativeLocationRight() tests")
    local location1 = Location:new({
        _x  = x1,
        _y  = y1,
        _z  = z1,
        _dx = dx1,
        _dy = dy1,
    })

    -- test right 1
    local steps = 1
    local relativeLocation = location1:getRelativeLocationRight(steps)
    local expectedX = x1
    local expectedY = y1
    local expectedZ = z1
    local expectedDx = dy1
    local expectedDy = -dx1
    assert(relativeLocation:getX() == expectedX, "gotten getX(="..relativeLocation:getX()..") not the same as expected(="..expectedX..")")
    assert(relativeLocation:getY() == expectedY, "gotten getY(="..relativeLocation:getY()..") not the same as expected(="..expectedY..")")
    assert(relativeLocation:getZ() == expectedZ, "gotten getY(="..relativeLocation:getZ()..") not the same as expected(="..expectedZ..")")
    assert(relativeLocation:getDX() == expectedDx, "gotten getDX(="..relativeLocation:getDX()..") not the same as expected(="..expectedDx..")")
    assert(relativeLocation:getDY() == expectedDy, "gotten getDY(="..relativeLocation:getDY()..") not the same as expected(="..expectedDy..")")

    -- test right 2
    steps = 2
    relativeLocation = location1:getRelativeLocationRight(steps)
    expectedX = x1
    expectedY = y1
    expectedZ = z1
    expectedDx = -dx1
    expectedDy = -dy1
    assert(relativeLocation:getX() == expectedX, "gotten getX(="..relativeLocation:getX()..") not the same as expected(="..expectedX..")")
    assert(relativeLocation:getY() == expectedY, "gotten getY(="..relativeLocation:getY()..") not the same as expected(="..expectedY..")")
    assert(relativeLocation:getZ() == expectedZ, "gotten getY(="..relativeLocation:getZ()..") not the same as expected(="..expectedZ..")")
    assert(relativeLocation:getDX() == expectedDx, "gotten getDX(="..relativeLocation:getDX()..") not the same as expected(="..expectedDx..")")
    assert(relativeLocation:getDY() == expectedDy, "gotten getDY(="..relativeLocation:getDY()..") not the same as expected(="..expectedDy..")")

    -- cleanup test
end

function T_Location.T_blockDistanceTo()
    -- prepare test
    corelog.WriteToLog("* Location:blockDistanceTo() tests")
    local location1 = Location:new({
        _x  = x1,
        _y  = y1,
        _z  = z1,
        _dx = dx1,
        _dy = dy1,
    })
    local location2 = Location:new({
        _x  = x2,
        _y  = y2,
        _z  = z2,
        _dx = dx2,
        _dy = dy2,
    })

    -- test
    local blockDistance = location1:blockDistanceTo(location2)
    local expectedBlockDistance = math.abs(x2 - x1) + math.abs(y2 - y1) + math.abs(z2 - z1)
    assert(blockDistance == expectedBlockDistance, "gotten blockDistanceTo(="..blockDistance..") not the same as expected(="..expectedBlockDistance..")")

    -- cleanup test
end

return T_Location
