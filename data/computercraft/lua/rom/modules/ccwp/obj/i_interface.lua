local IInterface = {
}

--[[
    This module specifies the IInterface interface.

    It defines functions other interfaces can use.
--]]

--    _____ _____       _             __
--   |_   _|_   _|     | |           / _|
--     | |   | |  _ __ | |_ ___ _ __| |_ __ _  ___ ___
--     | |   | | | '_ \| __/ _ \ '__|  _/ _` |/ __/ _ \
--    _| |_ _| |_| | | | ||  __/ |  | || (_| | (_|  __/
--   |_____|_____|_| |_|\__\___|_|  |_| \__,_|\___\___|

function IInterface.UnimplementedMethodError(interfaceName, methodName)
    error("Method "..methodName.."() should be implemented in Obj classes. It should not be called directly on "..interfaceName.." interface.")
end

return IInterface
