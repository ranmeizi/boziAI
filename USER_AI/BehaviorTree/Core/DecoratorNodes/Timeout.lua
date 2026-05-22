local Node = require("AI_sakray.USER_AI.BehaviorTree.Core.Node")
local Timeout = setmetatable({}, { __index = Node })
Timeout.__index = Timeout

function Timeout:new(name, child, timeout)
    local node = Node.new(self)
    node.child = child
    node.name = name
    node.timeout = timeout
    return node
end

function Timeout:execute()

    if Blackboard.timers[self.name] == nil then
        ---@type AbstractTimer
        Blackboard.timers[self.name] = {
            startTime = GetTick(),
            timeout = self.timeout
        }
    end

    ---@type AbstractTimer
    local timer = Blackboard.timers[self.name]

    local expired_at = timer.startTime + timer.timeout

    if GetTick() < expired_at then
        -- 没到时间
        return NodeStates.FAILURE
    end

    -- 执行
    local status = self.child:execute()

    -- 清空计时器
    Blackboard.timers[self.name] = nil

    return status
end

return Timeout
