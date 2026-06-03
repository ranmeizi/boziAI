--[[
    除了主人 和 生命体 其他的hpsp 看起来是获取不到
]]
local Logger = require('AI_sakray/USER_AI/Logger')

Logger.info('[Environment] 模块已加载')

local function updateTargetInfoOnTable(table, id)
    table.id = id
    table.hp = GetV(V_HP, id)
    table.hp_max = GetV(V_MAXHP, id)
    table.sp = GetV(V_SP, id)
    table.sp_max = GetV(V_MAXSP, id)
    table.pos = {}
    local x, y = GetV(V_POSITION, id)
    table.pos.x = x
    table.pos.y = y
    table.type = GetV(V_HOMUNTYPE, id) -- 寻敌过滤见 config.lua + ConfigModule
    table.attack_range = GetV(V_ATTACKRANGE, id)
    table.motion = GetV(V_MOTION, id)
    table.target = GetV(V_TARGET, id)
end

function Environment()
    -- TraceAI('Action Environment')

    -- 更新自身信息
    updateTargetInfoOnTable(Blackboard.objects.homu, Blackboard.id)
    -- 计算生命体与主人距离
    Blackboard.objects.owner.distance = GetDistance2(Blackboard.id, Blackboard.owner_id)

    -- 更新主人信息
    updateTargetInfoOnTable(Blackboard.objects.owner, Blackboard.owner_id)

    -- 获取所有敌人
    local actors = GetActors()

    Blackboard.objects.monsters = {}                  -- 刷新

    Blackboard.objects.homu_safe_target = Array:new() -- 刷新


    for index, value in ipairs(actors) do
        if IsMonster(value) == 1 then
            Blackboard.objects.monsters[value] = {}
            updateTargetInfoOnTable(Blackboard.objects.monsters[value], value)
            -- 是敌人的话多检测一下 target 计算一下 distance
            Blackboard.objects.monsters[value].distance = GetDistance2(Blackboard.id, value)
            Blackboard.objects.monsters[value].distance_owner = GetDistance2(Blackboard.owner_id, value)
        end

        local homu_type = GetV(V_HOMUNTYPE, value)
        -- 属于生命体但不是自己
        if
            (homu_type > 0 and homu_type < 17 and value ~= Blackboard.id)
            or homu_type == 1579 -- 种的海葵
            or homu_type == 1555 -- 种的苗娃
        then
            -- 找他们有没有活着的目标
            local target = GetV(V_TARGET, value)
            if target ~= nil and target > 0 and GetV(V_MOTION, target) ~= MOTION_DEAD then
                Blackboard.objects.homu_safe_target:push(target)
            end
        end
    end

    -- Drain 停格判定节拍（每帧 +1，供坐标静止计时）
    Blackboard.drain_tick = (Blackboard.drain_tick or 0) + 1

    -- 清空仇恨列表
    Blackboard.objects.aggroListHomu = Array:new()
    Blackboard.objects.aggroListOwner = Array:new()

    -- 从 monster 列表里统计一下 仇恨列表
    for index, value in ipairs(Blackboard.objects.monsters) do
        local item = {
            id = value.id,
            distance = value.distance
        }
        if value.target == Blackboard.id then
            Blackboard.objects.aggroListHomu:push(item)
        elseif value.target == Blackboard.owner_id then
            Blackboard.objects.aggroListOwner:push(item)
        end
    end

    return NodeStates.SUCCESS
end

return Environment
