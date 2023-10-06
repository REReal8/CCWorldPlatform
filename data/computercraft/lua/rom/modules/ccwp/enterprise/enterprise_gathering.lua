-- define class
local Class = require "class"
local MObjHost = require "mobj_host"
local enterprise_gathering = Class.NewClass(MObjHost)

--[[
    The enterprise_gathering is a MObjHost. It provides services for building and using MObj's where materials can be gathered, like mines and on the surface.
--]]

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

-- note: currently enterprise is treated like a singleton, but by directly using the name of the module
-- ToDo: consider making changes to enteprise to
--          - explicitly make it a singleton (by construction with :newInstance(hostName) and using the singleton pattern)
--          - properly initialise it (by adding and implementing the _init method)
--          - adopt other classes to these changes
enterprise_gathering._hostName  = "enterprise_gathering"

--    _____ ____  _     _                  _   _               _
--   |_   _/ __ \| |   (_)                | | | |             | |
--     | || |  | | |__  _   _ __ ___   ___| |_| |__   ___   __| |___
--     | || |  | | '_ \| | | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--    _| || |__| | |_) | | | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |_____\____/|_.__/| | |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--                    _/ |
--                   |__/

function enterprise_gathering:getClassName()
    return "enterprise_gathering"
end

--                        _                           _   _               _
--                       (_)                         | | | |             | |
--    ___  ___ _ ____   ___  ___ ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __|/ _ \ '__\ \ / / |/ __/ _ \ | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \  __/ |   \ V /| | (_|  __/ | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/\___|_|    \_/ |_|\___\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/

return enterprise_gathering
