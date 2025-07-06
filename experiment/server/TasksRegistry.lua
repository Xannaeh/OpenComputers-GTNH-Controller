-- TasksRegistry.lua
-- Persistent registry for tasks

local fs = require("filesystem")
local serialization = require("serialization")

local TASKS_FILE = "/experiment/data/tasks.lua"

local TasksRegistry = {}

function TasksRegistry:new()
    local obj = {
        tasks = {}
    }
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
    table.insert(self.tasks, task)
    self:save()
end

function TasksRegistry:get_next()
    if #self.tasks > 0 then
        local task = table.remove(self.tasks, 1)
        self:save()
        return task
    else
        return nil
    end
end

function TasksRegistry:list()
    return self.tasks
end

return TasksRegistry
