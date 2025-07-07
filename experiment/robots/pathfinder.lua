-- pathfinder.lua
-- Adds obstacle avoidance & persists robot position

local robot = require("robot")
local fs = require("filesystem")
local serialization = require("serialization")

local Pathfinder = {}
Pathfinder.__index = Pathfinder

function Pathfinder:new(agent)
    local obj = {
        agent = agent
    }
    setmetatable(obj, self)
    return obj
end

function Pathfinder:save_state()
    local file = io.open("/experiment/data/robot_state.lua", "w")
    file:write("return " .. serialization.serialize({
        pos = self.agent.pos,
        facing = self.agent.facing
    }))
    file:close()
end

function Pathfinder:turn_to(direction)
    local left_turns = { north = "west", west = "south", south = "east", east = "north" }
    while self.agent.facing ~= direction do
        robot.turnLeft()
        self.agent.facing = left_turns[self.agent.facing]
        self:save_state()
    end
end

function Pathfinder:step_forward()
    -- Try forward
    if not robot.detect() then
        if robot.forward() then return true end
    end

    -- Try sidestep left
    robot.turnLeft()
    if not robot.detect() then
        if robot.forward() then
            robot.turnRight()
            return true
        end
    end
    robot.turnRight() -- undo left

    -- Try sidestep right
    robot.turnRight()
    if not robot.detect() then
        if robot.forward() then
            robot.turnLeft()
            return true
        end
    end
    robot.turnLeft() -- undo right

    print("⚠️ Obstacle detected: cannot move forward or around.")
    return false
end

function Pathfinder:step_up()
    if robot.up() then
        self.agent.pos.y = self.agent.pos.y + 1
        self:save_state()
        return true
    end
    return false
end

function Pathfinder:step_down()
    if robot.down() then
        self.agent.pos.y = self.agent.pos.y - 1
        self:save_state()
        return true
    end
    return false
end

function Pathfinder:go_to(target)
    if not target then error("Pathfinder:go_to() nil target") end

    local dx = target.x - self.agent.pos.x
    local dz = target.z - self.agent.pos.z

    -- X axis
    if dx ~= 0 then
        if dx > 0 then self:turn_to("east") else self:turn_to("west") end
        for i = 1, math.abs(dx) do
            if not self:step_forward() then break end
            self.agent.pos.x = self.agent.pos.x + (dx > 0 and 1 or -1)
            self:save_state()
        end
    end

    -- Z axis
    if dz ~= 0 then
        if dz > 0 then self:turn_to("south") else self:turn_to("north") end
        for i = 1, math.abs(dz) do
            if not self:step_forward() then break end
            self.agent.pos.z = self.agent.pos.z + (dz > 0 and 1 or -1)
            self:save_state()
        end
    end
end

return Pathfinder
