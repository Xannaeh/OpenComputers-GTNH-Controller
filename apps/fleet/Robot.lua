-- 🌸 Robot.lua — Handles robot registry logic
local serialization = require("serialization")
local fs = require("filesystem")

local RobotRegistry = {}
RobotRegistry.__index = RobotRegistry

function RobotRegistry.new()
    local self = setmetatable({}, RobotRegistry)
    self.robots = {}
    self.file = "/data/robot_registry.dat"
    self:load()
    return self
end

function RobotRegistry:register(id, jobType)
    self.robots[id] = {
        id = id,
        jobType = jobType,
        status = "idle"
    }
    self:save()
    print("🤖 Registered robot: " .. id .. " as " .. jobType)
end

function RobotRegistry:updateStatus(id, status)
    if self.robots[id] then
        self.robots[id].status = status
        self:save()
    end
end

function RobotRegistry:save()
    local file = io.open(self.file, "w")
    file:write(serialization.serialize(self.robots))
    file:close()
end

function RobotRegistry:load()
    if fs.exists(self.file) then
        local file = io.open(self.file, "r")
        self.robots = serialization.unserialize(file:read("*a"))
        file:close()
    end
end

function RobotRegistry:list()
    for id, robot in pairs(self.robots) do
        print("🤖 " .. id .. " [" .. robot.jobType .. "] - " .. robot.status)
    end
end

return RobotRegistry
