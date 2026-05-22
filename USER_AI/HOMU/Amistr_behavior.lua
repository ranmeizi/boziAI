--[[ Amistr / Amistr_H：共用主树；不续 buff、Kill 不主动施法（见 skill.lua / kill/amistr.lua）]]

local BaseBehavior = require('AI_sakray/USER_AI/HOMU/base_behavior')

local AmistrBehaviorTree = {
    root = BaseBehavior.root,
}

return AmistrBehaviorTree
