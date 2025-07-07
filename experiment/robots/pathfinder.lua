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

function Pathfinder:go_to(target, stop_before)
    if not target then
        error("Pathfinder:go_to() called with nil target")
    end

    print("\n🔍 [Pathfinder] --- GO_TO DEBUG ---")
    print("TARGET:  x="..target.x.." z="..target.z)
    print("AGENT POS:  x="..self.agent.pos.x.." z="..self.agent.pos.z)
    print("-------------------------------")

    local dx = target.x - self.agent.pos.x
    local dz = target.z - self.agent.pos.z

    -- Only stop short if told to
    if stop_before then
        if dx ~= 0 then
            if dx > 0 then dx = dx - 1 else dx = dx + 1 end
        elseif dz ~= 0 then
            if dz > 0 then dz = dz - 1 else dz = dz + 1 end
        end
    end

    -- Move X
    if dx ~= 0 then
        if dx > 0 then self:turn_to("east") else self:turn_to("west") end
        for i = 1, math.abs(dx) do robot.forward() end
        self.agent.pos.x = self.agent.pos.x + dx
    end

    -- Move Z
    if dz ~= 0 then
        if dz > 0 then self:turn_to("south") else self:turn_to("north") end
        for i = 1, math.abs(dz) do robot.forward() end
        self.agent.pos.z = self.agent.pos.z + dz
    end

    print("✅ [Pathfinder] Arrived at: x="..self.agent.pos.x.." z="..self.agent.pos.z)
end




return Pathfinder
