--[[
  定长环形缓冲区：固定容量，满时覆盖最旧元素。O(1) push / get / last。

  用途：主人移动轨迹、滑动窗口采样等。逻辑下标 1 = 最旧，len() = 最新。

  local RingBuffer = require('AI_sakray/USER_AI/libs/RingBuffer')
  local path = RingBuffer.new(100)
  path:push_point(x, y, { t = GetTick(), min_dist = 1 })
  local dx, dy = path:avg_displacement(10)
]]

local RingBuffer = {}

---@param cap number|nil
function RingBuffer.new(cap)
    cap = math.floor(tonumber(cap) or 100)
    if cap < 1 then
        cap = 1
    end

    return {
        _cap = cap,
        _size = 0,
        --- 满容时指向最旧元素的下标（1.._cap）；未满时恒为 1
        _head = 1,
        _data = {},
    }
end

function RingBuffer:cap()
    return self._cap
end

function RingBuffer:len()
    return self._size
end

function RingBuffer:is_empty()
    return self._size == 0
end

function RingBuffer:is_full()
    return self._size >= self._cap
end

function RingBuffer:clear()
    self._size = 0
    self._head = 1
    self._data = {}
end

--- 满容时最旧元素在 _data 中的物理下标
function RingBuffer:_phys_index(logical_index)
    assert(logical_index >= 1 and logical_index <= self._size)

    if self._size < self._cap then
        return logical_index
    end

    local idx = self._head + logical_index - 1
    if idx > self._cap then
        idx = idx - self._cap
    end
    return idx
end

---@param logical_index number 1 = 最旧
function RingBuffer:get(logical_index)
    if not self:in_bounds(logical_index) then
        return nil
    end
    return self._data[self:_phys_index(logical_index)]
end

function RingBuffer:in_bounds(logical_index)
    return logical_index >= 1 and logical_index <= self._size
end

function RingBuffer:first()
    return self:get(1)
end

function RingBuffer:last()
    if self._size == 0 then
        return nil
    end
    return self:get(self._size)
end

---@param value any
function RingBuffer:push(value)
    assert(value ~= nil)

    if self._size < self._cap then
        self._size = self._size + 1
        self._data[self._size] = value
        return
    end

    self._data[self._head] = value
    self._head = self._head + 1
    if self._head > self._cap then
        self._head = 1
    end
end

--- 仅当坐标相对上次有变化（且满足 min_dist）时入队，减少重复点
---@param x number
---@param y number
---@param opts { t?: number, min_dist?: number }|nil
---@return boolean pushed
function RingBuffer:push_point(x, y, opts)
    assert(x ~= nil and y ~= nil)
    opts = opts or {}

    local last = self:last()
    if last ~= nil and last.x == x and last.y == y then
        return false
    end

    local min_dist = opts.min_dist or 0
    if last ~= nil and min_dist > 0 then
        local dx = math.abs(x - last.x)
        local dy = math.abs(y - last.y)
        local cheb = math.max(dx, dy)
        if cheb < min_dist then
            return false
        end
    end

    local entry = { x = x, y = y }
    if opts.t ~= nil then
        entry.t = opts.t
    end
    self:push(entry)
    return true
end

function RingBuffer:ipairs()
    local logical = 0
    local buf = self
    return function()
        logical = logical + 1
        if logical > buf._size then
            return
        end
        return logical, buf:get(logical)
    end
end

function RingBuffer:rpairs()
    local logical = self._size + 1
    local buf = self
    return function()
        logical = logical - 1
        if logical < 1 then
            return
        end
        return logical, buf:get(logical)
    end
end

--- 最旧 → 最新 净位移（需各点含 x,y）
---@return number|nil dx
---@return number|nil dy
function RingBuffer:net_displacement()
    if self._size < 2 then
        return nil, nil
    end

    local a = self:first()
    local b = self:last()
    if a == nil or b == nil or a.x == nil or a.y == nil or b.x == nil or b.y == nil then
        return nil, nil
    end

    return b.x - a.x, b.y - a.y
end

--- 最旧点与最新点的直线距离（勾股弦长，非路径折线总长）
--- 路点很多而弦长很小 → 可能在绕圈；需各点含 x,y
---@return number
function RingBuffer:chord_length()
    if self._size < 2 then
        return 0
    end

    local a = self:first()
    local b = self:last()
    if a == nil or b == nil or a.x == nil or a.y == nil or b.x == nil or b.y == nil then
        return 0
    end

    local dx = b.x - a.x
    local dy = b.y - a.y
    return math.sqrt(dx * dx + dy * dy)
end

--- 最近一段位移（最新点 − 次新点）
---@return number|nil dx
---@return number|nil dy
function RingBuffer:last_delta()
    if self._size < 2 then
        return nil, nil
    end

    local a = self:get(self._size - 1)
    local b = self:last()
    if a == nil or b == nil or a.x == nil or a.y == nil or b.x == nil or b.y == nil then
        return nil, nil
    end

    return b.x - a.x, b.y - a.y
end

--- 最近 k 段位移的算术平均，抗抖动；k 默认 min(10, len-1)
---@param k number|nil
---@return number|nil dx
---@return number|nil dy
function RingBuffer:avg_displacement(k)
    local n = self._size
    if n < 2 then
        return nil, nil
    end

    k = k or math.min(10, n - 1)
    k = math.floor(k)
    if k < 1 then
        k = 1
    end
    if k > n - 1 then
        k = n - 1
    end

    local start_logical = n - k
    local sum_dx, sum_dy = 0, 0

    for i = start_logical + 1, n do
        local prev = self:get(i - 1)
        local cur = self:get(i)
        if prev == nil or cur == nil or prev.x == nil or prev.y == nil or cur.x == nil or cur.y == nil then
            return nil, nil
        end
        sum_dx = sum_dx + (cur.x - prev.x)
        sum_dy = sum_dy + (cur.y - prev.y)
    end

    return sum_dx / k, sum_dy / k
end

return require('AI_sakray/USER_AI/libs/class')(RingBuffer)
