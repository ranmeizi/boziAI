--[[
  加载 config.lua，提供寻敌黑白名单与 Filir 击杀参数（无地图/代控依赖）。
]]

local Logger = require('AI_sakray/USER_AI/Logger')
local userConfig = require('AI_sakray/USER_AI/config')

local M = {}

---@type table<number, boolean>
local effectiveBlacklist = {}

---@type table<number, boolean>
local effectiveWhitelist = {}

---@type table<number, boolean>
local effectiveFilirMoonBlacklist = {}

local whitelistActive = false

---@param src table|nil
---@return table<number, boolean>
local function copyBoolMap(src)
    local out = {}
    if type(src) ~= 'table' then
        return out
    end
    for k, v in pairs(src) do
        if v == true then
            out[k] = true
        end
    end
    return out
end

local function recomputeWhitelistActive()
    whitelistActive = false
    for _, allowed in pairs(effectiveWhitelist) do
        if allowed == true then
            whitelistActive = true
            break
        end
    end
end

---@return table
local function filir_kill_cfg()
    local cfg = userConfig.filir_kill
    if type(cfg) ~= 'table' then
        return {}
    end
    return cfg
end

function M.init()
    effectiveBlacklist = copyBoolMap(userConfig.target_blacklist)
    effectiveWhitelist = copyBoolMap(userConfig.target_whitelist)
    effectiveFilirMoonBlacklist = copyBoolMap(filir_kill_cfg().moon_blacklist)
    recomputeWhitelistActive()
    Logger.info('[ConfigModule] init OK')
end

---@param homunType number|nil
---@return boolean
function M.is_blacklisted_type(homunType)
    if homunType == nil or homunType == 0 then
        return false
    end
    return effectiveBlacklist[homunType] == true
end

---@param homunType number|nil
---@return boolean
function M.is_whitelisted_type(homunType)
    if not whitelistActive then
        return true
    end
    if homunType == nil or homunType == 0 then
        return false
    end
    return effectiveWhitelist[homunType] == true
end

function M.is_whitelist_active()
    return whitelistActive
end

---@param homunType number|nil
---@return boolean
function M.is_filir_moon_viable_type(homunType)
    if homunType == nil or homunType == 0 then
        return true
    end
    return effectiveFilirMoonBlacklist[homunType] ~= true
end

---@return boolean
function M.filir_kill_skillonly()
    local cfg = filir_kill_cfg()
    return cfg.skillonly == true
end

---@return number
function M.filir_kill_moon_range()
    local cfg = filir_kill_cfg()
    local r = cfg.moon_range
    if r == nil or r <= 0 then
        return 14
    end
    return r
end

---@return number
function M.filir_kill_moon_level()
    local cfg = filir_kill_cfg()
    local lv = cfg.moon_level
    if lv == nil or lv <= 0 then
        return 1
    end
    return lv
end

---@return number
function M.filir_kill_skill_entry_casts()
    local cfg = filir_kill_cfg()
    local n = cfg.skill_entry_casts
    if n == nil or n <= 0 then
        return 10
    end
    return n
end

---@return boolean
function M.attack_dance_enabled()
    return userConfig.attack_dance == true
end

return M
