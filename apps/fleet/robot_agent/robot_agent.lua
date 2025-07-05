local component = require("component")
local modem = component.modem
local serialization = require("serialization")
local event = require("event")
local RobotRegistry = require("apps/fleet/RobotRegistry")

local agent = {}
agent.version = "4.1.1-debug"

-- ✅ Read ID
local file = io.open("/robot_id.txt", "r")
agent.id = file:read("*l")
file:close()
print("🤖 Robot ID: " .. agent.id)

-- ✅ Load registry
local reg = RobotRegistry.new()
local data = reg:load()

local info = nil
for _, robot in ipairs(data.robots) do
    if robot.id == agent.id then
        info = robot
        break
    end
end

if not info then
    print("❌ Robot ID not found in registry!")
    return
end

print(("📍 Registered at: (%d,%d,%d)"):format(info.x or 0, info.y or 0, info.z or 0))

agent.tasks = {}

-- Load any tasks from registry if present
if info.tasks and #info.tasks > 0 then
    print("🔍 Found " .. tostring(#info.tasks) .. " tasks in registry.")
    for _, t in ipairs(info.tasks) do
        print("📋 Registry task: " .. t)
        -- We only know the ID, so broadcast must re-provide full task!
    end
else
    print("📂 No tasks in registry at startup.")
end

function agent:checkForUpdates()
    print("🔄 Checking for updates...")
    os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/apps/fleet/robot_agent/robot_agent.lua -O /apps/fleet/robot_agent/robot_agent.lua")
    os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/apps/fleet/jobs/courier_job.lua -O /apps/fleet/jobs/courier_job.lua")
    os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/apps/fleet/Pathfinder.lua -O /apps/fleet/Pathfinder.lua")
end

function agent:runJob(jobType, params)
    print("⚙️ Loading job: " .. jobType)
    local jobPath = "/apps/fleet/jobs/" .. jobType .. "_job.lua"
    local ok, jobFile = pcall(loadfile, jobPath)
    if not ok or not jobFile then
        print("⚠️ Could not load job: " .. jobPath)
        return
    end
    local job = jobFile()
    if job.run then
        print("✅ Running job handler.")
        job.run(params, agent)
    else
        print("⚠️ Invalid job handler.")
    end
end

function agent:start()
    modem.open(123)
    print("📡 Listening for tasks...")

    while true do
        local name, _, _, _, _, message = event.pull(0.5)
        if name == "modem_message" then
            print("📡 Message received.")
            local ok, task = pcall(serialization.unserialize, message)
            if ok and task and task.assignedRobot == agent.id then
                print("➕ New task received: " .. task.jobType)
                table.insert(agent.tasks, task)
                print("📋 Task list size: " .. #agent.tasks)
            else
                print("⚠️ Message ignored or not for me.")
            end
        end

        if #agent.tasks > 0 then
            print("🕒 Tasks in queue: " .. #agent.tasks)
            table.sort(agent.tasks, function(a, b) return (a.priority or 1) < (b.priority or 1) end)
            local task = table.remove(agent.tasks, 1)
            print("🚚 Executing: " .. task.jobType)
            agent:runJob(task.jobType, task.params)
        else
            print("⏳ No tasks to run right now...")
        end
    end
end

print("📂 Robot Registry path: " .. reg.path)

agent:checkForUpdates()
agent:start()
