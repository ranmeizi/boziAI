--[[ Kill 任务共用节点与默认近战策略 ]]

local NormalAttack = require('AI_sakray/USER_AI/BehaviorTree/common/actions/NormalAttack')
local MoveTo = require('AI_sakray/USER_AI/BehaviorTree/common/actions/MoveTo')

local M = {}

M.GIVEUP_TIME = 7 * 1000
M.IGNORE_TIME = 60 * 1000 * 2

--- @param task KillTask
function M.condition_is_dead(task)
    if task == nil then
        return NodeStates.SUCCESS
    end

    local target = Blackboard.objects.monsters[task.target_id]
    if target == nil then
        return NodeStates.SUCCESS
    end

    if target.motion == MOTION_DEAD then
        return NodeStates.SUCCESS
    end

    return NodeStates.FAILURE
end

--- @param task KillTask
function M.action_attack(task)
    return NormalAttack(task.target_id)
end

--- @param task KillTask
function M.action_move_to(task)
    return MoveTo({
        target_id = task.target_id,
        kill_extension = true,
    })
end

function M.make_giveupable_moveto()
    return Selector:new({
        Timeout:new(
            'moveto_timer',
            ActionNode:new(function()
                local task = Blackboard.task
                if task == nil then
                    return NodeStates.FAILURE
                end
                Blackboard.ignore_cache:set(task.target_id, task.target_id, M.IGNORE_TIME)
                return NodeStates.SUCCESS
            end),
            M.GIVEUP_TIME
        ),
        ActionNode:new(Task.withTask(M.action_move_to)),
    })
end

--- 走打：先普攻（失败也继续），再追击 / 绕目标移动
function M.make_default_strategy()
    local giveupable_moveto = M.make_giveupable_moveto()
    return Succeeder:new(
        Sequence:new({
            Succeeder:new(ActionNode:new(Task.withTask(M.action_attack))),
            giveupable_moveto,
        })
    )
end

return M
