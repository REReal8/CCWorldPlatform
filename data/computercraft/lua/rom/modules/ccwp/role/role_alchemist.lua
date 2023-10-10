-- define role
local role_alchemist = {}

-- ToDo: add proper module description
--[[
    This role ...
--]]

local coreutils = require "coreutils"
local corelog = require "corelog"
local coremove = require "coremove"
local coreinventory = require "coreinventory"

local InputChecker = require "input_checker"
local ItemTable = require "obj_item_table"

local enterprise_turtle

--    _______        _                   __  __      _        _____        _
--   |__   __|      | |          ___    |  \/  |    | |      |  __ \      | |
--      | | __ _ ___| | _____   ( _ )   | \  / | ___| |_ __ _| |  | | __ _| |_ __ _
--      | |/ _` / __| |/ / __|  / _ \/\ | |\/| |/ _ \ __/ _` | |  | |/ _` | __/ _` |
--      | | (_| \__ \   <\__ \ | (_>  < | |  | |  __/ || (_| | |__| | (_| | || (_| |
--      |_|\__,_|___/_|\_\___/  \___/\/ |_|  |_|\___|\__\__,_|_____/ \__,_|\__\__,_|

function role_alchemist.Craft_MetaData(...)
    -- get & check input from description
    local checkSuccess, recipe, productItemCount, workingLocation, priorityKey = InputChecker.Check([[
        This function returns the MetaData for Craft_Task.

        Return value:
                                        - (table) metadata

        Parameters:
            taskData                    - (table) data about the crafting task
                recipe                  + (table) crafting recipe
                    yield               - (number) of items produced by recipe
                productItemName         - (string) name of item to produce
                productItemCount        + (number) of items to produce
                workingLocation         + (Location) world location to do the crafting
                priorityKey             + (string, "") priorityKey for this assignment
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("role_alchemist.Craft_MetaData: Invalid input") return {success = false} end

    -- determine needed items
    local itemList = role_alchemist.Craft_ItemsNeeded(recipe, productItemCount)
    if not itemList then corelog.Error("role_alchemist.Craft_MetaData: Failed obtaining itemList") return {success = false} end
    local fuelNeeded = 0 -- task starts at workingLocation, 0 movement from there

    -- return metadata
    return {
        startTime   = coreutils.UniversalTime(),
        location    = workingLocation:copy(),
        needTool    = false,
        needTurtle  = true,
        fuelNeeded  = fuelNeeded,
        itemsNeeded = itemList,

        priorityKey = priorityKey,
    }
end

function role_alchemist.Craft_ItemsNeeded(...)
    -- get & check input from description
    local checkSuccess, recipe, productItemCount = InputChecker.Check([[
        This function returns the ingredientsNeeded for crafting a recipe.

        Return value:
            ingredientsNeeded       - (table) ingredientsNeeded to produce items
            productSurplus          - (number) number of surplus requested products

        Parameters:
            recipe                  + (table) crafting recipe
                yield               - (number) of items produced by recipe
            productItemCount        + (number) of items to produce
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("role_alchemist.Craft_ItemsNeeded: Invalid input") return nil end

    -- build item list
    local itemList = {}
    local yield = 1
    for k, ingredientInfo in pairs(recipe) do
        -- loop on only ingredients (skip yield)
        if type(ingredientInfo) == "table" then
            -- increment counter
            local ingredientItemName = ingredientInfo.itemName
            itemList[ingredientItemName] = (itemList[ingredientItemName] or 0) + ingredientInfo.itemCount
        elseif type(ingredientInfo) == "number" then
            yield = ingredientInfo
        end
    end

    -- correct for yield and itemProduceCount
    for itemName, itemCount in pairs(itemList) do
        itemList[itemName] = math.ceil(itemList[itemName] * productItemCount / yield)
    end

    -- calculate the surplus
    local productSurplus = (recipe.yield - productItemCount % recipe.yield) % recipe.yield

    -- return itemList
    return itemList, productSurplus
end

local function ItemInRecipe(itemName, recipe)
    -- loop all slots
    for slot=1,16 do if recipe[ slot ] and recipe[ slot ].itemName == itemName then return true end end

    -- not present
    return false
end

local function PrepareCraftingArea(recipe, times)
    --[[
       This function prepares the crafting area within the turtle.

       Return value:
           nil

       Parameters:
           recipe                      - (table) crafting recipe
               yield                   - (number) of items produced by recipe
               key, value              - (table) multiple key-value-pairs of slot, ingredient information
                   key = [slot]        - (number) of slot in turtle
                   value               - (table) information of ingredient to place in slot
                       itemName        - (string) name of ingredient item in slot
                       itemCount       - (number) of ingredients to place in slot
           times                       - (number) of times to apply the recipe
   ]]

   -- presume we can use the ItemDepot below us
   local craftArea = {false, false, false, false, false, true,  true,  true,  false, true,  true,  true,  false, true,  true,  true,  }
   local sideArea  = {true,  true,  true,  true,  true,  false, false, false, true,  false, false, false, true,  false, false, false, }

   -- drop stuff we don't need
   for slot=1,16 do

       -- what is in this slot?
       local itemDetail = coreinventory.GetItemDetail(slot)

       -- something in this slot and we don't need it?
       if itemDetail and not ItemInRecipe(itemDetail.name, recipe) then turtle.select(slot) turtle.dropDown() end
   end

   -- loop the crafting area
   for slot=1,16 do
       -- only for the crafting area
       if craftArea[slot] then

           -- something present here?
           local itemDetail = coreinventory.GetItemDetail(slot)
           if itemDetail then

               -- find a empty slot to store the stuff now in this slot
               local emptySlot = coreinventory.GetEmptySlot(sideArea)

               -- move all stuf from current slot to this slot
               turtle.select(slot)
               turtle.transferTo(emptySlot)
           end

           -- do we need stuff in this slot?
           if type(recipe[slot]) == "table" then
               -- find stuff that is needed here
               local itemName      =         recipe[slot].itemName
               local itemCount     = times * recipe[slot].itemCount
               local itemPresent   = turtle.getItemCount(slot)         -- slot is empty at this point

               -- go, find the stuff
               local itemSlot  = 1
               while itemCount > itemPresent and itemSlot <= 16 do

                   -- skip crafting spots allready prepared
                   if itemSlot > slot or sideArea[itemSlot] then

                       -- see what is in this slot
                       itemDetail = coreinventory.GetItemDetail(itemSlot)

                       -- usefull?
                       if type(itemDetail) == "table" and itemDetail.name == itemName then

                           -- great, transfer!
                           turtle.select(itemSlot)
                           turtle.transferTo(slot, itemCount - itemPresent)

                           -- how many in the slot right now?
                           itemPresent = turtle.getItemCount(slot)
                       end
                   end

                   -- don't forget to increase the slot
                   itemSlot = itemSlot + 1
               end
           end
       end
   end

   -- drop everything we don't need
   for slot=1,16 do

       -- this applies only to the side area (if something present)
       if sideArea[slot] and coreinventory.GetItemDetail(slot) then

           -- drop it!
           turtle.select(slot)
           turtle.dropDown()
       end
   end
end

function role_alchemist.Craft_Task(...)
    -- get & check input from description
    local checkSuccess, recipe, yield, productItemName, productItemCount, workingLocation = InputChecker.Check([[
        This Task function crafts items. The ingredients for crafting should be present in the turtle executing this task.

        Return value:
                                        - (table)
                success                 - (boolean) whether the task executed succesfull
                turtleOutputItemsLocator- (URL) locating the items that where produced (in a turtle)
                turtleWasteItemsLocator - (URL) locating waste items produced during production

        Parameters:
            taskData                    - (table) data about the crafting task
                recipe                  + (table) crafting recipe
                    yield               + (number) of items produced by recipe
                productItemName         + (string) name of item to produce
                productItemCount        + (number) of items to produce
                workingLocation         + (Location) world location to do the crafting
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("role_alchemist.Craft_Task: Invalid input") return {success = false} end

    -- equip crafting_table
    coreinventory.Equip("minecraft:crafting_table")

    -- get turtle we are doing task with
    enterprise_turtle = enterprise_turtle or require "enterprise_turtle"
    local turtleLocator = enterprise_turtle:getCurrentTurtleLocator()
    if not turtleLocator then corelog.Error("role_alchemist.Craft_Task: Failed obtaining current turtleLocator") return {success = false} end
    local turtleObj = enterprise_turtle:getObject(turtleLocator)
    if not turtleObj then corelog.Error("role_alchemist.Craft_Task: Failed obtaining current Turtle") return {success = false} end

    -- remember input items
    local beginTurtleItemTable = turtleObj:getInventoryAsItemTable()

    -- calculate how many times we need to "do" the recipe
    local times = math.ceil(productItemCount / yield)

    -- move to the crafting location
    coremove.GoTo(workingLocation)

    -- do the magic!
    PrepareCraftingArea(recipe, times)
    turtle.craft()

    -- re-take the stuff from the chest below
    coreinventory.GetAllItems("down")

    -- determine output items
    local endTurtleItemTable = turtleObj:getInventoryAsItemTable()
    local uniqueEndItemTable, _commonItemTable, _uniqueBeginItemTable = ItemTable.compare(endTurtleItemTable, beginTurtleItemTable)
    if not uniqueEndItemTable then corelog.Error("role_alchemist.Craft_Task: Failed obtaining uniqueEndItemTable") return {success = false} end

    -- determine waste items
    local wasteItems = {}
    for wasteItemName, wasteItemCount in pairs(uniqueEndItemTable) do
        if wasteItemName ~= productItemName then
            wasteItems[wasteItemName] = wasteItemCount
        end
    end
    if next(wasteItems) ~= nil then
        corelog.WriteToLog(">crafting waste: "..textutils.serialise(wasteItems, {compact = true}))
    end

    -- determine output & waste locators
    local turtleOutputItemsLocator = turtleLocator:copy()
    turtleOutputItemsLocator:setQuery({ [productItemName] = productItemCount })
    local turtleWasteItemsLocator = turtleLocator:copy()
    turtleWasteItemsLocator:setQuery(wasteItems)

    -- end
    local result = {
        success                     = true,
        turtleOutputItemsLocator    = turtleOutputItemsLocator,
        turtleWasteItemsLocator     = turtleWasteItemsLocator,
    }
    return result
end

function role_alchemist.Smelt_MetaData(...)
    -- get & check input from description
    local checkSuccess, recipe, productItemCount, workingLocation, fuelItemName, fuelItemCount, priorityKey = InputChecker.Check([[
        This function returns the MetaData for Smelt_Task.

        Return value:
                                        - (table) metadata

        Parameters:
            taskData                    - (table) data about the task
                recipe                  + (table) smelting recipe
                    itemName            - (string) name of smelting ingredient to use
                    yield               - (number) of items produced by recipe
                productItemCount        + (number) of items to produce
                workingLocation         + (Location) world location to do the smelting (in front of the furnance)
                fuelItemName            + (string) name of fuel item to use
                fuelItemCount           + (number) of fuel items to use
                priorityKey             + (string, "") priorityKey for this assignment
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("role_alchemist.Smelt_MetaData: Invalid input") return {success = false} end

    -- determine needed items
    local itemList = role_alchemist.Smelt_ItemsNeeded(recipe, productItemCount, fuelItemName, fuelItemCount)
    local fuelNeeded = 4 -- task starts at workingLocation, very little (4) movement from there

    -- return metadata
    return {
        startTime   = coreutils.UniversalTime(),
        location    = workingLocation:copy(),
        needTool    = false,
        needTurtle  = true,
        fuelNeeded  = fuelNeeded,
        itemsNeeded = itemList,

        priorityKey = priorityKey,
    }
end

function role_alchemist.Smelt_ItemsNeeded(recipe, productItemCount, fuelItemName, fuelItemCount)
    -- check input
    if type(recipe) ~= "table" then corelog.Error("role_alchemist.Smelt_ItemsNeeded: Invalid recipe") return { } end
    if type(productItemCount) ~= "number" then corelog.Error("role_alchemist.Smelt_ItemsNeeded: Invalid productItemCount") return { } end
    if type(fuelItemName) ~= "string" then corelog.Error("role_alchemist.Smelt_ItemsNeeded: Invalid fuelItemName") return { } end
    if type(fuelItemCount) ~= "number" then corelog.Error("role_alchemist.Smelt_ItemsNeeded: Invalid fuelItemCount") return { } end

    -- get yield
    local yield = recipe.yield
    if type(yield) ~= "number" then corelog.Error("role_alchemist.Smelt_ItemsNeeded: Invalid yield") return { } end

    -- build item list
    local itemList = {
        [recipe.itemName] = math.ceil(productItemCount / recipe.yield),
    }
    itemList[fuelItemName] = (itemList[fuelItemName] or 0) + fuelItemCount

    -- calculate the surplus
    local productSurplus = (recipe.yield - productItemCount % recipe.yield) % recipe.yield

    -- return itemList
--    corelog.WriteToLog("Smelt_ItemsNeeded: itemList="..textutils.serialise(itemList))
    return itemList, productSurplus
end

function role_alchemist.Smelt_Task(...)
    -- get & check input from description
    local checkSuccess, itemName, yield, productItemCount, workingLocation, fuelItemName, fuelItemCount = InputChecker.Check([[
        This Task function smelts items. The ingredients for smelting should be present in the turtle executing this task.

        Return value:
            task result                 - (table)
                success                 - (boolean) whether the smelting was succesfull
                smeltReadyTime          - (number) the time when the smelting is expexted to be ready

        Parameters:
            taskData                    - (table) data about the task
                recipe                  - (table) smelting recipe
                    itemName            + (string) name of smelting ingredient to use
                    yield               + (number) of items produced by recipe
                productItemCount        + (number) of items to produce
                workingLocation         + (Location) world location to do the smelting (in front of the furnance)
                fuelItemName            + (string) name of fuel item to use
                fuelItemCount           + (number) of fuel items to use
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("role_alchemist.Smelt_Task: Invalid input") return {success = false} end

    -- prepare
    local times = math.ceil(productItemCount / yield)

    -- go to the furnace
    coremove.GoTo(workingLocation)

    -- move on top of the furnace
    coremove.Up()
    coremove.Forward()

    -- fill furnace with it's ingredient
    coreinventory.SelectItem(itemName)
    turtle.dropDown(times)

    -- move to the front of the furnace
    coremove.GoTo(workingLocation)

    -- fill the furnace with fuel
    coreinventory.SelectItem(fuelItemName)
    turtle.drop(fuelItemCount)

    -- determine expected completion time
    local smeltingTime = 10 * times -- one smelting operation is sayed to take 10 seconds
    local now = coreutils.UniversalTime()
    local smeltReadyTime = now + smeltingTime/50

    -- end
    return {success = true, smeltReadyTime = smeltReadyTime}
end

function role_alchemist.Pickup_MetaData(...)
    -- get & check input from description
    local checkSuccess, workingLocation, priorityKey = InputChecker.Check([[
        This function returns the MetaData for Pickup_Task.

        Return value:
                                        - (table) metadata

        Parameters:
            taskData                    - (table) data about the task
                productItemName         - (string) name of item to produce
                productItemCount        - (number) of items to produce
                workingLocation         + (Location) world location to do the smelting (in front of the furnance)
                priorityKey             + (string, "") priorityKey for this assignment
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("role_alchemist.Pickup_MetaData: Invalid input") return {success = false} end

    -- determine needed fuel
    local fuelNeeded = 4 -- task starts at workingLocation, very little (4) movement from there

    -- return metadata
    return {
        startTime   = coreutils.UniversalTime(),
        location    = workingLocation:copy(),
        needTool    = false,
        needTurtle  = true,
        fuelNeeded  = fuelNeeded,
        itemsNeeded = {},

        priorityKey = priorityKey,
    }
end

function role_alchemist.Pickup_Task(...)
    -- get & check input from description
    local checkSuccess, productItemName, productItemCount, workingLocation = InputChecker.Check([[
        This Task picks up smelted items from a furnace.

        Return value:
                                        - (table)
                success                 - (boolean) whether the task executed succesfull
                turtleOutputItemsLocator- (URL) locating the items that where produced (in a turtle)
                turtleWasteItemsLocator - (URL) locating waste items produced during production

        Parameters:
            taskData                    - (table) data about the task
                productItemName         + (string) name of item to produce
                productItemCount        + (number) of items to produce
                workingLocation         + (Location) world location to do the smelting (in front of the furnance)
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("role_alchemist.Pickup_Task: Invalid input") return {success = false} end

    -- get turtle we are doing task with
    enterprise_turtle = enterprise_turtle or require "enterprise_turtle"
    local turtleLocator = enterprise_turtle:getCurrentTurtleLocator()
    if not turtleLocator then corelog.Error("role_alchemist.Pickup_Task: Failed obtaining current turtleLocator") return {success = false} end
    local turtleObj = enterprise_turtle:getObject(turtleLocator)
    if not turtleObj then corelog.Error("role_alchemist.Pickup_Task: Failed obtaining current Turtle") return {success = false} end

    -- remember input items
    local beginTurtleItemTable = turtleObj:getInventoryAsItemTable()

    -- go to the furnace
    coremove.GoTo(workingLocation)

    -- remove remaining fuel from furnace
    turtle.suck()

    -- move below the furnace
    coremove.Down()
    coremove.Forward()

    -- suck the results from furnace
    turtle.suckUp()

    -- move back to workingLocation
    coremove.GoTo(workingLocation)

    -- determine output items
    local endTurtleItemTable = turtleObj:getInventoryAsItemTable()
    local uniqueEndItemTable, _commonItemTable, _uniqueBeginItemTable = ItemTable.compare(endTurtleItemTable, beginTurtleItemTable)
    if not uniqueEndItemTable then corelog.Error("role_alchemist.Pickup_Task: Failed obtaining uniqueEndItemTable") return {success = false} end
    local wasteItems = {}
    local producedProductItems = 0
    for itemName, itemCount in pairs(uniqueEndItemTable) do
        if itemName == productItemName then
            -- check enough
            if itemCount < productItemCount then
                corelog.Warning("role_alchemist.Pickup_Task: Only retrieved "..itemName.." "..productItemName.." from furnace (expected was "..productItemCount..")")
            end
            producedProductItems = productItemCount

            -- check for waste
            local wasteCount = itemCount - productItemCount
            if wasteCount > 0 then
                wasteItems[itemName] = wasteCount
            end
        else
            wasteItems[itemName] = itemCount
        end
    end
    if next(wasteItems) ~= nil then
        corelog.WriteToLog(">smelting waste: "..textutils.serialise(wasteItems, {compact = true}))
    end

    -- determine output & waste locators
    local turtleOutputItemsLocator = turtleLocator:copy()
    turtleOutputItemsLocator:setQuery({ [productItemName] = producedProductItems })
    local turtleWasteItemsLocator = turtleLocator:copy()
    turtleWasteItemsLocator:setQuery(wasteItems)

    -- end
    local result = {
        success                     = true,
        turtleOutputItemsLocator    = turtleOutputItemsLocator,
        turtleWasteItemsLocator     = turtleWasteItemsLocator,
    }
    return result
end

--    _                 _    __                  _   _
--   | |               | |  / _|                | | (_)
--   | | ___   ___ __ _| | | |_ _   _ _ __   ___| |_ _  ___  _ __  ___
--   | |/ _ \ / __/ _` | | |  _| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
--   | | (_) | (_| (_| | | | | | |_| | | | | (__| |_| | (_) | | | \__ \
--   |_|\___/ \___\__,_|_| |_|  \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
--
--

return role_alchemist
