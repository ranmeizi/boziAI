--[[
  分级日志：输出到 TraceAI

  Logger.info('hello')
  Logger.configure({ min_level = 'DEBUG', tag = 'pf' })
]]

local Logger = {}

Logger.LEVEL = {
    DEBUG = 10,
    INFO = 20,
    WARN = 30,
    ERROR = 40,
}

Logger.LEVEL_NAME = {
    [Logger.LEVEL.DEBUG] = 'DEBUG',
    [Logger.LEVEL.INFO] = 'INFO',
    [Logger.LEVEL.WARN] = 'WARN',
    [Logger.LEVEL.ERROR] = 'ERROR',
}

local LEVEL_BY_NAME = {
    DEBUG = Logger.LEVEL.DEBUG,
    INFO = Logger.LEVEL.INFO,
    WARN = Logger.LEVEL.WARN,
    ERROR = Logger.LEVEL.ERROR,
    debug = Logger.LEVEL.DEBUG,
    info = Logger.LEVEL.INFO,
    warn = Logger.LEVEL.WARN,
    error = Logger.LEVEL.ERROR,
}

Logger._config = {
    min_level = Logger.LEVEL.DEBUG,
    tag = nil,
}

local function resolve_level(level)
    if type(level) == 'number' then
        return level
    end
    if type(level) == 'string' then
        return LEVEL_BY_NAME[level]
    end
    return nil
end

local function get_tick()
    if type(GetTick) == 'function' then
        return GetTick()
    end
    return 0
end

---@param opts { min_level?: number|string, tag?: string|nil }|nil
function Logger.configure(opts)
    if opts == nil then
        return
    end
    if opts.min_level ~= nil then
        local lv = resolve_level(opts.min_level)
        if lv ~= nil then
            Logger._config.min_level = lv
        end
    end
    if opts.tag ~= nil then
        Logger._config.tag = opts.tag
    end
end

---@param tag string|nil
function Logger.set_tag(tag)
    Logger._config.tag = tag
end

---@param level number|string
---@return boolean
function Logger.is_enabled(level)
    local lv = resolve_level(level)
    if lv == nil then
        return false
    end
    return lv >= Logger._config.min_level
end

---@param level number
---@param message string
---@return string
function Logger.format(level, message)
    local name = Logger.LEVEL_NAME[level] or 'LOG'
    local tick = get_tick()
    local tag = Logger._config.tag
    if tag ~= nil and tag ~= '' then
        return string.format('[%s] tick=%d [%s] %s', name, tick, tag, message)
    end
    return string.format('[%s] tick=%d %s', name, tick, message)
end

---@param level number
---@param message string
---@param _opts table|nil 保留参数位，兼容旧调用
function Logger.write(level, message, _opts)
    if not Logger.is_enabled(level) then
        return
    end

    message = tostring(message or '')
    local line = Logger.format(level, message)

    if rawget(_G, 'TraceAI') then
        TraceAI(line)
    end
end

--- 模块内安全获取（require 缓存；与 Util 挂全局二选一）
---@return table
function Logger.ensure()
    return Logger
end

_G.Logger = Logger

---@param message string
---@param opts table|nil
function Logger.debug(message, opts)
    Logger.write(Logger.LEVEL.DEBUG, message, opts)
end

---@param message string
---@param opts table|nil
function Logger.info(message, opts)
    Logger.write(Logger.LEVEL.INFO, message, opts)
end

---@param message string
---@param opts table|nil
function Logger.warn(message, opts)
    Logger.write(Logger.LEVEL.WARN, message, opts)
end

---@param message string
---@param opts table|nil
function Logger.error(message, opts)
    Logger.write(Logger.LEVEL.ERROR, message, opts)
end

return Logger
