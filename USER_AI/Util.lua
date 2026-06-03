Logger = require('AI_sakray/USER_AI/Logger')

function GetDistance(x1, y1, x2, y2)
	return math.floor(math.sqrt((x1 - x2) ^ 2 + (y1 - y2) ^ 2))
end

function GetDistance2(id1, id2)
	local x1, y1 = GetV(V_POSITION, id1)
	local x2, y2 = GetV(V_POSITION, id2)
	if (x1 == -1 or x2 == -1) then
		return -1
	end
	return GetDistance(x1, y1, x2, y2)
end

function GetOwnerPosition(id)
	return GetV(V_POSITION, GetV(V_OWNER, id))
end

function GetDistanceFromOwner(id)
	local x1, y1 = GetOwnerPosition(id)
	local x2, y2 = GetV(V_POSITION, id)
	if (x1 == -1 or x2 == -1) then
		return -1
	end
	return GetDistance(x1, y1, x2, y2)
end

function IsOutOfSight(id1, id2)
	local x1, y1 = GetV(V_POSITION, id1)
	local x2, y2 = GetV(V_POSITION, id2)
	if (x1 == -1 or x2 == -1) then
		return true
	end
	local d = GetDistance(x1, y1, x2, y2)
	if d > 20 then
		return true
	else
		return false
	end
end

-- 插队
---comment
---@param task MoveToTask | KillTask | StopTask | FarmTask | GrindTask | DrainTask | TouchTask | UseSkillTask | Solve2048Task | RoundHeartTask | RoundRectTask | RoundRandomTask
---@param options TryJumpTaskOptions | nil
function TryJumpTask(task, options)
	-- 保存当前任务
	local currTask = Blackboard.task
	if currTask ~= nil then
		Blackboard.task = nil
		Blackboard.task_queue:unshift(currTask)
	end

	local removeUniqueTask = options == nil and nil or options.removeUniqueTask

	if removeUniqueTask == true then
		-- 删除 queue 里 名为 task.name 的任务
		Blackboard.task_queue = Blackboard.task_queue:filter(function(item)
			return item.name ~= task.name
		end)
	end

	Blackboard.task = task

	return NodeStates.SUCCESS
end

--- 当前无 task 时从队列取出 persistent 任务（如 Grind/Farm/Drain）
---@return boolean promoted
function promoteTaskFromQueue()
	if Blackboard.task ~= nil then
		return false
	end
	if Blackboard.task_queue == nil or Blackboard.task_queue:len() == 0 then
		return false
	end
	Blackboard.task = Blackboard.task_queue:shift()
	Logger.info('[AI] promote task from queue: ' .. tostring(Blackboard.task.name))
	return true
end

---@param task table|nil
local function reset_kill_task_runtime(task)
	if task == nil then
		return
	end
	if task.name ~= 'Kill' then
		return
	end
	task._hasFirstAttack = nil
	task._skillOnWay = nil
end

--- 生命体重新召唤（id 变化）时清 Kill 临时状态
---@param old_id number
---@param new_id number
function on_homunculus_id_changed(old_id, new_id)
	Logger.info(string.format(
		'[AI] homunculus id changed %s -> %s',
		tostring(old_id), tostring(new_id)
	))
	reset_kill_task_runtime(Blackboard.task)
	if Blackboard.task_queue ~= nil then
		for _, t in Blackboard.task_queue:ipairs() do
			reset_kill_task_runtime(t)
		end
	end
end

-- 是否经历了 X 秒
---@param sec number
function PerXSecond(sec)
	return math.floor(GetTick() / 1000) % sec == 0
end
