--[[ Filir / Filir_H：月光 + 普攻（SP / skillonly / 目标 moon_blacklist 动态切换）]]

local UseSkill = require('AI_sakray/USER_AI/BehaviorTree/common/actions/UseSkill')
local NormalAttack = require('AI_sakray/USER_AI/BehaviorTree/common/actions/NormalAttack')
local AttackDance = require('AI_sakray/USER_AI/HOMU/kill/attack_dance')
local ConfigModule = require('AI_sakray/USER_AI/ConfigModule')
local Common = require('AI_sakray/USER_AI/HOMU/kill/common')
local SkillInfo = require('AI_sakray/USER_AI/HOMU/skill')

local function homu_sp()
    local homu = Blackboard.objects.homu
    if homu ~= nil and homu.sp ~= nil and homu.sp >= 0 then
        return homu.sp
    end
    local sp = GetV(V_SP, Blackboard.id)
    if sp ~= nil and sp >= 0 then
        return sp
    end
    return nil
end

---@param target_id number|nil
---@return number|nil
local function target_homun_type(target_id)
    if target_id == nil then
        return nil
    end
    local monster = Blackboard.objects.monsters[target_id]
    if monster ~= nil and monster.type ~= nil and monster.type ~= 0 then
        return monster.type
    end
    return GetV(V_HOMUNTYPE, target_id)
end

local function filir_kill_sp_reserve()
    if Blackboard.buff_conf == nil then
        return 0
    end
    return SkillInfo.keep_buff_sp_reserve(
        Blackboard.type,
        Blackboard.buff_conf
    )
end

local function filir_moon_sp_cost()
    local level = ConfigModule.filir_kill_moon_level()
    return SkillInfo.skill_sp_cost(level, HFLI_MOON)
end

--- 混合模式：从普攻切回月光所需 SP = keep_buff + N 次月光
local function filir_kill_skill_entry_min_sp()
    return filir_kill_sp_reserve()
        + filir_moon_sp_cost() * ConfigModule.filir_kill_skill_entry_casts()
end

--- 目标是否适合月光（念属性等 moon_blacklist 除外）
---@param task KillTask|KillWithOwnerTask
---@return boolean
local function filir_moon_viable(task)
    if task == nil or task.target_id == nil then
        return false
    end
    return ConfigModule.is_filir_moon_viable_type(target_homun_type(task.target_id))
end

--- 资源/模式层：是否倾向走月光枝
---@return boolean
local function filir_prefer_moon()
    if ConfigModule.filir_kill_skillonly() then
        return true
    end
    local sp = homu_sp()
    if sp == nil then
        return false
    end
    return sp > filir_kill_skill_entry_min_sp()
end

--- 本 tick 是否走月光击杀（viable × prefer × SP 够一次月光）
---@param task KillTask|KillWithOwnerTask
---@return boolean
local function filir_use_moon_kill(task)
    if not filir_moon_viable(task) then
        return false
    end
    if not filir_prefer_moon() then
        return false
    end

    local sp = homu_sp()
    if sp == nil then
        return false
    end

    local reserve = filir_kill_sp_reserve()
    local moon_cost = filir_moon_sp_cost()
    return sp > reserve + moon_cost
end

local function filir_melee_attack(task)
    if not ConfigModule.attack_dance_enabled() then
        return NormalAttack(task.target_id)
    end
    return AttackDance.step(task)
end

local function filir_moon_attack(task)
    local level = ConfigModule.filir_kill_moon_level()
    local range = ConfigModule.filir_kill_moon_range()
    if GetDistance2(task.target_id, Blackboard.id) <= range then
        return UseSkill(level, HFLI_MOON, task.target_id)
    end
    return NodeStates.FAILURE
end

local function filir_kill_subtree()
    local giveupable_moveto = Common.make_giveupable_moveto()

    local moon_kill = Sequence:new({
        ConditionNode:new(Task.withTask(function(task)
            if not filir_use_moon_kill(task) then
                return NodeStates.FAILURE
            end
            return NodeStates.SUCCESS
        end)),
        ActionNode:new(Task.withTask(filir_moon_attack)),
    })

    local melee_kill = Selector:new({
        Sequence:new({
            ConditionNode:new(Task.withTask(function(task)
                if task._hasFirstAttack == true then
                    return NodeStates.FAILURE
                end
                return NodeStates.SUCCESS
            end)),
            ActionNode:new(Task.withTask(function(task)
                local res = NormalAttack(task.target_id)
                if res == NodeStates.FAILURE then
                    return res
                end
                Blackboard.task._hasFirstAttack = true
                return NodeStates.SUCCESS
            end)),
        }),
        ActionNode:new(Task.withTask(filir_melee_attack)),
    })

    return Succeeder:new(
        Sequence:new({
            Inverter:new(
                Selector:new({
                    moon_kill,
                    melee_kill,
                })
            ),
            giveupable_moveto,
        })
    )
end

return {
    build = filir_kill_subtree,
}
