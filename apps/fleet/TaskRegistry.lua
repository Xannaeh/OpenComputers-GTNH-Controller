local DataHelper = require("apps/DataHelper")

local TaskRegistry = {}
TaskRegistry.__index = TaskRegistry

function TaskRegistry.new()
    local self = setmetatable({}, TaskRegistry)
    self.path = "/data/tasks.json"
    return self
end

function TaskRegistry:load()
    print("[DEBUG] Loading JSON from:", self.path)
    local data = DataHelper.loadJson(self.path) or { tasks = {} }
    print("[DEBUG] Loaded root keys:")
    for k, v in pairs(data) do
        print(string.format("[DEBUG]   %s : %s", tostring(k), type(v)))
    end
    print("[DEBUG] tasks field type:", type(data.tasks))
    print("[DEBUG] tasks count:", #data.tasks)
    return data
end

function TaskRegistry:save(data)
    print("[DEBUG] Saving JSON to:", self.path)
    DataHelper.saveJson(self.path, data)
end

function TaskRegistry:add(task)
    print("[DEBUG] Adding new task:", task.id)
    local data = self:load()
    table.insert(data.tasks, task)
    self:save(data)
    print("[DEBUG] Task saved.")
end

function TaskRegistry:list()
    local data = self:load()
    print("[DEBUG] Listing tasks:")
    for i, task in ipairs(data.tasks) do
        print(string.format("[DEBUG] Task #%d", i))
        for k, v in pairs(task) do
            print(string.format("[DEBUG]   %s = %s", tostring(k), tostring(v)))
        end
        if not task.deleted then
            print("📝 " .. task.id .. " — " .. task.description .. " [" .. task.jobType .. "]")
        else
            print("[DEBUG] (skipped: marked deleted)")
        end
    end
end

return TaskRegistry
