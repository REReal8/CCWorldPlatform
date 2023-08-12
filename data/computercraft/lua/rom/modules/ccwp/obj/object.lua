local Object = {}

function Object.IsInstanceOf(object, class)
    --[[
        Function that returns if a given object is an instance of the specified class (or interface).
    ]]

    local mt = getmetatable(object)
    while mt do
        if mt == class then
            return true
        end
        mt = getmetatable(mt)
    end

    return false
end

return Object