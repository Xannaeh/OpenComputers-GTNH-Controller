-- agent.lua
-- Core RobotAgent class
-- Controls robot main behavior loop

local Agent = {}

function Agent:new(job)
    local obj = {
        job = job
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Agent:run()
    if self.job then
        self.job:execute()
    elseif self.network then
        local task = self.network:request_task()
        if task then
            -- Example: dynamic job load
            if task.type == "courier" then
                local Courier = require("jobs.courier")
                local courier_job = Courier:new()
                courier_job:execute(task)  -- Pass the task!
            end
        else
            print("No task received.")
        end
    else
        print("No job assigned, no network available.")
    end
end

return Agent
