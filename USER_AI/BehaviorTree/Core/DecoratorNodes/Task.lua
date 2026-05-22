local Logger = require('AI_sakray/USER_AI/Logger')
local Node = require("AI_sakray.USER_AI.BehaviorTree.Core.Node")
local TaskNode = setmetatable({}, { __index = Node })
TaskNode.__index = TaskNode

function TaskNode:new(child)
    local node = setmetatable(Node.new(self), self)
    node.child = child
    return node
end

function TaskNode:execute()
    -- 执行子节点
    local status = self.child:execute()

    if status == NodeStates.RUNNING then
        -- 如果子节点返回 RUNNING，保持任务不变
        return NodeStates.SUCCESS
    elseif status == NodeStates.SUCCESS or status == NodeStates.FAILURE then
        -- 如果子节点返回 SUCCESS 或 FAILURE，清除当前任务
        Logger.info('TaskNode: 当前任务完成，状态: ' .. (status == NodeStates.SUCCESS and 'SUCCESS' or 'FAILURE'))
        Blackboard.task = nil

        -- 从任务队列中取下一个任务
        local nextTask = Blackboard.task_queue:shift()
        if nextTask then
            Blackboard.task = nextTask
            Logger.info('TaskNode: 从任务队列中取出新任务: ' .. tostring(nextTask.name))
            return NodeStates.SUCCESS
        else
            Logger.debug('TaskNode: 没有任务可执行')
            return NodeStates.FAILURE
        end
    end
    return status
end

--- 高阶函数 withTask
--- @generic T : table
--- @param task T 任务对象，必须是一个表
--- @param func fun(task: T): NodeStates 子函数，接收任务对象并返回节点状态
--- @return fun(): NodeStates 返回一个包装后的函数
local function withTask(func)
    return function()
        local task = Blackboard.task
        return func(task)
    end
end

TaskNode.withTask = withTask

return TaskNode
