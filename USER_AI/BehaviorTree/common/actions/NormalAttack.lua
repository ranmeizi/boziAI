--- NormalAttack 对敌人普通攻击
---@param target_id number
function NormalAttack(target_id)
    -- 判断攻击距离
    local attack_range = Blackboard.objects.homu.attack_range

    local distance = Blackboard.objects.monsters[target_id].distance

    if distance > attack_range then
        return NodeStates.FAILURE
    end

    -- 攻击
    Attack(Blackboard.id, target_id)

    return NodeStates.SUCCESS
end

return NormalAttack
