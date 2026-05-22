local Node = require("AI_sakray.USER_AI.BehaviorTree.Core.Node")
local Selector = setmetatable({}, { __index = Node })
Selector.__index = Selector

function Selector:new(children)
    local node = setmetatable(Node.new(self), self) -- 确保绑定到 Selector
    node.children = children or {}
    return node
end

function Selector:execute()
    for _, child in ipairs(self.children) do
        if child:execute() == NodeStates.SUCCESS then
            return NodeStates.SUCCESS
        end
    end
    return NodeStates.FAILURE
end

return Selector