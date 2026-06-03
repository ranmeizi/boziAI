--[[
    Attack dance — 仅距离怪 <= 1 格时走位，否则只普攻。

    目标 MOTION_MOVE：向主人移动 1 格 → 普攻 → Move 到主人格
    目标 MOTION_ATTACK / MOTION_STAND：单帧走位 + 普攻（step / step_double）
]]

local NormalAttack = require('AI_sakray/USER_AI/BehaviorTree/common/actions/NormalAttack')

local M = {
    melee_range = 1,
}

local function sign(n)
    if n > 0 then
        return 1
    end
    if n < 0 then
        return -1
    end
    return 0
end

local function targetMotion(target_id)
    return GetV(V_MOTION, target_id)
end

local function move_toward_owner()
    local owner_id = Blackboard.owner_id
    if owner_id == nil then
        return false
    end
    local ox, oy = GetV(V_POSITION, owner_id)
    local hx, hy = GetV(V_POSITION, Blackboard.id)
    if ox == -1 or oy == -1 or hx == -1 or hy == -1 then
        return false
    end
    local dx = sign(ox - hx)
    local dy = sign(oy - hy)
    if dx == 0 and dy == 0 then
        return false
    end
    Move(Blackboard.id, hx + dx, hy + dy)
    return true
end

local function move_to_owner()
    local owner_id = Blackboard.owner_id
    if owner_id == nil then
        return false
    end
    local ox, oy = GetV(V_POSITION, owner_id)
    if ox == -1 or oy == -1 then
        return false
    end
    Move(Blackboard.id, ox, oy)
    return true
end

local function move_away_then_toward(target_id)
    local mx, my = GetV(V_POSITION, target_id)
    local hx, hy = GetV(V_POSITION, Blackboard.id)
    if mx == -1 or my == -1 or hx == -1 or hy == -1 then
        return false
    end
    local away_x = sign(hx - mx)
    local away_y = sign(hy - my)
    if away_x == 0 and away_y == 0 then
        return false
    end
    local ax = hx + away_x
    local ay = hy + away_y
    Move(Blackboard.id, ax, ay)
    local toward_x = sign(mx - ax)
    local toward_y = sign(my - ay)
    if toward_x == 0 and toward_y == 0 then
        return true
    end
    Move(Blackboard.id, ax + toward_x, ay + toward_y)
    return true
end

local function move_toward_monster(target_id)
    local mx, my = GetV(V_POSITION, target_id)
    local hx, hy = GetV(V_POSITION, Blackboard.id)
    if mx == -1 or my == -1 or hx == -1 or hy == -1 then
        return false
    end
    local dx = sign(mx - hx)
    local dy = sign(my - hy)
    if dx == 0 and dy == 0 then
        return false
    end
    Move(Blackboard.id, hx + dx, hy + dy)
    return true
end

---@param target_id number
---@return NodeStates
local function run_burst_once(target_id)
    move_away_then_toward(target_id)
    move_toward_monster(target_id)
    local res = NormalAttack(target_id)
    move_toward_monster(target_id)
    return res
end

---@param target_id number
---@return NodeStates
local function run_burst_double(target_id)
    move_away_then_toward(target_id)
    local res = NormalAttack(target_id)
    local res2 = NormalAttack(target_id)
    move_toward_monster(target_id)
    move_toward_monster(target_id)
    if res2 == NodeStates.FAILURE then
        return res2
    end
    return res
end

local function in_melee_range(target_id)
    local dist = GetDistance2(Blackboard.id, target_id)
    return dist >= 0 and dist <= M.melee_range
end

---@param task KillTask
---@param burst_fn fun(target_id: number): NodeStates
---@return NodeStates
local function run_by_target_motion(task, burst_fn)
    local target_id = task.target_id
    if not in_melee_range(target_id) then
        return NormalAttack(target_id)
    end

    local motion = targetMotion(target_id)
    if motion == MOTION_MOVE then
        move_toward_owner()
        local res = NormalAttack(target_id)
        move_to_owner()
        return res
    end
    if motion == MOTION_ATTACK or motion == MOTION_STAND then
        return burst_fn(target_id)
    end

    return NormalAttack(target_id)
end

---@param task KillTask
---@return NodeStates
function M.step(task)
    return run_by_target_motion(task, run_burst_once)
end

---@param task KillTask
---@return NodeStates
function M.step_double(task)
    return run_by_target_motion(task, run_burst_double)
end

return M
