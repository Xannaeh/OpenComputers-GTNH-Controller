-- 🌸 fleet.lua — Fleet App glue, real tasks show

local term = require("term")
local gpu = require("component").gpu
local RobotRegistry = require("apps/fleet/RobotRegistry")
local TaskRegistry = require("apps/fleet/TaskRegistry")
local style = require("apps/Style")

local fleet = {
    registry = RobotRegistry.new(),
    tasks = TaskRegistry.new()
}

-- Add task keeps working for future, uses DataHelper JSON
function fleet:addTask(task)
    self.tasks:add(task)
end

function fleet:showTasks()
    self.tasks:list() -- this now does a real fresh file read
end

function fleet:menu()
    term.clear()
    gpu.setForeground(style.header)
    print("\n+------------ Fleet Manager -----------+")
    print("+-------------- OPTIONS ---------------+")

    gpu.setForeground(style.highlight) io.write("1. ")
    gpu.setForeground(style.text) print("Register Robot")

    gpu.setForeground(style.highlight) io.write("2. ")
    gpu.setForeground(style.text) print("Add Task")

    gpu.setForeground(style.highlight) io.write("3. ")
    gpu.setForeground(style.text) print("Assign Tasks")

    gpu.setForeground(style.highlight) io.write("4. ")
    gpu.setForeground(style.text) print("Show Robots")

    gpu.setForeground(style.highlight) io.write("5. ")
    gpu.setForeground(style.text) print("Show Tasks")

    gpu.setForeground(style.highlight) io.write("6. ")
    gpu.setForeground(style.text) print("Exit")

    gpu.setForeground(style.header)
    print("+--------------------------------------+")

    print()
    gpu.setForeground(style.highlight)
    io.write("Select option number: ")
    gpu.setForeground(style.text)
    local choice = io.read()

    if choice == "1" then
        gpu.setForeground(style.highlight) io.write("Robot ID: ")
        gpu.setForeground(style.text) local id = io.read()

        gpu.setForeground(style.highlight) io.write("Job Type: ")
        gpu.setForeground(style.text) local job = io.read()

        self.registry:register(id, job)

    elseif choice == "2" then
        gpu.setForeground(style.highlight) io.write("Task Desc: ")
        gpu.setForeground(style.text) local desc = io.read()

        gpu.setForeground(style.highlight) io.write("Job Type: ")
        gpu.setForeground(style.text) local job = io.read()

        local task = {
            id = "task_" .. math.random(1000),
            description = desc,
            jobType = job,
            priority = 1,
            parent = nil,
            subtasks = {},
            deleted = false
        }

        self:addTask(task)

    elseif choice == "3" then
        -- Placeholder, no real assign yet
        print("Task assigning not yet implemented.")
    elseif choice == "4" then
        self.registry:list()
        gpu.setForeground(style.highlight)
        io.write("\nPress Enter to return to the menu...")
        gpu.setForeground(style.text)
        io.read()
    elseif choice == "5" then
        gpu.setForeground(style.header)
        print("\n+-------------- Tasks -----------------+")
        gpu.setForeground(style.text)
        self:showTasks()
        gpu.setForeground(style.highlight)
        io.write("\nPress Enter to return...")
        gpu.setForeground(style.text)
        io.read()
    else
        gpu.setForeground(style.header)
        print("Goodbye, see you next mission! 🌙")
        gpu.setForeground(style.text)
        return
    end

    self:menu()
end

fleet:menu()
