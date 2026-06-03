---@class MoveToOptions MoveTo 参数
---@field pos_x number|nil  要么给 xy 要么给 target_id
---@field pos_y number|nil
---@field target_id number|nil
---@field kill_extension boolean|nil  KillTask：站到主人→目标延长线上、越过目标 1 格

--- 超过此距离时先 MoveToOwner，再逐格靠近（与 path_finder 局部窗半径一致）
local MAX_DIRECT_MOVE_DIST = 15

--- 8 邻格偏移（与目标重合时随机挪一格，避免走不动）
local ADJACENT_OFFSETS = {
    { -1, -1 }, { 0, -1 }, { 1, -1 },
    { -1,  0 },             { 1,  0 },
    { -1,  1 }, { 0,  1 }, { 1,  1 },
}

---@param hx number
---@param hy number
---@return number nx, number ny
local function random_adjacent_cell(hx, hy)
    local i = (math.floor(GetTick() / 97 + (Blackboard.id or 0)) % #ADJACENT_OFFSETS) + 1
    local off = ADJACENT_OFFSETS[i]
    return hx + off[1], hy + off[2]
end

local function sign(n)
    if n > 0 then
        return 1
    end
    if n < 0 then
        return -1
    end
    return 0
end

--- KillTask：主人→怪方向延长 1 格（怪身后一格）
---@param owner_id number
---@param target_id number
---@return number|nil x, number|nil y
local function kill_extension_cell(owner_id, target_id)
    local ox, oy = GetV(V_POSITION, owner_id)
    local mx, my = GetV(V_POSITION, target_id)
    if ox == -1 or oy == -1 or mx == -1 or my == -1 then
        return nil, nil
    end
    local dx, dy = mx - ox, my - oy
    if dx == 0 and dy == 0 then
        return nil, nil
    end
    return mx + sign(dx), my + sign(dy)
end

--- MoveTo 移动到 xy 坐标 或 target 位置
---@param options MoveToOptions
function MoveTo(options)
    -- 目标
    if options.target_id == nil and (options.pos_x == nil or options.pos_y == nil) then
        return NodeStates.FAILURE -- 拜拜 没法move task 结束
    end

    -- 结束条件
    local homu_x, homu_y = GetV(V_POSITION, Blackboard.id)

    local x = options.pos_x;
    local y = options.pos_y;

    if options.target_id ~= nil then
        if options.kill_extension and Blackboard.owner_id then
            x, y = kill_extension_cell(Blackboard.owner_id, options.target_id)
            if x == nil then
                x, y = GetV(V_POSITION, options.target_id)
            end
        else
            x, y = GetV(V_POSITION, options.target_id)
        end
    end

    if homu_x == -1 or homu_y == -1 then
        return NodeStates.FAILURE
    end

    if homu_x == x and homu_y == y then
        -- 与目标同格无法靠近：随机邻格挪一步，下 tick 再追（giveupable_moveto 等）
        x, y = random_adjacent_cell(homu_x, homu_y)
    end

    local dist = GetDistance(homu_x, homu_y, x, y)
    if dist > MAX_DIRECT_MOVE_DIST and Blackboard.owner_id ~= nil then
        MoveToOwner(Blackboard.id)
        return NodeStates.SUCCESS
    end

    Move(Blackboard.id, x, y)


    return NodeStates.SUCCESS
end

return MoveTo
