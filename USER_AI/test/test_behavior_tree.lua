local Sequence = require("AI_sakray.USER_AI.BehaviorTree.Core.ControlNodes.Sequence")
local Selector = require("AI_sakray.USER_AI.BehaviorTree.Core.ControlNodes.Selector")
local ActionNode = require("AI_sakray.USER_AI.BehaviorTree.Core.ExecutionNodes.ActionNode")
local ConditionNode = require("AI_sakray.USER_AI.BehaviorTree.Core.ExecutionNodes.ConditionNode")
local Cooldown = require("AI_sakray.USER_AI.BehaviorTree.Core.DecoratorNodes.Cooldown")
local Succeeder = require("AI_sakray.USER_AI.BehaviorTree.Core.DecoratorNodes.Succeeder")
local Retry = require("AI_sakray.USER_AI.BehaviorTree.Core.DecoratorNodes.Retry")
local Repeat = require("AI_sakray.USER_AI.BehaviorTree.Core.DecoratorNodes.Repeat")
local Inverter = require("AI_sakray.USER_AI.BehaviorTree.Core.DecoratorNodes.Inverter")
local Failer = require("AI_sakray.USER_AI.BehaviorTree.Core.DecoratorNodes.Failer")
local Timeout = require("AI_sakray.USER_AI.BehaviorTree.Core.DecoratorNodes.Timeout")
require 'AI_sakray.USER_AI.libs.ragnarok'

-- 测试条件节点
local function isEnemyNearby()
    print("检查敌人是否在附近...")
    return true
end

local conditionNode = ConditionNode:new(isEnemyNearby)
assert(conditionNode:execute() == true, "ConditionNode 测试失败")

-- 测试动作节点
local function attackEnemy()
    print("攻击敌人!")
    return true
end

local actionNode = ActionNode:new(attackEnemy)
assert(actionNode:execute() == true, "ActionNode 测试失败")

-- 测试选择器节点
local selector = Selector:new({
    ConditionNode:new(function() return false end),
    ActionNode:new(function() print("选择器执行动作"); return true end)
})
assert(selector:execute() == true, "Selector 测试失败")

-- 测试序列节点
local sequence = Sequence:new({
    ConditionNode:new(function() return true end),
    ActionNode:new(function() print("序列执行动作"); return true end)
})
assert(sequence:execute() == true, "Sequence 测试失败")

-- 测试 Cooldown
local cooldownNode = Cooldown:new(ActionNode:new(function()
    print("执行 Cooldown 动作")
    return true
end), 10)

assert(cooldownNode:execute() == true, "Cooldown 测试失败")
assert(cooldownNode:execute() == false, "Cooldown 测试失败")

-- 测试 Succeeder
local succeederNode = Succeeder:new(ActionNode:new(function()
    print("执行 Succeeder 动作")
    return false
end))
assert(succeederNode:execute() == true, "Succeeder 测试失败")

-- 测试 Retry
local retryNode = Retry:new(ActionNode:new(function()
    print("执行 Retry 动作")
    return false
end), 3)
assert(retryNode:execute() == false, "Retry 测试失败")

-- 测试 Repeat
local repeatNode = Repeat:new(ActionNode:new(function()
    print("执行 Repeat 动作")
    return true
end), 3)
assert(repeatNode:execute() == true, "Repeat 测试失败")

-- 测试 Inverter
local inverterNode = Inverter:new(ActionNode:new(function()
    print("执行 Inverter 动作")
    return false
end))
assert(inverterNode:execute() == true, "Inverter 测试失败")

-- 测试 Failer
local failerNode = Failer:new(ActionNode:new(function()
    print("执行 Failer 动作")
    return true
end))
assert(failerNode:execute() == false, "Failer 测试失败")

-- 测试 Timeout
local timeoutNode = Timeout:new(ActionNode:new(function()
    print("执行 Timeout 动作")
    return true
end), 10)
assert(timeoutNode:execute() == true, "Timeout 测试失败")

print("所有测试通过!")