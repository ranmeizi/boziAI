local Node = require("AI_sakray.USER_AI.BehaviorTree.Core.Node")
local ActionNode = setmetatable({}, { __index = Node })
ActionNode.__index = ActionNode

function ActionNode:new(action)
    local node = setmetatable(Node.new(self), self) -- 确保绑定到 ActionNode
    node.action = action
    return node
end

function ActionNode:execute()
    if self.action then
        return self.action()
    end
    return NodeStates.FAILURE
end

return ActionNode