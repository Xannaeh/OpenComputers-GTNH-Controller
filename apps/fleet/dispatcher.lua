local component = require("component")
local serialization = require("serialization")
local TaskRegistry = require("apps/fleet/TaskRegistry")

print("🌸 Dispatcher starting...")

local modem = nil
for addr, _ in component.list("modem") do
    local m = component.proxy(addr)
    if m.isWireless and m.isWireless() then
        modem = m
        print("✅ Found Wireless Network Card: " .. addr)
        break
    end
end

if not modem then
    print("❌ No Wireless Network Card found! Cannot dispatch tasks.")
    return
end

local tasks = TaskRegistry.new():load().tasks

-- Sort by priority (lower = higher)
table.sort(tasks, function(a, b) return a.priority < b.priority end)

local count = 0
for _, task in ipairs(tasks) do
    if not task.deleted and task.assignedRobot then
        local payload = {
            jobType = task.jobType,
            params = task.params,
            assignedRobot = task.assignedRobot
        }

        local message = serialization.serialize(payload)

        print("📡 Dispatching: " .. task.id .. " ➜ " .. task.assignedRobot)
        print("📦 Payload: " .. message)

        local ok = modem.broadcast(123, message)
        if ok then
            print("✅ Broadcast sent.")
            count = count + 1
        else
            print("❌ Broadcast failed.")
        end

        -- Handle subtasks immediately if any
        if task.subtasks and #task.subtasks > 0 then
            print("🔗 Subtasks: " .. table.concat(task.subtasks, ","))
        end

        os.sleep(0.5)
    end
end

if count == 0 then
    print("⚠️ No tasks to dispatch! Did you assign any?")
else
    print("🌸 All tasks dispatched.")
end
