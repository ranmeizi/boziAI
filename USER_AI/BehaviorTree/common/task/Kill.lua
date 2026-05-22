--[[
    Kill 杀死目标 [跨tick]

    按 Blackboard.type（V_HOMUNTYPE）选择战斗子树，见 HOMU/kill/registry.lua
]]

local KillRegistry = require('AI_sakray/USER_AI/HOMU/kill/registry')
local Common = require('AI_sakray/USER_AI/HOMU/kill/common')

local KillTask = RunningOrNot:new(
    Sequence:new({
        Inverter:new(ConditionNode:new(Task.withTask(Common.condition_is_dead))),
        ActionNode:new(function()
            return KillRegistry.get_combat_subtree(Blackboard.type):execute()
        end),
    })
)

local Kill = Task:new(KillTask)
---@type Node 与 Kill 任务相同的跨 tick 击杀逻辑（供其它 Task 内嵌）
Kill.running = KillTask

return Kill
