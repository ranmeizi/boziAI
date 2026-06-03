local Logger = require('AI_sakray/USER_AI/Logger')
local ResCommand = require 'AI_sakray.USER_AI.BehaviorTree.common.actions.ResCommand'
local UseSkill = require('AI_sakray/USER_AI/BehaviorTree/common/actions/UseSkill')
local Skill = require("AI_sakray/USER_AI/HOMU/skill")

--- 创建 MoveTo Task
--- [MoveTo.lua](${workspaceFolder}/USER_AI/BehaviorTree/common/task/MoveTo.lua)
local function createMoveToTask()
    local cmd = Blackboard.cmds:shift()
    if cmd == nil or cmd[1] ~= MOVE_CMD then
        Logger.warn('[CommandModule] MoveTo: cmd missing or type mismatch')
        return NodeStates.FAILURE
    end
    if cmd[2] == nil or cmd[3] == nil then
        Logger.warn('[CommandModule] MoveTo: missing pos')
        return NodeStates.FAILURE
    end

    ---@type MoveToTask
    local task = {
        name = 'MoveTo',
        pos_x = cmd[2],
        pos_y = cmd[3]
    }

    return TryJumpTask(task, { removeUniqueTask = true })
end

--- 创建 Kill Task
--- [Kill.lua](${workspaceFolder}/USER_AI/BehaviorTree/common/task/Kill.lua)
local function createKillTask()
    local cmd = Blackboard.cmds:shift()
    if cmd == nil or cmd[1] ~= ATTACT_OBJET_CMD then
        Logger.warn('[CommandModule] Kill: cmd missing or type mismatch')
        return NodeStates.FAILURE
    end
    if cmd[2] == nil then
        Logger.warn('[CommandModule] Kill: missing target_id')
        return NodeStates.FAILURE
    end

    ---@type KillTask
    local task = {
        name = 'Kill',
        target_id = cmd[2]
    }

    return TryJumpTask(task, { removeUniqueTask = true })
end

---@params index number
---@params type 1|3|7|9
local function createCmdCondition(index, type)
    return function()
        if Blackboard.cmds:len() < index then
            return NodeStates.FAILURE
        end
        local cmd = Blackboard.cmds:get(index)
        if cmd ~= nil and cmd[1] == type then
            return NodeStates.SUCCESS
        end
        return NodeStates.FAILURE
    end
end

local timerName = 'cmd_timer'

local function clear_cmds()
    Blackboard.cmds:clear()
end

local function clear_cmd_timer()
    Blackboard.timers[timerName] = nil
end

--- Alt+T 菜单：仅保留一条 FOLLOW（勿清 cmd_timer，否则 2s 超时永不触发）
local function begin_follow_option_wait()
    clear_cmds()
    Blackboard.cmds:push({ FOLLOW_CMD })
end

--- 双击 Alt+T / 取消：清空队列与任务，且不再留下 FOLLOW 占位
local function cancel_all_state()
    clear_cmds()
    clear_cmd_timer()
    Blackboard.task = nil
    Blackboard.task_queue:clear()
    Blackboard.buff_conf = nil
end

local function is_follow_option_wait()
    if Blackboard.cmds:len() ~= 1 then
        return NodeStates.FAILURE
    end
    local c = Blackboard.cmds:get(1)
    if c ~= nil and c[1] == FOLLOW_CMD then
        return NodeStates.SUCCESS
    end
    return NodeStates.FAILURE
end

