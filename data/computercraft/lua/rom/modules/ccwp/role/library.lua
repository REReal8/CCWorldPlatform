-- define library
local library = {}

local libraryName = "role"

function library.Init()
    -- add library to path
    package.path = package.path..";/rom/modules/ccwp/"..libraryName.."/?;/rom/modules/ccwp/"..libraryName.."/?.lua"
end

function library.T_All()
    -- prepare test
    local corelog = require "corelog"
    corelog.WriteToLog("*** "..libraryName.." library tests ***")

    local t_alchemist = require "test.t_alchemist"
    local t_builder = require "test.t_builder"
    local t_foresting = require "test.t_foresting"

    -- library tests
    t_alchemist.T_All()
    t_builder.T_All()
    t_foresting.T_All()
end

local function ExecuteLibraryTest(t)
	-- forward call with options
	local options	= {
        {key = "a", desc = "All",			    func = ExecuteLibraryTest, param = {filename = "T_RoleLibrary"}},

		{key = "1", desc = "alchemist", 		func = ExecuteLibraryTest, param = {filename = "t_alchemist"}},
		{key = "b", desc = "builder", 			func = ExecuteLibraryTest, param = {filename = "t_builder"}},
		{key = "x", desc = "Back to main menu", func = function () return true end }
	}
	return ExecuteXObjTest(t, "role", options, ExecuteLibraryTest)
end

function library.Setup()
    -- register library modules
    local ModuleRegistry = require "module_registry"
    local moduleRegistry = ModuleRegistry:getInstance()
    moduleRegistry:requireAndRegisterModule("role_alchemist")
    moduleRegistry:requireAndRegisterModule("role_builder")
    moduleRegistry:requireAndRegisterModule("role_conservator")
    moduleRegistry:requireAndRegisterModule("role_forester")
    moduleRegistry:requireAndRegisterModule("role_interactor")
    moduleRegistry:requireAndRegisterModule("role_energizer")
    moduleRegistry:requireAndRegisterModule("role_settler")

    -- register library modules test modules
    moduleRegistry:requireAndRegisterModule("T_RoleLibrary", libraryName..".library")

    moduleRegistry:requireAndRegisterModule("role_test", "test.role_test")
    moduleRegistry:requireAndRegisterModule("t_alchemist", "test.t_alchemist")
    moduleRegistry:requireAndRegisterModule("t_builder", "test.t_builder")
    moduleRegistry:requireAndRegisterModule("t_foresting", "test.t_foresting")

    -- add library test menu
    local coredisplay = require "coredisplay"
    coredisplay.MainMenuAddItem("r", "role lib tests", ExecuteLibraryTest, {})

    -- do other stuff
end

return library