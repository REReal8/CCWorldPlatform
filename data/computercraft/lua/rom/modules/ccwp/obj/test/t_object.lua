local T_Object = {}

local corelog = require "corelog"

local Object = require "object"

function T_Object.T_All()
    -- Object methods
    T_Object.T_IsInstanceOf_A()
    T_Object.T_IsInstanceOf_B()
    T_Object.T_IsInstanceOf_C()
    T_Object.T_IsInstanceOf_D()
    T_Object.T_IsInstanceOf_Mixin_ccwp()
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

function T_Object.at_IsInstanceOf(approachName, IHuman, PersonClass, EmployeeClass)
    assert(approachName, "no approachName provided")
    assert(IHuman, "no IHuman provided")
    assert(PersonClass, "no PersonClass provided")
    assert(EmployeeClass, "no EmployeeClass provided")

    -- prepare test (cont)
    corelog.WriteToLog("* Object.IsInstanceOf() tests (approach "..approachName..")")

    -- Test IHuman
    assert(not Object.IsInstanceOf(IHuman, IHuman), "Failed: IHuman should not be any instance (even not of IHuman)")
    assert(IHuman.isSelfAware, "Failed: IHuman should specify isSelfAware method")
    assert(IHuman.getAge, "Failed: IHuman should specify getAge method")
    assert(IHuman:isSelfAware() == nil, "Failed: isSelfAware of IHuman should return nil (while it is "..textutils.serialise(IHuman:isSelfAware())..")")
    assert(IHuman:getAge() == nil, "Failed: getAge of IHuman return nil (while it is "..textutils.serialise(IHuman:getAge())..")")

    -- Test (IsInstanceOf with) PersonClass
    assert(Object.IsInstanceOf(PersonClass, IHuman), "Failed: PersonClass should be an instance of IHuman")
    assert(PersonClass.isSelfAware, "Failed: PersonClass should inherit isSelfAware from IHuman")
    assert(PersonClass.getAge, "Failed: PersonClass should inherit getAge from IHuman")

    -- Test (IsInstanceOf with) PersonClass instance
    local age1 = 16
    local name1 = "Alice"
    local personObj = PersonClass:newInstance(age1, name1) assert(personObj, "Failed creating personObj")
    assert(Object.IsInstanceOf(personObj, IHuman), "Failed: personObj should be an instance of IHuman")
    assert(Object.IsInstanceOf(personObj, PersonClass), "Failed: personObj should be an instance of PersonClass")
    assert(not Object.IsInstanceOf(personObj, EmployeeClass), "Failed: personObj should not be an instance of EmployeeClass")
    assert(personObj.isSelfAware, "Failed: personObj should inherit isSelfAware from PersonClass")
    assert(personObj.getAge, "Failed: personObj should inherit getAge from PersonClass")
    assert(personObj:getAge() == age1, "Failed: getAge of personObj should return "..age1.." (while it is "..textutils.serialise(personObj:getAge())..")")
    assert(personObj.name == name1, "Failed: name of personObj should be "..name1.." (while it is "..textutils.serialise(personObj.name)..")")

    -- Test (IsInstanceOf with) EmployeeClass
    assert(Object.IsInstanceOf(EmployeeClass, IHuman), "Failed: EmployeeClass should be an instance of IHuman")
    assert(Object.IsInstanceOf(EmployeeClass, PersonClass), "Failed: EmployeeClass should be an instance of PersonClass")
    assert(EmployeeClass.isSelfAware, "Failed: EmployeeClass should inherit isSelfAware from PersonClass")
    assert(EmployeeClass.getAge, "Failed: EmployeeClass should inherit getAge from PersonClass")

    -- Test (IsInstanceOf with) EmployeeClass instance
    local age2 = 50
    local name2 = "Bob"
    local employeeId1 = 123
    local employeeObj = EmployeeClass:newInstance(age2, name2, employeeId1) assert(employeeObj, "Failed creating employeeObj")
    assert(Object.IsInstanceOf(employeeObj, IHuman), "Failed: employeeObj should be an instance of IHuman")
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
    local IHuman = {}
    IHuman.__index = IHuman

    function IHuman:isSelfAware()
    end

    function IHuman:getAge()
    end

    -- prepare test: Define a class "PersonClass" inheriting from IHuman
    local PersonClass = {}
    PersonClass.__index = PersonClass
    setmetatable(PersonClass, IHuman)  -- Make PersonClass inherit from IHuman

    function PersonClass:newInstance(age, name)
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

    function EmployeeClass:newInstance(age, name, employeeId)
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
    T_Object.at_IsInstanceOf("A", IHuman, PersonClass, EmployeeClass)

    -- cleanup test
