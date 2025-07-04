local DataHelper = require("apps/DataHelper")

local TaskRegistry = {}
TaskRegistry.__index = TaskRegistry

function TaskRegistry.new()
    local self = setmetatable({}, TaskRegistry)
    self.path = "/data/tasks.json"
    return self
end

function TaskRegistry:load()
    return DataHelper.loadJson(self.path) or {tasks = {}}
end

function TaskRegistry:list()
    local data = self:load()
    for _, task in ipairs(data.tasks) do
        if not task.deleted then
            print("📝 " .. task.id .. " — " .. task.description .. " [" .. task.jobType .. "]")
        end
    end
end

function TaskRegistry:add(task)
    local data = self:load()
    table.insert(data.tasks, task)
    DataHelper.saveJson(self.path, data)
end

return TaskRegistry
