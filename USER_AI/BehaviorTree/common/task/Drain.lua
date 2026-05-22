--[[
    Drain loop（对标 Farm -> Kill）

    策略：每帧选「特殊敌人」→ TryJumpTask(Touch) → Touch 结束后队列里的 Drain 继续跑。

    特殊敌人条件（由 findDrainTarget 实现）：
    - 在月光（HFLI_MOON）可及范围内
    - 已有攻击目标（怪物正在打谁）
    - 尚未被本流程登记过（见 Drain.touchRegistry.has）

    Touch 任务通过 Drain.touchRegistry.mark 写入；不挂 Blackboard。
]]

local Logger = require('AI_sakray/USER_AI/Logger')
local touchedIds = {}

--- 供 Drain 寻敌、Touch 登记共用（挂在 Drain 节点上导出）
local touchRegistry = {
    ---@param id number
    mark = function(id)
        touchedIds[id] = true
    end,

    ---@param id number
    has = function(id)
        return touchedIds[id] == true
    end
}

---@return number|nil monster_id
local function findDrainTarget()
    ---@diagnostic disable-next-line
    local moonRange = GetV(V_SKILLATTACKRANGE, Blackboard.id, HFLI_MOON)
    if moonRange == nil or moonRange <= 0 then
        moonRange = 14
    end

    local bestId = nil
    local bestDist = nil

    for _, monster in pairs(Blackboard.objects.monsters or {}) do
        local mid = monster.id
        if mid ~= nil
            and touchRegistry.has(mid) == false
            and monster.motion ~= MOTION_DEAD
            and monster.target ~= nil
            and monster.target ~= 0
        then
            local d = monster.distance
            if d ~= nil and d >= 0 and d <= moonRange then
                if bestDist == nil or d < bestDist then
                    bestDist = d
                    bestId = mid
                end
            end
        end
    end

    return bestId
end

local Drain = Sequence:new({
    ActionNode:new(function()
        Blackboard.objects.drainTouchTarget = nil

        local res = findDrainTarget()
        Blackboard.objects.drainTouchTarget = res

        if res == nil then
            Logger.debug('Drain: no special target')
            MoveToOwner(Blackboard.id)
        end

        return NodeStates.SUCCESS
    end),
    ActionNode:new(function()
        if Blackboard.objects.drainTouchTarget == nil then
            return NodeStates.SUCCESS
        end

        ---@type TouchTask
        local task = {
            name = 'Touch',
            target_id = Blackboard.objects.drainTouchTarget
        }

        TryJumpTask(task, {})

        return NodeStates.SUCCESS
    end)
})

Drain.touchRegistry = touchRegistry

return Drain
