-- courier.lua
-- Calls Pathfinder with multiple B options

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
    print(string.format("🔍 Checking chest for: %s", name))
    local size = ic.getInventorySize(side)
    if not size then print("⚠️ Chest not found."); return nil, 0 end

    for slot = 1, size do
        local stack = ic.getStackInSlot(side, slot)
        if stack and stack.name == name then
            return slot, stack.size
        end
    end
    return nil, 0
end

function Courier:execute(task)
    local pf = Pathfinder:new(self.agent, tostring(task.id or "debug"))
    local origin = task.origin
    local destination = task.destination

    local origin_spots = {
        { x = origin.x, y = origin.y, z = origin.z - 1 },
        { x = origin.x - 1, y = origin.y, z = origin.z },
        { x = origin.x, y = origin.y, z = origin.z + 1 },
        { x = origin.x + 1, y = origin.y, z = origin.z }
    }
    local dest_spots = {
        { x = destination.x, y = destination.y, z = destination.z - 1 },
        { x = destination.x - 1, y = destination.y, z = destination.z },
        { x = destination.x, y = destination.y, z = destination.z + 1 },
        { x = destination.x + 1, y = destination.y, z = destination.z }
    }

    pf:try_targets(origin_spots)
    pf:face_target_block(origin)

    local slot, amount = find_item_slot(sides.front, task.item_name)
    if slot then ic.suckFromSlot(sides.front, slot, math.min(amount, task.amount)) end

    pf:try_targets(dest_spots)
    pf:face_target_block(destination)

    robot.drop(task.amount)

    pf:try_targets({ self.agent.home })
    print("✅ Courier done.")
end

return Courier
