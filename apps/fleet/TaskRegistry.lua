local DataHelper = require("apps/DataHelper")

local TaskRegistry = {}
TaskRegistry.__index = TaskRegistry

function TaskRegistry.new()
    return setmetatable({ path = "/data/tasks.lua" }, TaskRegistry)
end

function TaskRegistry:load()
    return DataHelper.loadTable(self.path) or { tasks = {} }
end

function TaskRegistry:save(tbl)
    DataHelper.saveTable(self.path, tbl)
end

function TaskRegistry:add(task)
    local d = self:load()
    table.insert(d.tasks, task)
    self:save(d)
end

function TaskRegistry:list()
    local d = self:load()
    for _, t in ipairs(d.tasks) do
        if not t.deleted then
            print(("📝 %s — %s [%s]"):format(t.id, t.description, t.jobType))
        end
    end
end

return TaskRegistry
