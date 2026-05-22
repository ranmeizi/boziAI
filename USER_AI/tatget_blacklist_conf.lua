--[[
    自动寻敌类型黑名单（V_HOMUNTYPE）
    键为 GetV(V_HOMUNTYPE, actorId)，值为 true 表示不参与自动寻敌。
    主人手动选中的目标不受此表影响。
]]
return {
    [1579] = true, -- 炼金种的海葵
    [1555] = true, -- 炼金种的苗娃
}
