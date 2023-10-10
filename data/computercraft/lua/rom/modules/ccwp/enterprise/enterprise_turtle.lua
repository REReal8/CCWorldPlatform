-- define class
local Class = require "class"
local MObjHost = require "mobj_host"
local enterprise_turtle = Class.NewClass(MObjHost)

--[[
    The enterprise_turtle is a MObjHost. It hosts Turtle's that can perform work in the pysical world.
--]]

local coreutils = require "coreutils"
local corelog = require "corelog"
local coreinventory = require "coreinventory"

local Callback = require "obj_callback"
local InputChecker = require "input_checker"
local ObjectFactory = require "object_factory"
local objectFactory = ObjectFactory:getInstance()
local Host = require "obj_host"

local Turtle = require "mobj_turtle"

local enterprise_assignmentboard = require "enterprise_assignmentboard"
local enterprise_shop = require "enterprise_shop"
local enterprise_energy = require "enterprise_energy"

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

-- note: currently enterprise is treated like a singleton, but by directly using the name of the module
-- ToDo: consider making changes to enterprise to
--          - explicitly make it a singleton (by construction with :newInstance(hostName) and using the singleton pattern)
--          - properly initialise it (by adding and implementing the _init method)
--          - adopt other classes to these changes
enterprise_turtle._hostName   = "enterprise_turtle"

local function GetATurtle()
    -- get all Turtles
    local turtles = enterprise_turtle:getObjects(Turtle:getClassName())
    if not turtles then corelog.Error("enterprise_turtle:GetATurtle: Failed obtaining Turtle's") return nil end

    -- select first Turtle
    -- ToDo: consider selecting a free Turtle (also based on some criteria) (maybe do this via assignments?)
    local _, turtleObjTable = next(turtles) -- first Turtle
    if not turtleObjTable then corelog.Error("enterprise_turtle:GetATurtle: Failed obtaining a Turtle") return nil end
    local turtleObj = objectFactory:create("Turtle", turtleObjTable) if not turtleObj then corelog.Error("enterprise_turtle:GetATurtle: failed converting turtle objTable to Turtle") return nil end

    -- end
    return turtleObj
end

