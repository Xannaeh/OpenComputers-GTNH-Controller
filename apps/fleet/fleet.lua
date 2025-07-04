-- 🌸 fleet.lua — Fleet App Main Menu, Task Manager, Glue Code

local term = require("term")
local gpu = require("component").gpu
local Job = require("apps/fleet/Job")
local RobotRegistry = require("apps/fleet/Robot")
local style = require("apps/Style")

local fleet = {
    registry = RobotRegistry.new(),
    tasks = {}
}

-- 🌸 Add task
function fleet:addTask(task)
    gpu.setForeground(style.highlight)
    print("[TASK] Added: " .. task.description)
    gpu.setForeground(style.text)
end

-- 🌸 Assign tasks to idle robots
function fleet:assignTasks()
    for _, task in ipairs(self.tasks) do
        for id, robot in pairs(self.registry.robots) do
            if robot.status == "idle" and robot.jobType == task.jobType then
                gpu.setForeground(style.highlight)
                print("[ASSIGN] Task assigned to: " .. id)
                robot.status = "busy"
                task.assigned = true
                self.registry:save()
                break
            end
        end
    end

    -- Remove assigned tasks
    local remaining = {}
    for _, t in ipairs(self.tasks) do
        if not t.assigned then
            table.insert(remaining, t)
        end
    end
    self.tasks = remaining
    gpu.setForeground(style.text)
end

-- 🌸 Cute Menu (styled)
-- 🌸 Cute Menu (styled like launcher)
function fleet:menu()
    term.clear()
    gpu.setForeground(style.header)
    print("\n+------------ Fleet Manager -----------+")

    gpu.setForeground(style.header)
    print("+-------------- OPTIONS ---------------+")

    -- Consistent number style like launcher
    gpu.setForeground(style.highlight)
    io.write("1. ")
    gpu.setForeground(style.text)
    print("Register Robot")

    gpu.setForeground(style.highlight)
    io.write("2. ")
    gpu.setForeground(style.text)
    print("Add Task")

    gpu.setForeground(style.highlight)
    io.write("3. ")
    gpu.setForeground(style.text)
    print("Assign Tasks")

    gpu.setForeground(style.highlight)
    io.write("4. ")
    gpu.setForeground(style.text)
    print("Show Robots")

    gpu.setForeground(style.highlight)
    io.write("5. ")
    gpu.setForeground(style.text)
    print("Exit")

    gpu.setForeground(style.header)
    print("+--------------------------------------+")

    print()
    gpu.setForeground(style.highlight)
    io.write("Select option number: ")
    gpu.setForeground(style.text)
    local choice = io.read()

    if choice == "1" then
        gpu.setForeground(style.highlight)
        io.write("Robot ID: ")
        gpu.setForeground(style.text)
        local id = io.read()

        gpu.setForeground(style.highlight)
        io.write("Job Type: ")
        gpu.setForeground(style.text)
        local job = io.read()

        self.registry:register(id, job)

    elseif choice == "2" then
        gpu.setForeground(style.highlight)
        io.write("Task Desc: ")
        gpu.setForeground(style.text)
        local desc = io.read()

        gpu.setForeground(style.highlight)
        io.write("Job Type: ")
        gpu.setForeground(style.text)
        local job = io.read()

        local t = Job.new("task_" .. math.random(1000), desc, job)
        self:addTask(t)

    elseif choice == "3" then
        self:assignTasks()

    elseif choice == "4" then
        self.registry:list()

    else
        gpu.setForeground(style.header)
        print("Goodbye, see you next mission! 🌙")
        gpu.setForeground(style.text)
        return
    end

    os.sleep(1)
    self:menu()
end


fleet:menu()