end

function T_Object.T_IsInstanceOf_B()
    --[[
        *** Approach B ***

        This approach uses relative to approach A:
        - slightly different initialisation logic
    ]]

    -- prepare test: Define a simple interface
    local IHuman = {}
    IHuman.__index = IHuman

    function IHuman:getAge()
    end

    function IHuman:isSelfAware()
    end

    -- prepare test: Define a class "PersonClass" inheriting from IHuman
    local PersonClass = {}
    setmetatable(PersonClass, IHuman)

    function PersonClass:newInstance(age, name)
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

    function EmployeeClass:newInstance(age, name, employeeId)
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
    T_Object.at_IsInstanceOf("B", IHuman, PersonClass, EmployeeClass)

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
    local IHuman = {}
    IHuman.__index = IHuman

    function IHuman:isSelfAware()
    end

    function IHuman:getAge()
    end

    -- prepare test: Define a class "PersonClass" inheriting from IHuman
    local PersonClass = {}
    setmetatable(PersonClass, IHuman) -- Make PersonClass inherit from IHuman

    function PersonClass:newInstance(...)
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
    local EmployeeClass = PersonClass:newInstance() -- Make EmployeeClass inherit from PersonClass

    function EmployeeClass:_init(age, name, employeeId) -- note: "overrides" PersonClass:__init
        -- initialisation
        PersonClass:_init(age, name) -- note: call PersonClass __init directly
        self.employeeId = employeeId
    end

    -- Test IsInstanceOf
    T_Object.at_IsInstanceOf("C", IHuman, PersonClass, EmployeeClass)

    -- cleanup test
end

function T_Object.T_IsInstanceOf_D()
    --[[
        *** Approach D ***

        This approach uses relative to approach C:
        -   Introduce and use meta class Class
    ]]

    -- Define functions for a meta class Class
    local Class = {}
    function Class.NewClass(...)
        --[[
            Define a new class (?? or even type). Optional arguments are the (proto)types the class should inherit from.
        ]]

        -- single inheritance: take first argument for now (ToDo: implement multiple inheritance later)
        local firstPrototype = select(1, ...)
        -- ToDo: implement multiple inheritance. Possibly by using a functon for __index

        -- set class info
        local cls = {}
        setmetatable(cls, firstPrototype)
        firstPrototype.__index = firstPrototype

        -- end
        return cls
    end

    -- Define an interface IHuman
    local IHuman = {}

    function IHuman:isSelfAware()
    end

    function IHuman:getAge()
    end

    -- Define a class "PersonClass" inheriting from IHuman
    local PersonClass = Class.NewClass(IHuman) -- Make PersonClass inherit from IHuman

    function PersonClass:newInstance(...)
        -- set instance class info
        local instance = {}
        setmetatable(instance, self)
        self.__index = self

        -- initialisation
        if ... then
            if not instance._init then corelog.Error("_init does not exist") return nil end
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

    -- Define a class "EmployeeClass" inheriting from PersonClass
    local EmployeeClass = Class.NewClass(PersonClass) -- Make EmployeeClass inherit from both PersonClass

    function EmployeeClass:_init(age, name, employeeId) -- note: "overrides" PersonClass:__init
        -- initialisation
        PersonClass:_init(age, name) -- note: now call PersonClass __init directly
        self.employeeId = employeeId
    end

    -- Test IsInstanceOf
    T_Object.at_IsInstanceOf("D", IHuman, PersonClass, EmployeeClass)

    -- cleanup test
end

-- Define class Class
local Class = {}

