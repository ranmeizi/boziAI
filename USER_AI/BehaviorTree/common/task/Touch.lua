--[[
    Touch：对目标施放一次 Drain 策略对应技能，并登记触摸冷却。
]]

local UseSkill = require('AI_sakray/USER_AI/BehaviorTree/common/actions/UseSkill')
local Drain = require('AI_sakray/USER_AI/BehaviorTree/common/task/Drain')
local Registry = require('AI_sakray/USER_AI/HOMU/drain/registry')

local function resolve_skill_level(strategy)
    local lv = strategy.skill_level
    if type(lv) == 'function' then
        return lv()
    end
    return lv or 1
end

return Task:new(
    RunningOrNot:new(
        ActionNode:new(function()
            local task = Blackboard.task
            if task == nil or task.target_id == nil then
                return NodeStates.FAILURE
            end

            local strategy = Registry.get_strategy_for_blackboard()
            local level = resolve_skill_level(strategy)
            UseSkill(level, strategy.skill_type, task.target_id)
            Drain.touchRegistry.mark(task.target_id)

            return NodeStates.FAILURE
        end)
    )
)
