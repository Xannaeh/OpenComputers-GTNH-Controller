-- pathfinder.lua
-- Adds sidestep with return to lane + persistent state

local robot = require("robot")
local serialization = require("serialization")

local Pathfinder = {}
Pathfinder.__index = Pathfinder

function Pathfinder:new(agent)
    local obj = { agent = agent }
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
    -- Try normal forward
    if not robot.detect() then
        if robot.forward() then
            self:update_position()
            return true
        end
    end

    print("⚠️ Block ahead: sidestepping left...")

    -- Sidestep left
    robot.turnLeft()
    local left_dir = self:next_facing("left")
    if not robot.detect() then
        if robot.forward() then
            self:update_position(left_dir)
            robot.turnRight()
            if not robot.detect() then
                if robot.forward() then
                    self:update_position()
                    robot.turnRight()
                    if robot.forward() then
                        self:update_position(left_dir == "west" and "east" or "west")
                        robot.turnLeft()
                        print("✅ Sidestepped left around and back on lane")
                        return true
                    end
                end
            end
            -- Failed, undo
            robot.turnLeft()
            robot.back()
            self:update_position(left_dir, -1)
            robot.turnRight()
        end
    end
    robot.turnRight()

    print("⚠️ Sidestepping right...")
    -- Sidestep right
    robot.turnRight()
    local right_dir = self:next_facing("right")
    if not robot.detect() then
        if robot.forward() then
            self:update_position(right_dir)
            robot.turnLeft()
            if not robot.detect() then
                if robot.forward() then
                    self:update_position()
                    robot.turnLeft()
                    if robot.forward() then
                        self:update_position(right_dir == "east" and "west" or "east")
                        robot.turnRight()
                        print("✅ Sidestepped right around and back on lane")
                        return true
                    end
                end
            end
            -- Failed, undo
            robot.turnRight()
            robot.back()
            self:update_position(right_dir, -1)
            robot.turnLeft()
        end
    end
    robot.turnLeft()

    print("❌ Could not bypass.")
    return false
end

function Pathfinder:update_position(side_dir, factor)
    local factor = factor or 1
    local facing = side_dir or self.agent.facing
    if facing == "north" then
        self.agent.pos.z = self.agent.pos.z - factor
    elseif facing == "south" then
        self.agent.pos.z = self.agent.pos.z + factor
    elseif facing == "east" then
        self.agent.pos.x = self.agent.pos.x + factor
    elseif facing == "west" then
        self.agent.pos.x = self.agent.pos.x - factor
    end
    self:save_state()
end

function Pathfinder:next_facing(turn)
    local order = { "north", "east", "south", "west" }
    local idx = 0
    for i, dir in ipairs(order) do
        if dir == self.agent.facing then idx = i break end
    end
    if turn == "left" then
        return order[(idx - 2) % 4 + 1]
    else
        return order[(idx) % 4 + 1]
    end
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
    print(string.format("📍 Moving to XZ: Δx=%d Δz=%d", dx, dz))

    if dx ~= 0 then
        self:turn_to(dx > 0 and "east" or "west")
        for i = 1, math.abs(dx) do
            if not self:step_forward() then break end
        end
    end

    if dz ~= 0 then
        self:turn_to(dz > 0 and "south" or "north")
        for i = 1, math.abs(dz) do
            if not self:step_forward() then break end
        end
    end
end

return Pathfinder
