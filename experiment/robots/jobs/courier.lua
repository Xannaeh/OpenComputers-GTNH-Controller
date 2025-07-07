-- courier.lua
-- Courier Job: moves items using Pathfinder with Agent state

local component = require("component")
local robot = require("robot")
local sides = require("sides")

local ic = component.inventory_controller

local Job = require("job")
local Pathfinder = require("pathfinder")

-- Proper class table
local Courier = {}

-- Inherit Job
setmetatable(Courier, { __index = Job })
Courier.__index = Courier

function Courier:new(agent)
    local obj = Job:new()
    setmetatable(obj, Courier)
    obj.agent = agent  -- 🗂️ Keep reference to the Agent with pos
    return obj
end

-- Helper: find an item slot in the chest
local function find_item_slot(side, name)
    local size = ic.getInventorySize(side)
    for slot = 1, size do
        local stack = ic.getStackInSlot(side, slot)
        if stack and stack.name == name then
            return slot, stack.size
        end
    end
    return nil, 0
end

function Courier:execute(task)
    print("📦 Courier job started.")

    local desired_item = task and task.item_name or "minecraft:iron_ingot"
    local desired_amount = task and task.amount or 4

    print("Item: " .. desired_item .. "  Amount: " .. desired_amount)

    local pf = Pathfinder:new(self.agent)

    -- === GO TO ORIGIN ===
    print("\n📌 GOING TO ORIGIN:", task.origin and ("x="..tostring(task.origin.x).." z="..tostring(task.origin.z)) or "NIL")
    pf:go_to(task.origin)

    local pickup_side = sides.front
    local slot, available = find_item_slot(pickup_side, desired_item)

    if slot then
        local to_suck = math.min(available, desired_amount)
        if ic.suckFromSlot(pickup_side, slot, to_suck) then
            print("✅ Picked up " .. to_suck .. " of " .. desired_item)
        else
            print("⚠️ Failed to pick up items.")
        end
    else
        print("❌ Item not found in pickup chest.")
    end

    -- === GO TO DESTINATION ===
    print("\n📌 GOING TO DESTINATION:", task.destination and ("x="..tostring(task.destination.x).." z="..tostring(task.destination.z)) or "NIL")
    pf:go_to(task.destination)

    if robot.drop(desired_amount) then
        print("✅ Dropped " .. desired_amount .. " of " .. desired_item)
    else
        print("⚠️ Nothing dropped.")
    end

    -- === RETURN TO BASE ===
    print("\n📌 GOING HOME:", self.agent.pos and ("x="..tostring(self.agent.pos.x).." z="..tostring(self.agent.pos.z)) or "NIL")
    pf:go_to(self.agent.pos) -- back to Agent's current base

    print("✅ Courier job done.")
end

return Courier
