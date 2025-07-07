-- courier.lua
-- Courier Job: moves items using Pathfinder with Agent state

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

-- SAFE Helper: find an item slot in the chest
local function find_item_slot(side, name)
    print(string.format("🔍 find_item_slot() called: side=%s name=%s", tostring(side), tostring(name)))

    local size = ic.getInventorySize(side)
    if not size then
        print("⚠️ Chest not detected: getInventorySize() returned nil.")
        return nil, 0
    end

    print(string.format("📦 Chest inventory size: %s", tostring(size)))

    for slot = 1, size do
        local stack = ic.getStackInSlot(side, slot)
        if stack then
            print(string.format("  🔢 Slot %d: %s x%s", slot, stack.name, stack.size))
            if stack.name == name then
                print(string.format("✅ Found: slot=%d size=%d", slot, stack.size))
                return slot, stack.size
            end
        else
            print(string.format("  🔢 Slot %d: empty", slot))
        end
    end

    print("❌ Item not found in chest.")
    return nil, 0
end

function Courier:execute(task)
    print("📦 Courier job started.")

    local desired_item = task.item_name or "minecraft:iron_ingot"
    local desired_amount = task.amount or 4

    print("Item: " .. desired_item .. "  Amount: " .. desired_amount)

    local pf = Pathfinder:new(self.agent)

    -- GO TO ORIGIN
    local origin = { x = tonumber(task.origin.x), y = tonumber(task.origin.y), z = tonumber(task.origin.z) }
    print(string.format("\n📌 GOING TO ORIGIN: x=%s z=%s", origin.x, origin.z))
    pf:go_to(origin, true)
    print("✅ Arrived at origin. Preparing to check chest...")

    os.sleep(0.1)

    local pickup_side = sides.front
    local slot, available = find_item_slot(pickup_side, desired_item)

    if slot then
        local to_suck = math.min(available, desired_amount)
        if ic.suckFromSlot(pickup_side, slot, to_suck) then
            print("✅ Picked up " .. to_suck .. " of " .. desired_item)
        else
            print("⚠️ Could not pick up items.")
        end
    else
        print("❌ Nothing picked up: item missing or chest not found.")
    end

    -- GO TO DESTINATION
    local destination = { x = tonumber(task.destination.x), y = tonumber(task.destination.y), z = tonumber(task.destination.z) }
    print(string.format("\n📌 GOING TO DESTINATION: x=%s z=%s", destination.x, destination.z))
    pf:go_to(destination, true)

    if robot.drop(desired_amount) then
        print("✅ Dropped " .. desired_amount .. " of " .. desired_item)
    else
        print("⚠️ Nothing dropped.")
    end

    -- RETURN TO BASE
    local home = {
        x = tonumber(self.agent.home and self.agent.home.x or self.agent.pos.x),
        y = tonumber(self.agent.home and self.agent.home.y or self.agent.pos.y),
        z = tonumber(self.agent.home and self.agent.home.z or self.agent.pos.z)
    }
    print(string.format("\n📌 GOING HOME: x=%s z=%s", home.x, home.z))
    pf:go_to(home, false)

    print("✅ Courier job done.")
end

return Courier
