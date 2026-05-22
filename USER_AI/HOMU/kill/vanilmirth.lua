--[[ Vanilmirth / Vanilmirth_H：混沌之触远程技能 + 普攻 ]]

local UseSkill = require('AI_sakray/USER_AI/BehaviorTree/common/actions/UseSkill')
local SkillInfo = require('AI_sakray/USER_AI/HOMU/skill')
local Common = require('AI_sakray/USER_AI/HOMU/kill/common')

local CHAOTIC_RANGE = 9

local function van_min_sp_for_chaotic()
    local book = SkillInfo.skillbook[HVAN_CHAOTIC]
    if book == nil or book['1'] == nil then
        return 9999
    end
    return book['1'].sp_cost
end

local function vanilmirth_kill_subtree()
    local giveupable_moveto = Common.make_giveupable_moveto()

    return Succeeder:new(
        Sequence:new({
            Inverter:new(
                Selector:new({
                    Sequence:new({
                        ConditionNode:new(Task.withTask(function(task)
                            if task._usedChaotic == true then
                                return NodeStates.FAILURE
                            end
                            local dist = GetDistance2(task.target_id, Blackboard.id)
                            if dist <= CHAOTIC_RANGE or Blackboard.objects.homu.sp < van_min_sp_for_chaotic() then
                                return NodeStates.FAILURE
                            end
                            return NodeStates.SUCCESS
                        end)),
                        ActionNode:new(Task.withTask(function(task)
                            UseSkill(1, HVAN_CHAOTIC, task.target_id)
                            Blackboard.task._usedChaotic = true
                            return NodeStates.SUCCESS
                        end)),
                    }),
                    ActionNode:new(Task.withTask(Common.action_attack)),
                })
            ),
            giveupable_moveto,
        })
    )
end

return {
    build = vanilmirth_kill_subtree,
}
