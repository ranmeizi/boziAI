local Logger = require('AI_sakray/USER_AI/Logger')

---------------------porings-------------------------

local poring_map                  = {
    [1002] = { name = '波利', value = 2 },
    [1113] = { name = '土波利', value = 4 },
    [1031] = { name = '波波利', value = 8 },
    [1242] = { name = '冰波利', value = 16 },
    [1613] = { name = '金属波利', value = 32 },
    [1784] = { name = '石头波利', value = 64 },
    [1836] = { name = '熔岩波利', value = 128 },
    [1894] = { name = '雨水波利', value = 256 },
    [1904] = { name = '炸弹波利', value = 512 },
    [1582] = { name = '恶魔波利', value = 1024 },
    [1096] = { name = '天使波利', value = 2048 }
}

function IsKeyInTable(table, key)
    for k, v in pairs(table) do
        if k == key then
            return true
        end
    end

    return false
end


local function saveGridToCsv(grid)
    local csv = ""
    Logger.debug('start create csv')
    for _, row in ipairs(grid) do
        local rowCSV = ""
        for _, value in ipairs(row) do
            -- 将值转换为字符串，并确保数字被引号包围，以符合 CSV 格式
            rowCSV = rowCSV .. (rowCSV ~= "" and "," or "") .. tostring(value)
        end
        -- 将行 CSV 添加到总 CSV 中，并在每行后添加换行符
        csv = csv .. rowCSV .. "\n"
    end
    Logger.debug('end csv value:' .. csv)
    return csv
end

--找波利
local function poring_identify(type)
    if IsKeyInTable(poring_map, type) then
        return poring_map[type].value
    end

    return nil
end

-- 从游戏坐标系转换数组index
local function transPosToArrayIndex(x, y)
    -- 原点x坐标
    local o_x = 231
    -- 原点y坐标
    local o_y = 169

    local row = 1 + o_y - y
    local col = 1 + x - o_x

    return row, col
end

-- 检查波利,写入文件
local function identify(myid)
    local grid = {
        { 0, 0, 0, 0 },
        { 0, 0, 0, 0 },
        { 0, 0, 0, 0 },
        { 0, 0, 0, 0 }
    }

    for i, id in ipairs(GetActors()) do
        local type = GetV(V_HOMUNTYPE, id)
        local motion = GetV(V_MOTION, id)
        local value = poring_identify(type)

        -- 是棋子种类
        if value ~= nil then
            -- 判断 x y 坐标
            local x, y = GetV(V_POSITION, id)

            local row, col = transPosToArrayIndex(x, y)

            -- 这个坐标落在 grid 中
            if row > 0 and row < 5 and col > 0 and col < 5 then
                -- 如果目标在grid中但是不是 动作时，抛出异常，进入下一tick
                if motion ~= MOTION_STAND then
                    -- 抛出异常
                    error("next tick")
                end
                grid[row][col] = value
            end
        end
    end

    return grid
end

function Solve2048State()
    Logger.debug('2048 in')
    if PerXSecond(1) then
        local grid = identify(Blackboard.id)

        -- 写入文件
        local content = saveGridToCsv(grid)

        local file, err = io.open("grid.csv", "w") -- "w" 模式表示写入，会覆盖文件内容
        if not file then
            error("无法打开文件: " .. err)
        end

        -- 将内容写入文件
        file:write(content)

        -- 关闭文件
        file:close()
    end

    -- 作为一个状态永远执行中,你需要手动终止
    return NodeStates.RUNNING
end

return Solve2048State