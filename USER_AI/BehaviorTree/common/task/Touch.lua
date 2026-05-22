--[[
    Touch：对目标施放一次月光，并将其 id 记入「攻击敌人」表，供 Drain 与其它逻辑过滤。
]]

local UseSkill = require('AI_sakray/USER_AI/BehaviorTree/common/actions/UseSkill')
local Drain = require 'AI_sakray.USER_AI.BehaviorTree.common.task.Drain'

return Task:new(
    RunningOrNot:new(
        ActionNode:new(function()
            local task = Blackboard.task
            if task == nil or task.target_id == nil then
                return NodeStates.FAILURE
            end

            UseSkill(1, HFLI_MOON, task.target_id)
            Drain.touchRegistry.mark(task.target_id)

            -- 与 UseSkillTask 相同：立刻结束当前 Task，让队列里的 Drain 继续
            return NodeStates.FAILURE
        end)
    )
)
