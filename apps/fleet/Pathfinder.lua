local robot = require("robot")
local component = require("component")
local registry = require("apps/fleet/RobotRegistry")

local Pathfinder = {}

function Pathfinder.moveTo(robotId, current, target)
    -- Basic A* stub: straight line
    local dx = target.x - current.x
    local dy = target.y - current.y
    local dz = target.z - current.z

    print("🧭 A* Moving... dx="..dx.." dz="..dz.." dy="..dy)

    -- X axis
    if dx ~= 0 then
        if dx > 0 then
            robot.turnRight()
        else
            robot.turnLeft()
        end
        for i = 1, math.abs(dx) do robot.forward() end
    end

    -- Z axis
    for i = 1, math.abs(dz) do robot.forward() end

    -- Y axis
    if dy > 0 then
        for i = 1, dy do robot.up() end
    elseif dy < 0 then
        for i = 1, -dy do robot.down() end
    end

    -- Update registry
    registry.new():updatePosition(robotId, target.x, target.y, target.z)
end

return Pathfinder
