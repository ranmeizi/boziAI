require 'AI_sakray.USER_AI.Const'
require 'AI_sakray.USER_AI.Util'
require 'AI_sakray.USER_AI.Memory'

Memory.load()

local function loop(id)
    print("memory:", Memory.persist.tick, Memory.persist.memory and Memory.persist.memory.state)

    Memory.persist.tick = (Memory.persist.tick or 0) + 1

    if math.random() > 0.5 then
        error('给我死')
    end

    Memory.store()
end

function AI(id)
    xpcall(function()
        loop(id)
    end, function(err)
        print("捕获到错误:", debug.traceback(err, 2))
        Memory.store()
    end)
end

AI()