-- define library
local library = {}

function library.Init()
    -- add library to path
    package.path = package.path..";/rom/modules/ccwp/core/?"..";/rom/modules/ccwp/core/?.lua"
end

local function ExecuteLibraryTest(t)
	-- forward call with options
	local options	= {
		{key = "m", desc = "coremove", 			func = ExecuteLibraryTest, param = {filename = "t_coremove"}},
		{key = "d", desc = "coredht", 			func = ExecuteLibraryTest, param = {filename = "t_coredht"}},
		{key = "i", desc = "coreinventory",		func = ExecuteLibraryTest, param = {filename = "t_coreinventory"}},
		{key = "x", desc = "Back to main menu", func = function () return true end }
	}
	return ExecuteXObjTest(t, "core", options, ExecuteLibraryTest)
end

function library.Setup()
    -- register library modules
    local ModuleRegistry = require "module_registry"
    local moduleRegistry = ModuleRegistry:getInstance()

    -- register library modules test modules
    moduleRegistry:requireAndRegisterModule("t_coremove", "test.t_coremove")
    moduleRegistry:requireAndRegisterModule("t_coredht", "test.t_coredht")
    moduleRegistry:requireAndRegisterModule("t_coreinventory", "test.t_coreinventory")

    -- add library test menu
    local coredisplay = require "coredisplay"
    coredisplay.MainMenuAddItem("c", "core lib tests", ExecuteLibraryTest, {})

    -- do other stuff
end

return library