local T_Factory = {}
local corelog = require "corelog"
local coreutils = require "coreutils"

local IObj = require "iobj"
local ObjArray = require "obj_array"
local Location = require "obj_location"

local ProductionSpot = require "mobj_production_spot"
local Factory = require "mobj_factory"

local enterprise_turtle = require "enterprise_turtle"
local enterprise_chests = require "enterprise_chests"

function T_Factory.T_All()
    -- base methods
    T_Factory.T_ImplementsIObj()
    T_Factory.T_new()
    T_Factory.T_IsOfType()
    T_Factory.T_isSame()
    T_Factory.T_copy()

    -- specific methods
    T_Factory.T_getAvailableInputLocator()
    T_Factory.T_getAvailableOutputLocator()
    T_Factory.T_getAvailableCraftSpot()
    T_Factory.T_getAvailableSmeltSpot()

    -- service methods
    T_Factory.T_can_ProvideItems_QOSrv()
end

local compact = { compact = true }

--    _                                     _   _               _
--   | |                                   | | | |             | |
--   | |__   __ _ ___  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   | '_ \ / _` / __|/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   | |_) | (_| \__ \  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_.__/ \__,_|___/\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

function T_Factory.T_ImplementsIObj()
    -- prepare test
    corelog.WriteToLog("* Factory IObj interface test")
    local obj = T_Factory.CreateFactory() if not obj then corelog.Error("failed obtaining Factory") return end

    -- test
    local implementsInterface = IObj.ImplementsInterface(obj)
    assert(implementsInterface, "Factory class does not (fully) implement IObj interface")

    -- cleanup test
end

local location1  = Location:new({_x= -6, _y= 0, _z= 1, _dx=0, _dy=1})
local inputLocator1 = enterprise_turtle.GetHostLocator_Att()
local locatorClassName = "URL"
local inputLocators1 = ObjArray:new({ _objClassName = locatorClassName, inputLocator1, })
local outputLocator1 = enterprise_turtle.GetHostLocator_Att()
local outputLocators1 = ObjArray:new({ _objClassName = locatorClassName, outputLocator1, })
local productionSpotClassName = "ProductionSpot"
local craftingSpot1 = ProductionSpot:new({ _location = location1:getRelativeLocation(3, 3, -4), _isCraftingSpot = true })
local craftingSpots1 = ObjArray:new({ _objClassName = productionSpotClassName, craftingSpot1, })
local smeltingSpot1 = ProductionSpot:new({ _location = location1:getRelativeLocation(3, 3, -3), _isCraftingSpot = false })
local smeltingSpots1 = ObjArray:new({ _objClassName = productionSpotClassName, smeltingSpot1, })

function T_Factory.T_new()
    -- prepare test
    corelog.WriteToLog("* Factory:new() tests")
    local className = "Factory"
    local id = coreutils.NewId()

    -- test
    local obj = T_Factory.CreateFactory(location1, inputLocators1, outputLocators1, craftingSpots1, smeltingSpots1, id) if not obj then corelog.Error("failed obtaining Factory") return end
    assert(obj:getClassName() == className, "gotten className(="..obj:getClassName()..") not the same as expected(="..className..")")
    assert(obj:getId() == id, "gotten id(="..obj:getId()..") not the same as expected(="..id..")")
    assert(obj:getBaseLocation():isSame(location1), "gotten getBaseLocation(="..textutils.serialise(obj:getBaseLocation(), compact)..") not the same as expected(="..textutils.serialise(location1, compact)..")")
    assert(obj:getInputLocators()[1]:isSame(inputLocator1), "gotten getInputLocators()[1](="..textutils.serialise(obj:getInputLocators()[1], compact)..") not the same as expected(="..textutils.serialise(inputLocator1, compact)..")")
    assert(obj:getOutputLocators()[1]:isSame(outputLocator1), "gotten getOutputLocators()[1](="..textutils.serialise(obj:getOutputLocators()[1], compact)..") not the same as expected(="..textutils.serialise(outputLocator1, compact)..")")
    assert(obj:getCraftingSpots()[1]:isSame(craftingSpot1), "gotten getCraftingSpots()[1](="..textutils.serialise(obj:getCraftingSpots()[1], compact)..") not the same as expected(="..textutils.serialise(craftingSpot1, compact)..")")
    assert(obj:getSmeltingSpots()[1]:isSame(smeltingSpot1), "gotten getSmeltingSpots()[1](="..textutils.serialise(obj:getSmeltingSpots()[1], compact)..") not the same as expected(="..textutils.serialise(smeltingSpot1, compact)..")")

    -- cleanup test
