-- 🌸 courier_job.lua — Moves items A ➜ B

local component = require("component")
local ic = component.inventory_controller

local courier = {}

function courier.run(params)
    print("📦 Picking up from side " .. params.fromSide)
    ic.suckFromSlot(params.fromSide, params.fromSlot or 1, params.count or 1)
    print("📦 Delivering to side " .. params.toSide)
    ic.dropIntoSlot(params.toSide, params.toSlot or 1, params.count or 1)
    print("✅ Delivery done!")
end

return courier
