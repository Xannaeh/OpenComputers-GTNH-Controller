local DataHelper = require("apps/DataHelper")

local RobotRegistry = {}
RobotRegistry.__index = RobotRegistry

function RobotRegistry.new()
    return setmetatable({ path = "/data/robots.lua" }, RobotRegistry)
end

function RobotRegistry:load()
    local d = DataHelper.loadTable(self.path) or { robots = {} }
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
        tasks = {},
        x = 0,
        y = 64,
        z = 0
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

function RobotRegistry:find(id)
    local d = self:load()
    for _, r in ipairs(d.robots) do
        if r.id == id then return r end
    end
    return nil
end

function RobotRegistry:findBestRobot(jobType)
    local d = self:load()
    local best = nil
    for _, robot in ipairs(d.robots) do
        if robot.active and robot.status == "idle" and robot.jobType == jobType then
            if not best or #robot.tasks < #best.tasks then
                best = robot
            end
        end
    end
    return best
end

function RobotRegistry:assignTask(robotId, taskId)
    local d = self:load()
    for _, robot in ipairs(d.robots) do
        if robot.id == robotId then
            if not robot.tasks then
                robot.tasks = {}
            end
            table.insert(robot.tasks, taskId)
            break -- ❌ Don't force busy — robot does it when starting work!
        end
    end
    self:save(d)
end

function RobotRegistry:updateStatus(robotId, status)
    local d = self:load()
    for _, robot in ipairs(d.robots) do
        if robot.id == robotId then
            robot.status = status
            break
        end
    end
    self:save(d)
end

function RobotRegistry:updatePosition(robotId, x, y, z)
    local d = self:load()
    for _, robot in ipairs(d.robots) do
        if robot.id == robotId then
            robot.x = x
            robot.y = y
            robot.z = z
            break
        end
    end
    self:save(d)
end

function RobotRegistry:list()
    local d = self:load()
    for _, r in ipairs(d.robots) do
        if r.active then
            local tasks = r.tasks or {}
            local x = tonumber(r.x) or 0
            local y = tonumber(r.y) or 0
            local z = tonumber(r.z) or 0
            print(("🤖 %s [%s] – %s – Tasks: %d – Pos: (%d,%d,%d)"):format(
                    r.id, r.jobType, r.status, #tasks, x, y, z))
        end
    end
end

return RobotRegistry
