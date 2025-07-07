-- agent.lua
-- Core RobotAgent class: controls robot main behavior loop and position

local Agent = {}

function Agent:new(network)
    local obj = {
        network = network,
        pos = { x = 32, y = 5, z = 0 },
        facing = "south",
        home = { x = 32, y = 5, z = 0 }  -- ✅ base world coords
    }
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
                local courier_job = Courier:new(self) -- pass Agent self
                courier_job:execute(task)
            end
            self.network:report_done(task.id or "unknown")
            os.sleep(3)
        else
            print("No tasks, waiting...")
            os.sleep(5)
        end
        os.sleep(5)
    end
end

return Agent
