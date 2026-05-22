local Node = {}
Node.__index = Node

function Node:new()
    local node = setmetatable({}, self) -- 确保绑定到调用者的元表
    return node
end

function Node:execute()
    error("execute() must be implemented in derived classes")
end

return Node