end

function T_Factory.CreateFactory(baseLocation, inputLocators, outputLocators, craftingSpots, smeltingSpots, id)
    -- check input
    id = id or coreutils.NewId()
    baseLocation = baseLocation or location1

    inputLocators = inputLocators or inputLocators1
    outputLocators = outputLocators or outputLocators1

    craftingSpots = craftingSpots or craftingSpots1
    smeltingSpots = smeltingSpots or smeltingSpots1

    -- create Factory object
    local obj = Factory:new({
        _id             = id,

        _baseLocation   = baseLocation,

        _inputLocators  = inputLocators,
        _outputLocators = outputLocators,

        _craftingSpots  = craftingSpots,
        _smeltingSpots  = smeltingSpots,
    })

    -- end
    return obj
end

function T_Factory.T_IsOfType()
    -- prepare test
    corelog.WriteToLog("* Factory.IsOfType() tests")
    local obj = T_Factory.CreateFactory() if not obj then corelog.Error("failed obtaining Factory") return end

    -- test valid
    local isOfType = Factory.IsOfType(obj)
    local expectedIsOfType = true
    assert(isOfType == expectedIsOfType, "gotten IsOfType(="..tostring(isOfType)..") not the same as expected(="..tostring(expectedIsOfType)..")")

    -- test different object
    isOfType = Factory.IsOfType("a atring")
    expectedIsOfType = false
    assert(isOfType == expectedIsOfType, "gotten IsOfType(="..tostring(isOfType)..") not the same as expected(="..tostring(expectedIsOfType)..")")

    -- test invalid _baseLocation
    obj._baseLocation = "a string"
    isOfType = Factory.IsOfType(obj)
    expectedIsOfType = false
    assert(isOfType == expectedIsOfType, "gotten IsOfType(="..tostring(isOfType)..") not the same as expected(="..tostring(expectedIsOfType)..")")
    obj._baseLocation = location1

    -- test invalid _inputLocators
    obj._inputLocators = "a string"
    isOfType = Factory.IsOfType(obj)
    expectedIsOfType = false
    assert(isOfType == expectedIsOfType, "gotten IsOfType(="..tostring(isOfType)..") not the same as expected(="..tostring(expectedIsOfType)..")")
    obj._inputLocators = inputLocators1

    -- test invalid _outputLocators
    obj._outputLocators = "a string"
    isOfType = Factory.IsOfType(obj)
    expectedIsOfType = false
    assert(isOfType == expectedIsOfType, "gotten IsOfType(="..tostring(isOfType)..") not the same as expected(="..tostring(expectedIsOfType)..")")
    obj._outputLocators = outputLocators1

    -- test invalid _craftingSpots
    obj._craftingSpots = "a string"
    isOfType = Factory.IsOfType(obj)
    expectedIsOfType = false
    assert(isOfType == expectedIsOfType, "gotten IsOfType(="..tostring(isOfType)..") not the same as expected(="..tostring(expectedIsOfType)..")")
    obj._craftingSpots = craftingSpots1

    -- test invalid _smeltingSpots
    obj._smeltingSpots = "a string"
    isOfType = Factory.IsOfType(obj)
    expectedIsOfType = false
    assert(isOfType == expectedIsOfType, "gotten IsOfType(="..tostring(isOfType)..") not the same as expected(="..tostring(expectedIsOfType)..")")
    obj._smeltingSpots = smeltingSpots1

    -- cleanup test
end

