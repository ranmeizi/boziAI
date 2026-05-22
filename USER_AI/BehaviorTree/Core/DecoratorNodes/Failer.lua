local Node = require("AI_sakray.USER_AI.BehaviorTree.Core.Node")
local Failer = setmetatable({}, { __index = Node })
Failer.__index = Failer

function Failer:new(child)
    local node = setmetatable(Node.new(self), self) -- 确保绑定到 Failer
    node.child = child
    return node
end

function Failer:execute()
    self.child:execute()
    return NodeStates.FAILURE
end

return Failer