local DataHelper = require("apps/DataHelper")

local RobotRegistry = {}
RobotRegistry.__index = RobotRegistry

function RobotRegistry.new()
    return setmetatable({ path = "/data/robots.lua" }, RobotRegistry)
end

function RobotRegistry:load()
    return DataHelper.loadTable(self.path) or { robots = {} }
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
            print(("🤖 %s [%s] – %s – Tasks: %d"):format(r.id, r.jobType, r.status, #r.tasks))
        end
    end
end

-- Find the robot with the fewest tasks for given jobType
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
