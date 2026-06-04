--[[ 按 V_HOMUNTYPE 返回 Drain 策略（运行时选技能/选怪） ]]

local FilirDrain = require('AI_sakray/USER_AI/HOMU/drain/filir')
local VanilmirthDrain = require('AI_sakray/USER_AI/HOMU/drain/vanilmirth')

local Registry = {}

---@type table<number, DrainStrategy>
Registry.by_type = {
    [FILIR] = FilirDrain,
    [FILIR2] = FilirDrain,
    [FILIR_H] = FilirDrain,
    [FILIR_H2] = FilirDrain,

    [VANILMIRTH] = VanilmirthDrain,
    [VANILMIRTH2] = VanilmirthDrain,
    [VANILMIRTH_H] = VanilmirthDrain,
    [VANILMIRTH_H2] = VanilmirthDrain,
}

Registry.default = FilirDrain

---@param homun_type number|nil
---@return DrainStrategy
function Registry.get_strategy(homun_type)
    return Registry.by_type[homun_type] or Registry.default
end

---@param homun_type number|nil
---@return DrainStrategy
function Registry.get_strategy_for_blackboard(homun_type)
    homun_type = homun_type or (rawget(_G, 'Blackboard') and Blackboard.type)
    return Registry.get_strategy(homun_type)
end

return Registry
