local ccwp = {}

local coreLibrary = require "core.library"
local objLibrary = require "obj.library"
local roleLibrary = require "role.library"
local mobjLibrary = require "mobj.library"
local enterpriseLibrary = require "enterprise.library"

function ccwp.Init()
    -- add & init libraries
    coreLibrary.Init()
    objLibrary.Init()
    roleLibrary.Init()
    mobjLibrary.Init()
    enterpriseLibrary.Init()
end

function ccwp.Startup()
    -- setup libraries
    coreLibrary.Setup()
    objLibrary.Setup()
    roleLibrary.Setup()
    mobjLibrary.Setup()
    enterpriseLibrary.Setup()

    -- register global ccwp module tests
    local ModuleRegistry = require "module_registry"
    local moduleRegistry = ModuleRegistry:getInstance()
    moduleRegistry:requireAndRegisterModule("t_main", "test.t_main")

    -- initialize core modules (old style)
    local core = require "core"
    core.Init()

    -- setup core modules
    core.Setup()

    -- nu werkelijk aan de slag
    core.Run()
end

return ccwp