--[[ 按 V_HOMUNTYPE 返回 Kill 战斗子树（模块加载时构建，保持节点状态） ]]

local Common = require('AI_sakray/USER_AI/HOMU/kill/common')
local FilirKill = require('AI_sakray/USER_AI/HOMU/kill/filir')
local LifKill = require('AI_sakray/USER_AI/HOMU/kill/lif')
local AmistrKill = require('AI_sakray/USER_AI/HOMU/kill/amistr')
local VanilmirthKill = require('AI_sakray/USER_AI/HOMU/kill/vanilmirth')

local Registry = {}

local default_subtree = Common.make_default_strategy()

Registry.subtrees = {
    [FILIR] = FilirKill.build(),
    [FILIR2] = FilirKill.build(),
    [FILIR_H] = FilirKill.build(),
    [FILIR_H2] = FilirKill.build(),
    [LIF] = LifKill.build(),
    [LIF2] = LifKill.build(),
    [LIF_H] = LifKill.build(),
    [LIF_H2] = LifKill.build(),
    [AMISTR] = AmistrKill.build(),
    [AMISTR2] = AmistrKill.build(),
    [AMISTR_H] = AmistrKill.build(),
    [AMISTR_H2] = AmistrKill.build(),
    [VANILMIRTH] = VanilmirthKill.build(),
    [VANILMIRTH2] = VanilmirthKill.build(),
    [VANILMIRTH_H] = VanilmirthKill.build(),
    [VANILMIRTH_H2] = VanilmirthKill.build(),
}

---@param homun_type number|nil
---@return Node
function Registry.get_combat_subtree(homun_type)
    return Registry.subtrees[homun_type] or default_subtree
end

return Registry
