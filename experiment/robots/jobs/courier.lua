-- courier.lua
-- Courier job using improved Pathfinder

local component = require("component")
local robot = require("robot")
local sides = require("sides")
local ic = component.inventory_controller

local Job = require("job")
local Pathfinder = require("pathfinder")

local Courier = {}
setmetatable(Courier, { __index = Job })
Courier.__index = Courier

function Courier:new(agent)
    local obj = Job:new()
    setmetatable(obj, Courier)
    obj.agent = agent
    return obj
end

local function find_item_slot(side, name)
    print(string.format("🔍 find_item_slot() called: side=%s name=%s", tostring(side), tostring(name)))

    local size = ic.getInventorySize(side)
    if not size then
        print("⚠️ No chest detected.")
        return nil, 0
    end

    print(string.format("📦 Chest inventory size: %s", tostring(size)))

    for slot = 1, size do
        local stack = ic.getStackInSlot(side, slot)
        if stack and stack.name == name then
            print(string.format("  🔢 Slot %d: %s x%s", slot, stack.name, stack.size))
            return slot, stack.size
        end
    end
    return nil, 0
end

function Courier:execute(task)
    print("📦 Courier started")

    local pf = Pathfinder:new(self.agent)

    local origin = { x = tonumber(task.origin.x), y = tonumber(task.origin.y), z = tonumber(task.origin.z) }
    local dest = { x = tonumber(task.destination.x), y = tonumber(task.destination.y), z = tonumber(task.destination.z) }

    pf:go_to(origin)

    local slot, available = find_item_slot(sides.front, task.item_name)
    if slot then
        local to_suck = math.min(available, task.amount)
        ic.suckFromSlot(sides.front, slot, to_suck)
    end

    pf:go_to(dest)
    robot.drop(task.amount)

    pf:go_to(self.agent.home)
    print("✅ Courier done.")
end

return Courier
