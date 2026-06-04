--[[
    用户配置（由 ConfigModule 在启动时加载）

    target_blacklist / target_whitelist：自动寻敌 V_HOMUNTYPE
    attack_dance：Filir 近战走位（false 则仅 NormalAttack）
    filir_kill：Filir 月光 / 普攻策略
]]

local blacklist = require('AI_sakray/USER_AI/tatget_blacklist_conf')
local whitelist = require('AI_sakray/USER_AI/tatget_whitelist_conf')

return {
    target_blacklist = blacklist,
    target_whitelist = whitelist,

    attack_dance = true,

    filir_kill = {
        skillonly = false,
        moon_range = 14,
        moon_level = 1,
        skill_entry_casts = 10,
        moon_blacklist = {},
    },

    -- Filir Drain（moon_level 省略则沿用 filir_kill.moon_level）
    filir_drain = {},

    -- Vanilmirth Drain：混乱等级；target_blacklist 为 V_HOMUNTYPE 不点名
    vanilmirth_drain = {
        skill_level = 1,
        still_delay_ms = 1000,
        target_blacklist = {},
    },
}
