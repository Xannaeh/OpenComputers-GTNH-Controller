local component = require("component")
local modem = component.modem
local computer = require("computer")

local agent = {}
agent.version = "1.0.0"

agent.tasks = {}

function agent:checkForUpdates()
    print("🔄 Checking for updates at recharge station...")
    -- Pull new code here if needed
end

function agent:syncTasks()
    print("🔗 Syncing tasks from base...")
    -- TODO: Fetch robot tasks from registry (e.g., via wireless)
    -- For now just log
end

function agent:listen()
    modem.open(123)
    print("📡 Listening for tasks...")
    while true do
        local _, _, from, port, _, message = computer.pullSignal("modem_message")
        print("💌 Got message: " .. message)
        -- Parse and handle task
    end
end

agent:checkForUpdates()
agent:syncTasks()
agent:listen()
