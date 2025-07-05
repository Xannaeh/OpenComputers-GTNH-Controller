local TaskRegistry = require("apps/fleet/TaskRegistry")
local RobotRegistry = require("apps/fleet/RobotRegistry")

print("🔄 Auto Assigner started...")

local taskReg = TaskRegistry.new()
local robotReg = RobotRegistry.new()

while true do
    local tasks = taskReg:load().tasks
    local assigned = 0

    for _, t in ipairs(tasks) do
        if not t.deleted and not t.assignedRobot then
            local robot = robotReg:findBestRobot(t.jobType)
            if robot then
                robotReg:assignTask(robot.id, t.id)
                taskReg:assign(t.id, robot.id)
                print("🔗 Auto-assigned " .. t.id .. " ➜ " .. robot.id)
                assigned = assigned + 1
            end
        end
    end

    if assigned == 0 then
        print("💤 No tasks to assign. Sleeping...")
    end

    os.sleep(5)
end
