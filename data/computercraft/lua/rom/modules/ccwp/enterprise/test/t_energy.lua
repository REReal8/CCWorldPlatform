local t_energy = {}

local corelog = require "corelog"
local coremove = require "coremove"

local Location = require "obj_location"

local T_BirchForest = require "test.t_mobj_birchforest"

local enterprise_energy = require "enterprise_energy"
local enterprise_forestry = require "enterprise_forestry"

local t_manufacturing = require "test.t_manufacturing"

function t_energy.T_All()
    t_energy.T_GetFuelNeed_Refuel_Att()
    t_energy.T_GetRefuelAmount_Att()
end

local levelm1 = -1
local level0 = 0
local level1 = 1
local level2 = 2
local level3 = 3

function t_energy.T_ResetParameters()
    enterprise_energy.ResetParameters()
end

-- print("GetParameters="..textutils.serialize(enterprise_energy.GetParameters()))

-- print("GetFuelNeed_Refuel_Att="..textutils.serialize(enterprise_energy.GetFuelNeed_Refuel_Att()))
function t_energy.T_GetFuelNeed_Refuel_Att()
    -- prepare test
    corelog.WriteToLog("* enterprise_energy.GetFuelNeed_Refuel_Att() tests")
    local turtleLocation = Location:new(coremove.GetLocation())
    local forestLocation = turtleLocation:getRelativeLocation(-3, -2, 0)
    local forest = T_BirchForest.CreateForest(levelm1, forestLocation) if not forest then corelog.Error("failed obtaining forest") return end
    local forestLocator = enterprise_forestry:saveObject(forest)

    local factoryLocation1 = turtleLocation:copy()
    local result = t_manufacturing.StartNewSite(factoryLocation1) if not result.success then corelog.Error("failed starting Site") return end
    local factoryLocator1 = result.siteLocator

    local energyParameters = enterprise_energy.GetParameters()
    local originalLevel = energyParameters.enterpriseLevel
    local originalForestLocator = energyParameters.forestLocator
    local originalFactoryLocator = energyParameters.factoryLocator

    -- test L0
    local level = level0

    enterprise_energy.UpdateEnterprise_SSrv({ enterpriseLevel = level, forestLocator = nil, factoryLocator = nil })
    local fuelNeed = enterprise_energy.GetFuelNeed_Refuel_Att()
    local expectedFuelNeed = 0
    assert(fuelNeed == expectedFuelNeed, "gotten fuelNeed(="..fuelNeed..") for enterpriseLevel "..level.." not the same as expected(="..expectedFuelNeed..")")

    -- test L1
    level = level1

    enterprise_energy.UpdateEnterprise_SSrv({ enterpriseLevel = level, forestLocator = forestLocator, factoryLocator = factoryLocator1})
    fuelNeed = enterprise_energy.GetFuelNeed_Refuel_Att()
    expectedFuelNeed = 41
    assert(fuelNeed == expectedFuelNeed, "gotten fuelNeed(="..fuelNeed..") for enterpriseLevel "..level.." not the same as expected(="..expectedFuelNeed..")")

    -- test L2
    forest:setLevel(level0)
    forestLocator = enterprise_forestry:saveObject(forest)
    level = level2

    enterprise_energy.UpdateEnterprise_SSrv({ enterpriseLevel = level, forestLocator = forestLocator, factoryLocator = factoryLocator1})
    fuelNeed = enterprise_energy.GetFuelNeed_Refuel_Att()
    expectedFuelNeed = 89
    assert(fuelNeed == expectedFuelNeed, "gotten fuelNeed(="..fuelNeed..") for enterpriseLevel "..level.." not the same as expected(="..expectedFuelNeed..")")

    t_manufacturing.StopSite(factoryLocator1)

    -- test L3
    forest:setLevel(level2)
    forest:setNTrees(3*6)
    forestLocator = enterprise_forestry:saveObject(forest)
    local factoryLocation2 = forestLocation:getRelativeLocation(12, 0, 0)
    result = t_manufacturing.StartNewSite(factoryLocation2) if not result.success then corelog.Error("failed starting Site") return end
    local factoryLocator2 = result.siteLocator
    level = level3

    enterprise_energy.UpdateEnterprise_SSrv({ enterpriseLevel = level, forestLocator = forestLocator, factoryLocator = factoryLocator2})
    fuelNeed = enterprise_energy.GetFuelNeed_Refuel_Att()
    expectedFuelNeed = 970
    assert(fuelNeed == expectedFuelNeed, "gotten fuelNeed(="..fuelNeed..") for enterpriseLevel "..level.." not the same as expected(="..expectedFuelNeed..")")

    -- cleanup test
    enterprise_energy.UpdateEnterprise_SSrv({ enterpriseLevel = originalLevel, forestLocator = originalForestLocator, factoryLocator = originalFactoryLocator })

    t_manufacturing.StopSite(factoryLocator2)

    enterprise_forestry:deleteResource(forestLocator)
