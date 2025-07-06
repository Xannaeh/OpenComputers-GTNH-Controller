-- main.lua
-- Server main loop: listens for robots, dispatches tasks

package.path = package.path .. ";/experiment/server/?.lua"
local component = require("component")
local event = require("event")
local serialization = require("serialization")

local Dispatcher = require("dispatcher")

local modem = component.modem


-- Open port
local PORT = 1234
modem.open(PORT)

print("Server dispatcher running. Listening on port " .. PORT)

local dispatcher = Dispatcher:new()

-- Example: Add a task if none exist
if #dispatcher.tasks_registry:list() == 0 then
    dispatcher:add_task({
        type = "courier",
        item_name = "minecraft:iron_ingot",
        amount = 4
    })
end

while true do
    local _, _, from, port, _, message = event.pull("modem_message")

    if port == PORT then
        if message == "request_task" then
            local task = dispatcher:get_next_task()
            if task then
                modem.send(from, PORT, serialization.serialize(task))
                print("Sent task to " .. from)
            else
                modem.send(from, PORT, "no_task")
                print("No tasks left.")
            end
        end
    end
end
