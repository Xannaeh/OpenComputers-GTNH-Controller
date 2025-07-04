local Robot = {}
Robot.__index = Robot

function Robot.new(name)
    local self = setmetatable({}, Robot)
    self.name = name
    self.job = nil
    return self
end

function Robot:assignJob(job)
    self.job = job
    print(self.name.." assigned to "..job.name)
end

return Robot