function Class:newInstance(...)
    --[[
        Function that creates and returns new instance from the calling class (i.e. self).

        An initialisation function _init of the calling class is called if it is present with the varargs as arguments.
    ]]

    -- create instance
    local instance = {}

    -- set instance class info
    setmetatable(instance, self)
    self.__index = self

    -- initialisation
    if instance._init then
        instance:_init(...)
    end

    -- end
    return instance
end

function Class.IsInstanceOf(object, class)
    --[[
        Function that returns if a given object is an instance of a specified class (or interface).
    ]]

    local mt = getmetatable(object)
    while mt do
        -- check inheritance is mixedin
        if mt.__mixinClasses then
            -- loop on mixinClasses
            for _i, mixinClass in ipairs(mt.__mixinClasses) do
                if mixinClass == class then
                    return true
                else
                    if Class.IsInstanceOf(mixinClass, class) == true then
                        return true
                    end
                end
            end
            return false
        else -- normal inheritance
            if mt == class then
                return true
            end
            mt = getmetatable(mt)
        end
    end

    -- end
    return false
end

function Class.NewClass(...)
    --[[
        This function creates and returns a new class that inherts behaviour from the supplied classes.
    ]]

    -- create class
    local class = {}

    -- remember mixins
    local mixinClasses = {...}

    -- create metatable
    local mt = {
        -- remember mixinClasses
        __mixinClasses  = mixinClasses,

        -- define property and method inheritance behavior
        __index         = function(self, key)
            -- walk inheritance chain: return property or method of first class containing key, starting from the class itself
            if rawget(class, key) then
--                corelog.WriteToLog("    key="..key.." direct")
                return class[key]
            else
--                corelog.WriteToLog("    key="..key.." on "..#mixinClasses.." parent(s)")
                -- loop on mixinClass
                for _i, mixinClass in ipairs(mixinClasses) do
--                    if mixinClass.getClassName then corelog.WriteToLog("    mixinClass="..mixinClass:getClassName()) end
--                    corelog.WriteToLog("    _i=".._i)
                    local value = mixinClass[key]
                    if value then
                        return value
                    end
                end

                return nil -- print some warning, or do we want/ expect it to fail here?
            end
        end
    }

    -- set metatable
    setmetatable(class, mt)

    -- end
    return class
end

function T_Object.T_IsInstanceOf_Mixin_ccwp()
    --[[
    ]]

    local approachName = "Mixin CCWP"
    corelog.WriteToLog("* Object.IsInstanceOf() tests (approach "..approachName..")")

    -- IObj definition
    corelog.WriteToLog("->define IObj")
    IObj = {}

    local IInterface = require "i_interface"

    function IObj:getClassName()
        IInterface.UnimplementedMethodError("IObj", "getClassName")
    end

    function IObj:isTypeOf(obj)
        IInterface.UnimplementedMethodError("IObj", "isTypeOf")
    end

    function IObj:isEqual(otherObj)
        IInterface.UnimplementedMethodError("IObj", "isEqual")
    end

    function IObj:copy()
        IInterface.UnimplementedMethodError("IObj", "copy")
    end

    -- ObjBase definition
    corelog.WriteToLog("->define ObjBase")
    ObjBase = Class.NewClass(Class, IObj)

    function ObjBase:getClassName()
        return "ObjBase"
    end

    function ObjBase:isTypeOf(obj)
        local mt = getmetatable(obj)
        while mt do
            if mt.__index == self or obj == self then
                return true
            end
            mt = getmetatable(mt.__index)
        end

        return false
    end

    -- ObjBase tests
    corelog.WriteToLog("->test ObjBase")
    assert(Class.IsInstanceOf(ObjBase, Class), "Failed: ObjBase should be an instance of Class")
    assert(Class.IsInstanceOf(ObjBase, IObj), "Failed: ObjBase should be an instance of IObj")
    assert(ObjBase.newInstance, "Failed: ObjBase should inherit newInstance from Class")
    assert(ObjBase.getClassName, "Failed: ObjBase should inherit getClassName from IObj")
    assert(ObjBase.isTypeOf, "Failed: ObjBase should inherit isTypeOf from IObj")
    assert(ObjBase.isEqual, "Failed: ObjBase should inherit isEqual from IObj")
    assert(ObjBase.copy, "Failed: ObjBase should inherit copy from IObj")

    -- Location definition
    corelog.WriteToLog("->define Location")
    Location = Class.NewClass(ObjBase)

    function Location:_init(x, y, z, dx, dy)
        self._x = x
        self._y = y
        self._z = z
        self._dx = dx
        self.dy = dy
    end

    function Location:getClassName()
        return "Location"
    end

    function Location:blockDistanceTo(o)
        -- check input
        if not Location:isTypeOf(o) then corelog.Warning("Location:blockDistanceTo: object not a Location (type="..type(o)..")") return 9999 end

        return math.abs(o._x - self._x) + math.abs(o._y - self._y) + math.abs(o._z - self._z)
    end

    -- Location test
    assert(Class.IsInstanceOf(Location, ObjBase), "Failed: Location should be an instance of ObjBase")
    assert(Class.IsInstanceOf(Location, Class), "Failed: Location should be an instance of Class")
    assert(Class.IsInstanceOf(Location, IObj), "Failed: Location should be an instance of IObj")
    assert(Location.newInstance, "Failed: Location should inherit newInstance from Class")
    corelog.WriteToLog("->test Location")
    local loc1 = Location:newInstance(10, 20, 10, 0, 1)
    assert(Class.IsInstanceOf(loc1, Location), "Failed: loc1 should be an instance of Location")
    assert(Class.IsInstanceOf(loc1, IObj), "Failed: loc1 should be an instance of Location")
    local loc2 = Location:newInstance(20, 20, 10, 0, 1)
    local blockDistance = loc1:blockDistanceTo(loc2)
    assert(blockDistance == 10, "Failed: blockDistance should be 10 but was "..blockDistance)

    -- IItemSupplier definition
    corelog.WriteToLog("->define IItemSupplier")
    IItemSupplier = {}

    function IItemSupplier:provideItemsTo_AOSrv()
    end

    -- IItemSupplier test
    corelog.WriteToLog("->test IItemSupplier")
    assert(not Class.IsInstanceOf(ObjBase, IItemSupplier), "Failed: ObjBase should not be an instance of IItemSupplier") -- tests not an instance returns false

    -- IItemDepot definition
    corelog.WriteToLog("->define IItemDepot")
    IItemDepot = {}

    function IItemDepot:storeItemsFrom_AOSrv()
    end

    -- IMObj definition
    corelog.WriteToLog("->define IMObj")
    IMObj = {}

    function IMObj:getBuildBlueprint()
    end

    function IMObj:getDismantleBlueprint()
    end

    -- Chest definition
    corelog.WriteToLog("->define Chest")
    Chest = Class.NewClass(ObjBase, IItemSupplier, IItemDepot, IMObj)

    function Chest:provideItemsTo_AOSrv()
    end

    -- Chest test
    corelog.WriteToLog("->test Chest")
    assert(Class.IsInstanceOf(Chest, ObjBase), "Failed: Chest should be an instance of ObjBase")
    assert(Class.IsInstanceOf(Chest, IItemSupplier), "Failed: Chest should be an instance of IItemSupplier")
    assert(Class.IsInstanceOf(Chest, IItemDepot), "Failed: Chest should be an instance of IItemDepot")
    assert(Class.IsInstanceOf(Chest, IMObj), "Failed: Chest should be an instance of IMObj")
    assert(Chest.provideItemsTo_AOSrv, "Failed: Chest should inherit provideItemsTo_AOSrv from IItemSupplier")
    assert(Chest.storeItemsFrom_AOSrv, "Failed: Chest should inherit storeItemsFrom_AOSrv from IItemDepot")
    assert(Chest.getBuildBlueprint, "Failed: Chest should inherit getBuildBlueprint from IMObj")
    assert(Chest.getDismantleBlueprint, "Failed: Chest should inherit getDismantleBlueprint from IMObj")

    corelog.WriteToLog("ok")
end

return T_Object
