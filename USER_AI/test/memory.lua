require 'AI_sakray.USER_AI.Memory'
local json = require('AI_sakray.USER_AI.libs.dkjson')

local options = {
    indent = true,      -- 美化输出，带缩进和换行
    level = 0,          -- 初始缩进级别
    noprotect = false   -- 不保护循环引用
}

Memory.load()

function AI()
    print("memory:", Memory.persist.tick, Memory.persist.memory and Memory.persist.memory.state)

    Memory.persist.tick = (Memory.persist.tick or 0) + 1

    Memory.store()
end

AI()
