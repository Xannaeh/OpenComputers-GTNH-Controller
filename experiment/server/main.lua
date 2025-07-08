-- Server main loop with debug logging

package.path = package.path .. ";/experiment/server/?.lua"

local component = require("component")
local event = require("event")
local serialization = require("serialization")
local computer = require("computer")

local modem = component.modem
local Dispatcher = require("dispatcher")

local PORT = 1234
modem.open(PORT)

print("🌐 Server dispatcher online. Port: " .. PORT)

local dispatcher = Dispatcher:new()

while true do
    local _, _, from, port, _, message = event.pull("modem_message")

    print(string.format("📡 Incoming: from=%s port=%s msg=%s", tostring(from), tostring(port), tostring(message)))

    if port == PORT then
        if message == "request_task" then
            local task = dispatcher:get_next_task()
            if task then
                local payload = serialization.serialize(task)
                modem.send(from, PORT, payload)
                print("✅ Sent task to: " .. tostring(from))
            else
                modem.send(from, PORT, "no_task")
                print("⚠️ No tasks left.")
            end

        elseif message:find("task_done:") == 1 then
            local id = message:sub(11)
            dispatcher:mark_done(id)
            print("✅ Marked done: " .. id)

        elseif message:find("UPDATE_MAP:") == 1 then
            local data = message:sub(12)
            print("📡 Raw UPDATE_MAP data: " .. data:sub(1, 100) .. "...")
            local ok, map = pcall(serialization.unserialize, data)
            if ok and map then
                local registry = require("registry")
                registry:merge_map(map)
                print("🗺️ Merged map update OK.")
            else
                print("❌ Failed to unserialize map update: " .. tostring(map))
            end
        end
    end
end
