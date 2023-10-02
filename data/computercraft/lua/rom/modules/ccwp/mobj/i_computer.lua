-- define interface
local IComputer = {
}

--[[
    This module specifies the interface IComputer.

    The IComputer interface defines methods for computational entities in CCWP (e.g. computercraft computers and turtiles). They are the
    objects on which the CCWP code is run.
--]]

local IInterface = require "i_interface"

--    _____ _____                            _                             _   _               _
--   |_   _/ ____|                          | |                           | | | |             | |
--     | || |     ___  _ __ ___  _ __  _   _| |_ ___ _ __   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |    / _ \| '_ ` _ \| '_ \| | | | __/ _ \ '__| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |___| (_) | | | | | | |_) | |_| | ||  __/ |    | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\_____\___/|_| |_| |_| .__/ \__,_|\__\___|_|    |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                              | |
--                              |_|

function IComputer:getComputerID()
    --[[
        Get the computer's ID.

        Return value:
                                - (number) the computer's ID
    ]]

    IInterface.UnimplementedMethodError("IComputer", "getComputerId")

    -- end
    return -1
end

function IComputer:turnOn()
    --[[
        Turn the other computer on.

        Return value:
                                - (boolean) if the computer is on
    ]]

    IInterface.UnimplementedMethodError("IComputer", "turnOn")

    -- end
    return false
end

function IComputer:getMainUIMenu()
    --[[
        Get the main (start) UI menu of the computer.

        This menu can be used in conjuction with coredisplay.MainMenu.

        Return value:
                                - (table)
                clear           - (boolean) whether or not to clear the display,
                func	        - (function) menu function to call
                param	        - (table, {}) parameter to pass to menu function
                intro           - (string) intro to print
                question        - (string, nil) final question to print
    ]]

    IInterface.UnimplementedMethodError("IComputer", "getMainUIMenu")

    -- end
    return {}
end

function IComputer:getAssignmentFilterAndResume()
    --[[
        Get assignment filter and computer resume for finding the next best assignment.

        The assignment filter is used to indicate to only accept assignments that satisfy certain conditions. This can e.g. be used
            to only accept assignments with high priority.

        The resume gives information on the computer and is used to determine if the computer is (best) suitable to take an assignment.
            This is can e.g. be used to indicate location, fuel level and equiped items.

        Return value:
                                    - (table)
                assignmentFilter    - (table) filter to apply in finding an Assignment
                resume              - (table) computer "resume" to consider in finding an Assignment
    --]]

    IInterface.UnimplementedMethodError("IComputer", "getAssignmentFilterAndResume")

    -- end
    return {}
end

return IComputer
