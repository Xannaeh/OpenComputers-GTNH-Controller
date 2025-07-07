-- courier.lua
-- Robust courier with facing fix

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
    print("🔍 find_item_slot: side="..tostring(side).." name="..name)
    local size = ic.getInventorySize(side)
    if not size then print("⚠️ Chest missing!") return nil, 0 end
    for slot = 1, size do
        local stack = ic.getStackInSlot(side, slot)
        if stack and stack.name == name then return slot, stack.size end
    end
    return nil, 0
end

function Courier:execute(task)
    print("📦 Courier start: "..task.item_name.." x"..task.amount)
    local pf = Pathfinder:new(self.agent, tostring(task.id or "debug"))

    local origin = { x = task.origin.x, y = task.origin.y, z = task.origin.z }
    local dest = { x = task.destination.x, y = task.destination.y, z = task.destination.z }

    origin = pf:adjust_stop_before(origin)
    dest = pf:adjust_stop_before(dest)

    pf:go_to(origin)
    pf:face_target(task.origin) -- ensure robot faces chest front

    local slot, available = find_item_slot(sides.front, task.item_name)
    if slot then
        local amount = math.min(available, task.amount)
        if ic.suckFromSlot(sides.front, slot, amount) then
            print("✅ Picked up "..amount)
        else
            print("⚠️ Pickup failed.")
        end
    else
        print("❌ Nothing picked up.")
    end

    pf:go_to(dest)
    pf:face_target(task.destination)

    if robot.drop(task.amount) then
        print("✅ Dropped.")
    else
        print("⚠️ Drop failed.")
    end

    pf:go_to(self.agent.home)
    print("✅ Courier done.")
end

return Courier
