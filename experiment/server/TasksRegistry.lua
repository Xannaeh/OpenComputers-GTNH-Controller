-- TasksRegistry.lua
-- Persistent registry for tasks with status tracking

local fs = require("filesystem")
local serialization = require("serialization")
local computer = require("computer")

local TASKS_FILE = "/experiment/data/tasks.lua"

local TasksRegistry = {}

function TasksRegistry:new()
    local obj = { tasks = {} }
    setmetatable(obj, self)
    self.__index = self
    obj:load()
    return obj
end

function TasksRegistry:load()
    if fs.exists(TASKS_FILE) then
        local file = io.open(TASKS_FILE, "r")
        local data = file:read("*a")
        file:close()
        local ok, parsed = pcall(load("return " .. data))
        if ok and parsed then
            self.tasks = parsed()
        else
            self.tasks = {}
        end
    else
        self.tasks = {}
    end
end

function TasksRegistry:save()
    local file = io.open(TASKS_FILE, "w")
    file:write("return " .. serialization.serialize(self.tasks))
    file:close()
end

function TasksRegistry:add(task)
    -- Auto-assign ID if missing
    if not task.id then
        task.id = tostring(math.floor(computer.uptime() * 1000))
    end
    task.status = "pending"
    table.insert(self.tasks, task)
    self:save()
end

function TasksRegistry:get_next()
    for _, task in ipairs(self.tasks) do
        if task.status == "pending" then
            task.status = "in_progress"
            self:save()
            return task
        end
    end
    return nil
end

function TasksRegistry:mark_done(id)
    for _, task in ipairs(self.tasks) do
        if tostring(task.id) == tostring(id) then
            print("Marking task " .. id .. " as done...")
            task.status = "done"
            self:save()
            print("✅ Saved tasks after marking done.")
            return true
        end
    end
    print("⚠️ Task " .. id .. " not found to mark done.")
    return false
end

function TasksRegistry:list()
    return self.tasks
end

return TasksRegistry
