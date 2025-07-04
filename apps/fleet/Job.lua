local Job = {}
Job.__index = Job

function Job.new(name)
    local self = setmetatable({}, Job)
    self.name = name
    self.status = "pending"
    return self
end

return Job
