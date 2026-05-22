local Logger = require('AI_sakray/USER_AI/Logger')
local json = require('AI_sakray/USER_AI.libs/dkjson')

--[[
  持久化载荷在 Memory.persist。磁盘文件与 persist 同构，可附加 tick 等测试字段。

  典型流程（Blackboard 已创建、且已写入 id/type 后再水合 buff）：
    require('AI_sakray/USER_AI/Memory')
    Memory.load()
    Memory.hydrateToBlackboard()  -- 内部用 _G.Blackboard

  存盘（会先 dehydrateFromBlackboard）：
    Memory.store()

  仅更新快照不写盘：
    Memory.dehydrateFromBlackboard()

  任务是否参与持久化：task.persistent == true（例如 Farm、Grind）。未标记或 false 的当前任务与队列项均不写入 / 读盘时忽略。
]]

local filePath = 'AI_sakray/memory.json'

---@class MemoryPersist
---@field version number
---@field buff_conf_enabled boolean
---@field task table|nil
---@field task_queue table[]

Memory = Memory or {}

Memory.PERSIST_VERSION = 1

--- 写入磁盘的纯数据（可含 tick 等测试用任意键）
Memory.persist = Memory.persist or {
    version = Memory.PERSIST_VERSION,
    buff_conf_enabled = false,
    task = nil,
    task_queue = {},
}

---@param task table|nil
---@return boolean
local function shouldPersistTask(task)
    return task ~= nil and task.persistent == true
end

--- 任务里以下划线开头的键视为运行时临时状态，不参与脱水
---@param task table|nil
---@return table|nil
local function copyTaskForPersist(task)
    if task == nil then
        return nil
    end
    local out = {}
    for k, v in pairs(task) do
        if type(k) == 'string' and k:sub(1, 1) == '_' then
            -- skip
        elseif type(v) ~= 'function' and type(v) ~= 'userdata' and type(v) ~= 'thread' then
            out[k] = v
        end
    end
    return out
end

---@param task table|nil
---@return table|nil
local function shallowCloneTask(task)
    if task == nil then
        return nil
    end
    local out = {}
    for k, v in pairs(task) do
        out[k] = v
    end
    return out
end

--- 从 Blackboard 抽取可序列化快照写入 Memory.persist（不立刻写盘）
---@param bb table|nil 默认 _G.Blackboard
function Memory.dehydrateFromBlackboard(bb)
    bb = bb or rawget(_G, 'Blackboard')
    if bb == nil then
        return
    end

    local p = Memory.persist
    p.version = Memory.PERSIST_VERSION
    p.buff_conf_enabled = bb.buff_conf ~= nil
    p.task = shouldPersistTask(bb.task) and copyTaskForPersist(bb.task) or nil

    local queue = {}
    if bb.task_queue ~= nil then
        for _, t in bb.task_queue:ipairs() do
            if shouldPersistTask(t) then
                queue[#queue + 1] = copyTaskForPersist(t)
            end
        end
    end
    p.task_queue = queue

    -- 旧版 JSON 可能含这两项，脱水后清掉以免下次 store 再写进去
    p.ignore_cache = nil
    p.black_list_cache = nil  -- 旧字段，脱水时一并清掉
    p.cooldown = nil
end

--- 将 Memory.persist 中内容灌回 Blackboard（需已由 AI 初始化 task_queue 等）
---@param bb table|nil 默认 _G.Blackboard
function Memory.hydrateToBlackboard(bb)
    bb = bb or rawget(_G, 'Blackboard')
    if bb == nil then
        return
    end

    local p = Memory.persist
    if p.buff_conf_enabled and bb.type ~= nil then
        local Skill = require('AI_sakray/USER_AI/HOMU/skill')
        local conf = Skill.buff_conf[bb.type]
        bb.buff_conf = conf
    else
        bb.buff_conf = nil
    end

    if bb.task_queue ~= nil then
        while bb.task_queue:len() > 0 do
            bb.task_queue:shift()
        end
        for _, t in ipairs(p.task_queue or {}) do
            if shouldPersistTask(t) then
                bb.task_queue:push(shallowCloneTask(t))
            end
        end
    end

    bb.task = shouldPersistTask(p.task) and shallowCloneTask(p.task) or nil
end

--- 读盘：JSON 合并进 Memory.persist（整文件即 persist 载荷，便于扩展测试字段）
function Memory.load()
    local file, err = io.open(filePath, 'r')
    if not file then
        return
    end

    local content = file:read('*a')
    file:close()

    local data, pos, decErr = json.decode(content, 1, nil)
    if data == nil then
        Logger.error('Memory.load decode 失败: ' .. tostring(decErr))
        return
    end

    if type(data) ~= 'table' then
        return
    end

    for k, v in pairs(data) do
        Memory.persist[k] = v
    end
    if Memory.persist.version == nil then
        Memory.persist.version = Memory.PERSIST_VERSION
    end
end

--- 脱水当前 Blackboard 并写入 memory.json
function Memory.store()
    Memory.dehydrateFromBlackboard()

    local options = {
        indent = true,
        level = 0,
        noprotect = false,
    }

    local jsonString = json.encode(Memory.persist, options) --[[@as string|nil]]
    if type(jsonString) ~= 'string' then
        Logger.error('Memory.store encode 失败')
        return
    end

    local file, err = io.open(filePath, 'w')
    if not file then
        Logger.error('Memory.store 无法打开文件: ' .. tostring(err))
        return
    end

    ---@cast jsonString string
    file:write(jsonString)
    file:close()
end

return Memory
