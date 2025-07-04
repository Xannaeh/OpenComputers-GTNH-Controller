local component = require("component")
local ic = component.inventory_controller
local robot = require("robot")

local courier = {}

function courier.run(params)
    print("🚶 Moving to pickup...")

    -- Example: move forward 3 blocks
    for i = 1, (params.pickupDistance or 1) do
        robot.forward()
    end

    print("📦 Picking up from side " .. params.fromSide)
    ic.suckFromSlot(params.fromSide, params.fromSlot or 1, params.count or 1)

    print("🔄 Turning around...")
    robot.turnAround()

    print("🚶 Moving to drop...")
    for i = 1, (params.dropDistance or 1) do
        robot.forward()
    end

    print("📦 Delivering to side " .. params.toSide)
    ic.dropIntoSlot(params.toSide, params.toSlot or 1, params.count or 1)

    print("✅ Delivery done!")

    -- Return to original position if needed
    robot.turnAround()
    for i = 1, (params.dropDistance or 1) do
        robot.forward()
    end
    robot.turnAround()
end

return courier
