--[[
    RoundRandom：在 target 周围 3 格范围内乱跳——每次随机选一格走过去，到了再换一格，
    直到任务被取消（或目标无效）。不含目标中心格；用 fixVertex 处理占格。
]]

local RADIUS = 3

--- 切比雪夫距离 <= RADIUS 的所有偏移（不含中心）
local CANDIDATES = {}
do
    for dx = -RADIUS, RADIUS do
        for dy = -RADIUS, RADIUS do
            if not (dx == 0 and dy == 0) then
                CANDIDATES[#CANDIDATES + 1] = { dx, dy }
            end
        end
    end
end

local NEIGHBOR_DELTA = {
    { 0, 0 },
    { 1, 0 },
    { -1, 0 },
    { 0, 1 },
    { 0, -1 },
    { 1, 1 },
    { 1, -1 },
    { -1, 1 },
    { -1, -1 },
}

local function isCellOccupied(x, y, selfId)
    local actors = GetActors()
    if actors == nil then
        return false
    end
    for _, aid in ipairs(actors) do
        if aid ~= nil and aid ~= selfId then
            local px, py = GetV(V_POSITION, aid)
            if px ~= -1 and py ~= -1 and px == x and py == y then
                return true
            end
        end
    end
    return false
end

local function fixVertex(ix, iy, selfId)
    for _, d in ipairs(NEIGHBOR_DELTA) do
        local cx, cy = ix + d[1], iy + d[2]
        if not isCellOccupied(cx, cy, selfId) then
            return cx, cy
        end
    end
    return ix, iy
end

--- Fisher–Yates 打乱 1..n
local function shuffleIndices(n)
    local o = {}
    for i = 1, n do
        o[i] = i
    end
    for i = n, 2, -1 do
        local j = math.random(i)
        o[i], o[j] = o[j], o[i]
    end
    return o
end

--- 在 RADIUS 格范围内随机挑一格（尽量别和当前脚下一格相同）
---@return number|nil, number|nil
local function pickRandomGoal(tx, ty, selfId, homu_x, homu_y)
    local order = shuffleIndices(#CANDIDATES)
    for _, k in ipairs(order) do
        local off = CANDIDATES[k]
        local wx, wy = tx + off[1], ty + off[2]
        local fx, fy = fixVertex(wx, wy, selfId)
        if fx ~= homu_x or fy ~= homu_y then
            return fx, fy
        end
    end
    for k = 1, #CANDIDATES do
        local off = CANDIDATES[k]
        local wx, wy = tx + off[1], ty + off[2]
        local fx, fy = fixVertex(wx, wy, selfId)
        return fx, fy
    end
    return nil, nil
end

local function ensureRng(task)
    if task._rng_seeded then
        return
    end
    local t = GetTick()
    math.randomseed(t + (Blackboard.id or 0) * 7919 + (task.target_id or 0))
    task._rng_seeded = true
end

local function tick(task)
    ensureRng(task)

    local tid = task.target_id
    local tx, ty = GetV(V_POSITION, tid)
    if tx == -1 or ty == -1 then
        return NodeStates.FAILURE
    end

    local selfId = Blackboard.id
    local hx, hy = GetV(V_POSITION, selfId)
    if hx == -1 or hy == -1 then
        return NodeStates.FAILURE
    end

    if task._gx == nil or task._gy == nil or (hx == task._gx and hy == task._gy) then
        local gx, gy = pickRandomGoal(tx, ty, selfId, hx, hy)
        if gx == nil then
            return NodeStates.RUNNING
        end
        task._gx, task._gy = gx, gy
        if hx == gx and hy == gy then
            return NodeStates.RUNNING
        end
    end

    local gx, gy = task._gx, task._gy
    gx, gy = fixVertex(gx, gy, selfId)

    if hx == gx and hy == gy then
        task._gx, task._gy = nil, nil
        return NodeStates.RUNNING
    end

    Move(selfId, gx, gy)
    return NodeStates.RUNNING
end

return Task:new(
    ActionNode:new(function()
        local task = Blackboard.task
        if task == nil or task.name ~= 'RoundRandom' then
            return NodeStates.FAILURE
        end
        return tick(task)
    end)
)
