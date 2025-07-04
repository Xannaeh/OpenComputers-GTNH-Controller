-- 🌸 robot_agent.lua — Runs on each robot/drone
local component = require("component")
local modem = component.modem
local computer = require("computer")

local agent = {}
agent.version = "1.0.0"

function agent:checkForUpdates()
    print("🔄 Checking for updates at recharge station...")
    -- Here you'd pull latest agent code & jobs from GitHub
    -- This is a stub for now
end

function agent:listen()
    modem.open(123)
    print("📡 Listening for tasks...")
    while true do
        local _, _, from, port, _, message = computer.pullSignal("modem_message")
        print("💌 Got message: " .. message)
        -- Run job logic here
    end
end

agent:checkForUpdates()
agent:listen()
