local T_Object = {}

local corelog = require "corelog"

local Object = require "object"

function T_Object.T_All()
    -- Object methods
    T_Object.T_IsInstanceOf()
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

function T_Object.T_IsInstanceOf()
    -- prepare test
    corelog.WriteToLog("* Object.IsInstanceOf() tests")

    -- prepare test: Define a simple interface
    local Interface = {}
    function Interface:foo()
    end

    -- prepare test: Define a class "Person" inheriting from Interface
    local Person = {}
    Person.__index = Person
    setmetatable(Person, Interface)  -- Make Person inherit from Interface
    function Person:new(name)
        local instance  = setmetatable({}, Person)
        instance.name = name
        return instance
    end

    -- prepare test: Define a class "Employee" inheriting from Person
    local Employee = {}
    Employee.__index = Employee
    setmetatable(Employee, Person)  -- Make Employee inherit from Person
    function Employee:new(name, employeeId)
        local instance  = setmetatable({}, Employee)
        instance.name = name
        instance.employeeId = employeeId
        return instance
    end

    -- Test IsInstanceOf with class and interface
    local personObj = Person:new("Alice")
    assert(Object.IsInstanceOf(personObj, Person), "Failed: personObj is an instance of Person")
    assert(Object.IsInstanceOf(personObj, Interface), "Failed: personObj is an instance of Interface")
    assert(not Object.IsInstanceOf(personObj, Employee), "Failed: personObj is not an instance of Employee")

    local employeeObj = Employee:new("Bob", 123)
    assert(Object.IsInstanceOf(employeeObj, Employee), "Failed: employeeObj is an instance of Employee")
    assert(Object.IsInstanceOf(employeeObj, Person), "Failed: employeeObj is an instance of Person")
    assert(Object.IsInstanceOf(employeeObj, Interface), "Failed: employeeObj is an instance of Interface")

    -- AnotherClass
    -- (this class uses a slightly different initialisation logic as the other ones)
    local AnotherClass = {}
    function AnotherClass:new()
        -- set instance class info
        local instance = {}
        setmetatable(instance, self)
        self.__index = self

        -- end
        return instance
    end
    setmetatable(AnotherClass, Interface)

    -- Test on AnotherClass
    local anotherObj = AnotherClass:new()
    assert(Object.IsInstanceOf(anotherObj, Interface), "Failed: anotherObj is expected to be an instance of Interface")

    -- cleanup test
end

return T_Object
