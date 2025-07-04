local component = require("component")
local serialization = require("serialization")

print("🌸 Dispatcher starting...")

-- Find the correct wireless modem
local modem = nil
for addr, _ in component.list("modem") do
    local m = component.proxy(addr)
    if m.isWireless and m.isWireless() then
        modem = m
        print("✅ Found Wireless Network Card: " .. addr)
        break
    else
        print("⚠️ Found a modem, but it’s not wireless: " .. addr)
    end
end

if not modem then
    print("❌ No Wireless Network Card found! Cannot dispatch tasks.")
    return
end

-- Test task payload
local task = {
    jobType = "courier",
    params = {
        fromSide = 3,
        toSide = 1,
        count = 1
    }
}

local message = serialization.serialize(task)

print("📡 Sending on port 123...")
print("📦 Payload: " .. message)

local ok = modem.broadcast(123, message)

if ok then
    print("✅ Broadcast sent successfully!")
else
    print("❌ Broadcast failed!")
end
