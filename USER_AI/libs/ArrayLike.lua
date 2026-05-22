-- Table based list, can handle up to 2^52 elements
-- See https://www.lua.org/pil/11.4.html

local ArrayLike = {}

function ArrayLike.new(
	self -- a list (table) using integer keys
)
	self._head_index = 0 -- zero-based head index simplifies one-based list indices
	self._length = #self
	return setmetatable({}, {
		__index = ArrayLike,
		__tojson = function(t)
			local cleaned = {}
			for k, v in pairs(t) do
				if type(v) ~= "function" then
					cleaned[k] = v
				end
				return json.encode(cleaned)
			end
		end
	})
end

function ArrayLike:len()
	-- list length
	return self._length
end

function ArrayLike:in_bounds(index)
	-- boolean whether the index is in list bounds
	return index >= 1 and index <= self:len()
end

function ArrayLike:get(
	index -- index from 1 (head) to length (tail)
)
	if not self:in_bounds(index) then
		return nil
	end
	return self[self._head_index + index]
end

function ArrayLike:set(
	-- index from 1 (head) to length (tail)
	index,
	-- value to set
	value
)
	assert(self:in_bounds(index) and value ~= nil)
	self[self._head_index + index] = value
end

function ArrayLike:ipairs()
	local index = 0
	-- iterator -> index, value
	return function()
		index = index + 1
		if index > self._length then
			return
		end
		return index, self[self._head_index + index]
	end
end

function ArrayLike:rpairs()
	local index = self._length + 1
	-- reverse iterator (starting at tail) -> index, value
	return function()
		index = index - 1
		if index < 1 then
			return
		end
		return index, self[self._head_index + index]
	end
end

function ArrayLike:push(value)
	assert(value ~= nil)
	self._length = self._length + 1
	self[self._head_index + self._length] = value
end

function ArrayLike:get_tail()
	return self[self._head_index + self._length]
end

function ArrayLike:pop()
	if self._length == 0 then
		return
	end
	local value = self:get_tail()
	self[self._head_index + self._length] = nil
	self._length = self._length - 1
	return value
end

function ArrayLike:unshift(value)
	self[self._head_index] = value
	self._head_index = self._head_index - 1
	self._length = self._length + 1
end

function ArrayLike:get_head()
	return self[self._head_index + 1]
end

function ArrayLike:shift()
	if self._length == 0 then
		return
	end
	local value = self:get_head()
	self._head_index = self._head_index + 1
	self._length = self._length - 1
	self[self._head_index] = nil
	return value
end

function ArrayLike:filter(predicate)
    assert(type(predicate) == "function", "filter 需要一个函数作为参数")
    
    -- 创建一个新的 ArrayLike 实例
    local filtered = ArrayLike.new({})
    
    -- 遍历当前 ArrayLike 的所有元素
    for index, value in self:ipairs() do
        if predicate(value, index) then
            filtered:push(value) -- 如果满足条件，加入新的 ArrayLike
        end
    end
    
    return filtered
end


function ArrayLike:clear()
	for i = 1, self._length do
		self[self._head_index + i] = nil
	end
	self._head_index = 0
	self._length = 0
end

return require("AI_sakray/USER_AI/libs/class")(ArrayLike)
