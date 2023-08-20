local T_Object = {}

local corelog = require "corelog"

local Object = require "object"

function T_Object.T_All()
    -- Object methods
    T_Object.T_IsInstanceOf_A()
    T_Object.T_IsInstanceOf_B()
    T_Object.T_IsInstanceOf_C()
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
    assert(approachName, "no approachName provided")
    assert(HumanInterface, "no HumanInterface provided")
    assert(PersonClass, "no PersonClass provided")
    assert(EmployeeClass, "no EmployeeClass provided")

    -- prepare test (cont)
    corelog.WriteToLog("* Object.IsInstanceOf() tests (approach "..approachName..")")

    -- Test IsInstanceOf on HumanInterface
    assert(HumanInterface:getAge() == nil, "Failed: getAge of personObj should return nil (while it is "..textutils.serialise(HumanInterface:getAge())..")")

    -- Test IsInstanceOf on PersonClass
    local age1 = 16
    local name1 = "Alice"
    local personObj = PersonClass:new(age1, name1)
    assert(Object.IsInstanceOf(personObj, HumanInterface), "Failed: personObj should be an instance of HumanInterface")
    assert(personObj:getAge() == age1, "Failed: getAge of personObj should return "..age1.." (while it is "..textutils.serialise(personObj:getAge())..")")
    assert(Object.IsInstanceOf(personObj, PersonClass), "Failed: personObj should be an instance of PersonClass")
    assert(personObj.name == name1, "Failed: name of personObj should be "..name1.." (while it is "..textutils.serialise(personObj.name)..")")
    assert(not Object.IsInstanceOf(personObj, EmployeeClass), "Failed: personObj should not be an instance of EmployeeClass")

    -- Test IsInstanceOf on EmployeeClass
    local age2 = 50
    local name2 = "Bob"
    local employeeId1 = 123
    local employeeObj = EmployeeClass:new(age2, name2, employeeId1)
    assert(Object.IsInstanceOf(employeeObj, HumanInterface), "Failed: employeeObj should be an instance of HumanInterface")
    assert(employeeObj:getAge() == age2, "Failed: getAge of employeeObj should return "..age2.." (while it is "..textutils.serialise(employeeObj:getAge())..")")
    assert(Object.IsInstanceOf(employeeObj, PersonClass), "Failed: employeeObj should be an instance of PersonClass")
    assert(employeeObj.name == name2, "Failed: name of employeeObj should be "..name2.." (while it is "..textutils.serialise(employeeObj.name)..")")
    assert(Object.IsInstanceOf(employeeObj, EmployeeClass), "Failed: employeeObj should be an instance of EmployeeClass")
    assert(employeeObj.employeeId == employeeId1, "Failed: employeeId of employeeObj should be "..employeeId1.." (while it is "..textutils.serialise(employeeObj.employeeId)..")")

    -- cleanup test
end

function T_Object.T_IsInstanceOf_A()
    -- *** Approach A ***

    -- prepare test: Define a simple interface
    local HumanInterface = {}
    function HumanInterface:getAge()
    end

    -- prepare test: Define a class "PersonClass" inheriting from HumanInterface
    local PersonClass = {}
    PersonClass.__index = PersonClass
    setmetatable(PersonClass, HumanInterface)  -- Make PersonClass inherit from HumanInterface

    function PersonClass:new(age, name)
        -- set instance class info
        local instance  = setmetatable({}, PersonClass)

        -- initialisation
        instance.age = age
        instance.name = name

        -- end
        return instance
    end

    function PersonClass:getAge()
        return self.age
    end

    -- prepare test: Define a class "EmployeeClass" inheriting from PersonClass
    local EmployeeClass = {}
    EmployeeClass.__index = EmployeeClass
    setmetatable(EmployeeClass, PersonClass)  -- Make EmployeeClass inherit from PersonClass

    function EmployeeClass:new(age, name, employeeId)
        -- set instance class info
        local instance = setmetatable({}, EmployeeClass)

        -- initialisation
        instance.age = age
        instance.name = name
        instance.employeeId = employeeId

        -- end
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
    function HumanInterface:getAge()
    end

    -- prepare test: Define a class "PersonClass" inheriting from HumanInterface
    local PersonClass = {}
    setmetatable(PersonClass, HumanInterface)

    function PersonClass:new(age, name)
        -- set instance class info
        local instance = {}
        setmetatable(instance, self)
        self.__index = self

        -- initialisation
        instance.age = age
        instance.name = name

        -- end
        return instance
    end

    function PersonClass:getAge()
        return self.age
    end

    -- prepare test: Define a class "EmployeeClass" inheriting from PersonClass
    local EmployeeClass = {}
    setmetatable(EmployeeClass, PersonClass)

    function EmployeeClass:new(age, name, employeeId)
        -- set instance class info
        local instance = {}
        setmetatable(instance, self)
        self.__index = self

        -- initialisation
        instance.age = age
        instance.name = name
        instance.employeeId = employeeId

        -- end
        return instance
    end

    -- Test IsInstanceOf
    T_Object.at_IsInstanceOf("B", HumanInterface, PersonClass, EmployeeClass)

    -- cleanup test
end

function T_Object.T_IsInstanceOf_C()
    -- *** Approach C ***
    -- (this approach uses relative to approach B
    --  -   a init method for initialisation
    --  -   the new method for inheriting from a super class (in EmployeeClass)

    -- prepare test: Define a simple interface
    local HumanInterface = {}
    function HumanInterface:getAge()
    end

    -- prepare test: Define a class "PersonClass" inheriting from HumanInterface
    local PersonClass = {}
    setmetatable(PersonClass, HumanInterface)

    function PersonClass:new(...)
        -- set instance class info
        local instance = {}
        setmetatable(instance, self)
        self.__index = self

        -- initialisation
        if ... then
            instance:_init(...)
        end

        -- end
        return instance
    end

    function PersonClass:_init(age, name)
        self.age = age
        self.name = name
    end

    function PersonClass:getAge()
        return self.age
    end

    -- prepare test: Define a class "EmployeeClass" inheriting from PersonClass
    local EmployeeClass = PersonClass:new()

    function EmployeeClass:_init(age, name, employeeId) -- note: "overrides" PersonClass:__init
        -- initialisation
        PersonClass:_init(age, name) -- note: call PersonClass __init directly
        self.employeeId = employeeId
    end

    -- Test IsInstanceOf
    T_Object.at_IsInstanceOf("with __call to initialise", HumanInterface, PersonClass, EmployeeClass)

    -- cleanup test
end

return T_Object
