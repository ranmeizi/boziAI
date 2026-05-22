---@class MoveToOptions MoveTo 参数
---@field pos_x number|nil  要么给 xy 要么给 target_id
---@field pos_y number|nil
---@field target_id number|nil

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
        -- 实时更新一下 target 的位置
        x, y = GetV(V_POSITION, options.target_id)
    end

    if homu_x == x and homu_y == y then
        -- target 的目标一般会因为攻击 提前结束
        return NodeStates.FAILURE
    end

    -- 移动
    Move(Blackboard.id, x, y)


    return NodeStates.SUCCESS
end

return MoveTo
