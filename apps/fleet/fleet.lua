local Job = loadfile("/apps/fleet/Job.lua")()
local Robot = loadfile("/apps/fleet/Robot.lua")()

local function main()
    print("Fleet Manager Loaded")
    -- Example usage
    local robot = Robot.new("Robo1")
    local job = Job.new("Mine Iron")
    robot:assignJob(job)
end

return main
