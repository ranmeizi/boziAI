--[[
  按 V_HOMUNTYPE 选择行为树模块（见 Const.lua）
]]

local FilirBT = require('AI_sakray/USER_AI/HOMU/Filir_behavior')
local LifBT = require('AI_sakray/USER_AI/HOMU/Lif_behavior')
local AmistrBT = require('AI_sakray/USER_AI/HOMU/Amistr_behavior')
local VanilmirthBT = require('AI_sakray/USER_AI/HOMU/Vanilmirth_behavior')

local Trees = {}

---@type table<number, table>
Trees.by_type = {
    [FILIR] = FilirBT,
    [FILIR2] = FilirBT,
    [FILIR_H] = FilirBT,
    [FILIR_H2] = FilirBT,
    [LIF] = LifBT,
    [LIF2] = LifBT,
    [LIF_H] = LifBT,
    [LIF_H2] = LifBT,
    [AMISTR] = AmistrBT,
    [AMISTR2] = AmistrBT,
    [AMISTR_H] = AmistrBT,
    [AMISTR_H2] = AmistrBT,
    [VANILMIRTH] = VanilmirthBT,
    [VANILMIRTH2] = VanilmirthBT,
    [VANILMIRTH_H] = VanilmirthBT,
    [VANILMIRTH_H2] = VanilmirthBT,
}

Trees.default = FilirBT

---@param homun_type number|nil GetV(V_HOMUNTYPE, id)
---@return table behavior module with .root
function Trees.get_module(homun_type)
    if homun_type == nil then
        return Trees.default
    end
    return Trees.by_type[homun_type] or Trees.default
end

return Trees
