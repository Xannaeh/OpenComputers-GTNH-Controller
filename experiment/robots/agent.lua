-- agent.lua
-- Core RobotAgent class
-- Controls robot main behavior loop

local Agent = {}

function Agent:new(network)
    local obj = { network = network }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Agent:run()
    while true do
        local task = self.network:request_task()
        if task then
            -- Example: dynamic job load
            if task.type == "courier" then
                local Courier = require("jobs.courier")
                local courier_job = Courier:new()
                courier_job:execute(task)
            end

            self.network:report_done(task.id or "unknown")
        else
            print("No tasks, waiting...")
        end
        os.sleep(5) -- ✅ Always sleep 5s before next loop
    end
end


return Agent
