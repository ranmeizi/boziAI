local Logger = require('AI_sakray/USER_AI/Logger')
local skillbook = require('AI_sakray/USER_AI/HOMU.skill').skillbook

local UseSkill = {}

---@param level number|string
---@param type number
---@return table|nil
function UseSkill.resolve_skill_info(level, type)
    local book = skillbook[type]
    if book == nil then
        return nil
    end
    return book[tostring(level)] or book[level]
end

---@param level number|string
---@param type number
---@return number 毫秒；0 表示不写 cooldown
function UseSkill.cooldown_ms_for(level, type)
    local info = UseSkill.resolve_skill_info(level, type)
    if info == nil then
        return 0
    end
    if info.cd and info.cd > 0 then
        return info.cd * 1000
    end
    if info.stay_duration and info.stay_duration > 0 then
        return info.stay_duration * 1000
    end
    return 0
end

---@param type number
---@return boolean
function UseSkill.is_on_cooldown(type)
    return Blackboard.cooldown:get(type) ~= nil
end

---@param level number|string
---@param type number
function UseSkill.put_on_cooldown(level, type)
    local ms = UseSkill.cooldown_ms_for(level, type)
    if ms > 0 then
        Blackboard.cooldown:set(type, true, ms)
    end
end

---@param level number|string
---@param type number
---@param target_id number
---@return string NodeStates
function UseSkill.cast(level, type, target_id)
    local attack_range = GetV(V_SKILLATTACKRANGE, Blackboard.id, type)
    local distance = GetDistance2(Blackboard.id, target_id)

    if distance > attack_range then
        return NodeStates.FAILURE
    end

    if UseSkill.is_on_cooldown(type) then
        return NodeStates.FAILURE
    end

    Logger.debug('useskill type:' .. type)

    UseSkill.put_on_cooldown(level, type)
    SkillObject(Blackboard.id, level, type, target_id)

    return NodeStates.SUCCESS
end

setmetatable(UseSkill, {
    __call = function(_, level, type, target_id)
        return UseSkill.cast(level, type, target_id)
    end,
})

return UseSkill
