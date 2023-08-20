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

    -- *** Approach A ***

    -- prepare test: Define a simple interface
    local InterfaceA = {}
    function InterfaceA:foo()
    end

    -- prepare test: Define a class "PersonClassA" inheriting from InterfaceA
    local PersonClassA = {}
    PersonClassA.__index = PersonClassA
    setmetatable(PersonClassA, InterfaceA)  -- Make PersonClassA inherit from InterfaceA
    function PersonClassA:new(name)
        local instance  = setmetatable({}, PersonClassA)
        instance.name = name
        return instance
    end

    -- prepare test: Define a class "EmployeeClassA" inheriting from PersonClassA
    local EmployeeClassA = {}
    EmployeeClassA.__index = EmployeeClassA
    setmetatable(EmployeeClassA, PersonClassA)  -- Make EmployeeClassA inherit from PersonClassA
    function EmployeeClassA:new(name, employeeId)
        local instance  = setmetatable({}, EmployeeClassA)
        instance.name = name
        instance.employeeId = employeeId
        return instance
    end

    -- Test IsInstanceOf on approach A
    local personAObj = PersonClassA:new("Alice")
    assert(Object.IsInstanceOf(personAObj, PersonClassA), "Failed: personAObj is an instance of PersonClassA")
    assert(Object.IsInstanceOf(personAObj, InterfaceA), "Failed: personAObj is an instance of InterfaceA")
    assert(not Object.IsInstanceOf(personAObj, EmployeeClassA), "Failed: personAObj is not an instance of EmployeeClassA")

    local employeeAObj = EmployeeClassA:new("Bob", 123)
    assert(Object.IsInstanceOf(employeeAObj, EmployeeClassA), "Failed: employeeAObj is an instance of EmployeeClassA")
    assert(Object.IsInstanceOf(employeeAObj, PersonClassA), "Failed: employeeAObj is an instance of PersonClassA")
    assert(Object.IsInstanceOf(employeeAObj, InterfaceA), "Failed: employeeAObj is an instance of InterfaceA")

    -- *** Approach B ***
    -- (this approach uses a slightly different initialisation logic as approach A)

    -- prepare test: Define a simple interface
    local InterfaceB = {}
    function InterfaceB:foo()
    end

    -- prepare test: Define a class "PersonClassB" inheriting from InterfaceB
    local PersonClassB = {}
    function PersonClassB:new()
        -- set instance class info
        local instance = {}
        setmetatable(instance, self)
        self.__index = self

        -- end
        return instance
    end
    setmetatable(PersonClassB, InterfaceB)

    -- Test IsInstanceOf on approach B
    local personBObj = PersonClassB:new()
    assert(Object.IsInstanceOf(personBObj, PersonClassB), "Failed: personBObj is an instance of PersonClassB")
    assert(Object.IsInstanceOf(personBObj, InterfaceB), "Failed: personBObj is expected to be an instance of InterfaceB")

    -- cleanup test
end

return T_Object
