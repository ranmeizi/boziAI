-- 把 Core 全挂全局上

_G.Selector = require('AI_sakray/USER_AI/BehaviorTree/Core/ControlNodes/Selector')
_G.Sequence = require('AI_sakray/USER_AI/BehaviorTree/Core/ControlNodes/Sequence')

_G.Cooldown = require('AI_sakray/USER_AI/BehaviorTree/Core/DecoratorNodes/Cooldown')
_G.Failer = require('AI_sakray/USER_AI/BehaviorTree/Core/DecoratorNodes/Failer')
_G.Inverter = require('AI_sakray/USER_AI/BehaviorTree/Core/DecoratorNodes/Inverter')
_G.Repeat = require('AI_sakray/USER_AI/BehaviorTree/Core/DecoratorNodes/Repeat')
_G.Retry = require('AI_sakray/USER_AI/BehaviorTree/Core/DecoratorNodes/Retry')
_G.Succeeder = require('AI_sakray/USER_AI/BehaviorTree/Core/DecoratorNodes/Succeeder')
_G.Task = require('AI_sakray/USER_AI/BehaviorTree/Core/DecoratorNodes/Task')
_G.Timeout = require('AI_sakray/USER_AI/BehaviorTree/Core/DecoratorNodes/Timeout')
_G.RunningOrNot = require('AI_sakray/USER_AI/BehaviorTree/Core/DecoratorNodes/RunningOrNot')

_G.ActionNode = require('AI_sakray/USER_AI/BehaviorTree/Core/ExecutionNodes/ActionNode')
_G.ConditionNode = require('AI_sakray/USER_AI/BehaviorTree/Core/ExecutionNodes/ConditionNode')

_G.BehaviorTree = require('AI_sakray/USER_AI/BehaviorTree/Core/BehaviorTree')