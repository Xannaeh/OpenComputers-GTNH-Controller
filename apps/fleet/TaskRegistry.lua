local DataHelper = require("apps/DataHelper")

local TaskRegistry = {}
TaskRegistry.__index = TaskRegistry

function TaskRegistry.new()
    local self = setmetatable({}, TaskRegistry)
    self.path = "/data/tasks.json"
    self.tasks = self:load() -- keep the whole {"tasks": []} table
    return self
end

function TaskRegistry:load()
    return DataHelper.loadJson(self.path) or { tasks = {} }
end

function TaskRegistry:save()
    DataHelper.saveJson(self.path, self.tasks)
end

function TaskRegistry:add(task)
    table.insert(self.tasks.tasks, task)
    self:save()
end

function TaskRegistry:list()
    print("[DEBUG] Loaded tasks.json:")
    for key, value in pairs(self.tasks) do
        print("[DEBUG] key:", key, ", value type:", type(value))
    end

    for _, task in ipairs(self.tasks.tasks) do
        print("[DEBUG] Inspecting task table:")
        for k, v in pairs(task) do
            print("[DEBUG] " .. k .. " = " .. tostring(v))
        end

        if not task.deleted then
            print("📝 " .. task.id .. " — " .. task.description .. " [" .. task.jobType .. "]")
        end
    end
end

return TaskRegistry
