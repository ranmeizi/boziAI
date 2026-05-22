local Node = require("AI_sakray.USER_AI.BehaviorTree.Core.Node")
local Cooldown = setmetatable({}, { __index = Node })
Cooldown.__index = Cooldown

function Cooldown:new(child, duration)
    local node = setmetatable(Node.new(self), self) -- 确保绑定到 Cooldown
    node.child = child
    node.duration = duration
    node.lastExecution = 0
    return node
end

function Cooldown:execute()
    local currentTick = GetTick()
    if currentTick >= self.lastExecution + self.duration then
        self.lastExecution = currentTick
        return self.child:execute()
    end
    return NodeStates.FAILURE
end

return Cooldown