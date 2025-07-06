-- dispatcher.lua
-- Dispatcher pulls tasks from TasksRegistry

package.path = package.path .. ";/experiment/server/?.lua"

local TasksRegistry = require("TasksRegistry")

local Dispatcher = {}

function Dispatcher:new()
    local obj = {}
    setmetatable(obj, self)
    self.__index = self

    obj.tasks_registry = TasksRegistry:new()
    return obj
end

function Dispatcher:add_task(task)
    self.tasks_registry:add(task)
end

function Dispatcher:get_next_task()
    return self.tasks_registry:get_next()
end

function Dispatcher:mark_done(id)
    return self.tasks_registry:mark_done(id)
end

return Dispatcher
