-- pathfinder.lua
-- Converts world coordinates to relative robot movement

local robot = require("robot")

local Pathfinder = {}
Pathfinder.__index = Pathfinder

function Pathfinder:new(start_pos, start_facing)
    local obj = {
        pos = { x = start_pos.x, y = start_pos.y, z = start_pos.z },
        facing = start_facing  -- "north", "east", "south", "west"
    }
    setmetatable(obj, self)
    return obj
end

-- Turns the robot to face a desired cardinal direction
function Pathfinder:turn_to(direction)
    local order = { "north", "east", "south", "west" }
    local left_turns = { north = "west", west = "south", south = "east", east = "north" }

    while self.facing ~= direction do
        robot.turnLeft()
        self.facing = left_turns[self.facing]
    end
end

-- Move to a world coordinate in X/Z plane
function Pathfinder:go_to(target)
    if not target then
        error("Pathfinder:go_to() called with nil target")
    end

    local dx = target.x - self.pos.x
    local dz = target.z - self.pos.z

    -- Move X
    if dx ~= 0 then
        if dx > 0 then
            self:turn_to("east")
        else
            self:turn_to("west")
        end
        for i = 1, math.abs(dx) do
            robot.forward()
        end
        self.pos.x = target.x
    end

    -- Move Z
    if dz ~= 0 then
        if dz > 0 then
            self:turn_to("south")
        else
            self:turn_to("north")
        end
        for i = 1, math.abs(dz) do
            robot.forward()
        end
        self.pos.z = target.z
    end

    -- TODO: handle Y later
end


return Pathfinder
