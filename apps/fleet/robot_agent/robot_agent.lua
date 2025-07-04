local component = require("component")
local modem = component.modem
local computer = require("computer")
local serialization = require("serialization")
local event = require("event")

local agent = {}
agent.version = "2.0.0"

agent.tasks = {}

function agent:checkForUpdates()
    print("🔄 Checking for updates at recharge station...")
    os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/apps/fleet/robot_agent/robot_agent.lua -O /robot_agent.lua")
    os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/apps/fleet/jobs/courier_job.lua -O /jobs/courier_job.lua")
end

function agent:syncTasks()
    print("🔗 Syncing tasks from base...")
    -- Optional future: pull tasks from file or server
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
        job.run(params)
    else
        print("⚠️ Invalid job handler in " .. jobPath)
    end
end

function agent:start()
    modem.open(123)
    print("📡 Listening + processing queue...")
    while true do
        local name, _, from, port, _, message = event.pull(0.1)
        if name == "modem_message" then
            print("💌 Got message: " .. message)
            local ok, task = pcall(serialization.unserialize, message)
            if ok and task and task.jobType then
                table.insert(self.tasks, task)
                print("➕ Added to queue: " .. task.jobType)
            else
                print("⚠️ Bad task payload.")
            end
        end

        if #self.tasks > 0 then
            local task = table.remove(self.tasks, 1)
            print("🚚 Running task: " .. task.jobType)
            self:runJob(task.jobType, task.params)
        end
    end
end

agent:checkForUpdates()
agent:syncTasks()
agent:start()
