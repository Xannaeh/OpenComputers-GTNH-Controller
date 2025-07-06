-- main.lua
-- Server main loop: listens for robots, dispatches tasks

package.path = package.path .. ";/experiment/server/?.lua"

local component = require("component")
local event = require("event")
local serialization = require("serialization")

local modem = component.modem
local Dispatcher = require("dispatcher")

-- Open port
local PORT = 1234
modem.open(PORT)

print("Server dispatcher running. Listening on port " .. PORT)

local dispatcher = Dispatcher:new()

-- Add some test tasks
dispatcher:add_task({
    type = "courier",
    origin = { x = 0, y = 64, z = 0 },
    target = { x = 5, y = 64, z = 0 },
    item_name = "minecraft:iron_ingot",
    amount = 4
})

while true do
    local _, _, from, port, _, message = event.pull("modem_message")

    if port == PORT then
        if message == "request_task" then
            local task = dispatcher:get_next_task()
            if task then
                local data = serialization.serialize(task)
                modem.send(from, PORT, data)
                print("Sent task to " .. from)
            else
                modem.send(from, PORT, "no_task")
                print("No task to send.")
            end
        end
    end
end
