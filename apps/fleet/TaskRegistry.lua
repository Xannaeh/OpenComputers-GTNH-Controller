-- 🌸 TaskRegistry.lua — Minimal: Just load and list

local DataHelper = require("apps/DataHelper")

local TaskRegistry = {}
TaskRegistry.__index = TaskRegistry

function TaskRegistry.new()
    local self = setmetatable({}, TaskRegistry)
    self.path = "/data/tasks.json"
    return self
end

function TaskRegistry:load()
    -- Always fresh read
    local tasksFile = DataHelper.loadJson(self.path)
    return tasksFile or {tasks = {}}
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
