local Node = require("AI_sakray.USER_AI.BehaviorTree.Core.Node")
local RunningOrNot = setmetatable({}, { __index = Node })
RunningOrNot.__index = RunningOrNot

function RunningOrNot:new(child, callback)
    local node = setmetatable(Node.new(self), self)
    node.child = child
    node.callback = callback
    return node
end

function RunningOrNot:execute()
    -- 执行子节点
    local status = self.child:execute()

    -- 如果子节点返回 SUCCESS，将其转换为 RUNNING
    if status == NodeStates.SUCCESS then
        return NodeStates.RUNNING
    end

    -- 任务结束 callback , 这里可以清理一些任务的副作用，例如关闭 keepbuff
    if self.callback ~= nil then
        self.callback()
    end

    -- 其他状态保持不变
    return status
end

return RunningOrNot