function T_Factory.T_isSame()
    -- prepare test
    corelog.WriteToLog("* Factory:isSame() tests")
    local id = coreutils.NewId()
    local obj = T_Factory.CreateFactory(location1, inputLocators1, outputLocators1, craftingSpots1, smeltingSpots1, id) if not obj then corelog.Error("failed obtaining Factory") return end
    local location2  = Location:new({_x= 100, _y= 0, _z= 100, _dx=1, _dy=0})
    local inputLocator2 = enterprise_chests:getHostLocator() -- note: more correct would be an actual Chest
    local inputLocators2 = { inputLocator2, }
    local outputLocator2 = enterprise_chests:getHostLocator() -- note: more correct would be an actual Chest
    local outputLocators2 = { outputLocator2, }
    local craftingSpot2 = ProductionSpot:new({ _location = location2:getRelativeLocation(3, 3, -4), _isCraftingSpot = true })
    local craftingSpots2 = { craftingSpot2, }
    local smeltingSpot2 = ProductionSpot:new({ _location = location2:getRelativeLocation(3, 3, -3), _isCraftingSpot = false })
    local smeltingSpots2 = { smeltingSpot2, }

    -- test same
    local obj1 = T_Factory.CreateFactory(location1, inputLocators1, outputLocators1, craftingSpots1, smeltingSpots1, id)
    local isSame = obj1:isSame(obj)
    local expectedIsSame = true
    assert(isSame == expectedIsSame, "gotten isSame(="..tostring(isSame)..") not the same as expected(="..tostring(expectedIsSame)..")")

    -- test different _baseLocation
    obj._baseLocation = location2
    isSame = obj1:isSame(obj)
    expectedIsSame = false
    assert(isSame == expectedIsSame, "gotten isSame(="..tostring(isSame)..") not the same as expected(="..tostring(expectedIsSame)..")")
    obj._baseLocation = location1

    -- test different _inputLocators
    obj._inputLocators = inputLocators2
    isSame = obj1:isSame(obj)
    expectedIsSame = false
    assert(isSame == expectedIsSame, "gotten isSame(="..tostring(isSame)..") not the same as expected(="..tostring(expectedIsSame)..")")
    obj._inputLocators = inputLocators1

    -- test different _outputLocators
    obj._outputLocators = outputLocators2
    isSame = obj1:isSame(obj)
    expectedIsSame = false
    assert(isSame == expectedIsSame, "gotten isSame(="..tostring(isSame)..") not the same as expected(="..tostring(expectedIsSame)..")")
    obj._outputLocators = outputLocators1

    -- test different _craftingSpots
    obj._craftingSpots = craftingSpots2
    isSame = obj1:isSame(obj)
    expectedIsSame = false
    assert(isSame == expectedIsSame, "gotten isSame(="..tostring(isSame)..") not the same as expected(="..tostring(expectedIsSame)..")")
    obj._craftingSpots = craftingSpots1

    -- test different _smeltingSpots
    obj._smeltingSpots = smeltingSpots2
    isSame = obj1:isSame(obj)
    expectedIsSame = false
    assert(isSame == expectedIsSame, "gotten isSame(="..tostring(isSame)..") not the same as expected(="..tostring(expectedIsSame)..")")
    obj._smeltingSpots = smeltingSpots1

    -- cleanup test
end

function T_Factory.T_copy()
    -- prepare test
    corelog.WriteToLog("* Factory:copy() tests")
    local obj = T_Factory.CreateFactory() if not obj then corelog.Error("failed obtaining Factory") return end

    -- test
    local copy = obj:copy()
    assert(copy:isSame(obj), "gotten copy(="..textutils.serialize(copy, compact)..") not the same as expected(="..textutils.serialize(obj, compact)..")")

    -- cleanup test
end

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

function T_Factory.T_getAvailableInputLocator()
    -- prepare test
    corelog.WriteToLog("* Factory:getAvailableInputLocator() tests")
    local obj = T_Factory.CreateFactory() if not obj then corelog.Error("failed obtaining Factory") return end

    -- test
    local locator = obj:getAvailableInputLocator()
    assert(locator:isSame(inputLocator1), "gotten getAvailableInputLocator(="..textutils.serialise(locator, compact)..") not the same as expected(="..textutils.serialise(inputLocator1, compact)..")")

    -- cleanup test
end

function T_Factory.T_getAvailableOutputLocator()
    -- prepare test
    corelog.WriteToLog("* Factory:getAvailableOutputLocator() tests")
    local obj = T_Factory.CreateFactory() if not obj then corelog.Error("failed obtaining Factory") return end

    -- test
    local locator = obj:getAvailableOutputLocator()
    assert(locator:isSame(outputLocator1), "gotten getAvailableOutputLocator(="..textutils.serialise(locator, compact)..") not the same as expected(="..textutils.serialise(outputLocator1, compact)..")")

    -- cleanup test
end

function T_Factory.T_getAvailableCraftSpot()
    -- prepare test
    corelog.WriteToLog("* Factory:getAvailableCraftSpot() tests")
    local obj = T_Factory.CreateFactory() if not obj then corelog.Error("failed obtaining Factory") return end

    -- test
    local spot = obj:getAvailableCraftSpot()
    assert(spot:isSame(craftingSpot1), "gotten getAvailableCraftSpot(="..textutils.serialise(spot, compact)..") not the same as expected(="..textutils.serialise(craftingSpot1, compact)..")")

    -- cleanup test
