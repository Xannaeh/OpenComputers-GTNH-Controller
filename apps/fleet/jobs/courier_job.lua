local component = require("component")
local ic = component.inventory_controller
local InventoryRegistry = require("apps/fleet/InventoryRegistry")
local Pathfinder = require("apps/fleet/Pathfinder")

local courier = {}

function courier.run(params, agent)
    local invReg = InventoryRegistry.new()
    local from = invReg:find(params.fromName)
    local to = invReg:find(params.toName)

    local reg = require("apps/fleet/RobotRegistry").new()
    local robotData = reg:find(agent.id)

    if not from or not to then
        print("❌ Source or destination inventory not found!")
        return
    end


    print("🚶 Moving to: " .. from.name)
    Pathfinder.moveTo(agent.id, robotData, from)
    ic.suckFromSlot(from.side, 1, params.count or 1)


    print("📦 Picking up...")
    Pathfinder.moveTo(agent.id, robotData, to)

    print("📦 Dropping...")
    ic.dropIntoSlot(to.side, 1, params.count or 1)

    print("✅ Delivery done!")
end

return courier
