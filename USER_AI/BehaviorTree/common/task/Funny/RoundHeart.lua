--[[
    RoundHeart：绕 target_id 按「方案1」点阵走心形

    点阵（列 0..6 左→右，行 0..5 上→下；🔵 为目标站立格）：
    ⚪🔴🔴⚪🔴🔴⚪   r0
    🔴⚪⚪🔴⚪⚪🔴   r1
    🔴⚪⚪🔵⚪⚪🔴   r2  ← 中心 (3,2) = target
    ⚪🔴⚪⚪⚪🔴⚪   r3
    ⚪⚪🔴⚪🔴⚪⚪   r4
    ⚪⚪⚪🔴⚪⚪⚪   r5

    🔴 为路径顶点。先经过目标正上方 (3,1)，再沿 🔴 逆时针一圈，再顺时针沿同轮廓返回。
    若格被占用：在理想格及八邻域 ±1 内取第一个空位（fixVertex）。

    世界坐标：中心格 (tx,ty) 对齐 🔵，本地 (c,r) → wx = tx + (c-3), wy = ty + (r-2)。
]]

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

--- 点阵中心（🔵）在 7×6 本地网格中的列、行（0 起）
local CENTER_C, CENTER_R = 3, 2

--- 逆时针沿全部 🔴 走一圈的本地 (列, 行)，起点为目标正上方 (3,1)
local CCW_LOCAL = {
    { 3, 1 },
    { 2, 0 },
    { 1, 0 },
    { 0, 1 },
    { 0, 2 },
    { 1, 2 },
    { 1, 3 },
    { 2, 4 },
    { 3, 5 },
    { 4, 4 },
    { 5, 3 },
    { 5, 2 },
    { 6, 2 },
    { 6, 1 },
    { 5, 0 },
    { 4, 0 },
}

---@param x number
---@param y number
---@param selfId number
---@return boolean
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

---@param ix number
---@param iy number
---@param selfId number
---@return number, number
local function fixVertex(ix, iy, selfId)
    for _, d in ipairs(NEIGHBOR_DELTA) do
        local cx, cy = ix + d[1], iy + d[2]
        if not isCellOccupied(cx, cy, selfId) then
            return cx, cy
        end
    end
    return ix, iy
end

local function reverseList(list)
    local out = {}
    for i = #list, 1, -1 do
        out[#out + 1] = list[i]
    end
    return out
end

--- 本地 (c,r) → 世界理想格（对齐 🔵）
local function localToWorld(tx, ty, c, r)
    return tx + (c - CENTER_C), ty + (r - CENTER_R)
end

---@param task table
local function ensureWaypoints(task)
    if task._wp ~= nil then
        return
    end

    local tid = task.target_id
    local tx, ty = GetV(V_POSITION, tid)
    if tx == -1 or ty == -1 then
        task._wp = {}
        return
    end

    local selfId = Blackboard.id
    local path = {}

    local ccw = {}
    for _, lr in ipairs(CCW_LOCAL) do
        local wx, wy = localToWorld(tx, ty, lr[1], lr[2])
        local fx, fy = fixVertex(wx, wy, selfId)
        ccw[#ccw + 1] = { fx, fy }
    end

    local function appendSegment(seg)
        for i = 1, #seg do
            local p = seg[i]
            local last = path[#path]
            if not last or last[1] ~= p[1] or last[2] ~= p[2] then
                path[#path + 1] = { p[1], p[2] }
            end
        end
    end

    appendSegment(ccw)

    local back = reverseList(ccw)
    if #back > 1 then
        local trimmed = {}
        for i = 2, #back do
            trimmed[#trimmed + 1] = back[i]
        end
        appendSegment(trimmed)
    end

    task._wp = path
    task._idx = 1
end

---@param task table
---@return number
local function tick(task)
    ensureWaypoints(task)

    local wp = task._wp
    if wp == nil or #wp == 0 then
        return NodeStates.FAILURE
    end

    local tid = task.target_id
    local tx, ty = GetV(V_POSITION, tid)
    if tx == -1 or ty == -1 then
        return NodeStates.FAILURE
    end

    local idx = task._idx or 1
    if idx > #wp then
        return NodeStates.SUCCESS
    end

    local goal = wp[idx]
    local gx, gy = goal[1], goal[2]
    local selfId = Blackboard.id
    gx, gy = fixVertex(gx, gy, selfId)

    local hx, hy = GetV(V_POSITION, selfId)
    if hx == gx and hy == gy then
        task._idx = idx + 1
        if task._idx > #wp then
            return NodeStates.SUCCESS
        end
        return NodeStates.RUNNING
    end

    Move(selfId, gx, gy)
    return NodeStates.RUNNING
end

return Task:new(
    ActionNode:new(function()
        local task = Blackboard.task
        if task == nil or task.name ~= 'RoundHeart' then
            return NodeStates.FAILURE
        end
        return tick(task)
    end)
)
