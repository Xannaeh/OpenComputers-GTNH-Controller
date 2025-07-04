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
    return DataHelper.loadJson(self.path) or {tasks = {}}
end

function TaskRegistry:save()
    DataHelper.saveJson(self.path, self.tasks)
end

function TaskRegistry:add(task)
    table.insert(self.tasks.tasks, task)
    self:save()
end

function TaskRegistry:list()
    self.tasks = self:load()
    for _, task in ipairs(self.tasks.tasks) do
        print("📝 " .. task.id .. " — " .. task.description .. " [" .. task.jobType .. "]")
    end
end

return TaskRegistry
