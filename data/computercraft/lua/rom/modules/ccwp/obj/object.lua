local Class = {}

function Class.IsInstanceOf(object, prototype)
    --[[
        Function that returns if a given object is an instance of a specified (proto)type (class or interface).
    ]]

    local mt = getmetatable(object)
    while mt do
        if mt == prototype then
            return true
        end
        mt = getmetatable(mt)
    end

    return false
end

return Class
