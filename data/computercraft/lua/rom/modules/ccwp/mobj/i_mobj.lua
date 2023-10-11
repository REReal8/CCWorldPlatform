-- define interface
local IMObj = {
}

--[[
    This module specifies the interface IMObj.

    The IMObj interface defines methods for objects representing "physical" things in the minecraft world that we would
    like to programmically interact with. Objects of a class implementing the interface are referred to as MObj's.
    MObj's are hosted by a MObjHost who interacts with the defined methods in this interface.

    MObj's should make sure that any async work is registered in the WIPAdministrator with the MObj id as wipId.
    For async work via projects this can be done by setting the 'wipId' key in the projectMeta to the MObj id.
--]]

local corelog = require "corelog"

local IInterface = require "i_interface"
local InputChecker = require "input_checker"

--    _____ __  __  ____  _     _
--   |_   _|  \/  |/ __ \| |   (_)
--     | | | \  / | |  | | |__  _
--     | | | |\/| | |  | | '_ \| |
--    _| |_| |  | | |__| | |_) | |
--   |_____|_|  |_|\____/|_.__/| |
--                            _/ |
--                           |__/

function IMObj:construct(...)
    -- get & check input from description
    local checkSuccess, param1, param2 = InputChecker.Check([[
        This method constructs a XXXMObj instance from a table of parameters with all necessary fields (in an objectTable) and methods (by setmetatable) as defined in the class.

        It also ensures all child MObj's the XXXMObj spawns are hosted on the appropriate MObjHost (by calling hostMObj_SSrv).

        The constructed XXXMObj is not yet saved in the MObjHost.

        Return value:
                                        - (XXXMObj) the constructed XXXMObj

        Parameters:
            constructParameters         - (table) parameters for constructing the XXXMObj
                param1                  + (Location) location of XXXMObj
                param2                  + (number, 2) ...
                ...
    ]], table.unpack(arg))
    if not checkSuccess then corelog.Error("XXXMObj:construct: Invalid input") return nil end

    IInterface.UnimplementedMethodError("IMObj", "construct")

    -- end
    return nil
end

function IMObj:destruct()
    --[[
        This method destructs a XXXMObj instance.

        It also ensures all child MObj's the XXXMObj is the parent of are released from the appropriate MObjHost (by calling releaseMObj_SSrv).

        The XXXMObj is not yet deleted from the MObjHost.

        Return value:
                                        - (boolean) whether the XXXMObj was succesfully destructed.

        Parameters:
    ]]

    IInterface.UnimplementedMethodError("IMObj", "destruct")

    -- end
    return false
end

function IMObj:getId()
    --[[
        Return the unique Id of the XXXMObj.
    ]]

    IInterface.UnimplementedMethodError("IMObj", "getId")

    -- end
    return "???"
end

function IMObj:getWIPId()
    --[[
        Returns the unique Id of the XXXMObj used for administering WIP.
    ]]

    IInterface.UnimplementedMethodError("IMObj", "getWIPId")

    -- end
    return "???"
end

function IMObj:getBuildBlueprint()
    --[[
        This method returns a blueprint for building the XXXMObj in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
    ]]

    IInterface.UnimplementedMethodError("IMObj", "getBuildBlueprint")

    -- end
    return nil, nil
end

function IMObj:getDismantleBlueprint()
    --[[
        This method returns a blueprint for dismantling the XXXMObj in the physical minecraft world.

        Return value:
            buildLocation               - (Location) the location to build the blueprint
            blueprint                   - (table) the blueprint

        Parameters:
    ]]

    IInterface.UnimplementedMethodError("IMObj", "getDismantleBlueprint")

    -- end
    return nil, nil
end

return IMObj
