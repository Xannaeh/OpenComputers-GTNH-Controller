local DataHelper = require("apps/DataHelper")

local TaskRegistry = {}
TaskRegistry.__index = TaskRegistry

function TaskRegistry.new()
    local self = setmetatable({}, TaskRegistry)
    self.path = "/data/tasks.json"
    return self
end

function TaskRegistry:load()
    return DataHelper.loadJson(self.path) or { tasks = {} }
end

function TaskRegistry:save(tasks)
    DataHelper.saveJson(self.path, tasks)
end

function TaskRegistry:add(task)
    local data = self:load()
    table.insert(data.tasks, task)
    self:save(data)
end

function TaskRegistry:list()
    local data = self:load()
    print("[DEBUG] Loaded tasks.json:")
    for key, value in pairs(data) do
        print("[DEBUG] key:", key, ", value type:", type(value))
    end

    for _, task in ipairs(data.tasks) do
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
