local T_Object = {}

local corelog = require "corelog"

local Object = require "object"

function T_Object.T_All()
    -- Object methods
    T_Object.T_IsInstanceOf_A()
    T_Object.T_IsInstanceOf_B()
end

--     ____  _     _           _
--    / __ \| |   (_)         | |
--   | |  | | |__  _  ___  ___| |_
--   | |  | | '_ \| |/ _ \/ __| __|
--   | |__| | |_) | |  __/ (__| |_
--    \____/|_.__/| |\___|\___|\__|
--               _/ |
--              |__/

function T_Object.pt_IsInstanceOf(className, object, prototypeName, prototype)
    -- prepare test
    assert(className, "no className provided")
    assert(object, "no object provided")
    assert(prototypeName, "no prototypeName provided")
    assert(prototype, "no prototype provided")
    corelog.WriteToLog("* "..className.." IsInstanceOf "..prototypeName.." type test")

    -- test
    assert(Object.IsInstanceOf(object, prototype), "Failed: object is expected to be an instance of "..prototypeName)
end


function T_Object.at_IsInstanceOf(approachName, HumanInterface, PersonClass, EmployeeClass)
    -- prepare test (cont)
    corelog.WriteToLog("* Object.IsInstanceOf() tests (approach "..approachName..")")

    -- Test IsInstanceOf on PersonClass
    local personObj = PersonClass:new("Alice")
    assert(Object.IsInstanceOf(personObj, PersonClass), "Failed: personObj should be an instance of PersonClass")
    assert(Object.IsInstanceOf(personObj, HumanInterface), "Failed: personObj should be an instance of HumanInterface")
    assert(not Object.IsInstanceOf(personObj, EmployeeClass), "Failed: personObj should not be an instance of EmployeeClass")

    -- Test IsInstanceOf on EmployeeClass
    local employeeObj = EmployeeClass:new("Bob", 123)
    assert(Object.IsInstanceOf(employeeObj, EmployeeClass), "Failed: employeeObj should be an instance of EmployeeClass")
    assert(Object.IsInstanceOf(employeeObj, HumanInterface), "Failed: employeeObj should be an instance of HumanInterface")
    assert(Object.IsInstanceOf(employeeObj, PersonClass), "Failed: employeeObj should be an instance of PersonClass")

    -- cleanup test
end

function T_Object.T_IsInstanceOf_A()
    -- *** Approach A ***

    -- prepare test: Define a simple interface
    local HumanInterface = {}
    function HumanInterface:isSelfAware()
    end

    -- prepare test: Define a class "PersonClass" inheriting from HumanInterface
    local PersonClass = {}
    PersonClass.__index = PersonClass
    setmetatable(PersonClass, HumanInterface)  -- Make PersonClass inherit from HumanInterface
    function PersonClass:new(name)
        local instance  = setmetatable({}, PersonClass)
        instance.name = name
        return instance
    end

    -- prepare test: Define a class "EmployeeClass" inheriting from PersonClass
    local EmployeeClass = {}
    EmployeeClass.__index = EmployeeClass
    setmetatable(EmployeeClass, PersonClass)  -- Make EmployeeClass inherit from PersonClass
    function EmployeeClass:new(name, employeeId)
        local instance  = setmetatable({}, EmployeeClass)
        instance.name = name
        instance.employeeId = employeeId
        return instance
    end

    -- Test IsInstanceOf
    T_Object.at_IsInstanceOf("A", HumanInterface, PersonClass, EmployeeClass)

    -- cleanup test
end

function T_Object.T_IsInstanceOf_B()
    -- *** Approach B ***
    -- (this approach uses a slightly different initialisation logic as approach A)

    -- prepare test: Define a simple interface
    local HumanInterface = {}
    function HumanInterface:isSelfAware()
    end

    -- prepare test: Define a class "PersonClass" inheriting from HumanInterface
    local PersonClass = {}
    function PersonClass:new()
        -- set instance class info
        local instance = {}
        setmetatable(instance, self)
        self.__index = self

        -- end
        return instance
    end
    setmetatable(PersonClass, HumanInterface)

    -- prepare test: Define a class "EmployeeClass" inheriting from PersonClass
    local EmployeeClass = {}
    function EmployeeClass:new()
        -- set instance class info
        local instance = {}
        setmetatable(instance, self)
        self.__index = self

        -- end
        return instance
    end
    setmetatable(EmployeeClass, PersonClass)

    -- Test IsInstanceOf
    T_Object.at_IsInstanceOf("B", HumanInterface, PersonClass, EmployeeClass)

    -- cleanup test
end

return T_Object