end

function T_Factory.T_getAvailableSmeltSpot()
    -- prepare test
    corelog.WriteToLog("* Factory:getAvailableSmeltSpot() tests")
    local obj = T_Factory.CreateFactory() if not obj then corelog.Error("failed obtaining Factory") return end

    -- test
    local spot = obj:getAvailableSmeltSpot()
    assert(spot:isSame(smeltingSpot1), "gotten getAvailableSmeltSpot(="..textutils.serialise(spot, compact)..") not the same as expected(="..textutils.serialise(smeltingSpot1, compact)..")")

    -- cleanup test
end

--                        _                           _   _               _
--                       (_)                         | | | |             | |
--    ___  ___ _ ____   ___  ___ ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \  __/ |   \ V /| | (_|  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/\___|_|    \_/ |_|\___\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

function T_Factory.T_can_ProvideItems_QOSrv()
    -- prepare test
    corelog.WriteToLog("* Factory:can_ProvideItems_QOSrv() tests")
    local obj = T_Factory.CreateFactory() if not obj then corelog.Error("failed obtaining Factory") return end

    -- test can not produce item without recipe
    local itemName = "anItemWithNoRecipe"
    local itemCount = 2
    local serviceResults = obj:can_ProvideItems_QOSrv({ provideItems = { [itemName] = itemCount} })
    assert(not serviceResults.success, "can_ProvideItems_QOSrv incorrectly success for "..itemCount.." "..itemName.."'s")

    -- test can craft
    itemName = "minecraft:birch_planks"
    itemCount = 10
    serviceResults = obj:can_ProvideItems_QOSrv({ provideItems = { [itemName] = itemCount} })
    assert(serviceResults.success, "can_ProvideItems_QOSrv incorrectly failed for "..itemCount.." "..itemName.."'s")

    -- test can not craft without available craftingSpot
    -- ToDo: improve when a spot can be marked unavailable
    local craftingSpots2 = ObjArray:new({ _objClassName = productionSpotClassName, })
    obj._craftingSpots = craftingSpots2
    serviceResults = obj:can_ProvideItems_QOSrv({ provideItems = { [itemName] = itemCount} })
    assert(not serviceResults.success, "can_ProvideItems_QOSrv incorrectly failed for "..itemCount.." "..itemName.."'s")
    obj._craftingSpots = craftingSpots1

    -- test can smelt
    itemName = "minecraft:charcoal"
    itemCount = 5
    serviceResults = obj:can_ProvideItems_QOSrv({ provideItems = { [itemName] = itemCount} })
    assert(serviceResults.success, "can_ProvideItems_QOSrv incorrectly failed for "..itemCount.." "..itemName.."'s")

    -- test can not smelt without available smeltingSpot
    -- ToDo: improve when a spot can be marked unavailable
    local smeltingSpots2 = ObjArray:new({ _objClassName = productionSpotClassName, })
    obj._smeltingSpots = smeltingSpots2
    serviceResults = obj:can_ProvideItems_QOSrv({ provideItems = { [itemName] = itemCount} })
    assert(not serviceResults.success, "can_ProvideItems_QOSrv incorrectly failed for "..itemCount.." "..itemName.."'s")
    obj._smeltingSpots = smeltingSpots1

    -- test can not produce without available inputLocator
    -- ToDo: improve by changing the availability of the inputLocator
    local inputLocators2 = ObjArray:new({ _objClassName = locatorClassName, })
    obj._inputLocators = inputLocators2
    serviceResults = obj:can_ProvideItems_QOSrv({ provideItems = { [itemName] = itemCount} })
    assert(not serviceResults.success, "can_ProvideItems_QOSrv incorrectly success for "..itemCount.." "..itemName.."'s")
    obj._inputLocators = inputLocators1

    -- test can not produce without available outputLocator
    -- ToDo: improve by changing the availability of the _outputLocators
    local outputLocators2 = ObjArray:new({ _objClassName = locatorClassName, })
    obj._outputLocators = outputLocators2
    serviceResults = obj:can_ProvideItems_QOSrv({ provideItems = { [itemName] = itemCount} })
    assert(not serviceResults.success, "can_ProvideItems_QOSrv incorrectly success for "..itemCount.." "..itemName.."'s")
    obj._outputLocators = outputLocators1

    -- cleanup test
end

return T_Factory