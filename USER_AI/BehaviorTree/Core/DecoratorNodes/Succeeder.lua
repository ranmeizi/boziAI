local Node = require("AI_sakray.USER_AI.BehaviorTree.Core.Node")
local Succeeder = setmetatable({}, { __index = Node })
Succeeder.__index = Succeeder

function Succeeder:new(child)
    local node = Node.new(self)
    node.child = child
    return node
end

function Succeeder:execute()
    self.child:execute()
    return NodeStates.SUCCESS
end

return Succeeder