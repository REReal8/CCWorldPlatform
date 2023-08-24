-- define module
local ModuleRegistry = {
    modules = {},
}

-- ToDo: add proper description here
--[[
    The InputChecker ...
--]]

--    _       _ _   _       _ _           _   _
--   (_)     (_) | (_)     | (_)         | | (_)
--    _ _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __
--   | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \
--   | | | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
--   |_|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

local instance = nil
function ModuleRegistry:getInstance()
    if not instance then
        instance = setmetatable({}, { __index = ModuleRegistry })
    end
    return instance
end

--                        _  __ _                       _   _               _
--                       (_)/ _(_)                     | | | |             | |
--    ___ _ __   ___  ___ _| |_ _  ___   _ __ ___   ___| |_| |__   ___   __| |___
--   / __| '_ \ / _ \/ __| |  _| |/ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
--   \__ \ |_) |  __/ (__| | | | | (__  | | | | | |  __/ |_| | | | (_) | (_| \__ \
--   |___/ .__/ \___|\___|_|_| |_|\___| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
--       | |
--       |_|

function ModuleRegistry:getModule(name)
    return self.modules[name]
end

function ModuleRegistry:registerModule(name, module)
    self.modules[name] = module
end

function ModuleRegistry:isRegistered(name)
    return self.modules[name] ~= nil
end

function ModuleRegistry:requireAndRegisterModule(name, requireName)
    -- use require to get module
    requireName = requireName or name
    local module = require(requireName)

    -- register object
    self:registerModule(name, module)
end

function ModuleRegistry:requireAndRegisterModuleTests(name)
    self:requireAndRegisterModule(name, "test."..name)
end

function ModuleRegistry:delistModule(name)
    self.modules[name] = nil
end

return ModuleRegistry
