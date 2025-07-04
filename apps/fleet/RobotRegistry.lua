local DataHelper = require("apps/DataHelper")

local RobotRegistry = {}
RobotRegistry.__index = RobotRegistry

function RobotRegistry.new()
    local self = setmetatable({}, RobotRegistry)
    self.path = "/data/robots.json"
    self.robots = self:load()
    return self
end

function RobotRegistry:load()
    return DataHelper.loadJson(self.path) or {robots = {}}
end

function RobotRegistry:save()
    DataHelper.saveJson(self.path, self.robots)
end

function RobotRegistry:register(id, jobType)
    table.insert(self.robots.robots, {
        id = id,
        jobType = jobType,
        status = "idle",
        active = true
    })
    self:save()
end

function RobotRegistry:dismantle(id)
    for _, robot in ipairs(self.robots.robots) do
        if robot.id == id then
            robot.active = false
            break
        end
    end
    self:save()
end

function RobotRegistry:list()
    self.robots = self:load() -- ✅ refresh first
    for _, robot in ipairs(self.robots.robots) do
        if robot.active then
            print("🤖 " .. robot.id .. " [" .. robot.jobType .. "] - " .. robot.status)
        end
    end
end


return RobotRegistry
