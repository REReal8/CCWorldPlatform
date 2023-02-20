local library = {}

function library.Init()
    -- add library to path
    package.path = package.path..";/rom/modules/ccwp/enterprise/?"
end

function library.Setup()
    -- register library modules
    local ModuleRegistry = require "module_registry"
    local moduleRegistry = ModuleRegistry:getInstance()
    moduleRegistry:requireAndRegisterModule("enterprise_assignmentboard")
    moduleRegistry:requireAndRegisterModule("enterprise_chests")
    moduleRegistry:requireAndRegisterModule("enterprise_construction")
    moduleRegistry:requireAndRegisterModule("enterprise_energy")
    moduleRegistry:requireAndRegisterModule("enterprise_factory")
    moduleRegistry:requireAndRegisterModule("enterprise_factory_site")
    moduleRegistry:requireAndRegisterModule("enterprise_forestry")
    moduleRegistry:requireAndRegisterModule("enterprise_isp")
    moduleRegistry:requireAndRegisterModule("enterprise_projects")
    moduleRegistry:requireAndRegisterModule("enterprise_shop")
    moduleRegistry:requireAndRegisterModule("enterprise_storage")
    moduleRegistry:requireAndRegisterModule("enterprise_turtle")

    -- register library modules test modules
    moduleRegistry:requireAndRegisterModuleTests("t_assignmentboard")
    moduleRegistry:requireAndRegisterModuleTests("t_chests")
    moduleRegistry:requireAndRegisterModuleTests("t_colonization")
    moduleRegistry:requireAndRegisterModuleTests("t_construction")
    moduleRegistry:requireAndRegisterModuleTests("t_energy")
    moduleRegistry:requireAndRegisterModuleTests("t_factory")
    moduleRegistry:requireAndRegisterModuleTests("t_forestry")
    moduleRegistry:requireAndRegisterModuleTests("t_isp")
    moduleRegistry:requireAndRegisterModuleTests("t_projects")
    moduleRegistry:requireAndRegisterModuleTests("t_shop")
    moduleRegistry:requireAndRegisterModuleTests("t_storage")
    moduleRegistry:requireAndRegisterModuleTests("enterprise_test")
    moduleRegistry:requireAndRegisterModuleTests("t_test")
    moduleRegistry:requireAndRegisterModuleTests("t_turtle")

    -- do other stuff
end

return library