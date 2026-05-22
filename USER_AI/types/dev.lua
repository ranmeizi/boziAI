---@alias NodeStates -1|1|0

---@class MoveToTask
---@field name 'MoveTo'
---@field pos_x number|nil  要么给 xy 要么给 target_id
---@field pos_y number|nil
---@field target_id number|nil

---@class KillTask Kill任务
---@field name 'Kill'
---@field target_id number 要杀的目标
---@field mode nil | 'default' | 'fullpower' | 'skillonly' 默认default
---@field _skillOnWay nil | true  在路上杀的标识
---@field _hasFirstAttack nil | true 是不是打了第一下

---@class StopTask 保持在屏幕里
---@field name 'Stop'

---@class FarmTask 生命体控角（madDog 寻敌）
---@field name 'Farm'
---@field persistent? true

---@class GrindTask 挂机打怪（loyalDog 寻敌）
---@field name 'Grind'
---@field persistent? true

---@class DrainTask 月光点名循环（寻特殊怪 → Touch）
---@field name 'Drain'

---@class TouchTask 对单怪一次月光并登记 id
---@field name 'Touch'
---@field target_id number

---@class Solve2048Task 玩2048
---@field name 'Solve2048'

---@class RoundHeartTask 绕目标走心形
---@field name 'RoundHeart'
---@field target_id number
---@field _wp? { number, number }[]
---@field _idx? number

---@class RoundRectTask 绕目标周围 8 格矩形环来回走（直到取消任务）
---@field name 'RoundRect'
---@field target_id number
---@field _wp? { number, number }[]
---@field _idx? number

---@class RoundRandomTask 绕目标周围 3 格内随机乱跳（直到取消任务）
---@field name 'RoundRandom'
---@field target_id number
---@field _gx? number
---@field _gy? number
---@field _rng_seeded? boolean

---@class UseSkillTask 放技能
---@field name 'UseSkill'
---@field level number 技能等级
---@field type number 技能编号
---@field target_id number 目标ID

---@class TryJumpTaskOptions
---@field removeUniqueTask? boolean 开启则删除队列里同名 task

---@class AbstractTimer 计时器
---@field startTime number 开始时间
---@field timeout number   延迟时间
