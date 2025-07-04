local component = require("component")
local modem = component.modem
local computer = require("computer")
local serialization = require("serialization")

local agent = {}
agent.version = "1.0.0"

agent.tasks = {}

function agent:checkForUpdates()
    print("🔄 Checking for updates at recharge station...")
    os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/apps/fleet/robot_agent/robot_agent.lua -O /robot_agent.lua")
    os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/apps/fleet/jobs/courier_job.lua -O /jobs/courier_job.lua")
end

function agent:syncTasks()
    print("🔗 Syncing tasks from base...")
    -- In future: request tasks from base server
end

function agent:runJob(jobType, params)
    local jobPath = "/jobs/" .. jobType .. "_job.lua"
    local ok, job = pcall(loadfile, jobPath)
    if not ok or not job then
        print("⚠️ Could not load job: " .. jobPath)
        return
    end
    local handler = job()
    if handler.run then
        handler.run(params)
    else
        print("⚠️ Invalid job handler in " .. jobPath)
    end
end

function agent:listen()
    modem.open(123)
    print("📡 Listening for tasks...")
    while true do
        local eventName, _, from, port, _, message = computer.pullSignal()
        if eventName == "modem_message" then
            print("💌 Got message: " .. message)
            local ok, task = pcall(serialization.unserialize, message)
            if ok and task and task.jobType then
                print("🔨 Running job: " .. task.jobType)
                self:runJob(task.jobType, task.params)
            else
                print("⚠️ Could not parse task payload")
            end
        end
    end
end

agent:checkForUpdates()
agent:syncTasks()
agent:listen()
