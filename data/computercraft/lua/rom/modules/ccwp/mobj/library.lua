-- define library
local library = {}

local libraryName = "mobj"

function library.Init()
    -- add library to path
    package.path = package.path..";/rom/modules/ccwp/"..libraryName.."/?;/rom/modules/ccwp/"..libraryName.."/?.lua"
end

function library.T_All()
    -- prepare test
    local corelog = require "corelog"
    corelog.WriteToLog("*** "..libraryName.." library tests ***")

    local T_TestMObj = require "test.t_mobj_test"
    local T_BirchForest = require "test.t_mobj_birchforest"
    local T_Chest = require "test.t_mobj_chest"
    local T_ProductionSpot = require "test.t_mobj_production_spot"
    local T_Factory = require "test.t_mobj_factory"
    local T_Silo = require "test.t_mobj_silo"
    local T_Turtle = require "test.t_mobj_turtle"
    local T_UtilStation = require "test.t_mobj_user_station"
    local t_mobj_host = require "test.t_mobj_host"

    -- library tests
    T_TestMObj.T_All()
    t_mobj_host.T_All()
    T_BirchForest.T_All()
    T_Chest.T_All()
    T_Factory.T_All()
    T_ProductionSpot.T_All()
    T_Silo.T_All()
    T_Turtle.T_All()
    T_UtilStation.T_All()
end

local function ExecuteLibraryTest(t)
    -- forward call with options
    local options	= {
        {key = "1", desc = "All",               func = ExecuteLibraryTest, param = {filename = "T_MObjLibrary"}},

        {key = "2", desc = "TestMObj",          func = ExecuteLibraryTest, param = {filename = "T_TestMObj"}},
        {key = "h", desc = "MObjHost",          func = ExecuteLibraryTest, param = {filename = "T_MObjHost"}},
        {key = "b", desc = "BirchForest",       func = ExecuteLibraryTest, param = {filename = "T_BirchForest"}},
        {key = "c", desc = "Chest",             func = ExecuteLibraryTest, param = {filename = "T_Chest"}},
        {key = "p", desc = "ProductionSpot",    func = ExecuteLibraryTest, param = {filename = "T_ProductionSpot"}},
        {key = "f", desc = "Factory",           func = ExecuteLibraryTest, param = {filename = "T_Factory"}},
        {key = "s", desc = "Silo",              func = ExecuteLibraryTest, param = {filename = "T_Silo"}},
        {key = "t", desc = "Turtle",            func = ExecuteLibraryTest, param = {filename = "T_Turtle"}},
        {key = "u", desc = "Util Station",      func = ExecuteLibraryTest, param = {filename = "T_UtilStation"}},
        {key = "x", desc = "Back to main menu", func = function () return true end }
    }
    return ExecuteXObjTest(t, "mobj", options, ExecuteLibraryTest)
end

function library.Setup()
    -- register library classes
    local ObjectFactory = require "object_factory"
    local objectFactory = ObjectFactory:getInstance()
    objectFactory:registerClass("TestMObj",     require "test.mobj_test")

    objectFactory:registerClass("MObjHost",     require "mobj_host")
    objectFactory:registerClass("Chest",        require "mobj_chest")
    objectFactory:registerClass("BirchForest",  require "mobj_birchforest")
    objectFactory:registerClass("Factory",      require "mobj_factory")
    objectFactory:registerClass("ProductionSpot",   require "mobj_production_spot")
    objectFactory:registerClass("Silo",         require "mobj_silo")
    objectFactory:registerClass("Turtle",       require "mobj_turtle")
    objectFactory:registerClass("UserStation",  require "mobj_user_station")

    -- register library modules
    local ModuleRegistry = require "module_registry"
    local moduleRegistry = ModuleRegistry:getInstance()
    moduleRegistry:requireAndRegisterModule("mobj_host") -- ToDo: beetje dubbel op met ook in ObjectFactory...
    moduleRegistry:requireAndRegisterModule("Factory", "mobj_factory") -- ToDo: refactor Factory to no longer need to register it also as a module
    moduleRegistry:requireAndRegisterModule("IMObj", "i_mobj")

    -- register library modules test modules
    moduleRegistry:requireAndRegisterModule("T_MObjLibrary", libraryName..".library")

    moduleRegistry:requireAndRegisterModule("T_TestMObj", "test.t_mobj_test")

    moduleRegistry:requireAndRegisterModule("T_MObjHost", "test.t_mobj_host")
    moduleRegistry:requireAndRegisterModule("T_BirchForest", "test.t_mobj_birchforest")
    moduleRegistry:requireAndRegisterModule("T_Chest", "test.t_mobj_chest")
    moduleRegistry:requireAndRegisterModule("T_ProductionSpot", "test.t_mobj_production_spot")
    moduleRegistry:requireAndRegisterModule("T_Factory", "test.t_mobj_factory")
    moduleRegistry:requireAndRegisterModule("T_Silo", "test.t_mobj_silo")
    moduleRegistry:requireAndRegisterModule("T_Turtle", "test.t_mobj_turtle")
    moduleRegistry:requireAndRegisterModule("T_UtilStation", "test.t_mobj_user_station")

    -- add library test menu
    local coredisplay = require "coredisplay"
    coredisplay.MainMenuAddItem("m", libraryName.." lib tests", ExecuteLibraryTest, {})

    -- do other stuff
end

return library