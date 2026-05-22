local Logger = require('AI_sakray/USER_AI/Logger')
local FindTarget = require 'AI_sakray.USER_AI.BehaviorTree.common.actions.FindTarget'

--[[
    Grind loop — 挂机打怪

    寻敌策略：loyalDogFindTarget（主人目标 → 友方协助 → 仇恨自己/主人 → 最近怪）

    无目标：跟主人；有目标：插队 Kill。
    与 Farm 相同可用 Alt+T 取消；persistent 参与记忆恢复。
]]
local Grind = Sequence:new({
    ActionNode:new(function()
        Blackboard.objects.bestTarget = nil

        local res = FindTarget.loyalDogFindTarget()
        Blackboard.objects.bestTarget = res

        if res == nil then
            Logger.debug('GRIND TARGET NIL')
            MoveToOwner(Blackboard.id)
            return NodeStates.SUCCESS
        end

        return NodeStates.SUCCESS
    end),
    ActionNode:new(function()
        if Blackboard.objects.bestTarget == nil then
            return NodeStates.SUCCESS
        end

        local task = {
            name = 'Kill',
            target_id = Blackboard.objects.bestTarget
        }

        TryJumpTask(task, {})

        return NodeStates.SUCCESS
    end)
})

return Grind
