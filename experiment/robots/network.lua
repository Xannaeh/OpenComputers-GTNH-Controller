-- network.lua
-- Robot network helper for talking to the server dispatcher

local component = require("component")
local event = require("event")
local serialization = require("serialization")

local Network = {}

Network.PORT = 1234  -- Match server port

function Network:new()
    local obj = {}
    setmetatable(obj, self)
    self.__index = self

    obj.modem = component.modem
    obj.modem.open(self.PORT)

    print("📡 Modem opened on port " .. self.PORT)

    return obj
end

function Network:request_task()
    -- Broadcast a task request
    self.modem.broadcast(self.PORT, "request_task")
    print("📡 Sent task request.")

    -- Wait for response
    local _, _, from, port, _, message = event.pull(5, "modem_message")
    if port == self.PORT and message then
        if message == "no_task" then
            print("⚠️ No task available.")
            return nil
        else
            local task = serialization.unserialize(message)
            print("✅ Task received.")
            return task
        end
    else
        print("⏰ No response.")
        return nil
    end
end

return Network
