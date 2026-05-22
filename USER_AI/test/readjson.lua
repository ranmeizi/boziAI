local json = require('AI_sakray.USER_AI.libs.dkjson')

local file, err = io.open("AI_sakray/memory.json", "r")
if not file then
    print("文件打开失败:", err)
    return
end

-- 读取全部内容到字符串
local content = file:read("*a")  -- "*a" 表示读取所有内容
file:close()  -- 关闭文件

local data, pos, err = json.decode(content, 1, nil)

local options = {
    indent = true,      -- 美化输出，带缩进和换行
    level = 0,          -- 初始缩进级别
    noprotect = false   -- 不保护循环引用
}

print("memory.state:", json.encode(data,options))