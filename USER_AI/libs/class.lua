-- Implementation helper for metatable-based "classes"
return function(class_table, superclass_table)
    if superclass_table then
        setmetatable(class_table, { __index = superclass_table })
    end
    local new = assert(class_table.new)
    local metatable = {
        __index = class_table,
        __tojson = function(t)
            local cleaned = {}
            for k, v in pairs(t) do
                if type(v) ~= "function" then
                    cleaned[k] = v
                end
                return json.encode(cleaned)
            end
        end
    }
    function class_table.new(...)
        return setmetatable(new(...), metatable)
    end

    return class_table
end
