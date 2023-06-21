local IObj = {
}

local corelog = require "corelog"

--[[
    This module implements the interface IObj.

    It's methods should be implemented by classes adhering to the interface, i.e. that want to use general IObj logic.
--]]

--    _                                     _   _               _
--   | |                                   | | | |             | |
--   | |__   __ _ ___  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   | '_ \ / _` / __|/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   | |_) | (_| \__ \  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_.__/ \__,_|___/\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

function IObj:new(o)
    --[[
        Classes implementing this method should return a new instance of the object based on a provided objectTable with it's fields.
    ]]

    corelog.Error("Method new() should be implemented in classes implementing the IObj interface. It should not be called directly.")
end

function IObj:getClassName()
    --[[
        Classes implementing this method should return the className of the object (i.e. self).
    ]]

    corelog.Error("Method getClassName() should be implemented in classes implementing the IObj interface. It should not be called directly.")

    return "???"
end

function IObj:isSame(obj)
    --[[
        Classes implementing this method should return if the object (i.e. self) is the same as the object 'obj'.
    ]]

    corelog.Error("Method isSame() should be implemented in classes implementing the IObj interface. It should not be called directly.")

    -- end
    return false
end

function IObj:copy()
    --[[
        Classes implementing this method should return a copy of the object (i.e. self).
    ]]

    corelog.Error("Method copy() should be implemented in classes implementing the IObj interface. It should not be called directly.")

    return nil
end

function IObj.ImplementsInterface(obj)
    --[[
        Returns if the object 'obj' implements this interface.
    ]]

    -- check
    if not obj.new then return false end
    if not obj.getClassName then return false end
    if not obj.isSame then return false end
    if not obj.copy then return false end

    -- end
    return true
end

--    _          _                    __                  _   _
--   | |        | |                  / _|                | | (_)
--   | |__   ___| |_ __   ___ _ __  | |_ _   _ _ __   ___| |_ _  ___  _ __  ___
--   | '_ \ / _ \ | '_ \ / _ \ '__| |  _| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
--   | | | |  __/ | |_) |  __/ |    | | | |_| | | | | (__| |_| | (_) | | | \__ \
--   |_| |_|\___|_| .__/ \___|_|    |_|  \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
--                | |
--                |_|

return IObj
