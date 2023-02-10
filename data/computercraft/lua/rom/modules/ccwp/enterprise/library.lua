local library = {}

function library.Init()
    -- add library to path
    package.path = package.path..";/rom/modules/ccwp/enterprise/?"
end

function library.Setup()
    -- register library modules
    local ModuleRegistry = require "module_registry"
    local moduleRegistry = ModuleRegistry:getInstance()
    moduleRegistry:requireAndRegisterObject("enterprise_assignmentboard")
    moduleRegistry:requireAndRegisterObject("enterprise_chests")
    moduleRegistry:requireAndRegisterObject("enterprise_construction")
    moduleRegistry:requireAndRegisterObject("enterprise_energy")
    moduleRegistry:requireAndRegisterObject("enterprise_factory")
    moduleRegistry:requireAndRegisterObject("enterprise_factory_site")
    moduleRegistry:requireAndRegisterObject("enterprise_forestry")
    moduleRegistry:requireAndRegisterObject("enterprise_isp")
    moduleRegistry:requireAndRegisterObject("enterprise_projects")
    moduleRegistry:requireAndRegisterObject("enterprise_shop")
    moduleRegistry:requireAndRegisterObject("enterprise_storage")
    moduleRegistry:requireAndRegisterObject("enterprise_test")
    moduleRegistry:requireAndRegisterObject("enterprise_turtle")

    -- register library modules test modules
    moduleRegistry:requireAndRegisterObjectTests("t_assignmentboard")
    moduleRegistry:requireAndRegisterObjectTests("t_chests")
    moduleRegistry:requireAndRegisterObjectTests("t_colonization")
    moduleRegistry:requireAndRegisterObjectTests("t_construction")
    moduleRegistry:requireAndRegisterObjectTests("t_energy")
    moduleRegistry:requireAndRegisterObjectTests("t_factory")
    moduleRegistry:requireAndRegisterObjectTests("t_forestry")
    moduleRegistry:requireAndRegisterObjectTests("t_isp")
    moduleRegistry:requireAndRegisterObjectTests("t_projects")
    moduleRegistry:requireAndRegisterObjectTests("t_shop")
    moduleRegistry:requireAndRegisterObjectTests("t_storage")
    moduleRegistry:requireAndRegisterObjectTests("t_test")
    moduleRegistry:requireAndRegisterObjectTests("t_turtle")

    -- do other stuff
end

return library