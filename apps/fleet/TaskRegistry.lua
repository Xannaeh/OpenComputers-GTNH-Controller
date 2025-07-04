local DataHelper = require("apps/DataHelper")

local TaskRegistry = {}
TaskRegistry.__index = TaskRegistry

function TaskRegistry.new()
    local self = setmetatable({}, TaskRegistry)
    self.path = "/data/tasks.json"
    return self
end

function TaskRegistry:load()
    local loaded = DataHelper.loadJson(self.path)
    return loaded or { tasks = {} }
end

function TaskRegistry:list()
    local fresh = self:load()
    for _, task in ipairs(fresh.tasks) do
        if not task.deleted then
            print("📝 " .. task.id .. " — " .. task.description .. " [" .. task.jobType .. "]")
        end
    end
end

function TaskRegistry:add(task)
    local fresh = self:load()
    table.insert(fresh.tasks, task)
    DataHelper.saveJson(self.path, fresh)
end

return TaskRegistry