--[[
    这里规定，下命令，在主人周围 8 格 代表 8个 options
    1️⃣2️⃣3️⃣       -1,1 | 0,1 | 1,1
    4️⃣👨🏻‍🦳5️⃣       -1,0  |      | 1,0
    6️⃣7️⃣8️⃣       -1,-1 | 0,-1 | 1,-1
    4 预留  5 RoundRect  6 RoundRandom  7 Grind
]]
local function getValidOptions(x, y)
    local ox = Blackboard.objects.owner.pos.x
    local oy = Blackboard.objects.owner.pos.y

    -- 定义相对坐标与选项编号的映射
    local optionsMap = {
        ["-1,1"]  = 1, -- 左上
        ["0,1"]   = 2, -- 上
        ["1,1"]   = 3, -- 右上
        ["-1,0"]  = 4, -- 左
        ["1,0"]   = 5, -- 右
        ["-1,-1"] = 6, -- 左下
        ["0,-1"]  = 7, -- 下
        ["1,-1"]  = 8  -- 右下
    }

    -- 计算相对坐标
    local dx = x - ox
    local dy = y - oy

    -- 查找选项编号
    local key = string.format("%d,%d", dx, dy)

    Logger.debug('getValidOptions' .. key)
    return optionsMap[key]
end

--- Option 触发时写日志（游戏内无额外提示）
---@param opt number 1..8
---@param detail string|nil
local function option_tip(opt, detail)
    local titles = {
        [1] = 'Option1 Farm',
        [2] = 'Option2 Buff',
        [3] = 'Option3 Drain',
        [4] = 'Option4 (reserved)',
        [5] = 'Option5 RoundRect',
        [6] = 'Option6 RoundRandom',
        [7] = 'Option7 Grind',
        [8] = 'Option8 2048',
    }
    local msg = titles[opt] or ('Option' .. tostring(opt))
    if detail ~= nil and detail ~= '' then
        msg = msg .. ' | ' .. tostring(detail)
    end
    Logger.info('[option] ' .. msg)
end

-- 选项
local OptionHandlers = {
    -- option1 生命体控角（madDog 寻敌）
    function()
        Logger.info('OPTION 1 Farm')
        option_tip(1, '生命体控角 / madDog')
        ---@type FarmTask
        local task = {
            name = 'Farm',
            persistent = true,
        }

        TryJumpTask(task, { removeUniqueTask = true })

        clear_cmds()
    end,
    -- option2 开关 保持buff environment module 去控制技能释放
    function()
        Logger.info('OPTION 2')
        local conf = Blackboard.buff_conf
        local type = Blackboard.type

        if conf == nil then
            Blackboard.buff_conf = Skill.buff_conf[type]
            option_tip(2, 'Buff 已开启')
        else
            Blackboard.buff_conf = nil
            option_tip(2, 'Buff 已关闭')
        end
    end,
    -- option3 大队模式：插队 Drain（结束用 Alt+T 连击，同 Farm/Grind）
    function()
        Logger.info('OPTION 3')
        option_tip(3, '大队模式 Drain')
        ---@type DrainTask
        local task = {
            name = 'Drain',
            persistent = true,
        }

        TryJumpTask(task, { removeUniqueTask = true })

        clear_cmds()
    end,
    -- option4 预留（开源版无地图/寻路模块）
    function()
        Logger.info('OPTION 4 reserved')
        option_tip(4, '未配置')
        clear_cmds()
    end,
    -- option5 绕主人 8 格环来回（Funny）
    function()
        Logger.info('OPTION 5 RoundRect')
        option_tip(5)
        TryJumpTask({
            name = 'RoundRect',
            target_id = Blackboard.owner_id,
        }, { removeUniqueTask = true })

        clear_cmds()
    end,
    -- option6 绕主人周围 3 格内随机跳（Funny）
    function()
        Logger.info('OPTION 6 RoundRandom')
        option_tip(6)
        TryJumpTask({
            name = 'RoundRandom',
            target_id = Blackboard.owner_id,
        }, { removeUniqueTask = true })

        clear_cmds()
    end,
    -- option7 挂机打怪（loyalDog 寻敌）
    function()
        Logger.info('OPTION 7 Grind')
        option_tip(7, 'loyalDog 挂机')
        ---@type GrindTask
        local task = {
            name = 'Grind',
            persistent = true,
        }

        TryJumpTask(task, { removeUniqueTask = true })

        clear_cmds()
    end,
    -- option8 2048
    function()
        Logger.info('OPTION 8')
        option_tip(8)
        ---@type Solve2048Task
        local task = {
            name = 'Solve2048'
        }

        TryJumpTask(task, { removeUniqueTask = true })
    end
}

