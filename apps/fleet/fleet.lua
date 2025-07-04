local term = require("term")
local gpu = require("component").gpu
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

function fleet:assignTasks()
    local tasks = self.tasks:load().tasks

    for _, t in ipairs(tasks) do
        if not t.deleted and not t.assignedRobot then
            local robot, robotData = self.registry:findBestRobot(t.jobType)
            if robot then
                -- Assign task to robot
                self.registry:assignTask(robot.id, t.id)
                self.tasks:assign(t.id, robot.id)
                print("🔗 Assigned " .. t.id .. " ➜ " .. robot.id)
            else
                print("⚠️ No available robot for job type: " .. t.jobType)
            end
        end
    end
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
    gpu.setForeground(style.text) print("Deactivate Robot")

    gpu.setForeground(style.highlight) io.write("7. ")
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
            deleted = false,
            assignedRobot = nil
        }

        self:addTask(task)

    elseif choice == "3" then
        self:assignTasks()
        gpu.setForeground(style.highlight)
        io.write("\nPress Enter to return to the menu...")
        gpu.setForeground(style.text)
        io.read()

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

    elseif choice == "6" then
        gpu.setForeground(style.highlight) io.write("Robot ID to deactivate: ")
        gpu.setForeground(style.text) local id = io.read()
        self.registry:deactivate(id)

    else
        gpu.setForeground(style.header)
        print("Goodbye, see you next mission! 🌙")
        gpu.setForeground(style.text)
        return
    end

    self:menu()
end

fleet:menu()
