-- pathfinder.lua
-- Converts world coordinates to relative moves; updates Agent pos directly

local robot = require("robot")

local Pathfinder = {}
Pathfinder.__index = Pathfinder

function Pathfinder:new(agent)
    local obj = {
        agent = agent  -- 🔗 reference to Agent (pos + facing)
    }
    setmetatable(obj, self)
    return obj
end

-- Turns the robot to face a desired cardinal direction
function Pathfinder:turn_to(direction)
    local left_turns = { north = "west", west = "south", south = "east", east = "north" }
    while self.agent.facing ~= direction do
        robot.turnLeft()
        self.agent.facing = left_turns[self.agent.facing]
    end
end

function Pathfinder:go_to(target)
    if not target then
        error("Pathfinder:go_to() called with nil target")
    end

    print("🔍 go_to called with:", target.x, target.z)
    print("🔍 current pos:", self.agent.pos.x, self.agent.pos.z)

    local dx = target.x - self.agent.pos.x
    local dz = target.z - self.agent.pos.z

    if dx ~= 0 then
        if dx > 0 then self:turn_to("east") else self:turn_to("west") end
        for i = 1, math.abs(dx) do robot.forward() end
    end
    self.agent.pos.x = target.x

    if dz ~= 0 then
        if dz > 0 then self:turn_to("south") else self:turn_to("north") end
        for i = 1, math.abs(dz) do robot.forward() end
    end
    self.agent.pos.z = target.z

    -- TODO: handle Y later
end

return Pathfinder
