-- define library
local library = {}

function library.Init()
    -- add library to path
    package.path = package.path..";/rom/modules/ccwp/enterprise/?;/rom/modules/ccwp/enterprise/?.lua"
end

function library.Setup()
    -- register library classes
    local ObjectFactory = require "object_factory"
    local objectFactory = ObjectFactory:getInstance()
    objectFactory:registerClass("MObjHost", require "eobj_mobj_host")

    -- register library modules
    local ModuleRegistry = require "module_registry"
    local moduleRegistry = ModuleRegistry:getInstance()
    moduleRegistry:requireAndRegisterModule("enterprise_assignmentboard")
    moduleRegistry:requireAndRegisterModule("eobj_mobj_host") -- ToDo: beetje dubbel op met ook in ObjectFactory...
    moduleRegistry:requireAndRegisterModule("enterprise_chests")
    moduleRegistry:requireAndRegisterModule("enterprise_construction")
    moduleRegistry:requireAndRegisterModule("enterprise_energy")
    moduleRegistry:requireAndRegisterModule("enterprise_manufacturing")
    moduleRegistry:requireAndRegisterModule("enterprise_utilities")
    moduleRegistry:requireAndRegisterModule("enterprise_forestry")
    moduleRegistry:requireAndRegisterModule("enterprise_isp")
    moduleRegistry:requireAndRegisterModule("enterprise_projects")
    moduleRegistry:requireAndRegisterModule("enterprise_shop")
    moduleRegistry:requireAndRegisterModule("enterprise_storage")
    moduleRegistry:requireAndRegisterModule("enterprise_turtle")
    moduleRegistry:requireAndRegisterModule("enterprise_administration")

    -- register library modules test modules
    moduleRegistry:requireAndRegisterModuleTests("t_assignmentboard")
    moduleRegistry:requireAndRegisterModule("T_MObjHost", "test.t_eobj_mobj_host")
    moduleRegistry:requireAndRegisterModuleTests("t_chests")
    moduleRegistry:requireAndRegisterModuleTests("t_colonization")
    moduleRegistry:requireAndRegisterModuleTests("t_construction")
    moduleRegistry:requireAndRegisterModuleTests("t_energy")
    moduleRegistry:requireAndRegisterModuleTests("t_manufacturing")
    moduleRegistry:requireAndRegisterModuleTests("t_forestry")
    moduleRegistry:requireAndRegisterModuleTests("t_isp")
    moduleRegistry:requireAndRegisterModuleTests("t_projects")
    moduleRegistry:requireAndRegisterModuleTests("t_shop")
    moduleRegistry:requireAndRegisterModuleTests("t_storage")
    moduleRegistry:requireAndRegisterModuleTests("enterprise_test")
    moduleRegistry:requireAndRegisterModuleTests("t_test")
    moduleRegistry:requireAndRegisterModuleTests("t_turtle")
    moduleRegistry:requireAndRegisterModuleTests("t_utilities")

    -- do other stuff
    local enterprise_utilities = require "enterprise_utilities"
    enterprise_utilities.Setup()
end

return library