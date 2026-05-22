local Logger = require('AI_sakray/USER_AI/Logger')
local typeBlacklist = require('AI_sakray/USER_AI/tatget_blacklist_conf')
local typeWhitelist = require('AI_sakray/USER_AI/tatget_whitelist_conf')

local whitelistActive = false
for _, allowed in pairs(typeWhitelist) do
    if allowed == true then
        whitelistActive = true
        break
    end
end

--- @param id number
local function checkIgnore(id)
    local val = Blackboard.ignore_cache:get(id)
    Logger.debug('DINF LOG' .. json.encode(val))
    return val ~= nil
end

--- @param homunType number|nil  GetV(V_HOMUNTYPE, id)
local function isBlacklistedType(homunType)
    if homunType == nil or homunType == 0 then
        return false
    end
    return typeBlacklist[homunType] == true
end

--- 白名单启用时，仅允许表内类型；未启用则一律通过
--- @param homunType number|nil
local function isWhitelistedType(homunType)
    if not whitelistActive then
        return true
    end
    if homunType == nil or homunType == 0 then
        return false
    end
    return typeWhitelist[homunType] == true
end

--- 是否允许参与自动寻敌（不含主人手动目标）
--- @param monster table|nil
local function isAutoTargetAllowed(monster)
    if monster == nil then
        return false
    end
    if isBlacklistedType(monster.type) then
        return false
    end
    if not isWhitelistedType(monster.type) then
        return false
    end
    if checkIgnore(monster.id) then
        return false
    end
    return true
end

--- @param actorId number
local function isActorAutoTargetAllowed(actorId)
    local monster = Blackboard.objects.monsters[actorId]
    if monster ~= nil then
        return isAutoTargetAllowed(monster)
    end
    local homunType = GetV(V_HOMUNTYPE, actorId)
    if isBlacklistedType(homunType) or not isWhitelistedType(homunType) then
        return false
    end
    return not checkIgnore(actorId)
end

local function clearIgnoreCacheInterval()
    if PerXSecond(60 * 10) then
        Blackboard.ignore_cache:clearExpired()
    end
end

local function getHomuFriendSafeTarget()
    return Blackboard.objects.homu_safe_target:pop()
end


--[[
    应该是探测不到客户端的 hp sp
    选最近的把
    或是自己记录一个权重

    找到   SUCCESS
    未找到 FAILURE

    我觉得应该记录一个战斗日志
    对于未知敌人，失败无所谓，最重要是需要在失败中吸取教训。

    1. 主人的目标，是第一优先级，因为主人目标是人工选的
    2.
]]
local function findBestTarget()
    -- 寻找最优敌人
    -- print('Action FindBestTarget')

    Blackboard.objects.bestTarget = nil -- 重置

    for _, monster in pairs(Blackboard.objects.monsters) do
        if isAutoTargetAllowed(monster) then
            if Blackboard.objects.bestTarget == nil then
                Blackboard.objects.bestTarget = monster
            elseif monster.distance < Blackboard.objects.bestTarget.distance then
                Blackboard.objects.bestTarget = monster
            end
        end
    end

    return Blackboard.objects.bestTarget
        and NodeStates.SUCCESS
        or NodeStates.FAILURE
end

-- 从 monster 里找最优的怪 (由于信息太少，先找最近的)
local function findBestTargetInMonsters()
    local target = nil
    for id, monster in pairs(Blackboard.objects.monsters) do
        -- 先要考虑，是否是屏幕内的 即与主人相距<=15
        if monster.distance_owner <= 15 and isAutoTargetAllowed(monster) then
            if target == nil then
                target = monster
            elseif monster.distance < target.distance then
                target = monster
            end
        end
    end



    return target and target.id or nil
end


-- 从 仇恨列表中找最近的怪
local function findNearestInAggroList(list)
    local item = nil

    for _, value in ipairs(list) do
        if isActorAutoTargetAllowed(value.id) then
            if item == nil then
                item = value
            elseif value.distance == 1 then
                return value.id
            elseif value.distance < item.distance then
                item = value
            end
        end
    end

    return item and item.id or nil
end

--[[
    疯狗型
    1. 主人的目标，是第一优先级，因为主人目标是人工选的
    2. 去找自己周围最指的打的
]]
local function madDogFindTarget()
    -- 1. 第一目标是主人打的
    if Blackboard.objects.owner.target ~= nil and Blackboard.objects.owner.target ~= 0 and GetV(V_MOTION, Blackboard.objects.owner.target) ~= -1 then
        -- 判断怪还或者
        return Blackboard.objects.owner.target
    end

    -- 2. monster 里找
    return findBestTargetInMonsters()
end

--[[
    忠犬型
    1. 主人的目标
    2. 攻击自己的目标
    3. 攻击主人的目标
]]
local function loyalDogFindTarget()
    -- 1. 第一目标是主人打的
    if Blackboard.objects.owner.target ~= nil and Blackboard.objects.owner.target ~= 0 and GetV(V_MOTION, Blackboard.objects.owner.target) ~= -1 then
        -- 判断怪还或者
        return Blackboard.objects.owner.target
    end

    -- 1.5 别人生命体
    local safe_homu_target = getHomuFriendSafeTarget()
    if safe_homu_target and isActorAutoTargetAllowed(safe_homu_target) then
        return safe_homu_target
    end

    -- 2. 攻击自己的怪
    local res = findNearestInAggroList(Blackboard.objects.aggroListHomu)

    if res ~= nil then
        return res
    end

    -- 3. 攻击主人的目标
    res = findNearestInAggroList(Blackboard.objects.aggroListOwner)

    if res ~= nil then
        return res
    end
end

--[[
    死狗型
    完全不打人
]]
local function deadDogFindTarget()

end


return {
    madDogFindTarget = madDogFindTarget,
    loyalDogFindTarget = loyalDogFindTarget,
    clearIgnoreCacheInterval = clearIgnoreCacheInterval
}
