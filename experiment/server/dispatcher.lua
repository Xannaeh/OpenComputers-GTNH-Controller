-- dispatcher.lua
-- Task Dispatcher: keeps task queue, assigns tasks to robots

local Dispatcher = {}

function Dispatcher:new()
    local obj = {
        tasks = {}
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Dispatcher:add_task(task)
    table.insert(self.tasks, task)
end

function Dispatcher:get_next_task()
    if #self.tasks > 0 then
        return table.remove(self.tasks, 1)
    else
        return nil
    end
end

return Dispatcher
