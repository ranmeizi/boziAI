-- 挂全局
_G.json = require('AI_sakray/USER_AI/libs/dkjson')
_G.Array = require('AI_sakray/USER_AI/libs/ArrayLike')
_G.CacheControl = require('AI_sakray/USER_AI/libs/CacheControl')
require('AI_sakray/USER_AI/Const')
require 'AI_sakray.USER_AI.Util'
require('AI_sakray/USER_AI/BehaviorTree/Core/init')

local HomuTrees = require('AI_sakray/USER_AI/HOMU/trees')
local FindTarget = require('AI_sakray/USER_AI/BehaviorTree/common/actions/FindTarget')
local ConfigModule = require('AI_sakray.USER_AI.ConfigModule')

-- 全局黑板
Blackboard = {
    id = nil, -- 生命体id

    is_init = true,

    owner_id = nil,

    type = nil,

    -- 客户端发送命令列表
    cmds = Array:new({}),

    -- 计时器 table
    timers = {},

    --[[
        任务记录
        {
            name: '任务名称',
            ... 按任务定义的动态参数类型
        }
    ]] --
    task = nil,

    -- 任务队列
    task_queue = Array.new({}),

    -- 寻敌忽略列表（暂时跳过某目标）
    ignore_cache = CacheControl:new(),

    -- 技能冷却
    cooldown = CacheControl:new(),

    -- 保持增益buff的配置项 (由 Option2 开启/关闭，或是由task开启/关闭)
    buff_conf = nil,

    --- Drain 低蓝休息（SP 滞回；见 Drain.lua）
    drain_resting = false,

    -- 调用 Environment 记录 objects , 后面可以用外置应用读出来
    objects = {
        -- 生命体
        homu = {
            id = nil,
            -- 生命值
            hp = nil,
            -- 最大生命值
            hp_max = nil,
            -- 魔法值
            sp = nil,
            -- 最大魔法值
            sp_max = nil,
            -- 类型(编号)
            type = nil,
            -- 位置
            pos = { x = nil, y = nil },
            -- 攻击距离
            attack_range = 0
        },
        -- 主人
        owner = {
            id = nil,
            -- 生命值
            hp = nil,
            -- 最大生命值
            hp_max = nil,
            -- 魔法值
            sp = nil,
            -- 最大魔法值
            sp_max = nil,
            -- 类型(编号)
            type = nil,
            -- 位置
            pos = { x = nil, y = nil },
            -- 攻击距离
            attack_range = 0,
            -- 目标
            target = nil,
            distance = nil,
        },

        -- 怪物列表
        monsters = {},

        -- 别人生命体打的怪，我去蹭应该是安全的
        homu_safe_target = Array:new({}),

        -- 生命体 仇恨列表
        aggroListHomu = Array:new({}),

        -- 主人 仇恨列表
        aggroListOwner = Array:new({}),

        -- 记录 find taeget 的结果
        bestTarget = nil,

        -- Drain 当前选中的特殊目标（对标 bestTarget）
        drainTouchTarget = nil
    },

    -- 记录日志
    logs = {
        -- hp 回复速度
        hp_avg_regen = 0,
        -- sp 回复速度
        sp_avg_regen = 0,
    }
}

require('AI_sakray/USER_AI/Memory')
Memory.load()

ConfigModule.init()

-- 每次脚本重载只水合一次（需先有 GetV 的 id/type）
local memoryHydrated = false

-- 初始化行为树（按生命体类型缓存）
local homu_trees = {}
local homu_tree_last_type = nil

local function get_homu_tree(homun_type)
    if homun_type == homu_tree_last_type and homu_trees[homun_type] ~= nil then
        return homu_trees[homun_type]
    end
    local mod = HomuTrees.get_module(homun_type)
    homu_trees[homun_type] = BehaviorTree:new(mod.root)
    homu_tree_last_type = homun_type
    Logger.info('[AI] behavior tree homun_type=' .. tostring(homun_type))
    return homu_trees[homun_type]
end

local function showTasks()
    if Blackboard.task == nil then
        Logger.debug('current task: nil')
    else
        Logger.debug('current task:' .. Blackboard.task.name)
    end


    local queue = 'task queue:'

    for index, value in Blackboard.task_queue:ipairs() do
        queue = queue .. value.name .. ','
    end

    Logger.debug(queue)
end

local function loop(id)
    Logger.debug('AI loop start')


    if Blackboard.is_init ~= true then
        Logger.info('INIT')
        Blackboard.is_init = true
    end

    -- 记录id
    local prev_homu_id = Blackboard._homu_id
    Blackboard.id = id
    Blackboard.owner_id = GetV(V_OWNER, id)
    Blackboard.type = GetV(V_HOMUNTYPE, id)

    if prev_homu_id ~= nil and prev_homu_id ~= id then
        on_homunculus_id_changed(prev_homu_id, id)
        promoteTaskFromQueue()
    end
    Blackboard._homu_id = id

    if not memoryHydrated then
        Memory.hydrateToBlackboard()
        memoryHydrated = true
    end

    showTasks()

    -- 按生命体类型运行对应行为树
    get_homu_tree(Blackboard.type):run()
end

function AI(id)
    xpcall(function()
        loop(id)

        -- 清理过期忽略项
        FindTarget.clearIgnoreCacheInterval()

        if PerXSecond(10) then

            Memory.store()

            local options = {
                indent = true,    -- 美化输出，带缩进和换行
                level = 0,        -- 初始缩进级别
                noprotect = false -- 不保护循环引用
            }

            -- TraceAI(json.encode(Blackboard.ignore_cache, options))
            -- TraceAI(json.encode(Blackboard.cooldown, options))
            -- 看一下 Blackboard 能格式化成啥样
            -- TraceAI(_G.json.encode(Blackboard, options))
            Logger.debug('kan : ' .. tostring(Blackboard.objects.homu.type))
        end
        
    end, function(err)
        Logger.error('出错天了噜' .. tostring(err))
        Memory.store()

        -- 打印堆栈信息
        Logger.error(debug.traceback(err))
        -- 抛出异常
        -- error(err)
    end)
end
