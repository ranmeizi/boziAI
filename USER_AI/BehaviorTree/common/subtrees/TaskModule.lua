local Logger = require('AI_sakray/USER_AI/Logger')
Logger.info('TaskModule')
local Farm = require 'AI_sakray.USER_AI.BehaviorTree.common.task.Farm'
local Grind = require 'AI_sakray.USER_AI.BehaviorTree.common.task.Grind'
local Drain = require 'AI_sakray.USER_AI.BehaviorTree.common.task.Drain'
local Touch = require 'AI_sakray.USER_AI.BehaviorTree.common.task.Touch'

local MoveTo = require 'AI_sakray.USER_AI.BehaviorTree.common.task.MoveTo'
local Kill = require 'AI_sakray.USER_AI.BehaviorTree.common.task.Kill'
local Stop = require('AI_sakray/USER_AI/BehaviorTree/common/task/Stop')
local UseSkill = require('AI_sakray/USER_AI/BehaviorTree/common/task/UseSkill')
local Solve2048 = require("AI_sakray/USER_AI/BehaviorTree/common/task/Solve2048")
local RoundHeart = require('AI_sakray/USER_AI/BehaviorTree/common/task/Funny/RoundHeart')
local RoundRect = require('AI_sakray/USER_AI/BehaviorTree/common/task/Funny/RoundRect')
local RoundRandom = require('AI_sakray/USER_AI/BehaviorTree/common/task/Funny/RoundRandom')

local handlers = {
    MoveTo = MoveTo,
    Kill = Kill,
    Stop = Stop,
    Farm = Farm,
    Grind = Grind,
    Drain = Drain,
    Touch = Touch,
    UseSkill = UseSkill,
    Solve2048 = Solve2048,
    RoundHeart = RoundHeart,
    RoundRect = RoundRect,
    RoundRandom = RoundRandom
}

local TaskModule = {}
TaskModule.__index = TaskModule

function TaskModule.execute()
    -- TraceAI('TaskModule start')

    -- 检查任务
    if Blackboard.task == nil then
        -- TraceAI('TaskModule Failure,reason no task')
        return NodeStates.FAILURE
    end

    -- TraceAI('seeeeeee' .. Blackboard.task.name)
    -- 检查handler
    local handler = handlers[Blackboard.task.name]

    if handler == nil then
        -- TraceAI('TaskModule Failure,reason no handler')
        return NodeStates.FAILURE
    end

    -- TraceAI('TaskModule Success')

    return handler:execute()
end

return TaskModule
