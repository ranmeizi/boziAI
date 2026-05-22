local MoveTo = require('AI_sakray/USER_AI/BehaviorTree/common/actions/MoveTo')
--[[
    MoveToPos — 移动到 task.pos 或 task.target_id

    子 Action 在到达时返回 FAILURE，RunningOrNot 才会结束本任务。
]]

return Task:new(
    RunningOrNot:new(
        ActionNode:new(function()
            ---@type MoveToTask
            local task = Blackboard.task

            return MoveTo({
                pos_x = task.pos_x,
                pos_y = task.pos_y,
                target_id = task.target_id
            })
        end)
    )
)
