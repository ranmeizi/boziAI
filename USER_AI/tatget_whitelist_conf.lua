--[[
    自动寻敌类型白名单（V_HOMUNTYPE）

    - 表中没有任何 [type] = true：不启用白名单，按黑名单 + 正常寻敌逻辑选怪。
    - 至少一项为 true：只攻击白名单中的类型（黑名单仍生效；主人手动目标不受影响）。

    示例（只打指定怪）：
    return {
        [1002] = true,
        [1113] = true,
    }
]]

-- 企业上 打金属波利
local lhz_fild01_whitelist = {
    [1613] = true -- 金属波利
}

return lhz_fild01_whitelist
