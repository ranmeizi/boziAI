local BehaviorTree = {}
BehaviorTree.__index = BehaviorTree

function BehaviorTree:new(root)
    local tree = setmetatable({}, self)
    tree.root = root
    return tree
end

function BehaviorTree:run()
    if self.root then
        self.root:execute()
    end
end

return BehaviorTree