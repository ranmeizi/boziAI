-- 挂全局
_G.json = require 'AI_sakray.USER_AI.libs.dkjson'
local Array = require('AI_sakray/USER_AI/libs/ArrayLike')

local options = {
    
}

local arr = Array:new()
arr:push(1)
print('arr', arr:get(1))

arr:push(2)
print('arr', arr:get(2))

arr:unshift(0)
print('arr', arr:get(1))

arr:clear()

print('arr')