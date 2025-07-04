-- 🌸 fleet.lua — Fleet App Main Menu, Task Manager, Glue Code

local term = require("term")
local gpu = require("component").gpu
local Job = require("apps/fleet/Job")
local RobotRegistry = require("apps/fleet/RobotRegistry")
local TaskRegistry = require("apps/fleet/TaskRegistry")
local style = require("apps/Style")

local fleet = {
    registry = RobotRegistry.new(),
    tasks = TaskRegistry.new()
}

function fleet:addTask(task)
    self.tasks:add(task)
end

function fleet:showTasks()
    self.tasks:list()
end

-- 🌸 Assign tasks to idle robots
function fleet:assignTasks()
    local tasksList = self.tasks:load().tasks
    local robotsList = self.registry:load().robots

    for _, task in ipairs(tasksList) do
        for _, robot in ipairs(robotsList) do
            if robot.active and robot.status == "idle" and robot.jobType == task.jobType then
                gpu.setForeground(style.highlight)
                print("[ASSIGN] Task assigned to: " .. robot.id)
                robot.status = "busy"
                task.assigned = true
                self.registry:save()
                break
            end
        end
    end

    -- Save only unassigned tasks
    local remaining = {}
    for _, t in ipairs(tasksList) do
        if not t.assigned then
            table.insert(remaining, t)
        end
    end
    self.tasks.tasks.tasks = remaining
    self.tasks:save()
    gpu.setForeground(style.text)
end

function fleet:menu()
    term.clear()
    gpu.setForeground(style.header)
    print("\n+------------ Fleet Manager -----------+")

    gpu.setForeground(style.header)
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

        local t = Job.new("task_" .. math.random(1000), desc, job)
        self:addTask(t)

    elseif choice == "3" then
        self:assignTasks()

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
        io.write("\nPress Enter to return to the menu...")
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