function enterprise_turtle:getObject(...)
    -- get & check input from description
    local checkSuccess, objectLocator = InputChecker.Check([[
        This method retrieves an object from the Host using a URL (that was once provided by the Host).

        Return value:
            object                  - (?) object obtained from the Host

        Parameters:
            objectLocator           + (URL) locator of the object within the Host
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("enterprise_turtle:getObject: Invalid input") return nil end

    -- check for "any turtle"
    if objectLocator:sameBase(enterprise_turtle.GetAnyTurtleLocator()) then
        -- ToDo: consider adjusting calling code/ project logic to select a specific Turtle as late as possible, as we probably now fix a Turtle to specific work

        -- get a Turtle
        local turtleObj = GetATurtle()

        -- return Turtle
        -- corelog.WriteToLog("Selecting Turtle "..turtleObj:getTurtleId().." as 'any Turtle'")
        return turtleObj
    end

    -- have base class Host provide the object
    return Host.getObject(self, objectLocator)
end

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

function enterprise_turtle:getClassName()
    return "enterprise_turtle"
end

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

function enterprise_turtle:reset()
    -- get Turtle's
    local turtles = self:getObjects("Turtle")
    if not turtles then corelog.Error("enterprise_turtle:reset: Failed obtaining Turtle's") return nil end

    -- reset all Turtle's
    for id, turtleObjTable in pairs(turtles) do
        -- convert to Turtle
        local turtleObj = objectFactory:create("Turtle", turtleObjTable) if not turtleObj then corelog.Error("enterprise_turtle:reset: failed converting turtle "..id.." objTable to Turtle") return nil end

        -- reset Turtle
        turtleObj:setFuelPriorityKey("")

        -- save Turtle
        local turtleLocator = enterprise_turtle:saveObject(turtleObj) if not turtleLocator then corelog.Error("enterprise_turtle:reset: failed saving turtle") return nil end
    end
end

local function GetTurtleLocator(turtleIdStr)
    --[[
        This method provides the locator of a turtle in the enterprise based on a 'turtleIdStr'.

        Return value:
            turtleLocator           - (URL) locating the turtle

        Parameters:
            turtleIdStr             + (string) id of the turtle
    --]]

    -- get resourcePath
    local objectPath = Host.GetObjectPath("Turtle", turtleIdStr)
    if not objectPath then corelog.Error("enterprise_turtle.GetTurtleLocator: Failed obtaining objectPath") return nil end

    -- get objectLocator
    local turtleLocator = enterprise_turtle:getResourceLocator(objectPath)
    if not turtleLocator then corelog.Error("enterprise_turtle.GetTurtleLocator: Failed obtaining turtleLocator") return nil end

    -- end
    return turtleLocator
end

function enterprise_turtle.GetAnyTurtleLocator()
    --[[
        This method provides a locator for any turtle (in the enterprise). The locator provided will be subsituted to the current
        turtle once it is to be used.

        Return value:
            turtleLocator       - (URL) locating any turtle

        Parameters:
    --]]

    -- end
    return GetTurtleLocator("any")
end

function enterprise_turtle:getCurrentTurtleLocator()
    --[[
        This method provides the locator of the current turtle (in enterprise_turtle).

        Return value:
            turtleLocator       - (URL) locating the current turtle

        Parameters:
    --]]

    -- check turtle
    if not turtle then corelog.Error("enterprise_turtle:getCurrentTurtleLocator: Current computer(ID="..os.getComputerID()..") not a Turtle") return end

    -- construct URL
    local currentTurtleId = os.getComputerID()
    local currentTurtleLocator = GetTurtleLocator(tostring(currentTurtleId))

    -- end
    return currentTurtleLocator
end

local function TriggerRefuelIfNeeded(turtleObj)
    -- get fuelLevels
    local turtleFuelLevel = turtle.getFuelLevel()
    local fuelLevels = enterprise_turtle.GetFuelLevels_Att()

    -- check fuelLevels
    local fuelLevel_Assignment = fuelLevels.fuelLevel_Assignment
    if turtleFuelLevel < fuelLevel_Assignment and turtleObj:getFuelPriorityKey() == "" then
        -- ensure this turtle now only starts taking new assignments with the priority key
        local priorityKey = coreutils.NewId()
        turtleObj:setFuelPriorityKey(priorityKey)
        local turtleLocator = enterprise_turtle:saveObject(turtleObj) if not turtleLocator then corelog.Error("enterprise_turtle.TriggerRefuelIfNeeded: failed saving turtle") return end

        -- prepare service call
        local refuelAmount = enterprise_energy.GetRefuelAmount_Att()
        local ingredientsItemSupplierLocator = enterprise_shop.GetShopLocator() -- ToDo: somehow get this passed into enterprise_turtle
        local wasteItemDepotLocator = turtleLocator:copy()                      -- ToDo: somehow get this passed into enterprise_turtle
        local serviceData = {
            turtleLocator                   = turtleLocator,
            fuelAmount                      = refuelAmount,
            ingredientsItemSupplierLocator  = ingredientsItemSupplierLocator,
            wasteItemDepotLocator           = wasteItemDepotLocator,

            assignmentsPriorityKey          = priorityKey,
        }
        local callback = Callback:newInstance("enterprise_turtle", "Fuel_Callback", { turtleLocator = turtleLocator, })

        -- call service
        enterprise_energy.ProvideFuelTo_ASrv(serviceData, callback)
    end
end

function enterprise_turtle.Fuel_Callback(...)
    -- get & check input from description
    local checkSuccess, turtleLocator = InputChecker.Check([[
        This callback should cleanup after enterprise_energy.ProvideFuelTo_ASrv is finished

        Return value:
                                    - (table)
                success             - (boolean) whether the callback executed successfully

        Parameters:
            callbackData            - (table) callbackData
                turtleLocator       + (URL) locator of the turtle
            serviceResults          + (table) result of service that calls back
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("enterprise_turtle.Fuel_Callback: Invalid input") return {success = false} end

    -- get Turtle
    local turtleObj = enterprise_turtle:getObject(turtleLocator) if not turtleObj then corelog.Error("enterprise_turtle.Fuel_Callback: Failed obtaining Turtle from turtleLocator="..turtleLocator:getURI()) return {success = false} end

    -- release priority key condition
    turtleObj:setFuelPriorityKey("")
    turtleLocator = enterprise_turtle:saveObject(turtleObj) if not turtleLocator then corelog.Error("enterprise_turtle.Fuel_Callback: failed saving turtle") return {success = false} end

    -- end
    return {success = true}
end

--                        _                           _   _               _
--                       (_)                         | | | |             | |
--    ___  ___ _ ____   ___  ___ ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \  __/ |   \ V /| | (_|  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/\___|_|    \_/ |_|\___\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

function enterprise_turtle.GetAssignmentForTurtle_SSrv(...)
    -- get & check input from description
    local checkSuccess, turtleLocator = InputChecker.Check([[
        This sync public service gets a new assignment for a turtle.

        Return value:
                                    - (table)
                success             - (boolean) whether the service executed successfully
                assignment          - (table) with the Assignment (nil of currently non available)

        Parameters:
            serviceData             - (table) data for this service
                turtleLocator       + (URL) locator of the turtle
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("enterprise_turtle.GetAssignmentForTurtle_SSrv: Invalid input") return {success = false} end

    -- get Turtle
    local turtleObj = enterprise_turtle:getObject(turtleLocator) if not turtleObj then corelog.Error("enterprise_turtle.GetAssignmentForTurtle_SSrv: Failed obtaining Turtle from turtleLocator="..turtleLocator:getURI()) return {success = false} end

    -- (re)fuel turtle if needed
    TriggerRefuelIfNeeded(turtleObj)

    -- look for best next assignment
    local assignmentFilter = turtleObj:getAssignmentFilter()
    local turtleId = turtleObj:getTurtleId()
    local turtleResume = turtleObj:getWorkerResume()
    local serviceResults = enterprise_assignmentboard.FindBestAssignment_SSrv({ assignmentFilter = assignmentFilter, turtleResume = turtleResume })
    -- ToDo: consider if an assignment board should determine what is best...
    if not serviceResults.success then corelog.Error("enterprise_turtle.GetAssignmentForTurtle_SSrv: FindBestAssignment_SSrv failed.") end
    local assignmentIdApplication = serviceResults.assignmentId

    -- did we find one?
    local nextAssignment = nil
    if assignmentIdApplication then
        -- apply
        enterprise_assignmentboard.ApplyToAssignment(turtleId, assignmentIdApplication)

        -- wait, maybe more turtles have applied
        os.sleep(1.25)

        -- check who gets the assignment
        nextAssignment = enterprise_assignmentboard.AssignmentSelectionProcedure(turtleId, assignmentIdApplication)
    end

    -- end
    local result = {
        success = true,
        assignment = nextAssignment,
    }
    return result
end

function enterprise_turtle.GetItemsLocations_SSrv(...)
    -- get & check input from description
    local checkSuccess, itemsLocator = InputChecker.Check([[
        This sync public service provides the current world locations of different items in an ItemDepot.

        Return value:
                                    - (table)
                success             - (boolean) whether the service executed successfully
                locations           - (table) with Location's of the different items

        Parameters:
            serviceData             - (table) data about this service
                itemsLocator        + (URL) locating the items for which to get the location
                                        (the "base" component of the URL specifies the ItemDepot that provides the items)
                                        (the "query" component of the URL specifies the items)
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("enterprise_turtle.GetItemsLocations_SSrv: Invalid input") return {success = false} end

    -- get location
    local serviceResults = enterprise_turtle.GetItemDepotLocation_SSrv({ itemDepotLocator = itemsLocator})
    if not serviceResults.success then corelog.Error("enterprise_turtle.GetItemsLocations_SSrv: failed obtaining location for ItemDepot "..itemsLocator:getURI()..".") return {success = false} end
    local location = serviceResults.location

    -- end
    return {
        success     = true,
        locations   = { location:copy() },
    }
end

function enterprise_turtle.GetItemDepotLocation_SSrv(...)
    -- get & check input from description
    local checkSuccess, itemDepotLocator = InputChecker.Check([[
        This sync public service provides the world location of an ItemDepot.

        Return value:
                                    - (table)
                success             - (boolean) whether the service executed successfully
                location            - (Location) location of the ItemDepot

        Parameters:
            serviceData             - (table) data about this service
                itemDepotLocator    + (URL) locating the ItemDepot for which to get the location
                                        (the "base" component of the URL should specify this ItemDepot enterprise)
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("enterprise_turtle.GetItemDepotLocation_SSrv: Invalid input") return {success = false} end

    -- check itemDepotLocator is for this enterprise
    if not enterprise_turtle:isLocatorFromHost(itemDepotLocator)  then corelog.Error("enterprise_turtle.GetItemDepotLocation_SSrv: Invalid itemDepotLocator (="..itemDepotLocator:getURI()..").") return {success = false} end

    -- get turtle
    local currentTurtleId = os.getComputerID()
    local turtleObj = enterprise_turtle:getObject(itemDepotLocator) if not turtleObj then corelog.Error("enterprise_turtle.GetItemDepotLocation_SSrv: Failed obtaining turtleObj from itemDepotLocator="..itemDepotLocator:getURI()) return {success = false} end
    if currentTurtleId ~= turtleObj:getTurtleId() then corelog.Error("enterprise_turtle.GetItemDepotLocation_SSrv: Getting ItemDepot location in one (id="..turtleObj:getTurtleId() ..") turtle from another (id="..currentTurtleId..") not implemented (?yet).") return {success = false} end

    -- get location
    local location = turtleObj:getLocation()

    -- end
    return {
        success     = true,
        location    = location:copy(),
    }
end

function enterprise_turtle.GetFuelLevels_Att()
    -- determine fuelLevel_Priority
    local fuelNeed_Refuel = enterprise_energy.GetFuelNeed_Refuel_Att()
    local assignmentStatistics = enterprise_assignmentboard.GetStatistics_Att()
    local maxFuelNeed_Travel = assignmentStatistics.maxFuelNeed_Travel
    local fuelLevel_Priority = fuelNeed_Refuel + maxFuelNeed_Travel

    -- determine fuelLevel_Assignment
    local maxFuelNeed_Assignment = assignmentStatistics.maxFuelNeed_Assignment
    local fuelLevel_Assignment = fuelLevel_Priority + maxFuelNeed_Assignment

    -- end
    local fuelLevels = {
        fuelLevel_Priority      = fuelLevel_Priority,
        fuelLevel_Assignment    = fuelLevel_Assignment,
    }
    return fuelLevels
end

return enterprise_turtle