end

function t_energy.T_GetRefuelAmount_Att()
    -- prepare test
    corelog.WriteToLog("* enterprise_energy.GetRefuelAmount_Att() tests")
    local forest = T_BirchForest.CreateForest() if not forest then corelog.Error("failed obtaining forest") return end
    local forestLocator = enterprise_forestry:saveObject(forest)

    local turtleLocation = Location:new(coremove.GetLocation())
    local factoryLocation1 = turtleLocation:copy()
    local result = t_manufacturing.StartNewSite(factoryLocation1) if not result.success then corelog.Error("failed starting Site") return end
    local factoryLocator1 = result.siteLocator

    local energyParameters = enterprise_energy.GetParameters()
    local originalLevel = energyParameters.enterpriseLevel
    local originalForestLocator = energyParameters.forestLocator
    local originalFactoryLocator = energyParameters.factoryLocator

    -- test L0
    local level = level0
    enterprise_energy.UpdateEnterprise_SSrv({ enterpriseLevel = level, forestLocator = nil, factoryLocator = nil })
    local refuelAmount = enterprise_energy.GetRefuelAmount_Att()
    local expectedRefuelAmount = 0
    assert(refuelAmount == expectedRefuelAmount, "gotten refuelAmount(="..refuelAmount..") for enterpriseLevel "..level.." not the same as expected(="..expectedRefuelAmount..")")

    -- test L1
    level = level1
    enterprise_energy.UpdateEnterprise_SSrv({ enterpriseLevel = level, forestLocator = forestLocator, factoryLocator = factoryLocator1 })
    refuelAmount = enterprise_energy.GetRefuelAmount_Att()
    expectedRefuelAmount = 60
    assert(refuelAmount == expectedRefuelAmount, "gotten refuelAmount(="..refuelAmount..") for enterpriseLevel "..level.." not the same as expected(="..expectedRefuelAmount..")")

    -- test L2
    level = level2
    enterprise_energy.UpdateEnterprise_SSrv({ enterpriseLevel = level, forestLocator = forestLocator, factoryLocator = factoryLocator1 })
    refuelAmount = enterprise_energy.GetRefuelAmount_Att()
    expectedRefuelAmount = 300
    assert(refuelAmount == expectedRefuelAmount, "gotten refuelAmount(="..refuelAmount..") for enterpriseLevel "..level.." not the same as expected(="..expectedRefuelAmount..")")

    -- test L3
    level = level3
    enterprise_energy.UpdateEnterprise_SSrv({ enterpriseLevel = level, forestLocator = forestLocator, factoryLocator = factoryLocator1 })
    refuelAmount = enterprise_energy.GetRefuelAmount_Att()
    expectedRefuelAmount = 1800
    assert(refuelAmount == expectedRefuelAmount, "gotten refuelAmount(="..refuelAmount..") for enterpriseLevel "..level3.." not the same as expected(="..expectedRefuelAmount..")")

    -- cleanup test
    enterprise_energy.UpdateEnterprise_SSrv({ enterpriseLevel = originalLevel, forestLocator = originalForestLocator, factoryLocator = originalFactoryLocator })

    t_manufacturing.StopSite(factoryLocator1)

    enterprise_forestry:deleteResource(forestLocator)
end

return t_energy