local T_ItemDepot = {}
local corelog = require "corelog"

local T_Obj = require "test.t_obj"

local compact = { compact = true }

--    _____ _____ _                 _____                   _                    _   _               _
--   |_   _|_   _| |               |  __ \                 | |                  | | | |             | |
--     | |   | | | |_ ___ _ __ ___ | |  | | ___ _ __   ___ | |_   _ __ ___   ___| |_| |__   ___   __| |___
--     | |   | | | __/ _ \ '_ ` _ \| |  | |/ _ \ '_ \ / _ \| __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| |_ _| |_| ||  __/ | | | | | |__| |  __/ |_) | (_) | |_  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____|_____|\__\___|_| |_| |_|_____/ \___| .__/ \___/ \__| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                                             | |
--                                             |_|

function T_ItemDepot.pt_ImplementsInterface(className, oTable)
    assert(className, "no className provided")
    assert(oTable, "no oTable provided")
    local obj = T_Obj.createObjFromTable(className, oTable) assert(obj, "failed obtaining "..className.." Obj from oTable "..textutils.serialise(oTable, compact))

    T_Obj.pt_ImplementsInterface("IItemDepot", className, obj)
end

return T_ItemDepot
