
local IDLE = Sequence:new({
    -- 跟住主人
    Sequence:new({
        ConditionNode:new(function()
            if Blackboard.objects.owner.distance > IDLE_FOLLOW_DISTANCE then
                return NodeStates.SUCCESS
            end

            return NodeStates.FAILURE
        end),
        ActionNode:new(function()
            MoveToOwner(Blackboard.id)
        end)
    })

})

return IDLE
