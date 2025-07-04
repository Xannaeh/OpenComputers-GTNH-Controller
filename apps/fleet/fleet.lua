-- 🌸 fleet.lua — Fleet App Main Menu, Task Manager, Glue Code

local term = require("term")
local Job = require("apps/fleet/Job")
local RobotRegistry = require("apps/fleet/Robot")

local fleet = {
    registry = RobotRegistry.new(),
    tasks = {}
}

-- 🌸 Add task
function fleet:addTask(task)
    table.insert(self.tasks, task)
    print("📝 Added task: " .. task.description)
end

-- 🌸 Assign tasks to idle robots
function fleet:assignTasks()
    for _, task in ipairs(self.tasks) do
        for id, robot in pairs(self.registry.robots) do
            if robot.status == "idle" and robot.jobType == task.jobType then
                print("🔗 Assigned task to: " .. id)
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
end

-- 🌸 Cute Menu
function fleet:menu()
    term.clear()
    term.setCursor(1,1)
    print("🌸 Fleet Manager 🌸")
    print("1️⃣ Register Robot")
    print("2️⃣ Add Task")
    print("3️⃣ Assign Tasks")
    print("4️⃣ Show Robots")
    print("5️⃣ Exit")

    local choice = io.read()
    if choice == "1" then
        io.write("🤖 Robot ID: ")
        local id = io.read()
        io.write("🛠️ Job Type: ")
        local job = io.read()
        self.registry:register(id, job)
    elseif choice == "2" then
        io.write("📝 Task Desc: ")
        local desc = io.read()
        io.write("🔑 Job Type: ")
        local job = io.read()
        local t = Job.new("task_" .. math.random(1000), desc, job)
        self:addTask(t)
    elseif choice == "3" then
        self:assignTasks()
    elseif choice == "4" then
        self.registry:list()
    else
        print("💖 Bye bye~")
        return
    end

    os.sleep(1)
    self:menu()
end

fleet:menu()
