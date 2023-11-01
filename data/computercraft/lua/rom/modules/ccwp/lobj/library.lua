-- define library
local library = {}

local libraryName = "lobj"

function library.Init()
    -- add library to path
    package.path = package.path..";/rom/modules/ccwp/"..libraryName.."/?;/rom/modules/ccwp/"..libraryName.."/?.lua"
end

function library.T_All()
    -- prepare test
    local corelog = require "corelog"
    corelog.WriteToLog("*** "..libraryName.." library tests ***")

    local T_Shop = require "test.t_mobj_shop"

    -- library tests
    T_Shop.T_All()
end

local function ExecuteLibraryTest(t)
    -- forward call with options
    local options	= {
        {key = "1", desc = "All",               func = ExecuteLibraryTest, param = {filename = "T_LObjLibrary"}},

        {key = "s", desc = "Shop",              func = ExecuteLibraryTest, param = {filename = "T_Shop"}},
        {key = "x", desc = "Back to main menu", func = function () return true end }
    }
    return ExecuteXObjTest(t, "mobj", options, ExecuteLibraryTest)
end

function library.Setup()
    -- register library classes
    local ObjectFactory = require "object_factory"
    local objectFactory = ObjectFactory:getInstance()
    objectFactory:registerClass("Shop",         require "mobj_shop")

    -- register library modules
    local ModuleRegistry = require "module_registry"
    local moduleRegistry = ModuleRegistry:getInstance()
    moduleRegistry:requireAndRegisterModule("IItemSupplier", "i_item_supplier")
    moduleRegistry:requireAndRegisterModule("IItemDepot", "i_item_depot")

    -- register library modules test modules
    moduleRegistry:requireAndRegisterModule("T_LObjLibrary", libraryName..".library")

    moduleRegistry:requireAndRegisterModule("T_IItemSupplier", "test.t_i_item_supplier")
    moduleRegistry:requireAndRegisterModule("T_IItemDepot", "test.t_i_item_depot")
    moduleRegistry:requireAndRegisterModule("T_Shop", "test.t_mobj_shop")

    -- add library test menu
    local coredisplay = require "coredisplay"
    coredisplay.MainMenuAddItem("l", libraryName.." lib tests", ExecuteLibraryTest, {})

    -- do other stuff
end

return library