local UseSkill = require('AI_sakray/USER_AI/BehaviorTree/common/actions/UseSkill')
--[[
    UseSkillTask

    使用技能
]]

return Task:new(
    RunningOrNot:new(
        ActionNode:new(function()
            ---@type UseSkillTask
            local task = Blackboard.task

            UseSkill(task.level, task.type, task.target_id)

            return NodeStates.FAILURE
        end)
    )
)
