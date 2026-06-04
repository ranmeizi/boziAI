--[[ Vanilmirth 系 Drain：混乱 HVAN_CHAOTIC；选怪规则可在此扩展 pick_target ]]

local ConfigModule = require('AI_sakray/USER_AI/ConfigModule')

---@type DrainStrategy
local strategy = {
    id = 'vanilmirth',
    skill_type = HVAN_CHAOTIC,
    default_range = 14,
    still_delay_ms = function()
        return ConfigModule.vanilmirth_drain_still_delay_ms()
    end,

    skill_level = function()
        return ConfigModule.vanilmirth_drain_skill_level()
    end,

    is_target_eligible = function(_monster, _mid)
        return ConfigModule.is_vanilmirth_drain_target_eligible(_monster, _mid)
    end,

    -- 示例：以后可改为按 SP、怪类型优先级等
    -- pick_target = function(candidates) ... end
}

return strategy
