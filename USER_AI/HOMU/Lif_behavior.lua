--[[ Lif / Lif_H：共用主树；不续 buff、Kill 不主动施法（见 skill.lua / kill/lif.lua）]]

local BaseBehavior = require('AI_sakray/USER_AI/HOMU/base_behavior')

local LifBehaviorTree = {
    root = BaseBehavior.root,
}

return LifBehaviorTree
