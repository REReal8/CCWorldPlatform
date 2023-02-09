local ccwp = {}

function ccwp.Startup()
    -- add & init libraries
    local coreLibrary = require "core.library"
    coreLibrary.Init()
    local objLibrary = require "obj.library"
    objLibrary.Init()
    local roleLibrary = require "role.library"
    roleLibrary.Init()
    local mobjLibrary = require "mobj.library"
    mobjLibrary.Init()
    local enterpriseLibrary = require "enterprise.library"
    enterpriseLibrary.Init()

    -- setup libraries
    coreLibrary.Setup()
    objLibrary.Setup()
    roleLibrary.Setup()
    mobjLibrary.Setup()
    enterpriseLibrary.Setup()

    -- register ccwp object tests
    local ObjectRegistry = require "object_registry"
    local objectRegistry = ObjectRegistry:getInstance()
    objectRegistry:requireAndRegisterObject("t_main", "test.t_main")

    -- initialize core modules (old style)
    local core = require "core"
    core.Init()

    -- setup core modules
    core.Setup()

    -- nu werkelijk aan de slag
    core.Run()
end

return ccwp