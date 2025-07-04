local component = require("component")
local serialization = require("serialization")

print("🌸 Dispatcher starting...")

-- Find wireless modem only
local modem = nil
for addr, _ in component.list("modem") do
    local m = component.proxy(addr)
    if m.isWireless and m.isWireless() then
        modem = m
        print("✅ Found Wireless Network Card: " .. addr)
        break
    else
        print("⚠️ Found modem but not wireless: " .. addr)
    end
end

if not modem then
    print("❌ No Wireless Network Card found! Cannot dispatch tasks.")
    return
end

-- Send multiple tasks!
for i = 1, 3 do
    local task = {
        jobType = "courier",
        params = {
            fromSide = 3,
            toSide = 1,
            count = i
        }
    }

    local message = serialization.serialize(task)

    print("📡 Sending task #" .. i .. " on port 123...")
    print("📦 Payload: " .. message)

    local ok = modem.broadcast(123, message)

    if ok then
        print("✅ Broadcast #" .. i .. " sent.")
    else
        print("❌ Broadcast #" .. i .. " failed.")
    end

    os.sleep(0.5) -- short delay
end

print("🌸 All test tasks dispatched!")
