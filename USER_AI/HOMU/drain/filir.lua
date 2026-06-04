--[[ Filir 系 Drain：月光 HFLI_MOON，念属性等用 moon_blacklist 过滤 ]]

local ConfigModule = require('AI_sakray/USER_AI/ConfigModule')

local function target_homun_type(monster, mid)
    if monster.type ~= nil and monster.type ~= 0 then
        return monster.type
    end
    return GetV(V_HOMUNTYPE, mid)
end

---@type DrainStrategy
local strategy = {
    id = 'filir',
    skill_type = HFLI_MOON,
    default_range = 14,
    still_delay_ms = 1000,

    skill_level = function()
        return ConfigModule.filir_drain_moon_level()
    end,

    is_target_eligible = function(monster, mid)
        return ConfigModule.is_filir_moon_viable_type(target_homun_type(monster, mid))
    end,

    -- pick_target = nil 使用公共「最近一只」
}

return strategy
