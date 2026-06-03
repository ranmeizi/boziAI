local skillbook = {
    -- 月光
    [HFLI_MOON] = {
        ['1'] = { sp_cost = 4, cd = 0, stay_duration = nil },
        ['2'] = { sp_cost = 8, cd = 0, stay_duration = nil },
        ['3'] = { sp_cost = 12, cd = 0, stay_duration = nil },
        ['4'] = { sp_cost = 16, cd = 0, stay_duration = nil },
        ['5'] = { sp_cost = 20, cd = 0, stay_duration = nil },
    },
    --[[
        闪避
        Level	            1	2	3	4	5
        Additional Flee	    20	30	40	50	60
        Duration     	    60s	55s	50s	45s	40s
        After Cast Delay	60s	70s	80s	90s	120s 
    --]]
    [HFLI_FLEET] = {
        ['1'] = { sp_cost = 30, cd = 60, stay_duration = 60 }, --
        ['2'] = { sp_cost = 40, cd = 70, stay_duration = 55 },
        ['3'] = { sp_cost = 50, cd = 80, stay_duration = 50 },
        ['4'] = { sp_cost = 60, cd = 90, stay_duration = 45 },
        ['5'] = { sp_cost = 70, cd = 120, stay_duration = 40 },
    },
    --[[
        加攻击
        Level	            1	2	3	4	5
        Additional ASPD	    3	6	9	12	15
        ATK	                110%	115%	120%	125%	130%
        Duration	        60s	55s	50s	45s	40s
        Cast Delay	        60s	70s	80s	90s	120s
        SP Cost	            30	40	50	60	70
    --]]
    [HFLI_SPEED] = {
        ['1'] = { sp_cost = 30, cd = 60, stay_duration = 60 },
        ['2'] = { sp_cost = 40, cd = 70, stay_duration = 55 },
        ['3'] = { sp_cost = 50, cd = 80, stay_duration = 50 },
        ['4'] = { sp_cost = 60, cd = 90, stay_duration = 45 },
        ['5'] = { sp_cost = 70, cd = 120, stay_duration = 40 },
    },

    -- Vanilmirth（数值待实测）
    [HVAN_CHAOTIC] = {
        ['1'] = { sp_cost = 10, cd = 0, stay_duration = nil },
        ['2'] = { sp_cost = 14, cd = 0, stay_duration = nil },
        ['3'] = { sp_cost = 18, cd = 0, stay_duration = nil },
        ['4'] = { sp_cost = 22, cd = 0, stay_duration = nil },
        ['5'] = { sp_cost = 26, cd = 0, stay_duration = nil },
    },
}

local filir_buff = { { 1, HFLI_FLEET }, { 1, HFLI_SPEED } }
-- local filir_buff = { { 1, HFLI_FLEET } }

-- Lif / Amistr 为辅助系：不在行为树中续 buff、不自动施法（skillbook 仅作数据参考）
local vanilmirth_buff = {}

--- keep_buff（Environment 续 buff）所需 SP 之和
---@param homun_type number|nil
---@param conf table|nil 默认 buff_conf[homun_type] 或 Blackboard.buff_conf
---@return number
local function keep_buff_sp_reserve(homun_type, conf)
    if conf == nil and homun_type ~= nil then
        conf = buff_conf[homun_type]
    end
    if conf == nil or #conf == 0 then
        return 0
    end
    local total = 0
    for i = 1, #conf do
        local entry = conf[i]
        local level = entry[1]
        local stype = entry[2]
        local book = skillbook[stype]
        local info = book and (book[tostring(level)] or book[level])
        if info ~= nil and info.sp_cost ~= nil then
            total = total + info.sp_cost
        end
    end
    return total
end

---@param level number|string
---@param skill_type number
---@return number
local function skill_sp_cost(level, skill_type)
    local book = skillbook[skill_type]
    local info = book and (book[tostring(level)] or book[level])
    if info ~= nil and info.sp_cost ~= nil then
        return info.sp_cost
    end
    return 0
end

local buff_conf = {
    [FILIR] = filir_buff,
    [FILIR2] = filir_buff,
    [FILIR_H] = filir_buff,
    [FILIR_H2] = filir_buff,
    [VANILMIRTH] = vanilmirth_buff,
    [VANILMIRTH2] = vanilmirth_buff,
    [VANILMIRTH_H] = vanilmirth_buff,
    [VANILMIRTH_H2] = vanilmirth_buff,
}

return {
    skillbook = skillbook,
    buff_conf = buff_conf,
    keep_buff_sp_reserve = keep_buff_sp_reserve,
    skill_sp_cost = skill_sp_cost,
}
