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


function T_Object.at_IsInstanceOf(approachName, Interface, PersonClass, EmployeeClass)
    -- prepare test (cont)
    corelog.WriteToLog("* Object.IsInstanceOf() tests (approach "..approachName..")")

    -- Test IsInstanceOf on approach A
    local personObj = PersonClass:new("Alice")
    assert(Object.IsInstanceOf(personObj, PersonClass), "Failed: personObj is an instance of PersonClass")
    assert(Object.IsInstanceOf(personObj, Interface), "Failed: personObj is an instance of Interface")
    assert(not Object.IsInstanceOf(personObj, EmployeeClass), "Failed: personObj is not an instance of EmployeeClass")

    local employeeObj = EmployeeClass:new("Bob", 123)
    assert(Object.IsInstanceOf(employeeObj, EmployeeClass), "Failed: employeeObj is an instance of EmployeeClass")
    assert(Object.IsInstanceOf(employeeObj, PersonClass), "Failed: employeeObj is an instance of PersonClass")
    assert(Object.IsInstanceOf(employeeObj, Interface), "Failed: employeeObj is an instance of Interface")

    -- cleanup test
end


function T_Object.T_IsInstanceOf_A()
    -- *** Approach A ***

    -- prepare test: Define a simple interface
    local Interface = {}
    function Interface:foo()
    end

    -- prepare test: Define a class "PersonClass" inheriting from Interface
    local PersonClass = {}
    PersonClass.__index = PersonClass
    setmetatable(PersonClass, Interface)  -- Make PersonClass inherit from Interface
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
    T_Object.at_IsInstanceOf("A", Interface, PersonClass, EmployeeClass)

    -- cleanup test
end

function T_Object.T_IsInstanceOf_B()
    -- *** Approach B ***
    -- (this approach uses a slightly different initialisation logic as approach A)

    -- prepare test: Define a simple interface
    local Interface = {}
    function Interface:foo()
    end

    -- prepare test: Define a class "PersonClass" inheriting from Interface
    local PersonClass = {}
    function PersonClass:new()
        -- set instance class info
        local instance = {}
        setmetatable(instance, self)
        self.__index = self

        -- end
        return instance
    end
    setmetatable(PersonClass, Interface)

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
    T_Object.at_IsInstanceOf("B", Interface, PersonClass, EmployeeClass)

    -- cleanup test
end

return T_Object
