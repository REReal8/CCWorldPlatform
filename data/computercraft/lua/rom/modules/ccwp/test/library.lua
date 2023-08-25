-- define library
local library = {}

function library.Init()
    -- add library to path
    package.path = package.path..";/rom/modules/ccwp/test/?"..";/rom/modules/ccwp/test/?.lua"
end

function library.Setup()
--[[
    -- register library classes
    local ObjectFactory = require "object_factory"
    local objectFactory = ObjectFactory:getInstance()
    objectFactory:registerClass("XxxYyy", require "xxx_yyy")
 ]]

    -- register library modules
    local ModuleRegistry = require "module_registry"
    local moduleRegistry = ModuleRegistry:getInstance()
    moduleRegistry:requireAndRegisterModule("t_main", "test.t_main")

    -- do other stuff
end

return library
