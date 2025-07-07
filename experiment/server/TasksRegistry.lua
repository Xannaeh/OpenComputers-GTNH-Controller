-- TasksRegistry.lua
-- Single source of truth: tasks.lua is live + persistent

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
    print("🔍 TasksRegistry:load() starting...")
    if fs.exists(TASKS_FILE) then
        local file = io.open(TASKS_FILE, "r")
        local data = file:read("*a")
        file:close()
        print("📂 Found tasks.lua at:", TASKS_FILE)
        print("📄 Raw file content:\n" .. data)

        local ok, chunk = pcall(load(data))
        if ok and chunk then
            local ok2, parsed = pcall(chunk)
            if ok2 then
                self.tasks = parsed
                print("✅ Parsed OK. Tasks loaded: " .. tostring(#self.tasks))
            else
                print("❌ Chunk run failed: " .. tostring(parsed))
                self.tasks = {}
            end
        else
            print("❌ Load() failed: " .. tostring(chunk))
            self.tasks = {}
        end
    else
        print("⚠️ tasks.lua does not exist, starting with empty list.")
        self.tasks = {}
    end
end



function TasksRegistry:save()
    local file = io.open(TASKS_FILE, "w")
    file:write("return " .. serialization.serialize(self.tasks))
    file:close()
end

function TasksRegistry:add(task)
    if not task.id then
        task.id = tostring(math.floor(computer.uptime() * 1000))
    end
    task.status = "pending"
    table.insert(self.tasks, task)
    self:save()
    print("✅ Added task " .. task.id)
end

function TasksRegistry:get_next()
    for _, task in ipairs(self.tasks) do
        if task.status == "pending" then
            task.status = "in_progress"
            self:save()
            print("➡️ Dispatching task: " .. serialization.serialize(task))
            return task
        end
    end
    print("🟢 No pending tasks to dispatch.")
    return nil
end


function TasksRegistry:mark_done(id)
    for _, task in ipairs(self.tasks) do
        if tostring(task.id) == tostring(id) then
            task.status = "done"
            self:save()
            print("✅ Marked task " .. id .. " as done")
            return true
        end
    end
    print("⚠️ Could not find task " .. id)
    return false
end

function TasksRegistry:list()
    return self.tasks
end

return TasksRegistry
