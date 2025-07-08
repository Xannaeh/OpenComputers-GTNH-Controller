-- Robot network helper with clear debug logging

local component = require("component")
local event = require("event")
local serialization = require("serialization")

local Network = {}

Network.PORT = 1234

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
    self.modem.broadcast(self.PORT, "request_task")
    print("📡 Sent: request_task")

    local _, _, _, port, _, message = event.pull(5, "modem_message")
    if port == self.PORT and message then
        print("📡 Got reply: " .. tostring(message))
        if message == "no_task" then
            print("⚠️ No task available.")
            return nil
        else
            local task = serialization.unserialize(message)
            print("✅ Task received: " .. serialization.serialize(task))
            return task
        end
    else
        print("⏰ No response for task request.")
        return nil
    end
end

function Network:report_done(id)
    self.modem.broadcast(self.PORT, "task_done:" .. id)
    print("📡 Reported task done: " .. id)
end

function Network:send_update_map(map)
    local payload = serialization.serialize(map)
    self.modem.broadcast(self.PORT, "UPDATE_MAP:" .. payload)
    print("📡 Sent UPDATE_MAP payload: " .. payload:sub(1, 100) .. "...")
end

return Network
