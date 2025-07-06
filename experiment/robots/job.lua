-- job.lua
-- Base Job interface class

local Job = {}

function Job:new()
    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Job:execute()
    error("Job:execute() must be implemented by subclass")
end

return Job
