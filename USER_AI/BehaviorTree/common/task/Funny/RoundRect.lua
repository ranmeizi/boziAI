--[[
    RoundRect：绕 target 周围一圈 8 格（不含中心）行走，顺时针 / 逆时针来回，直到任务被取消。

    本地偏移（中心为目标格 (0,0)，上为 y-1）：
        (-1,-1) (0,-1) (1,-1)
        (-1,0)  [ * ]  (1,0)
        (-1,1)  (0,1)  (1,1)

    逆时针一圈起点为「正上方」(0,-1)，顺序：
        (0,-1)→(-1,-1)→(-1,0)→(-1,1)→(0,1)→(1,1)→(1,0)→(1,-1)
    再走反向段回到起点附近（与 RoundHeart 相同拼接方式），然后整段循环。
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

--- 逆时针沿 8 邻格一圈（不含中心），起点为目标正上方
local CCW_LOCAL = {
    { 0, -1 },
    { -1, -1 },
    { -1, 0 },
    { -1, 1 },
    { 0, 1 },
    { 1, 1 },
    { 1, 0 },
    { 1, -1 },
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

local function reverseList(list)
    local out = {}
    for i = #list, 1, -1 do
        out[#out + 1] = list[i]
    end
    return out
end

local function localToWorld(tx, ty, dc, dr)
    return tx + dc, ty + dr
end

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
        task._idx = 1
        idx = 1
    end

    local goal = wp[idx]
    local gx, gy = goal[1], goal[2]
    local selfId = Blackboard.id
    gx, gy = fixVertex(gx, gy, selfId)

    local hx, hy = GetV(V_POSITION, selfId)
    if hx == gx and hy == gy then
        task._idx = idx + 1
        if task._idx > #wp then
            task._idx = 1
        end
        return NodeStates.RUNNING
    end

    Move(selfId, gx, gy)
    return NodeStates.RUNNING
end

return Task:new(
    ActionNode:new(function()
        local task = Blackboard.task
        if task == nil or task.name ~= 'RoundRect' then
            return NodeStates.FAILURE
        end
        return tick(task)
    end)
)
