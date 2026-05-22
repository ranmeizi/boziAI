local CacheControl = {}
CacheControl.__index = CacheControl

-- 构造函数
function CacheControl.new()
    local self = setmetatable({}, CacheControl)
    self.store = {}
    return self
end

-- 设置缓存项
function CacheControl:set(key, value, ttl)
    local now = GetTick()  -- 转换为毫秒，与JavaScript的Date.now()一致
    local item = {
        value = value,
        expiry = ttl and (now + ttl) or nil
    }
    self.store[key] = item
end

-- 获取缓存项
function CacheControl:get(key)
    local now = GetTick()
    local item = self.store[key]
    
    if item then
        if item.expiry and now > item.expiry then
            -- 如果缓存项已过期，则删除并返回 nil
            self:delete(key)
        else
            return item.value
        end
    end
    return nil
end

-- 删除缓存项
function CacheControl:delete(key)
    self.store[key] = nil
end

-- 清理所有过期的缓存项
function CacheControl:clearExpired()
    local now = GetTick()
    for key, item in pairs(self.store) do
        if item.expiry and now > item.expiry then
            self:delete(key)
        end
    end
end

return CacheControl