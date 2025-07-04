local component = require("component")
local ic = component.inventory_controller
local robot = require("robot")
local InventoryRegistry = require("apps/fleet/InventoryRegistry")

local courier = {}

function courier.run(params)
    local registry = InventoryRegistry.new()

    local from = registry:find(params.fromName)
    local to = registry:find(params.toName)

    if not from or not to then
        print("❌ Source or destination inventory not found!")
        return
    end

    print("🚶 Moving to: " .. from.name)
    -- TODO: Real pathfinding — for now, just assume it’s straight line
    -- e.g. robot.forward() n times

    print("📦 Picking up...")
    ic.suckFromSlot(from.side, 1, params.count or 1)

    print("🚶 Moving to: " .. to.name)
    -- TODO: Real pathfinding again

    print("📦 Dropping...")
    ic.dropIntoSlot(to.side, 1, params.count or 1)

    print("✅ Delivery done!")
end

return courier
