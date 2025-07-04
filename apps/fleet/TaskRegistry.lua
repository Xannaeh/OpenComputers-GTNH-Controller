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
    if not loaded then
        print("[DEBUG] No tasks file found or empty. Returning empty list.")
        return { tasks = {} }
    end
    print("[DEBUG] Loaded tasks.json:")
    for k, v in pairs(loaded) do
        print("[DEBUG] key: " .. tostring(k) .. ", value type: " .. type(v))
    end
    return loaded
end

function TaskRegistry:list()
    local fresh = self:load()
    if #fresh.tasks == 0 then
        print("[DEBUG] No tasks to show.")
    end
    for _, task in ipairs(fresh.tasks) do
        print("[DEBUG] Inspecting task table:")
        for k, v in pairs(task) do
            print("[DEBUG] " .. tostring(k) .. " = " .. tostring(v))
        end
        if not task.deleted then
            print("📝 " .. task.id .. " — " .. task.description .. " [" .. task.jobType .. "]")
        else
            print("[DEBUG] Skipping deleted task: " .. task.id)
        end
    end
end

function TaskRegistry:add(task)
    local fresh = self:load()
    table.insert(fresh.tasks, task)
    DataHelper.saveJson(self.path, fresh)
    print("[DEBUG] Added task & saved.")
end

return TaskRegistry
