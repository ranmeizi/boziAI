--[[
    Drain loop（对标 Farm -> Kill）

    特殊敌人：月光范围内、非攻击非死亡、同一格坐标连续静止 STILL_DELAY_MS（约 STILL_DELAY_TICKS 个 Environment 帧）、
    且距上次对该 id 施法已满 TOUCH_COOLDOWN_MS 后 Touch。

    休息：SP < REST_ENTER_SP 进入，直至 SP > sp_max * REST_EXIT_SP_RATIO 恢复；休息中不选目标。
]]

local Logger = require('AI_sakray/USER_AI/Logger')

--- monster_id -> 上次成功月光时的 GetTick(ms)
local touchedAtById = {}

local TOUCH_COOLDOWN_MS = 5000

--- 每只怪独立：monster_id -> { x, y, since_tick }（since_tick = 首次停在该格的 Blackboard.drain_tick）
local stillById = {}

local STILL_DELAY_MS = 1000
local MS_PER_ENV_TICK = 100
local STILL_DELAY_TICKS = math.max(1, math.ceil(STILL_DELAY_MS / MS_PER_ENV_TICK))

local REST_ENTER_SP = 20
local REST_EXIT_SP_RATIO = 0.3
local resting = false

local function normId(id)
    if id == nil then
        return nil
    end
    return tonumber(id) or id
end

local function onTouchCooldown(id)
    id = normId(id)
    if id == nil then
        return false
    end
    local at = touchedAtById[id]
    if at == nil then
        return false
    end
    if GetTick() - at >= TOUCH_COOLDOWN_MS then
        touchedAtById[id] = nil
        return false
    end
    return true
end

local touchRegistry = {
    mark = function(id)
        id = normId(id)
        if id == nil then
            return
        end
        touchedAtById[id] = GetTick()
        stillById[id] = nil
    end,
    onCooldown = onTouchCooldown,
    ---@deprecated 同 onCooldown
    has = onTouchCooldown,
}

local function liveMotion(id)
    return GetV(V_MOTION, id)
end

--- 可点名：非死亡、非攻击（含 ATTACK2 / COUNTER）
local function isDrainableMotion(motion)
    if motion == nil or motion == -1 then
        return false
    end
    if motion == MOTION_DEAD then
        return false
    end
    if motion == MOTION_ATTACK
        or motion == MOTION_ATTACK2
        or motion == MOTION_COUNTER
    then
        return false
    end
    return true
end

local function monsterPos(monster, mid)
    if monster.pos ~= nil and monster.pos.x ~= nil and monster.pos.y ~= nil then
        return monster.pos.x, monster.pos.y
    end
    return GetV(V_POSITION, mid)
end

--- 仅更新该 mid 自己的停格计时，坐标变化则重置
local function updateStillWatch(mid, monster)
    local x, y = monsterPos(monster, mid)
    if x == nil or y == nil then
        stillById[mid] = nil
        return
    end
    local tick = Blackboard.drain_tick or 0
    local rec = stillById[mid]
    if rec == nil or rec.x ~= x or rec.y ~= y then
        stillById[mid] = { x = x, y = y, since_tick = tick }
    end
end

--- 同一格已连续静止够久（按 Environment 帧计，避免 GetTick 非毫秒导致失效）
local function stillReady(mid)
    local rec = stillById[mid]
    if rec == nil or rec.since_tick == nil then
        return false
    end
    local tick = Blackboard.drain_tick or 0
    return tick - rec.since_tick >= STILL_DELAY_TICKS
end

--- 视野外/已消失怪的计时清掉，避免 id 复用串台
local function pruneStillWatch(activeIds)
    for mid in pairs(stillById) do
        if not activeIds[mid] then
            stillById[mid] = nil
        end
    end
end

---@return number
local function get_moon_range()
    ---@diagnostic disable-next-line
    local moonRange = GetV(V_SKILLATTACKRANGE, Blackboard.id, HFLI_MOON)
    if moonRange == nil or moonRange <= 0 then
        return 14
    end
    return moonRange
end

