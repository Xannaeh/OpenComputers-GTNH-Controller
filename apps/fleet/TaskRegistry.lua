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

function TaskRegistry:save(data)
    DataHelper.saveJson(self.path, data)
end

function TaskRegistry:add(task)
    local data = self:load()
    table.insert(data.tasks, task)
    self:save(data)
end

function TaskRegistry:list()
    local data = self:load()

    print("[DEBUG] Loaded tasks.json root keys:")
    for key, value in pairs(data) do
        print(string.format("[DEBUG] root key: '%s' type: %s", key, type(value)))
    end

    if not data.tasks then
        print("[DEBUG] tasks field is nil!")
        return
    end

    print("[DEBUG] tasks field type: " .. type(data.tasks))
    print("[DEBUG] tasks count: " .. tostring(#data.tasks))

    for i, task in ipairs(data.tasks) do
        print(string.format("[DEBUG] Task #%d:", i))
        for k, v in pairs(task) do
            print(string.format("  %s = %s", k, tostring(v)))
        end

        if not task.deleted then
            print("📝 " .. task.id .. " — " .. task.description .. " [" .. task.jobType .. "]")
        end
    end
end

return TaskRegistry
