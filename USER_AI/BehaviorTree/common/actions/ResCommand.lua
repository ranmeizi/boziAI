local Logger = require('AI_sakray/USER_AI/Logger')

 --- ResCommand 接收客户端 msg 放到 cmds List 里
 function ResCommand()
    -- 去找有没有客户端发来的指令，如果有，那么就存入，由 CommandModule 后续节点去消费 cmd列表中的命令
    local msg = GetMsg(Blackboard.id)

    if msg ~= nil and msg[1] ~= NOME_CMD then
        Logger.debug('有消息' .. json.encode(msg))
        Blackboard.cmds:push(msg)
    end

    return NodeStates.SUCCESS
end

return ResCommand