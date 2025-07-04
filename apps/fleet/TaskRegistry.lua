local DataHelper = require("apps/DataHelper")

local TaskRegistry = {}
TaskRegistry.__index = TaskRegistry

function TaskRegistry.new()
    local self = setmetatable({}, TaskRegistry)
    self.path = "/data/tasks.json"
    self.tasks = self:load()
    return self
end

function TaskRegistry:load()
    self.tasks = DataHelper.loadJson(self.path) or {tasks = {}}
    return self.tasks
end

function TaskRegistry:save()
    DataHelper.saveJson(self.path, self.tasks)
end

function TaskRegistry:add(task)
    table.insert(self.tasks.tasks, task)
    self:save()
end

function TaskRegistry:list()
    local tasksData = self:load()
    for _, task in ipairs(tasksData.tasks) do
        if not task.deleted then
            print("📝 " .. task.id .. " — " .. task.description .. " [" .. task.jobType .. "]")
        end
    end
end

return TaskRegistry
