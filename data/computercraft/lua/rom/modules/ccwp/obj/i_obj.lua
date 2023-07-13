local IObj = {
}

local corelog = require "corelog"

local InputChecker = require "input_checker"

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

function IObj:new(...)
    -- get & check input from description
    local checkSuccess, o = InputChecker.Check([[
        This method constructs a XXXObj instance from an objectTable with all necessary fields as defined in the class.

        Return value:
                o                       - (XXXObj) the constructed XXXObj

        Parameters:
            o                           + (table) objectTable of this XXXObj
                field1                  - (Location) location of XXXObj
                field2                  - (number, 2) ...
                ...
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("XXXMObj:new: Invalid input") return {} end

    corelog.Error("Method new() should be implemented in classes implementing the IObj interface. It should not be called directly.")
end

function IObj:getClassName()
    --[[
        Method that returns the className of the Obj (i.e. self).
    ]]

    corelog.Error("Method getClassName() should be implemented in classes implementing the IObj interface. It should not be called directly.")

    return "???"
end

function IObj.IsOfType(obj)
    --[[
        Method that returns if an object 'obj' is of type of this class.
    ]]

    corelog.Error("Method IsOfType() should be implemented in classes implementing the IObj interface. It should not be called directly.")

    -- end
    return false
end

function IObj:isSame(obj)
    --[[
        Method that returns if the Obj (i.e. self) is the same as the object 'obj'.
    ]]

    corelog.Error("Method isSame() should be implemented in classes implementing the IObj interface. It should not be called directly.")

    -- end
    return false
end

function IObj:copy()
    --[[
        Method that returns a copy of the Obj (i.e. self).
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
    -- ToDo: consider adding checks for method (parameter) signatures.

    -- end
    return true
end

return IObj
