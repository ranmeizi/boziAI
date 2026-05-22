--[[
  LUA_PATH="?.lua;?/init.lua" lua AI_sakray/USER_AI/test/logger_test.lua
]]

package.path = '?.lua;?/init.lua;' .. (package.path or '')

_G.GetTick = function()
    return 4242
end

_G.TraceAI = function(msg)
    print('[TraceAI] ' .. tostring(msg))
end

local Logger = require('USER_AI/Logger')

local passed, failed = 0, 0

local function assert_true(cond, name)
    if cond then
        passed = passed + 1
    else
        failed = failed + 1
        print('FAIL: ' .. name)
    end
end

Logger.configure({ min_level = 'WARN', tag = 'test' })

assert_true(not Logger.is_enabled('DEBUG'), 'debug below min')
assert_true(Logger.is_enabled('WARN'), 'warn at min')

local line = Logger.format(Logger.LEVEL.WARN, 'hello')
assert_true(line:find('tick=4242', 1, true) ~= nil, 'tick in line')
assert_true(line:find('[test]', 1, true) ~= nil, 'tag in line')
assert_true(line:find('[WARN]', 1, true) ~= nil, 'level in line')

Logger.debug('should not print')
Logger.warn('should print')

print(string.format('\nlogger_test: %d passed, %d failed', passed, failed))
os.exit(failed > 0 and 1 or 0)
