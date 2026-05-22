local Logger = require('AI_sakray/USER_AI/Logger')
local Solve2048State = require('AI_sakray/USER_AI/BehaviorTree/common/actions/Solve2048State')

return Task:new(
    RunningOrNot:new(
        ActionNode:new(function()
            Logger.debug('2048le?')
            return Solve2048State()
        end)
    )
)