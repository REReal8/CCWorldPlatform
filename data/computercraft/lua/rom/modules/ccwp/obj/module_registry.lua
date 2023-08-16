local ModuleRegistry = {
    modules = {},
}

function ModuleRegistry:getModule(name)
    return self.modules[name]
end

local instance = nil
function ModuleRegistry:getInstance()
    if not instance then
        instance = setmetatable({}, { __index = ModuleRegistry })
    end
    return instance
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