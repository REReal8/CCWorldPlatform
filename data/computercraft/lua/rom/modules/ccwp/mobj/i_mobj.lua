local IMObj = {
}

local corelog = require "corelog"

local InputChecker = require "input_checker"
local Callback = require "obj_callback"

--[[
    This module implements the interface IMObj.

    The IMObj interface defines methods for objects representing "physical" things in the minecraft world that we would
    like to programmically interact with. Objects of a class implementing the interface are referred to as MObj's.
    MObj's are hosted by a MObjHost who interacts with the defined methods in this interface.

    MObj's should also implement the IObj interface.
--]]

--    _____ __  __  ____  _     _                  _   _               _
--   |_   _|  \/  |/ __ \| |   (_)                | | | |             | |
--     | | | \  / | |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | | | |\/| | |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| |_| |  | | |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____|_|  |_|\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                            _/ |
--                           |__/

function IMObj:construct(...)
    -- get & check input from description
    local checkSuccess, param1, param2 = InputChecker.Check([[
        This method constructs a XXXMObj instance from a table of parameters with all necessary fields (in an objectTable) and methods (by setmetatable) as defined in the class.

        It also registers all child MObj's the XXXMObj spawns (by calling the RegisterMObj method on the appropriate MObjHost).

        The constructed XXXMObj is not activated or saved in the Host.

        Return value:
                                        - (XXXMObj) the constructed XXXMObj

        Parameters:
            constructParameters         - (table) parameters for constructing the MObj
                param1                  + (Location) location of XXXMObj
                param2                  + (number, 2) ...
                ...
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("XXXMObj:construct: Invalid input") return {} end

    corelog.Error("Method construct() should be implemented in classes implementing the IMObj interface. It should not be called directly.")
end

function IMObj:destruct()
    --[[
        This method destructs a XXXMObj instance.

        It also delists all child MObj's the XXXMObj is the parent of (by calling the DelistMObj method on the appropriate MObjHost).

        The XXXMObj is not yet deleted from the Host.

        Return value:
                                        - (boolean) whether the XXXMObj was succesfully destructed.

        Parameters:
    ]]

    corelog.Error("Method destruct() should be implemented in classes implementing the IMObj interface. It should not be called directly.")
    return false
end

function IMObj:getId()
    --[[
        Return a unique Id of the XXXMObj.
    ]]

    corelog.Error("Method getId() should be implemented in classes implementing the IMObj interface. It should not be called directly.")
end

function IMObj:completeRunningBusiness_AOSrv(...)
    -- get & check input from description
    local checkSuccess, callback = InputChecker.Check([[
        This method ensures all running business is completed.

        Return value:
                                        - (boolean) whether the service was scheduled successfully

        Async service return value (to Callback):
                                        - (table)
                success                 - (boolean) whether all business was successfully completed

        Parameters:
            serviceData                 - (table) data for this service
            callback                    + (Callback) to call once service is ready
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("XXXMObj:completeRunningBusiness_AOSrv: Invalid input") return Callback.ErrorCall(callback) end

    corelog.Error("Service completeRunningBusiness_AOSrv() should be implemented in classes implementing the IMObj interface. It should not be called directly.")
    return Callback.ErrorCall(callback)
end

function IMObj:getBuildBlueprint()
    --[[
        This method returns a blueprint for building the XXXMObj in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
    ]]

    corelog.Error("Method getBuildBlueprint() should be implemented in classes implementing the IMObj interface. It should not be called directly.")
end

function IMObj:getDismantleBlueprint()
    --[[
        This method returns a blueprint for dismantling the XXXMObj in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
    ]]

    corelog.Error("Method getDismantleBlueprint() should be implemented in classes implementing the IMObj interface. It should not be called directly.")
end

--        _        _   _                       _   _               _
--       | |      | | (_)                     | | | |             | |
--    ___| |_ __ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| __/ _` | __| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ || (_| | |_| | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/\__\__,_|\__|_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

function IMObj.ImplementsInterface(obj)
    --[[
        Returns if the object 'obj' implements this interface.
    ]]

    -- check
    if not obj.construct then return false end
    if not obj.destruct then return false end
    if not obj.getId then return false end
    if not obj.completeRunningBusiness_AOSrv then return false end
    if not obj.getBuildBlueprint then return false end
    if not obj.getDismantleBlueprint then return false end
    -- ToDo: consider adding checks for method (parameter) signatures.

    -- end
    return true
end

return IMObj
