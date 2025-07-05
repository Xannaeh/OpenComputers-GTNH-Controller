local DataHelper = require("apps/DataHelper")

local TaskRegistry = {}
TaskRegistry.__index = TaskRegistry

function TaskRegistry.new()
    return setmetatable({ path = "/data/tasks.lua" }, TaskRegistry)
end

function TaskRegistry:load()
    return DataHelper.loadTable(self.path) or { tasks = {} }
end

function TaskRegistry:save(tbl)
    DataHelper.saveTable(self.path, tbl)
end

function TaskRegistry:add(task)
    local d = self:load()
    table.insert(d.tasks, task)
    self:save(d)
end

function TaskRegistry:list()
    local d = self:load()
    for _, t in ipairs(d.tasks) do
        if not t.deleted then
            local assigned = t.assignedRobot or "-"
            print(("📝 %s – %s [%s] ➜ %s"):format(
                    t.id, t.description, t.jobType, assigned))
        end
    end
end

function TaskRegistry:assign(taskId, robotId)
    local d = self:load()
    for _, t in ipairs(d.tasks) do
        if t.id == taskId then
            t.assignedRobot = robotId
            t.sent = false  -- ✅ reset sent so dispatcher picks it up
            print("✅ Assigned " .. t.id .. " ➜ " .. robotId)
            break
        end
    end
    self:save(d)
end

function TaskRegistry:unassign(taskId)
    local d = self:load()
    for _, t in ipairs(d.tasks) do
        if t.id == taskId then
            t.assignedRobot = nil
            t.sent = false
            print("↩️ Unassigned " .. t.id)
            break
        end
    end
    self:save(d)
end

return TaskRegistry