---@param target_id number
---@return boolean
---@return number|nil sp
---@return number|nil sp_max
local function getHomuSp()
    local homu = Blackboard.objects and Blackboard.objects.homu
    if homu ~= nil and homu.sp ~= nil and homu.sp_max ~= nil then
        return homu.sp, homu.sp_max
    end
    if Blackboard.id == nil then
        return nil, nil
    end
    return GetV(V_SP, Blackboard.id), GetV(V_MAXSP, Blackboard.id)
end

--- 滞回：SP < 10 进入休息，SP > 30% max 退出
local function updateRestState()
    local sp, sp_max = getHomuSp()
    if sp == nil or sp_max == nil or sp_max <= 0 then
        Blackboard.drain_resting = resting
        return resting
    end
    if resting then
        if sp > sp_max * REST_EXIT_SP_RATIO then
            resting = false
        end
    elseif sp < REST_ENTER_SP then
        resting = true
    end
    Blackboard.drain_resting = resting
    return resting
end

---@return boolean
local function isResting()
    return resting
end

local function is_in_moon_range(target_id)
    local id = normId(target_id)
    if id == nil then
        return false
    end
    local d = GetDistance2(Blackboard.id, id)
    if d < 0 then
        return false
    end
    return d <= get_moon_range()
end

local function findDrainTarget()
    updateRestState()
    if isResting() then
        return nil
    end

    local bestId = nil
    local bestDist = nil
    local activeIds = {}

    for _, monster in pairs(Blackboard.objects.monsters or {}) do
        local mid = normId(monster.id)
        if mid ~= nil then
            activeIds[mid] = true
            updateStillWatch(mid, monster)
            local motion = liveMotion(mid)
            if not touchRegistry.onCooldown(mid)
                and isDrainableMotion(motion)
                and stillReady(mid)
                and is_in_moon_range(mid)
            then
                local d = monster.distance
                if d ~= nil and d >= 0 then
                    if bestDist == nil or d < bestDist then
                        bestDist = d
                        bestId = mid
                    end
                end
            end
        end
    end

    pruneStillWatch(activeIds)
    return bestId
end

local Drain = Sequence:new({
    ActionNode:new(function()
        Blackboard.objects.drainTouchTarget = nil
        local res = findDrainTarget()
        Blackboard.objects.drainTouchTarget = res
        if res == nil then
            if isResting() then
                Logger.debug('Drain: resting (sp recover)')
            else
                Logger.debug('Drain: no special target')
            end
            MoveToOwner(Blackboard.id)
        end
        return NodeStates.SUCCESS
    end),
    ActionNode:new(function()
        if Blackboard.objects.drainTouchTarget == nil then
            return NodeStates.SUCCESS
        end
        ---@type TouchTask
        TryJumpTask({
            name = 'Touch',
            target_id = Blackboard.objects.drainTouchTarget
        }, {})
        return NodeStates.SUCCESS
    end)
})

---@return { id: number, at: number }[]
function Drain.exportTouchedIds()
    local arr = {}
    local now = GetTick()
    for id, at in pairs(touchedAtById) do
        if now - at < TOUCH_COOLDOWN_MS then
            arr[#arr + 1] = { id = id, at = at }
        end
    end
    return arr
end

---@param data { id: number, at: number }[]|number[]|table|nil
function Drain.hydrateTouchedIds(data)
    for k in pairs(touchedAtById) do
        touchedAtById[k] = nil
    end
    if type(data) ~= 'table' then
        return
    end
    local now = GetTick()
    for _, item in ipairs(data) do
        if type(item) == 'table' and item.id ~= nil and item.at ~= nil then
            local id = normId(item.id)
            local at = tonumber(item.at)
            if id ~= nil and at ~= nil and now - at < TOUCH_COOLDOWN_MS then
                touchedAtById[id] = at
            end
        elseif type(item) == 'number' then
            local id = normId(item)
            if id ~= nil then
                touchedAtById[id] = now
            end
        end
    end
end

Drain.touchRegistry = touchRegistry
Drain.get_moon_range = get_moon_range
Drain.is_in_moon_range = is_in_moon_range
Drain.isResting = isResting
Drain.updateRestState = updateRestState

return Drain
