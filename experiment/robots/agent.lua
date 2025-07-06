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
    else
        print("No job assigned.")
    end
end

return Agent
