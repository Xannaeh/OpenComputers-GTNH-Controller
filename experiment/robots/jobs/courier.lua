-- courier.lua
-- Courier Job with path debug logging

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
        print("⚠️ No chest detected: getInventorySize() returned nil.")
        return nil, 0
    end

    print(string.format("📦 Chest inventory size: %s", tostring(size)))
    for slot = 1, size do
        local stack = ic.getStackInSlot(side, slot)
        if stack then
            print(string.format("  🔢 Slot %d: %s x%s", slot, stack.name, stack.size))
            if stack.name == name then
                return slot, stack.size
            end
        end
    end

    print("❌ Item not found in chest.")
    return nil, 0
end

function Courier:execute(task)
    print("📦 Courier started\nItem: "..task.item_name.."  Amount: "..task.amount)

    local pf = Pathfinder:new(self.agent, tostring(task.id or "debug"))

    -- === ORIGIN ===
    local origin = {
        x = tonumber(task.origin.x), y = tonumber(task.origin.y), z = tonumber(task.origin.z)
    }
    print(string.format("📌 GOING TO ORIGIN: x=%s z=%s", origin.x, origin.z))
    pf:go_to(origin)

    local pickup_side = sides.front
    local slot, available = find_item_slot(pickup_side, task.item_name)

    if slot then
        local to_suck = math.min(available, task.amount)
        if ic.suckFromSlot(pickup_side, slot, to_suck) then
            print("✅ Picked up "..to_suck.." of "..task.item_name)
        else
            print("⚠️ Couldn’t pick up items.")
        end
    else
        print("❌ Nothing picked up: item not found or chest missing.")
    end

    -- === DEST ===
    local destination = {
        x = tonumber(task.destination.x), y = tonumber(task.destination.y), z = tonumber(task.destination.z)
    }
    print(string.format("📌 GOING TO DESTINATION: x=%s z=%s", destination.x, destination.z))
    pf:go_to(destination)

    if robot.drop(task.amount) then
        print("✅ Dropped "..task.amount)
    else
        print("⚠️ Drop failed.")
    end

    -- === HOME ===
    local home = self.agent.home
    print(string.format("📌 GOING HOME: x=%s z=%s", home.x, home.z))
    pf:go_to(home)

    print("✅ Courier done.")
end

return Courier
