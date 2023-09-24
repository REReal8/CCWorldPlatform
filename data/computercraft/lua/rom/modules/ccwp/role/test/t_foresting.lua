local t_foresting = {}

local corelog = require "corelog"
local coreinventory = require "coreinventory"
local coreutils = require "coreutils"
local coredht = require "coredht"
local coremove = require "coremove"

local role_forester = require "role_forester"

function t_foresting.T_All()
end

function t_foresting.T_BirchGrow()
    -- zorg dat er een kist onder de turtle staat met een paar saplings. De turtle moet een modem (links) en een diamond axe (rechts of inventory) hebben

    local saplings
    local logs
    local sticks

    local growTime
    local fuelUsage
    local harvestTime

    -- quip the axe / hatchet
    coreinventory.Equip("minecraft:diamond_axe")

    -- remove the ground under us, usefull for crafting later
    --turtle.digDown()

    -- plant the sapling
    turtle.suckDown(1)
    coreinventory.SelectItem("minecraft:birch_sapling")
    turtle.place()

    -- endless
    while true do
        -- sepling just planted, record the time
        growTime = coreutils.UniversalTime()

        -- wait for a tree
        local has_block, data
        while not has_block or type(data) ~= "table" or data.name ~= "minecraft:birch_log" do
            -- ff wachten
            os.sleep(0.25)

            -- opnieuw kijken
            has_block, data = turtle.inspect()
        end

        -- grown!
        growTime = coreutils.UniversalTime() - growTime

        -- move into position (don't count this step as harvesting)
        coremove.Up()
        fuelUsage   = turtle.getFuelLevel()
        harvestTime = coreutils.UniversalTime()

        -- boom omhakken
        role_forester.KapBoom()

        -- klaar met omhakken, wat hebben we geleerd?
        fuelUsage   = fuelUsage                 - turtle.getFuelLevel()
        harvestTime = coreutils.UniversalTime() - harvestTime

        -- terug naar onze plek
        coremove.Backward()
        coremove.Down()

        -- inventory tellen
        saplings    = coreinventory.CountItem("minecraft:birch_sapling") - 1
        logs        = coreinventory.CountItem("minecraft:birch_log")
        sticks      = coreinventory.CountItem("minecraft:stick")

        -- sapling in the chest
        coreinventory.DropAll("minecraft:birch_sapling", "down")

        -- use as fuel what we can
        for slot=1,16 do turtle.select(slot) turtle.refuel() end

        -- clean inventory
        coreinventory.DropAllItems("down")

        -- save the data
        coredht.SaveData({
            saplings    = saplings,
            logs        = logs,
            sticks      = sticks,
            fuelUsage   = fuelUsage,
            growTime    = growTime,
            harvestTime = harvestTime,
        }, "test", "BirchGrow", coreutils.NewId())

        -- info
        print("Fuel level: "..turtle.getFuelLevel().."units")

        -- get one new sapling
        turtle.suckDown(1)
    end
end

function t_foresting.T_BirchGrowToFile()
    -- get the data
    local filename  = '/log/birchgrow.csv'
    local data = coredht.GetData("test", "BirchGrow") if type(data) ~= "table" then corelog.Error("Failed obtaining data") return nil end

    corelog.WriteToLog("data:")
    corelog.WriteToLog(data)

    -- new file
    coreutils.WriteToFile(filename, "saplings;logs;sticks;fuelUsage;growTime;harvestTime", "overwrite")

    -- loop entries
    for k, v in pairs(data) do
        coreutils.WriteToFile(filename, v.saplings..";"..v.logs..";"..v.sticks..";"..v.fuelUsage..";"..string.format("%.3f", v.growTime)..";"..string.format("%.3f", v.harvestTime), "append")
    end
end

return t_foresting
