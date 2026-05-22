--[[
  各系生命体共用的主行为树根：命令 → 环境 → 任务 → 空闲
]]

local CommandModule = require('AI_sakray/USER_AI/BehaviorTree/common/subtrees/CommandModule')
local TaskModule = require('AI_sakray/USER_AI/BehaviorTree/common/subtrees/TaskModule')
local EnvironmentModule = require('AI_sakray/USER_AI/BehaviorTree/common/subtrees/EnvironmentModule')
local IDLE = require('AI_sakray/USER_AI/BehaviorTree/common/subtrees/IDLE')

local BaseBehavior = {}

BaseBehavior.root = Sequence:new({
    CommandModule,
    EnvironmentModule,
    Inverter:new(TaskModule),
    IDLE,
})

return BaseBehavior
