local component = require("component")
local serialization = require("serialization")
local TaskRegistry = require("apps/fleet/TaskRegistry")
local DataHelper = require("apps/DataHelper")
local event = require("event")
local computer = require("computer")  -- ✅ ✅ FIX: you need this!

print("🌸 Dispatcher starting...")

-- ✅ Find wireless modem
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

modem.open(123)

while true do
    local registry = TaskRegistry.new()
    local tasksData = registry:load()
    local tasks = tasksData.tasks or {}

    -- Sort by priority
    table.sort(tasks, function(a, b) return a.priority < b.priority end)

    local dispatched = 0

    for _, task in ipairs(tasks) do
        if not task.deleted and task.assignedRobot and not task.sent then
            local payload = {
                id = task.id,
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
                dispatched = dispatched + 1
                task.sent = true
            else
                print("❌ Broadcast failed.")
            end

            if task.subtasks and #task.subtasks > 0 then
                print("🔗 Subtasks: " .. table.concat(task.subtasks, ","))
            end

            os.sleep(0.5)
        end
    end

    -- ✅ Save back updated tasks
    if dispatched > 0 then
        registry:save(tasksData)
    end

    -- ✅ Listen for ACKs for 5 seconds
    local startTime = computer.uptime()
    while computer.uptime() - startTime < 5 do
        local name, _, _, _, _, message = event.pull(0.5)
        if name == "modem_message" then
            local ok, msg = pcall(serialization.unserialize, message)
            if ok and msg and msg.event == "task_completed" then
                print("✅ Completion ACK from " .. msg.robotId .. " for " .. msg.taskId)
                for _, t in ipairs(tasks) do
                    if t.id == msg.taskId then
                        t.deleted = true
                        print("✅ Marked task " .. t.id .. " as completed.")
                        break
                    end
                end
                registry:save(tasksData)
            end
        end
    end

    if dispatched == 0 then
        print("⚠️ No tasks to dispatch! Sleeping...")
    else
        print("🌸 All tasks dispatched. Sleeping...")
    end

    os.sleep(5)
end
