--[[ Filir / Filir_H：月光 + 普攻节奏 ]]

local UseSkill = require('AI_sakray/USER_AI/BehaviorTree/common/actions/UseSkill')
local NormalAttack = require('AI_sakray/USER_AI/BehaviorTree/common/actions/NormalAttack')
local SkillInfo = require('AI_sakray/USER_AI/HOMU/skill')
local Common = require('AI_sakray/USER_AI/HOMU/kill/common')

local function filir_min_buff_sp()
    return SkillInfo.skillbook[HFLI_FLEET]['1'].sp_cost
        + SkillInfo.skillbook[HFLI_SPEED]['1'].sp_cost
end

local function filir_kill_subtree()
    local giveupable_moveto = Common.make_giveupable_moveto()

    return Succeeder:new(
        Sequence:new({
            Inverter:new(
                Selector:new({
                    Sequence:new({
                        ConditionNode:new(Task.withTask(function(task)
                            if task._hasFirstAttack == true then
                                return NodeStates.FAILURE
                            end
                            return NodeStates.SUCCESS
                        end)),
                        ActionNode:new(Task.withTask(function(task)
                            local res = NormalAttack(task.target_id)
                            if res == NodeStates.FAILURE then
                                return res
                            end
                            Blackboard.task._hasFirstAttack = true
                            return NodeStates.SUCCESS
                        end)),
                    }),
                    ActionNode:new(Task.withTask(function(task)
                        if task.mode ~= 'skillonly'
                            and Blackboard.objects.homu.sp > Blackboard.objects.homu.sp_max * 0.8 then
                            Blackboard.task.mode = 'skillonly'
                        end
                        if task.mode == 'skillonly' and Blackboard.objects.homu.sp < filir_min_buff_sp() then
                            Blackboard.task.mode = 'default'
                        end
                        return NodeStates.FAILURE
                    end)),
                    ActionNode:new(Task.withTask(function(task)
                        if task.mode == 'skillonly' and GetDistance2(task.target_id, Blackboard.id) <= 2 then
                            UseSkill(1, HFLI_MOON, task.target_id)
                            return NodeStates.SUCCESS
                        end
                        return NodeStates.FAILURE
                    end)),
                    ActionNode:new(Task.withTask(function(task)
                        return NormalAttack(task.target_id)
                    end)),
                })
            ),
            giveupable_moveto,
        })
    )
end

return {
    build = filir_kill_subtree,
}
