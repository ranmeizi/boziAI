local Node = require("AI_sakray.USER_AI.BehaviorTree.Core.Node")
local ConditionNode = setmetatable({}, { __index = Node })
ConditionNode.__index = ConditionNode

function ConditionNode:new(condition)
    local node = setmetatable(Node.new(self), self) -- 确保绑定到 ConditionNode
    node.condition = condition
    return node
end

function ConditionNode:execute()
    if self.condition then
        return self.condition()
    end
    return NodeStates.FAILURE
end

return ConditionNode