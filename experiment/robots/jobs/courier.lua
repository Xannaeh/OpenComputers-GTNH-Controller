-- courier.lua
-- Courier Job: moves items between world coordinates using Pathfinder

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

function Courier:new()
    local obj = Job:new()
    setmetatable(obj, Courier)
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

    -- === PATHFINDER ===
    local pf = Pathfinder:new({ x = 32, y = 5, z = 0 }, "south")  -- TODO: your base coords & facing

    -- Go to origin chest (real world)
    pf:go_to(task.origin)

    print("✅ After go_to origin: pos=", pf.pos.x, pf.pos.z)
    print("✅ After go_to destination: pos=", pf.pos.x, pf.pos.z)

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

    -- Go to destination chest (real world)
    pf:go_to(task.destination)

    print("✅ After go_to origin: pos=", pf.pos.x, pf.pos.z)
    print("✅ After go_to destination: pos=", pf.pos.x, pf.pos.z)

    if robot.drop(desired_amount) then
        print("✅ Dropped " .. desired_amount .. " of " .. desired_item)
    else
        print("⚠️ Nothing dropped.")
    end

    -- Return to base origin
     pf:go_to({ x = 32, y = 5, z = 0 })

    print("✅ Courier job done.")
end

return Courier
