local Job = require("apps/fleet/Job")
local Robot = require("apps/fleet/Robot")

local function main()
    print("Fleet Manager Loaded")
    -- Example usage
    local robot = Robot.new("Robo1")
    local job = Job.new("Mine Iron")
    robot:assignJob(job)
end

return main
