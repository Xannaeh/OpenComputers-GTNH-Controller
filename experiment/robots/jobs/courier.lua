-- courier.lua
-- Courier job with safe stop-one-before, improved debug

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
        print("⚠️ Chest not found.")
        return nil, 0
    end

    for slot = 1, size do
        local stack = ic.getStackInSlot(side, slot)
        if stack and stack.name == name then
            print(string.format("✅ Found %s in slot %d (amount %d)", name, slot, stack.size))
            return slot, stack.size
        end
    end
    return nil, 0
end

function Courier:execute(task)
    print("📦 Courier started: "..task.item_name.." x"..task.amount)

    local pf = Pathfinder:new(self.agent, tostring(task.id or "debug"))

    local origin = { x = task.origin.x, y = task.origin.y, z = task.origin.z }
    local dest   = { x = task.destination.x, y = task.destination.y, z = task.destination.z }

    -- Adjust: stop 1 block before target chest
    pf:log("⚙️  Adjusting path to stop one before chest.")
    origin = pf:adjust_stop_before(origin)
    dest   = pf:adjust_stop_before(dest)

    pf:go_to(origin)

    local slot, available = find_item_slot(sides.front, task.item_name)
    if slot then
        local to_suck = math.min(available, task.amount)
        if ic.suckFromSlot(sides.front, slot, to_suck) then
            print("✅ Picked up "..to_suck)
        else
            print("⚠️ Failed to pick up.")
        end
    else
        print("❌ Nothing picked up.")
    end

    pf:go_to(dest)

    if robot.drop(task.amount) then
        print("✅ Dropped.")
    else
        print("⚠️ Drop failed.")
    end

    pf:go_to(self.agent.home)
    print("✅ Courier done.")
end

return Courier
