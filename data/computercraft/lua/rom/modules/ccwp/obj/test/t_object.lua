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

    -- Test HumanInterface
    assert(not Object.IsInstanceOf(HumanInterface, HumanInterface), "Failed: HumanInterface should not be any instance (even not of HumanInterface)")
    assert(HumanInterface.isSelfAware, "Failed: HumanInterface should specify isSelfAware method")
    assert(HumanInterface.getAge, "Failed: HumanInterface should specify getAge method")
    assert(HumanInterface:isSelfAware() == nil, "Failed: isSelfAware of HumanInterface should return nil (while it is "..textutils.serialise(HumanInterface:isSelfAware())..")")
    assert(HumanInterface:getAge() == nil, "Failed: getAge of HumanInterface return nil (while it is "..textutils.serialise(HumanInterface:getAge())..")")

    -- Test (IsInstanceOf with) PersonClass
    assert(Object.IsInstanceOf(PersonClass, HumanInterface), "Failed: PersonClass should be an instance of HumanInterface")
    assert(PersonClass.isSelfAware, "Failed: PersonClass should inherit isSelfAware from HumanInterface")
    assert(PersonClass.getAge, "Failed: PersonClass should inherit getAge from HumanInterface")

    -- Test (IsInstanceOf with) PersonClass instance
    local age1 = 16
    local name1 = "Alice"
    local personObj = PersonClass:new(age1, name1)
    assert(Object.IsInstanceOf(personObj, HumanInterface), "Failed: personObj should be an instance of HumanInterface")
    assert(Object.IsInstanceOf(personObj, PersonClass), "Failed: personObj should be an instance of PersonClass")
    assert(not Object.IsInstanceOf(personObj, EmployeeClass), "Failed: personObj should not be an instance of EmployeeClass")
    assert(personObj.isSelfAware, "Failed: personObj should inherit isSelfAware from PersonClass")
    assert(personObj.getAge, "Failed: personObj should inherit getAge from PersonClass")
    assert(personObj:getAge() == age1, "Failed: getAge of personObj should return "..age1.." (while it is "..textutils.serialise(personObj:getAge())..")")
    assert(personObj.name == name1, "Failed: name of personObj should be "..name1.." (while it is "..textutils.serialise(personObj.name)..")")

    -- Test (IsInstanceOf with) EmployeeClass
    assert(Object.IsInstanceOf(EmployeeClass, HumanInterface), "Failed: EmployeeClass should be an instance of HumanInterface")
    assert(Object.IsInstanceOf(EmployeeClass, PersonClass), "Failed: EmployeeClass should be an instance of PersonClass")
    assert(EmployeeClass.isSelfAware, "Failed: EmployeeClass should inherit isSelfAware from PersonClass")
    assert(EmployeeClass.getAge, "Failed: EmployeeClass should inherit getAge from PersonClass")

    -- Test (IsInstanceOf with) EmployeeClass instance
    local age2 = 50
    local name2 = "Bob"
    local employeeId1 = 123
    local employeeObj = EmployeeClass:new(age2, name2, employeeId1)
    assert(Object.IsInstanceOf(employeeObj, HumanInterface), "Failed: employeeObj should be an instance of HumanInterface")
    assert(Object.IsInstanceOf(employeeObj, PersonClass), "Failed: employeeObj should be an instance of PersonClass")
    assert(Object.IsInstanceOf(employeeObj, EmployeeClass), "Failed: employeeObj should be an instance of EmployeeClass")
    assert(employeeObj.isSelfAware, "Failed: employeeObj should inherit isSelfAware from EmployeeClass")
    assert(employeeObj.getAge, "Failed: employeeObj should inherit getAge from EmployeeClass")
    assert(employeeObj:getAge() == age2, "Failed: getAge of employeeObj should return "..age2.." (while it is "..textutils.serialise(employeeObj:getAge())..")")
    assert(employeeObj.name == name2, "Failed: name of employeeObj should be "..name2.." (while it is "..textutils.serialise(employeeObj.name)..")")
    assert(employeeObj.employeeId == employeeId1, "Failed: employeeId of employeeObj should be "..employeeId1.." (while it is "..textutils.serialise(employeeObj.employeeId)..")")

    -- cleanup test
end

function T_Object.T_IsInstanceOf_A()
    --[[
        *** Approach A ***
    ]]

    -- prepare test: Define a simple interface
    local HumanInterface = {}
    HumanInterface.__index = HumanInterface

    function HumanInterface:isSelfAware()
    end

    function HumanInterface:getAge()
    end

    -- prepare test: Define a class "PersonClass" inheriting from HumanInterface
    local PersonClass = {}
    PersonClass.__index = PersonClass
    setmetatable(PersonClass, HumanInterface)  -- Make PersonClass inherit from HumanInterface

    function PersonClass:new(age, name)
        -- set instance class info
        local instance = setmetatable({}, PersonClass)

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
    --[[
        *** Approach B ***

        This approach uses relative to approach A:
        - slightly different initialisation logic
    ]]

    -- prepare test: Define a simple interface
    local HumanInterface = {}
    HumanInterface.__index = HumanInterface

    function HumanInterface:getAge()
    end

    function HumanInterface:isSelfAware()
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
    --[[
        *** Approach C ***`

        This approach uses relative to approach B:
        -   a init method for initialisation
        -   the new method for inheriting from a super class (in EmployeeClass)
    ]]

    -- prepare test: Define a simple interface
    local HumanInterface = {}
    HumanInterface.__index = HumanInterface

    function HumanInterface:isSelfAware()
    end

    function HumanInterface:getAge()
    end

    -- prepare test: Define a class "PersonClass" inheriting from HumanInterface
    local PersonClass = {}
    setmetatable(PersonClass, HumanInterface) -- Make PersonClass inherit from HumanInterface

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
    local EmployeeClass = PersonClass:new() -- Make EmployeeClass inherit from HumanInterface

    function EmployeeClass:_init(age, name, employeeId) -- note: "overrides" PersonClass:__init
        -- initialisation
        PersonClass:_init(age, name) -- note: call PersonClass __init directly
        self.employeeId = employeeId
    end

    -- Test IsInstanceOf
    T_Object.at_IsInstanceOf("C", HumanInterface, PersonClass, EmployeeClass)

    -- cleanup test
end

return T_Object
