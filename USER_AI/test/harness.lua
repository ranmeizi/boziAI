--[[ USER_AI 单元测试小框架 ]]

local M = {
    passed = 0,
    failed = 0,
    errors = {},
}

function M.assert_true(cond, msg)
    if not cond then
        error(msg or 'assert_true failed', 2)
    end
end

function M.assert_eq(actual, expected, msg)
    if actual ~= expected then
        error(string.format(
            '%s: expected %s (%s), got %s (%s)',
            msg or 'assert_eq',
            tostring(expected),
            type(expected),
            tostring(actual),
            type(actual)
        ), 2)
    end
end

function M.assert_near(actual, expected, eps, msg)
    eps = eps or 1e-6
    if math.abs(actual - expected) > eps then
        error(string.format(
            '%s: expected ~%s, got %s',
            msg or 'assert_near',
            tostring(expected),
            tostring(actual)
        ), 2)
    end
end

function M.run(name, fn)
    local ok, err = xpcall(fn, debug.traceback)
    if ok then
        M.passed = M.passed + 1
        print('[PASS] ' .. name)
    else
        M.failed = M.failed + 1
        table.insert(M.errors, { name = name, err = err })
        print('[FAIL] ' .. name)
        print(err)
    end
end

function M.summary()
    print(string.format('\n%d passed, %d failed', M.passed, M.failed))
    return M.failed == 0
end

return M
