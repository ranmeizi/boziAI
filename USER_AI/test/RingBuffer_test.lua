--[[
  RingBuffer 单元测试
  lua AI_sakray/USER_AI/test/RingBuffer_test.lua
]]

local harness = require('AI_sakray/USER_AI/test/harness')
local RingBuffer = require('AI_sakray/USER_AI/libs/RingBuffer')

local function run(name, fn)
    harness.run(name, fn)
end

run('push and get sequential', function()
    local rb = RingBuffer.new(3)
    rb:push(10)
    rb:push(20)
    rb:push(30)
    harness.assert_eq(rb:len(), 3)
    harness.assert_eq(rb:get(1), 10)
    harness.assert_eq(rb:get(2), 20)
    harness.assert_eq(rb:get(3), 30)
    harness.assert_eq(rb:first(), 10)
    harness.assert_eq(rb:last(), 30)
end)

run('overwrite oldest when full', function()
    local rb = RingBuffer.new(3)
    rb:push(1)
    rb:push(2)
    rb:push(3)
    rb:push(4)
    harness.assert_true(rb:is_full())
    harness.assert_eq(rb:len(), 3)
    harness.assert_eq(rb:get(1), 2)
    harness.assert_eq(rb:get(2), 3)
    harness.assert_eq(rb:get(3), 4)
    rb:push(5)
    harness.assert_eq(rb:get(1), 3)
    harness.assert_eq(rb:get(3), 5)
end)

run('wrap many pushes', function()
    local rb = RingBuffer.new(5)
    for i = 1, 20 do
        rb:push(i)
    end
    harness.assert_eq(rb:len(), 5)
    harness.assert_eq(rb:get(1), 16)
    harness.assert_eq(rb:get(5), 20)
end)

run('clear', function()
    local rb = RingBuffer.new(10)
    rb:push(1)
    rb:clear()
    harness.assert_eq(rb:len(), 0)
    harness.assert_true(rb:is_empty())
    harness.assert_eq(rb:last(), nil)
    rb:push(99)
    harness.assert_eq(rb:get(1), 99)
end)

run('push_point dedup same cell', function()
    local rb = RingBuffer.new(10)
    harness.assert_true(rb:push_point(5, 5))
    harness.assert_true(not rb:push_point(5, 5))
    harness.assert_eq(rb:len(), 1)
end)

run('push_point min_dist', function()
    local rb = RingBuffer.new(10)
    rb:push_point(0, 0, { min_dist = 2 })
    harness.assert_true(not rb:push_point(1, 0, { min_dist = 2 }))
    harness.assert_true(rb:push_point(2, 0, { min_dist = 2 }))
    harness.assert_eq(rb:len(), 2)
end)

run('chord_length head tail', function()
    local rb = RingBuffer.new(10)
    harness.assert_eq(rb:chord_length(), 0)
    rb:push_point(0, 0)
    harness.assert_eq(rb:chord_length(), 0)
    rb:push_point(3, 4)
    harness.assert_eq(rb:chord_length(), 5)
    rb:push_point(3, 4)
    harness.assert_eq(rb:chord_length(), 5)
    rb:push_point(0, 0)
    harness.assert_eq(rb:chord_length(), 0)
end)

run('net_displacement', function()
    local rb = RingBuffer.new(10)
    rb:push_point(0, 0)
    rb:push_point(3, 4)
    local dx, dy = rb:net_displacement()
    harness.assert_eq(dx, 3)
    harness.assert_eq(dy, 4)
end)

run('avg_displacement smooths zigzag', function()
    local rb = RingBuffer.new(10)
    rb:push_point(0, 0)
    rb:push_point(1, 0)
    rb:push_point(0, 0)
    rb:push_point(1, 0)
    local dx, dy = rb:avg_displacement(3)
    harness.assert_near(dx, 1 / 3, 1e-6)
    harness.assert_near(dy, 0, 1e-6)
end)

run('ipairs order oldest first', function()
    local rb = RingBuffer.new(3)
    rb:push(1)
    rb:push(2)
    rb:push(3)
    rb:push(4)
    local order = {}
    for _, v in rb:ipairs() do
        order[#order + 1] = v
    end
    harness.assert_eq(#order, 3)
    harness.assert_eq(order[1], 2)
    harness.assert_eq(order[3], 4)
end)

run('cap minimum 1', function()
    local rb = RingBuffer.new(0)
    harness.assert_eq(rb:cap(), 1)
    rb:push(1)
    rb:push(2)
    harness.assert_eq(rb:len(), 1)
    harness.assert_eq(rb:get(1), 2)
end)

print(string.format('\nRingBuffer: %d passed, %d failed', harness.passed, harness.failed))
if harness.failed > 0 then
    os.exit(1)
end