-- 好像有些太啰嗦，就当是测试节点，以后用一个function搞定

local CommandModule = Sequence:new({
    -- 获取消息
    ActionNode:new(ResCommand),
    -- 判断
    Succeeder:new(
        Selector:new({
            Sequence:new({
                -- 判断第一位是不是 FOLLOW_CMD,如果是，进入后续 x tick 的第二 cmd 的判断
                ConditionNode:new(createCmdCondition(1, FOLLOW_CMD)),
                -- 这里要进行第二次判断,如果通过 就结束

                Selector:new({
                    Sequence:new({
                        -- 双击 Alt+T：取消任务且 cmds 不得再留 FOLLOW
                        ConditionNode:new(createCmdCondition(2, FOLLOW_CMD)),
                        ActionNode:new(function()
                            cancel_all_state()
                            Logger.info('OPTION cancel Alt+T x2')
                            return NodeStates.SUCCESS
                        end)
                    }),
                    Sequence:new({
                        -- 用 Move 命令选中 人物周边8个格子，代表8个选项
                        ConditionNode:new(createCmdCondition(2, MOVE_CMD)),
                        ActionNode:new(function()
                            local cmd = Blackboard.cmds:get(2)

                            if cmd == nil then
                                return NodeStates.FAILURE
                            end

                            local x = cmd[2]
                            local y = cmd[3]

                            local opt = getValidOptions(x, y)

                            if opt == nil then
                                return NodeStates.FAILURE
                            end

                            OptionHandlers[opt]()
                            clear_cmd_timer()
                            return NodeStates.SUCCESS
                        end)
                    }),
                }),
                -- 仅在「只有一条 FOLLOW、尚未选格」时进入 2s 等待；取消/选选项后不再 push FOLLOW
                Sequence:new({
                    ConditionNode:new(is_follow_option_wait),
                    ActionNode:new(function()
                        begin_follow_option_wait()
                        if Blackboard.timers[timerName] == nil then
                            Blackboard.timers[timerName] = {
                                startTime = GetTick(),
                                timeout = 2000,
                            }
                        end
                        return NodeStates.SUCCESS
                    end),
                    Timeout:new(
                        timerName,
                        ActionNode:new(function()
                            clear_cmds()
                            clear_cmd_timer()
                            Logger.debug('OPTION wait timeout 2s')
                            return NodeStates.FAILURE
                        end),
                        2000
                    )
                }),
            }),
            Sequence:new({
                -- 判断第一位是不是 MOVE_CMD
                ConditionNode:new(createCmdCondition(1, MOVE_CMD)),
                -- 插队一个 MoveTo Task
                ActionNode:new(createMoveToTask)
            }),
            Sequence:new({
                -- 判断第一位是不是 ATTACT_OBJET_CMD
                ConditionNode:new(createCmdCondition(1, ATTACT_OBJET_CMD)),
                -- 插队一个 Kill Task
                ActionNode:new(createKillTask)
            }),
            Sequence:new({
                -- 判断第一位是不是 SKILL_OBJECT_CMD
                ConditionNode:new(createCmdCondition(1, SKILL_OBJECT_CMD)),
                -- 放技能
                ActionNode:new(function()
                    local cmd = Blackboard.cmds:shift()
                    if cmd == nil or cmd[1] ~= SKILL_OBJECT_CMD then
                        Logger.warn('[CommandModule] UseSkill: cmd missing or type mismatch')
                        return NodeStates.FAILURE
                    end
                    UseSkill(cmd[2], cmd[3], cmd[4])
                    return NodeStates.SUCCESS
                end)
            }),
        })
    )
})

return CommandModule
