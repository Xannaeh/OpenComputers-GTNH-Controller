-- courier.lua
-- Courier Job: moves items between locations, using task data

local component = require("component")
local robot = require("robot")
local sides = require("sides")

local ic = component.inventory_controller

local Job = require("job")

-- Proper class table
local Courier = {}

-- Inherit Job
setmetatable(Courier, { __index = Job })
Courier.__index = Courier

function Courier:new()
    local obj = Job:new()  -- call parent new
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

    -- === PICKUP ===

    -- Move to pickup chest (example: 3 blocks forward)
    for i = 1, 3 do
        robot.forward()
    end

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

    -- Return to start
    for i = 1, 3 do
        robot.back()
    end

    -- === DROP ===

    -- Turn 180°
    robot.turnLeft()
    robot.turnLeft()

    -- Move to drop-off chest (3 blocks forward other side)
    for i = 1, 3 do
        robot.forward()
    end

    -- Drop items
    if robot.drop(desired_amount) then
        print("✅ Dropped " .. desired_amount .. " of " .. desired_item)
    else
        print("⚠️ Nothing dropped.")
    end

    -- Return to base
    for i = 1, 3 do
        robot.back()
    end

    -- Reset orientation
    robot.turnLeft()
    robot.turnLeft()

    print("✅ Courier job done.")
end

return Courier
