local IObj = {
}

local corelog = require "corelog"

--[[
    This module implements the interface IObj.

    The IObj interface defines basic methods all objects should adhere to.

    Objects of a class implementing the interface are called Obj's.
--]]

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

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

function IObj.IsOfType(obj)
    --[[
        Classes implementing this method should return if an instance 'obj' is of type of the class.
    ]]

    corelog.Error("Method IsOfType() should be implemented in classes implementing the IObj interface. It should not be called directly.")

    -- end
    return false
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

--        _        _   _                       _   _               _
--       | |      | | (_)                     | | | |             | |
--    ___| |_ __ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| __/ _` | __| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ || (_| | |_| | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/\__\__,_|\__|_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

function IObj.ImplementsInterface(obj)
    --[[
        Returns if the object 'obj' implements this interface.
    ]]

    -- check
    if not obj.new then return false end
    if not obj.getClassName then return false end
    if not obj.IsOfType then return false end
    if not obj.isSame then return false end
    if not obj.copy then return false end

    -- end
    return true
end

return IObj
