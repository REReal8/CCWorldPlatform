-- define class
local Class = require "class"
local MObjHost = require "mobj_host"
local IRegistry = require "i_registry"
local enterprise_employment = Class.NewClass(MObjHost, IRegistry)

--[[
    The enterprise_employment is a MObjHost. It hosts Worker's that can perform work (i.e. assignments).
--]]

local coreutils = require "coreutils"
local corelog = require "corelog"
local coremove = require "coremove"

local Callback = require "obj_callback"
local InputChecker = require "input_checker"
local ObjectFactory = require "object_factory"
local objectFactory = ObjectFactory:getInstance()
local ObjHost = require "obj_host"
local ObjTable = require "obj_table"
local URL = require "obj_url"
local Location  = require "obj_location"

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
enterprise_employment._hostName   = "enterprise_employment"

local function GetATurtle()
    -- get all Turtles
    local turtles = enterprise_employment:getObjects(Turtle:getClassName())
    if not turtles then corelog.Error("enterprise_employment:GetATurtle: Failed obtaining Turtle's") return nil end

    -- select first Turtle
    -- ToDo: consider selecting a free Turtle (also based on some criteria) (maybe do this via assignments?)
    local _, turtleObjTable = next(turtles) -- first Turtle
    if not turtleObjTable then corelog.Error("enterprise_employment:GetATurtle: Failed obtaining a Turtle") return nil end
    local turtleObj = objectFactory:create("Turtle", turtleObjTable) if not turtleObj then corelog.Error("enterprise_employment:GetATurtle: failed converting turtle objTable to Turtle") return nil end

    -- end
    return turtleObj
end

