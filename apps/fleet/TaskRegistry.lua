local DataHelper = require("apps/DataHelper")

local TaskRegistry = {}
TaskRegistry.__index = TaskRegistry

function TaskRegistry.new()
    local self = setmetatable({}, TaskRegistry)
    self.path = "/data/tasks.json"
    return self
end

-- fresh read every call
function TaskRegistry:load()
    return DataHelper.loadJson(self.path) or {tasks = {}}
end

function TaskRegistry:list()
    local data = self:load()

    print("[DEBUG] tasks table raw keys:")
    for k, v in pairs(data.tasks) do
        print(string.format("  key=%s (%s)", tostring(k), type(k)))
    end

    local shown = 0
    for _, task in pairs(data.tasks) do      -- ←  pairs not ipairs
        if type(task) == "table" and not task.deleted then
            shown = shown + 1
            print("📝 " .. task.id .. " — " .. task.description .. " [" .. task.jobType .. "]")
        end
    end

    if shown == 0 then
        print("(no active tasks)")
    end
end

-- leave add/ save exactly as before, if you still need them
return TaskRegistry
