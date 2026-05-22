local Node = require("AI_sakray.USER_AI.BehaviorTree.Core.Node")
local Sequence = setmetatable({}, { __index = Node })
Sequence.__index = Sequence

function Sequence:new(children)
    local node = setmetatable(Node.new(self), self) -- 确保绑定到 Sequence
    node.children = children or {}
    return node
end

function Sequence:execute()
    for _, child in ipairs(self.children) do
        if child:execute() == NodeStates.FAILURE then
            return NodeStates.FAILURE
        end
    end
    return NodeStates.SUCCESS
end

return Sequence