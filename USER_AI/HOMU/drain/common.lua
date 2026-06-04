--[[
  Drain 公共逻辑：停格计时、触摸冷却、低蓝休息、行为树骨架。
  各系差异（技能、射程、选怪）由 strategy 注入，见 filir.lua / vanilmirth.lua。
]]

local Logger = require('AI_sakray/USER_AI/Logger')

local M = {}

--- monster_id -> 上次成功施法时的 GetTick(ms)
local touchedAtById = {}

local TOUCH_COOLDOWN_MS = 5000

--- monster_id -> { x, y, since_tick }
local stillById = {}

local MS_PER_ENV_TICK = 100

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

M.touchRegistry = {
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

---@param motion number|nil
---@return boolean
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

---@param mid number
---@param monster table
---@param still_delay_ticks number
local function updateStillWatch(mid, monster, still_delay_ticks)
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

---@param mid number
---@param still_delay_ticks number
---@return boolean
local function stillReady(mid, still_delay_ticks)
    local rec = stillById[mid]
    if rec == nil or rec.since_tick == nil then
        return false
    end
    local tick = Blackboard.drain_tick or 0
    return tick - rec.since_tick >= still_delay_ticks
end

local function pruneStillWatch(activeIds)
    for mid in pairs(stillById) do
        if not activeIds[mid] then
            stillById[mid] = nil
        end
    end
end

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

function M.updateRestState()
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

function M.isResting()
    return resting
end

---@param strategy DrainStrategy
---@return number
function M.get_skill_range(strategy)
    if Blackboard.id == nil then
        return strategy.default_range or 14
    end
    ---@diagnostic disable-next-line
    local r = GetV(V_SKILLATTACKRANGE, Blackboard.id, strategy.skill_type)
    if r == nil or r <= 0 then
        return strategy.default_range or 14
    end
    return r
end

---@param strategy DrainStrategy
---@param target_id number
---@return boolean
function M.is_in_skill_range(strategy, target_id)
    local id = normId(target_id)
    if id == nil then
        return false
    end
    local d = GetDistance2(Blackboard.id, id)
    if d < 0 then
        return false
    end
    return d <= M.get_skill_range(strategy)
end

---@param strategy DrainStrategy
---@return number still_delay_ticks
local function still_delay_ticks_for(strategy)
    local ms = strategy.still_delay_ms or 1000
    if type(ms) == 'function' then
        ms = ms()
    end
    if ms == nil or ms <= 0 then
        ms = 1000
    end
    return math.max(1, math.ceil(ms / MS_PER_ENV_TICK))
end

---@class DrainCandidate
---@field id number
---@field distance number
---@field monster table

---@param strategy DrainStrategy
---@return number|nil target_id
function M.findDrainTarget(strategy)
    M.updateRestState()
    if M.isResting() then
        return nil
    end

    local still_ticks = still_delay_ticks_for(strategy)
    local candidates = {}

    for _, monster in pairs(Blackboard.objects.monsters or {}) do
        local mid = normId(monster.id)
        if mid ~= nil then
            updateStillWatch(mid, monster, still_ticks)
            local motion = liveMotion(mid)
            local eligible = strategy.is_target_eligible == nil
                or strategy.is_target_eligible(monster, mid)
            if not M.touchRegistry.onCooldown(mid)
                and isDrainableMotion(motion)
                and stillReady(mid, still_ticks)
                and M.is_in_skill_range(strategy, mid)
                and eligible
            then
                local d = monster.distance
                if d ~= nil and d >= 0 then
                    candidates[#candidates + 1] = {
                        id = mid,
                        distance = d,
                        monster = monster,
                    }
                end
            end
        end
    end

    local activeIds = {}
    for i = 1, #candidates do
        activeIds[candidates[i].id] = true
    end
    pruneStillWatch(activeIds)

    if strategy.pick_target ~= nil then
        return strategy.pick_target(candidates)
    end

    local bestId = nil
    local bestDist = nil
    for i = 1, #candidates do
        local c = candidates[i]
        if bestDist == nil or c.distance < bestDist then
            bestDist = c.distance
            bestId = c.id
        end
    end
    return bestId
end

---@return { id: number, at: number }[]
function M.exportTouchedIds()
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
function M.hydrateTouchedIds(data)
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

return M
