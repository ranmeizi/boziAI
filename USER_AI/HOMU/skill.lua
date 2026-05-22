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

local buff_conf = {
    [FILIR] = filir_buff,
    [FILIR_H] = filir_buff,
    [VANILMIRTH] = vanilmirth_buff,
    [VANILMIRTH_H] = vanilmirth_buff,
}

return {
    skillbook = skillbook,
    buff_conf = buff_conf,
}
