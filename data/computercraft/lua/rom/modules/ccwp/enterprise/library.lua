local library = {}

function library.Init()
    -- add library to path
    package.path = package.path..";/rom/modules/ccwp/enterprise/?"
end

function library.Setup()
    -- register library objects
    local ObjectRegistry = require "object_registry"
    local objectRegistry = ObjectRegistry:getInstance()
    objectRegistry:requireAndRegisterObject("enterprise_assignmentboard")
    objectRegistry:requireAndRegisterObject("enterprise_chests")
    objectRegistry:requireAndRegisterObject("enterprise_construction")
    objectRegistry:requireAndRegisterObject("enterprise_energy")
    objectRegistry:requireAndRegisterObject("enterprise_factory")
    objectRegistry:requireAndRegisterObject("enterprise_factory_site")
    objectRegistry:requireAndRegisterObject("enterprise_forestry")
    objectRegistry:requireAndRegisterObject("enterprise_isp")
    objectRegistry:requireAndRegisterObject("enterprise_projects")
    objectRegistry:requireAndRegisterObject("enterprise_shop")
    objectRegistry:requireAndRegisterObject("enterprise_storage")
    objectRegistry:requireAndRegisterObject("enterprise_test")
    objectRegistry:requireAndRegisterObject("enterprise_turtle")

    -- register library object tests
    objectRegistry:requireAndRegisterObjectTests("t_assignmentboard")
    objectRegistry:requireAndRegisterObjectTests("t_chests")
    objectRegistry:requireAndRegisterObjectTests("t_colonization")
    objectRegistry:requireAndRegisterObjectTests("t_construction")
    objectRegistry:requireAndRegisterObjectTests("t_energy")
    objectRegistry:requireAndRegisterObjectTests("t_factory")
    objectRegistry:requireAndRegisterObjectTests("t_forestry")
    objectRegistry:requireAndRegisterObjectTests("t_isp")
    objectRegistry:requireAndRegisterObjectTests("t_projects")
    objectRegistry:requireAndRegisterObjectTests("t_shop")
    objectRegistry:requireAndRegisterObjectTests("t_storage")
    objectRegistry:requireAndRegisterObjectTests("t_test")
    objectRegistry:requireAndRegisterObjectTests("t_turtle")

    -- do other stuff
end

return library