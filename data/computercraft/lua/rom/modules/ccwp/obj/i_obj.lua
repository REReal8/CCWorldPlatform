local IObj = {
}

--[[
    This module implements the interface IObj.

    It defines a set of methods that classes adhering to this interface must implement.

    Objects adhering to this interface are referred to as Obj's.
--]]

local function unimplementedMethodError(methodName)
    error("Method "..methodName.."() should be implemented in Obj classes. It should not be called directly on IObj interface.")
end

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

function IObj:new(...)
    --[[
        This method constructs a XXXObj instance from an objectTable with all necessary fields as defined in the class.

        Return value:
                o                       - (XXXObj) the constructed XXXObj

        Parameters:
            o                           + (table) objectTable of this XXXObj
                field1                  - (Location) location of XXXObj
                field2                  - (number, 2) ...
                ...
    ]]

    unimplementedMethodError("new")
end

function IObj:getClassName()
    --[[
        Method that returns the className of the Obj (i.e. self).
    ]]

    unimplementedMethodError("getClassName")

    return "???"
end

function IObj:isTypeOf(obj)
    --[[
        Method that returns if an object 'obj' is of type of this class.
    ]]

    unimplementedMethodError("isTypeOf")

    -- end
    return false
end

function IObj:isEqual(otherObj)
    --[[
        Method that returns if the current Obj is equal to another Obj.
    ]]

    unimplementedMethodError("isEqual")

    -- end
    return false
end

function IObj:copy()
    --[[
        Method that returns a copy of the Obj (i.e. self).
    ]]

    unimplementedMethodError("copy")

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
    if not obj.isTypeOf then return false end
    if not obj.isEqual then return false end
    if not obj.copy then return false end
    -- ToDo: consider adding checks for method (parameter) signatures.

    -- end
    return true
end

return IObj
