local DataHelper = require("apps/DataHelper")

local RobotRegistry = {}
RobotRegistry.__index = RobotRegistry

function RobotRegistry.new()
    return setmetatable({ path = "/data/robots.lua" }, RobotRegistry)
end

function RobotRegistry:load()
    local d = DataHelper.loadTable(self.path) or { robots = {} }
    -- 🛡️ Safe patch: add tasks field to old robots
    for _, robot in ipairs(d.robots) do
        if not robot.tasks then robot.tasks = {} end
    end
    return d
end

function RobotRegistry:save(tbl)
    DataHelper.saveTable(self.path, tbl)
end

function RobotRegistry:register(id, jobType)
    local d = self:load()
    table.insert(d.robots, {
        id = id,
        jobType = jobType,
        status = "idle",
        active = true,
        tasks = {}
    })
    self:save(d)
end

function RobotRegistry:deactivate(id)
    local d = self:load()
    for _, robot in ipairs(d.robots) do
        if robot.id == id then
            robot.active = false
            break
        end
    end
    self:save(d)
end

function RobotRegistry:list()
    local d = self:load()
    for _, r in ipairs(d.robots) do
        if r.active then
            local taskCount = r.tasks and #r.tasks or 0
            print(("🤖 %s [%s] – %s – Tasks: %d"):format(r.id, r.jobType, r.status, taskCount))
        end
    end
end

function RobotRegistry:findBestRobot(jobType)
    local d = self:load()
    local best = nil
    for _, robot in ipairs(d.robots) do
        if robot.active and robot.status ~= "offline" and robot.jobType == jobType then
            if not best or #robot.tasks < #best.tasks then
                best = robot
            end
        end
    end
    return best, d
end

function RobotRegistry:assignTask(robotId, taskId)
    local d = self:load()
    for _, robot in ipairs(d.robots) do
        if robot.id == robotId then
            table.insert(robot.tasks, taskId)
            robot.status = "busy"
            break
        end
    end
    self:save(d)
end

return RobotRegistry