function enterprise_employment:getObject(...)
    -- get & check input from description
    local checkSuccess, objectLocator = InputChecker.Check([[
        This method retrieves an object from the ObjHost using a URL (that was once provided by the ObjHost).

        Return value:
            object                  - (?) object obtained from the ObjHost

        Parameters:
            objectLocator           + (URL) locator of the object within the ObjHost
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("enterprise_employment:getObject: Invalid input") return nil end

    -- check for "any turtle"
    if objectLocator:sameBase(enterprise_employment.GetAnyTurtleLocator()) then
        -- ToDo: consider adjusting calling code/ project logic to select a specific Turtle as late as possible, as we probably now fix a Turtle to specific work

        -- get a Turtle
        local turtleObj = GetATurtle()

        -- return Turtle
        -- corelog.WriteToLog("Selecting Turtle "..turtleObj:getWorkerId().." as 'any Turtle'")
        return turtleObj
    end

    -- have base class ObjHost provide the object
    return ObjHost.getObject(self, objectLocator)
end

--    _____ ____  _     _
--   |_   _/ __ \| |   (_)
--     | || |  | | |__  _
--     | || |  | | '_ \| |
--    _| || |__| | |_) | |
--   |_____\____/|_.__/| |
--                    _/ |
--                   |__/

function enterprise_employment:getClassName()
    return "enterprise_employment"
end

--                       _             _                     _
--                      | |           | |                   | |
--   __      _____  _ __| | _____ _ __| |     ___   ___ __ _| |_ ___  _ __
--   \ \ /\ / / _ \| '__| |/ / _ \ '__| |    / _ \ / __/ _` | __/ _ \| '__|
--    \ V  V / (_) | |  |   <  __/ |  | |___| (_) | (_| (_| | || (_) | |
--     \_/\_/ \___/|_|  |_|\_\___|_|  |______\___/ \___\__,_|\__\___/|_|

local function GetWorkLocatorsPath()
    return ObjHost.GetObjectPath(ObjTable:getClassName(), "workerLocators")
end

local function GetWorkerLocators(employmentHost)
    -- get workerLocatorsLocator
    local workerLocatorsPath = GetWorkLocatorsPath()
    local workerLocatorsLocator = employmentHost:getResourceLocator(workerLocatorsPath)
    if not workerLocatorsLocator then corelog.Error("enterprise_employment.GetWorkerLocators: Failed obtaining workerLocatorsLocator") return nil end

    -- get workerLocators
    local workerLocatorsTable = employmentHost:getResource(workerLocatorsLocator)
    if not workerLocatorsTable then
        corelog.WriteToLog("enterprise_employment.GetWorkerLocators: Creating new workerLocatorsTable")

        -- (re)set workerLocators
        local workerLocators = ObjTable:newInstance(URL:getClassName())
        employmentHost:saveResource(workerLocators, workerLocatorsPath)

        -- retrieve again
        workerLocatorsTable = employmentHost:getResource(workerLocatorsLocator)
        if not workerLocatorsTable then corelog.Error("enterprise_employment.GetWorkerLocators: Failed (re)setting workerLocators") return nil end
    end

    -- convert to ObjTable
    local workerLocators = ObjTable:new(workerLocatorsTable)
    if not workerLocators then corelog.Error("enterprise_employment.GetWorkerLocators: failed converting workerLocatorsTable(="..textutils.serialise(workerLocatorsTable)..") to ObjTable object for workerLocatorsLocator="..workerLocatorsLocator:getURI()) return nil end

    -- end
    return workerLocators
end

local function SaveWorkerLocators(employmentHost, workerLocators)
    -- get workerLocatorsLocator
    local workerLocatorsPath = GetWorkLocatorsPath()

    -- save workerLocators
    local workerLocatorsLocator = employmentHost:saveResource(workerLocators, workerLocatorsPath)

    -- end
    return workerLocatorsLocator
end

function enterprise_employment:getRegistered(...)
    -- get & check input from description
    local checkSuccess, workerId = InputChecker.Check([[
        This method provides the locator of a Worker 'workerId'.

        Return value:
            workerLocator       - (URL) locating the Worker

        Parameters:
            workerId            + (number) workerId of the Worker
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("enterprise_employment:getRegistered: Invalid input") return nil end

    -- get workerLocators
    local workerLocators = GetWorkerLocators(self)
    if not workerLocators then corelog.Error("enterprise_employment:getRegistered: Failed obtaining workerLocators") return nil end

    -- get workerLocator
    for workerKey, aWorkerLocator in workerLocators:objs() do
        if workerKey == workerId then
            return aWorkerLocator
        end
    end

    -- end
    corelog.Warning("enterprise_employment:getRegistered: workerLocator for Worker "..workerId.." not found")
    return nil
end

function enterprise_employment:register(...)
    -- get & check input from description
    local checkSuccess, workerId, theWorkerLocator = InputChecker.Check([[
        This method registers the locator of a Worker 'workerId' in enterprise_employment.

        Note that the Worker itself should already be available in the world/ hosted by enterprise_employment.

        Return value:
                                    - (boolean) whether the method executed successfully

        Parameters:
            workerId                + (number) workerId of the Worker
            workerLocator           + (URL) locating the Worker
    --]], table.unpack(arg))
    if not checkSuccess then corelog.Error("enterprise_employment:register: Invalid input") return false end

    -- get workerLocators
    local workerLocators = GetWorkerLocators(self)
    if not workerLocators then corelog.Error("enterprise_employment:register: Failed obtaining workerLocators") return false end

    -- register the Worker
    corelog.WriteToLog(">Registering Worker (workerId="..workerId..", workerLocator="..theWorkerLocator:getURI()..")")
    workerLocators[workerId] = theWorkerLocator

    -- save workerLocators
    local workerLocatorsLocator = SaveWorkerLocators(self, workerLocators)
    if not workerLocatorsLocator then corelog.Error("enterprise_employment:register: Failed saving workerLocators") return false end

    -- end
    return true
end

function enterprise_employment:isRegistered(...)
    -- get & check input from description
    local checkSuccess, workerId = InputChecker.Check([[
        This method returns if a locator of a Worker 'workerId' is registered enterprise_employment.

        Return value:
                                    - (boolean) whether a locator is registered by 'workerId'

        Parameters:
            workerId                + (number) workerId of the Worker
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("enterprise_employment:isRegistered: Invalid input") return false end

    -- get workerLocators
    local workerLocators = GetWorkerLocators(self)
    if not workerLocators then corelog.Error("enterprise_employment:isRegistered: Failed obtaining workerLocators") return false end

    -- check if registered
    local isRegistered = workerLocators[workerId] ~= nil

    -- end
    return isRegistered
end

function enterprise_employment:delist(...)
    -- get & check input from description
    local checkSuccess, workerId = InputChecker.Check([[
        This method delists the locator of a Worker 'workerId' from enterprise_employment.

        Note that the Worker is not removed from the world/ released from enterprise_employment.

        Return value:
                                    - (boolean) whether the method executed successfully

        Parameters:
            workerId                + (number) workerId of the Worker
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("enterprise_employment:delist: Invalid input") return false end

    -- get workerLocators
    local workerLocators = GetWorkerLocators(self)
    if not workerLocators then corelog.Error("enterprise_employment:delist: Failed obtaining workerLocators") return false end

    -- get Workers
    for registeredWorkedId, _ in pairs(workerLocators) do
        -- check we found it
        if registeredWorkedId == workerId then
            -- remove from list
            corelog.WriteToLog(">Delisting Worker "..registeredWorkedId.." from enterprise_employment")
            workerLocators[registeredWorkedId] = nil

            -- save workerLocators
            local workerLocatorsLocator = SaveWorkerLocators(self, workerLocators)
            if not workerLocatorsLocator then corelog.Error("enterprise_employment:delist: Failed saving workerLocators") return false end

            -- found and delisted it!
            return true
        end
    end

    -- end
    return false -- did not find it!
end

function enterprise_employment:getCurrentWorkerLocator()
    --[[
        This method provides the locator of the current Worker (in enterprise_employment).

        Return value:
            workerLocator       - (URL) locating the current Worker

        Parameters:
    --]]

    -- get current workerLocator
    local workerId = os.getComputerID()
    -- local currentWorkerLocator = GetTurtleLocator(tostring(workerId))
    local currentWorkerLocator = self:getRegistered(workerId)
    if not currentWorkerLocator then
        -- check if this is the first turtle
        if turtle and self:getNumberOfObjects("Turtle") == 0 then
            corelog.WriteToLog("This seems to be the first Turtle, we will make an exception and host and register it")
            -- note:    in all other cases we want the programmic logic that created the Worker to also host and register it in enterprise_employment,
            --          however for the first one this is a bit hard. Hence we do it here as an exception to this special case.

            -- host the first Turtle
            local coremove_location = Location:new(coremove.GetLocation())
            currentWorkerLocator = self:hostMObj_SSrv({ className = "Turtle", constructParameters = {
                workerId    = workerId,
                location    = coremove_location,
            }}).mobjLocator
            if not currentWorkerLocator then corelog.Error("enterprise_employment:getCurrentWorkerLocator: Failed hosting 1st Turtle "..workerId) return nil end

            -- register this first Turtle
            local registered = self:register(workerId, currentWorkerLocator)
            if not registered then corelog.Error("enterprise_employment:getCurrentWorkerLocator: Failed registering 1st Turtle "..workerId) return nil end
        end
    end
    if not currentWorkerLocator then corelog.Warning("enterprise_employment:getCurrentWorkerLocator: workerLocator for (current) Worker "..workerId.." not found") return nil end

    -- end
    return currentWorkerLocator:copy()
end

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

function enterprise_employment:reset()
    -- get Turtle's
    local turtles = self:getObjects("Turtle")
    if not turtles then corelog.Error("enterprise_employment:reset: Failed obtaining Turtle's") return nil end

    -- reset all Turtle's
    for id, turtleObjTable in pairs(turtles) do
        -- convert to Turtle
        local turtleObj = objectFactory:create("Turtle", turtleObjTable) if not turtleObj then corelog.Error("enterprise_employment:reset: failed converting turtle "..id.." objTable to Turtle") return nil end

        -- reset Turtle
        turtleObj:setFuelPriorityKey("")

        -- save Turtle
        local turtleLocator = enterprise_employment:saveObject(turtleObj) if not turtleLocator then corelog.Error("enterprise_employment:reset: failed saving turtle") return nil end
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
    local objectPath = ObjHost.GetObjectPath("Turtle", turtleIdStr)
    if not objectPath then corelog.Error("enterprise_employment.GetTurtleLocator: Failed obtaining objectPath") return nil end

    -- get objectLocator
    local turtleLocator = enterprise_employment:getResourceLocator(objectPath)
    if not turtleLocator then corelog.Error("enterprise_employment.GetTurtleLocator: Failed obtaining turtleLocator") return nil end

    -- end
    return turtleLocator
end

function enterprise_employment.GetAnyTurtleLocator()
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

function enterprise_employment:triggerTurtleRefuelIfNeeded(turtleObj)
    -- get fuelLevels
    local turtleFuelLevel = turtle.getFuelLevel()
    local fuelLevels = self.GetFuelLevels_Att()

    -- check fuelLevels
    local fuelLevel_Assignment = fuelLevels.fuelLevel_Assignment
    if turtleFuelLevel < fuelLevel_Assignment and turtleObj:getFuelPriorityKey() == "" then
        -- ensure this turtle now only starts taking new assignments with the priority key
        local priorityKey = coreutils.NewId()
        turtleObj:setFuelPriorityKey(priorityKey)
        local turtleLocator = self:saveObject(turtleObj) if not turtleLocator then corelog.Error("enterprise_employment:triggerTurtleRefuelIfNeeded: failed saving turtle") return end

        -- prepare service call
        local refuelAmount = enterprise_energy.GetRefuelAmount_Att()
        local ingredientsItemSupplierLocator = enterprise_shop.GetShopLocator() -- ToDo: somehow get this passed into enterprise_employment
        local wasteItemDepotLocator = turtleLocator:copy()                      -- ToDo: somehow get this passed into enterprise_employment
        local serviceData = {
            turtleLocator                   = turtleLocator,
            fuelAmount                      = refuelAmount,
            ingredientsItemSupplierLocator  = ingredientsItemSupplierLocator,
            wasteItemDepotLocator           = wasteItemDepotLocator,

            assignmentsPriorityKey          = priorityKey,
        }
        local callback = Callback:newInstance("enterprise_employment", "Fuel_Callback", { turtleLocator = turtleLocator, })

        -- call service
        enterprise_energy.ProvideFuelTo_ASrv(serviceData, callback)
    end
end

function enterprise_employment.Fuel_Callback(...)
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
    if not checkSuccess then corelog.Error("enterprise_employment.Fuel_Callback: Invalid input") return {success = false} end

    -- get Turtle
    local turtleObj = enterprise_employment:getObject(turtleLocator) if not turtleObj then corelog.Error("enterprise_employment.Fuel_Callback: Failed obtaining Turtle from turtleLocator="..turtleLocator:getURI()) return {success = false} end

    -- release priority key condition
    turtleObj:setFuelPriorityKey("")
    turtleLocator = enterprise_employment:saveObject(turtleObj) if not turtleLocator then corelog.Error("enterprise_employment.Fuel_Callback: failed saving turtle") return {success = false} end

    -- end
    return {success = true}
end

--                        _
--                       (_)
--    ___  ___ _ ____   ___  ___ ___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \
--   \__ \  __/ |   \ V /| | (_|  __/
--   |___/\___|_|    \_/ |_|\___\___|

function enterprise_employment.GetItemsLocations_SSrv(...)
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
    if not checkSuccess then corelog.Error("enterprise_employment.GetItemsLocations_SSrv: Invalid input") return {success = false} end

    -- get location
    local serviceResults = enterprise_employment.GetItemDepotLocation_SSrv({ itemDepotLocator = itemsLocator})
    if not serviceResults.success then corelog.Error("enterprise_employment.GetItemsLocations_SSrv: failed obtaining location for ItemDepot "..itemsLocator:getURI()..".") return {success = false} end
    local location = serviceResults.location

    -- end
    return {
        success     = true,
        locations   = { location:copy() },
    }
end

function enterprise_employment.GetItemDepotLocation_SSrv(...)
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
    if not checkSuccess then corelog.Error("enterprise_employment.GetItemDepotLocation_SSrv: Invalid input") return {success = false} end

    -- check itemDepotLocator is for this enterprise
    if not enterprise_employment:isLocatorFromHost(itemDepotLocator)  then corelog.Error("enterprise_employment.GetItemDepotLocation_SSrv: Invalid itemDepotLocator (="..itemDepotLocator:getURI()..").") return {success = false} end

    -- get turtle
    local currentTurtleId = os.getComputerID()
    local turtleObj = enterprise_employment:getObject(itemDepotLocator) if not turtleObj then corelog.Error("enterprise_employment.GetItemDepotLocation_SSrv: Failed obtaining turtleObj from itemDepotLocator="..itemDepotLocator:getURI()) return {success = false} end
    if currentTurtleId ~= turtleObj:getWorkerId() then corelog.Error("enterprise_employment.GetItemDepotLocation_SSrv: Getting ItemDepot location in one (id="..turtleObj:getWorkerId() ..") turtle from another (id="..currentTurtleId..") not implemented (?yet).") return {success = false} end

    -- get location
    local location = turtleObj:getLocation()

    -- end
    return {
        success     = true,
        location    = location:copy(),
    }
end

function enterprise_employment.GetFuelLevels_Att()
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

return enterprise_employment
