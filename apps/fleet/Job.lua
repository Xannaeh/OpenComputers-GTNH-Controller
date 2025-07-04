-- 🌸 Job.lua — Defines Job class + simple Task structure
local Job = {}
Job.__index = Job

function Job.new(id, description, jobType, priority)
    local self = setmetatable({}, Job)
    self.id = id or ""
    self.description = description or ""
    self.jobType = jobType or ""
    self.priority = priority or 1
    self.assigned = false
    return self
end

return Job
