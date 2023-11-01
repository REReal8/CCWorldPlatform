-- define library
local library = {}

local libraryName = "core"

function library.Init()
    -- add library to path
    package.path = package.path..";/rom/modules/ccwp/"..libraryName.."/?;/rom/modules/ccwp/"..libraryName.."/?.lua"
end

function library.T_All()
    -- prepare test
    local corelog = require "corelog"
    corelog.WriteToLog("*** "..libraryName.." library tests ***")

    local t_coredht = require "test.t_coredht"

    -- library tests
    t_coredht.T_All()
end

local function ExecuteLibraryTest(t)
	-- forward call with options
	local options	= {
        {key = "1", desc = "All",			    func = ExecuteLibraryTest, param = {filename = "T_CoreLibrary"}},

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
    moduleRegistry:requireAndRegisterModule("T_CoreLibrary", libraryName..".library")

    moduleRegistry:requireAndRegisterModule("t_coremove", "test.t_coremove")
    moduleRegistry:requireAndRegisterModule("t_coredht", "test.t_coredht")
    moduleRegistry:requireAndRegisterModule("t_coreinventory", "test.t_coreinventory")

    -- add library test menu
    local coredisplay = require "coredisplay"
    coredisplay.MainMenuAddItem("c", "core lib tests", ExecuteLibraryTest, {})

    -- do other stuff
end

return library