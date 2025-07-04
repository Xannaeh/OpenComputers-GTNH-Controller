local component = require("component")
local modem = component.modem
local serialization = require("serialization")
local event = require("event")
local computer = require("computer")
local RobotRegistry = require("apps/fleet/RobotRegistry")
local Pathfinder = require("apps/fleet/Pathfinder")

local agent = {}
agent.version = "3.0.0"

-- Load robot ID
local file = io.open("/robot_id.txt", "r")
agent.id = file:read("*l")
file:close()

agent.tasks = {}

function agent:checkForUpdates()
    print("🔄 Checking for updates...")
    os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/apps/fleet/robot_agent/robot_agent.lua -O /robot_agent.lua")
    os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/apps/fleet/jobs/courier_job.lua -O /jobs/courier_job.lua")
    os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/apps/fleet/Pathfinder.lua -O /apps/fleet/Pathfinder.lua")
end

function agent:syncTasks()
    -- Later: real sync with server
end

function agent:runJob(jobType, params)
    local jobPath = "/jobs/" .. jobType .. "_job.lua"
    local ok, jobFile = pcall(loadfile, jobPath)
    if not ok or not jobFile then
        print("⚠️ Could not load job: " .. jobPath)
        return
    end
    local job = jobFile()
    if job.run then
        job.run(params, agent)
    else
        print("⚠️ Invalid job handler.")
    end
end

function agent:start()
    modem.open(123)
    print("📡 Listening + queue processor: " .. agent.id)
    while true do
        local name, _, _, _, _, message = event.pull(0.1)
        if name == "modem_message" then
            local ok, task = pcall(serialization.unserialize, message)
            if ok and task and task.assignedRobot == agent.id then
                table.insert(agent.tasks, task)
                print("➕ Task accepted: " .. task.jobType)
            end
        end

        if #agent.tasks > 0 then
            local task = table.remove(agent.tasks, 1)
            print("🚚 Running: " .. task.jobType)
            agent:runJob(task.jobType, task.params)
        end
    end
end

agent:checkForUpdates()
agent:syncTasks()
agent:start()
