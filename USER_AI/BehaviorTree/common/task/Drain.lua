--[[
    Drain loop（对标 Farm -> Kill）

    按生命体类型选策略（HOMU/drain/）：
    - Filir：月光 HFLI_MOON + moon_blacklist
    - Vanilmirth：混乱 HVAN_CHAOTIC（选怪可扩展 pick_target）

    公共：停格、触摸冷却、低蓝休息见 HOMU/drain/common.lua
]]

local Logger = require('AI_sakray/USER_AI/Logger')
local Common = require('AI_sakray/USER_AI/HOMU/drain/common')
local Registry = require('AI_sakray/USER_AI/HOMU/drain/registry')

local Drain = Sequence:new({
    ActionNode:new(function()
        local strategy = Registry.get_strategy_for_blackboard()
        Blackboard.objects.drainTouchTarget = nil
        local res = Common.findDrainTarget(strategy)
        Blackboard.objects.drainTouchTarget = res
        if res == nil then
            if Common.isResting() then
                Logger.debug('Drain[' .. strategy.id .. ']: resting (sp recover)')
            else
                Logger.debug('Drain[' .. strategy.id .. ']: no special target')
            end
            MoveToOwner(Blackboard.id)
        end
        return NodeStates.SUCCESS
    end),
    ActionNode:new(function()
        if Blackboard.objects.drainTouchTarget == nil then
            return NodeStates.SUCCESS
        end
        local strategy = Registry.get_strategy_for_blackboard()
        ---@type TouchTask
        TryJumpTask({
            name = 'Touch',
            target_id = Blackboard.objects.drainTouchTarget,
            drain_strategy_id = strategy.id,
        }, {})
        return NodeStates.SUCCESS
    end),
})

Drain.touchRegistry = Common.touchRegistry
Drain.exportTouchedIds = Common.exportTouchedIds
Drain.hydrateTouchedIds = Common.hydrateTouchedIds
Drain.isResting = Common.isResting
Drain.updateRestState = Common.updateRestState
Drain.findDrainTarget = Common.findDrainTarget
Drain.get_skill_range = Common.get_skill_range
Drain.is_in_skill_range = Common.is_in_skill_range

---@deprecated 使用 get_skill_range(strategy)
function Drain.get_moon_range()
    local Registry = require('AI_sakray/USER_AI/HOMU/drain/registry')
    local strategy = Registry.get_strategy_for_blackboard()
    return Common.get_skill_range(strategy)
end

---@deprecated 使用 is_in_skill_range(strategy, id)
function Drain.is_in_moon_range(target_id)
    local Registry = require('AI_sakray/USER_AI/HOMU/drain/registry')
    local strategy = Registry.get_strategy_for_blackboard()
    return Common.is_in_skill_range(strategy, target_id)
end

return Drain
