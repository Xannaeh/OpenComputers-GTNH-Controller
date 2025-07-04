local component = require("component")
local serialization = require("serialization")
local DataHelper = require("apps/DataHelper")
local RobotRegistry = require("apps/fleet/RobotRegistry")
local TaskRegistry = require("apps/fleet/TaskRegistry")

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

local tasks = TaskRegistry.new():load().tasks
local robots = RobotRegistry.new():load().robots

local count = 0
for _, task in ipairs(tasks) do
    if not task.deleted and task.assignedRobot then
        local payload = {
            jobType = task.jobType,
            params = task.params,
            assignedRobot = task.assignedRobot
        }

        local message = serialization.serialize(payload)

        print("📡 Dispatching task: " .. task.id .. " ➜ " .. task.assignedRobot)
        print("📦 Payload: " .. message)

        local ok = modem.broadcast(123, message)

        if ok then
            print("✅ Broadcast sent.")
            count = count + 1
        else
            print("❌ Broadcast failed.")
        end

        os.sleep(0.5)
    end
end

if count == 0 then
    print("⚠️ No tasks to dispatch! Did you assign any?")
else
    print("🌸 All tasks dispatched!")
end
