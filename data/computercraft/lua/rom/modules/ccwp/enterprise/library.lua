-- define library
local library = {}

function library.Init()
    -- add library to path
    package.path = package.path..";/rom/modules/ccwp/enterprise/?;/rom/modules/ccwp/enterprise/?.lua"
end

local function ExecuteLibraryTest(t)
	-- forward call with options
	local options	= {
		{key = "1", desc = "enterprise_test",	func = ExecuteLibraryTest, param = {filename = "t_test"}},
		{key = "a", desc = "assignmentboard",	func = ExecuteLibraryTest, param = {filename = "t_assignmentboard"}},
		{key = "t", desc = "employment", 		func = ExecuteLibraryTest, param = {filename = "t_employment"}},
		{key = "p", desc = "projects", 			func = ExecuteLibraryTest, param = {filename = "t_projects"}},
		{key = "e", desc = "energy", 			func = ExecuteLibraryTest, param = {filename = "t_energy"}},
		{key = "c", desc = "chests", 			func = ExecuteLibraryTest, param = {filename = "t_chests"}},
		{key = "i", desc = "isp", 				func = ExecuteLibraryTest, param = {filename = "t_isp"}},
		{key = "b", desc = "construction", 		func = ExecuteLibraryTest, param = {filename = "t_construction"}},
		{key = "s", desc = "storage", 			func = ExecuteLibraryTest, param = {filename = "t_storage"}},
		{key = "m", desc = "manufacturing", 	func = ExecuteLibraryTest, param = {filename = "t_manufacturing"}},
		{key = "f", desc = "forestry", 			func = ExecuteLibraryTest, param = {filename = "t_forestry"}},
		{key = "o", desc = "shop", 				func = ExecuteLibraryTest, param = {filename = "t_shop"}},
		{key = "n", desc = "colonization", 		func = ExecuteLibraryTest, param = {filename = "t_colonization"}},
		{key = "u", desc = "utilities", 		func = ExecuteLibraryTest, param = {filename = "t_utilities"}},
		{key = "x", desc = "Back to main menu", func = function () return true end }
	}
	return ExecuteXObjTest(t, "enterprise", options, ExecuteLibraryTest)
end

function library.Setup()
    -- register library classes
    -- local ObjectFactory = require "object_factory"
    -- local objectFactory = ObjectFactory:getInstance()

    -- register library modules
    local ModuleRegistry = require "module_registry"
    local moduleRegistry = ModuleRegistry:getInstance()
    moduleRegistry:requireAndRegisterModule("enterprise_assignmentboard")
    moduleRegistry:requireAndRegisterModule("enterprise_chests")
    moduleRegistry:requireAndRegisterModule("enterprise_construction")
    moduleRegistry:requireAndRegisterModule("enterprise_dump")
    moduleRegistry:requireAndRegisterModule("enterprise_energy")
    moduleRegistry:requireAndRegisterModule("enterprise_manufacturing")
    moduleRegistry:requireAndRegisterModule("enterprise_utilities")
    moduleRegistry:requireAndRegisterModule("enterprise_forestry")
    moduleRegistry:requireAndRegisterModule("enterprise_isp")
    moduleRegistry:requireAndRegisterModule("enterprise_projects")
    moduleRegistry:requireAndRegisterModule("enterprise_shop")
    moduleRegistry:requireAndRegisterModule("enterprise_storage")
    moduleRegistry:requireAndRegisterModule("enterprise_employment")
    moduleRegistry:requireAndRegisterModule("enterprise_administration")

    -- register library modules test modules
    moduleRegistry:requireAndRegisterModuleTests("t_assignmentboard")
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
    moduleRegistry:requireAndRegisterModuleTests("t_employment")
    moduleRegistry:requireAndRegisterModuleTests("t_utilities")

    -- add library test menu
    local coredisplay = require "coredisplay"
    coredisplay.MainMenuAddItem("e", "enterprise lib tests", ExecuteLibraryTest, {})

    -- do other stuff
    local enterprise_utilities  = require "enterprise_utilities"    enterprise_utilities.Setup()
end

return library