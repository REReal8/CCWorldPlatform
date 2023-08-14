local T_MObj = {}

local T_Obj = require "test.t_obj"

local compact = { compact = true }

--    _____ __  __  ____  _     _                  _   _               _
--   |_   _|  \/  |/ __ \| |   (_)                | | | |             | |
--     | | | \  / | |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | | | |\/| | |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| |_| |  | | |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____|_|  |_|\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                            _/ |
--                           |__/

function T_MObj.pt_ImplementsInterface(className, oTable)
    assert(className, "no className provided")
    assert(oTable, "no oTable provided")
    local obj = T_Obj.createObjFromTable(className, oTable) assert(obj, "failed obtaining "..className.." Obj from oTable "..textutils.serialise(oTable, compact))

    T_Obj.pt_ImplementsInterface("IMObj", className, obj)
end

return T_MObj
