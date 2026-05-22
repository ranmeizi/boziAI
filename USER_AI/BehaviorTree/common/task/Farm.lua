local Logger = require('AI_sakray/USER_AI/Logger')
local FindTarget = require 'AI_sakray.USER_AI.BehaviorTree.common.actions.FindTarget'

--[[
    Farm loop — 生命体自主控角

    寻敌策略：madDogFindTarget（优先主人正在打的目标，否则最近怪）
    无目标：跟主人；有目标：Kill。
]]
local Farm = Sequence:new({
    ActionNode:new(function()
        Blackboard.objects.bestTarget = nil

        local res = FindTarget.madDogFindTarget()
        Blackboard.objects.bestTarget = res

        if res == nil then
            Logger.debug('FARM TARGET NIL')
            MoveToOwner(Blackboard.id)
            return NodeStates.SUCCESS
        end

        Logger.debug('FARM has target id=' .. tostring(res))
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
    end),
})

return Farm
