# UseSkill 语法修复 Patch

仅包含提交 `ca7a89cb9e3ecc9650e9c07da51d27cdca2d981e`（`fix: 语法bug`）。

## 改动

- **文件**：`USER_AI/BehaviorTree/common/actions/UseSkill.lua`
- **内容**：把 `local function` + 事后挂字段，改成表模块 + `__call`，消除 LuaLS「不能在 function 引用中注入字段」报错；`UseSkill(level, type, id)` 调用方式不变。

## 合并到别的库

**前提：** 目标库里的 `UseSkill.lua` 已是「可调用函数 + 挂 `UseSkill.xxx`」那一版（通常来自 `8e6c7cf` 或等价改动）。若还是更早的纯函数实现，本 patch 可能对不上。

```bash
cd /path/to/other-repo
git apply --check /path/to/AI_sakray/patches/ca7a89c-fix-useskill.patch
git apply /path/to/AI_sakray/patches/ca7a89c-fix-useskill.patch
# 或保留提交信息：
git am /path/to/AI_sakray/patches/ca7a89c-fix-useskill.patch
```

## 重新生成

```bash
git show ca7a89cb9e3ecc9650e9c07da51d27cdca2d981e > patches/ca7a89c-fix-useskill.patch
```
