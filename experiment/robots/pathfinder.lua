-- pathfinder.lua
-- Modular: try multiple targets, robust dodge & log + chest detection fix

local robot = require("robot")
local fs = require("filesystem")
local serialization = require("serialization")

local Pathfinder = {}
Pathfinder.__index = Pathfinder

function Pathfinder:new(agent, task_id)
    local obj = {
        agent = agent,
        log_file = "/experiment/data/debug_path_" .. tostring(task_id) .. ".log"
    }
    setmetatable(obj, self)

    local f = io.open(obj.log_file, "w")
    f:write("📍 Pathfinder Debug Log for Task ", tostring(task_id), "\n")
    f:close()

    return obj
end

function Pathfinder:log(msg)
    local f = io.open(self.log_file, "a")
    f:write(msg .. "\n")
    f:close()
    print(msg)
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
        self:log("🔄 Turn Left → Facing: " .. self.agent.facing)
    end
end

function Pathfinder:face_target_block(target)
    local dx = target.x - self.agent.pos.x
    local dz = target.z - self.agent.pos.z

    if math.abs(dx) > math.abs(dz) then
        if dx > 0 then self:turn_to("east") else self:turn_to("west") end
    else
        if dz > 0 then self:turn_to("south") else self:turn_to("north") end
    end

    self:log(string.format("🎯 Facing block: dx=%s dz=%s → %s", dx, dz, self.agent.facing))
end

function Pathfinder:update_pos_forward()
    local f = self.agent.facing
    if f == "north" then self.agent.pos.z = self.agent.pos.z - 1
    elseif f == "south" then self.agent.pos.z = self.agent.pos.z + 1
    elseif f == "east" then self.agent.pos.x = self.agent.pos.x + 1
    elseif f == "west" then self.agent.pos.x = self.agent.pos.x - 1 end
    self:save_state()
end

function Pathfinder:step_forward(goal)
    -- 🟢 If the goal is ahead, and the block IS detected, stop: it's the chest!
    local dx = goal.x - self.agent.pos.x
    local dz = goal.z - self.agent.pos.z
    if math.abs(dx) + math.abs(dz) == 1 then
        self:log("✅ Block ahead is chest, stopping here.")
        return false
    end

    if not robot.detect() then
        if robot.forward() then
            self:update_pos_forward()
            self:log(string.format("✅ Forward → Pos: x=%s z=%s", self.agent.pos.x, self.agent.pos.z))
            return true
        end
    end

    -- Obstacle → try sidestep
    for _, side in ipairs({ "left", "right" }) do
        self:log("⚠️ Block ahead → Try sidestep " .. side)
        local turn = side == "left" and robot.turnLeft or robot.turnRight
        local undo = side == "left" and robot.turnRight or robot.turnLeft
        turn()
        if not robot.detect() then
            if robot.forward() then
                local facing = self.agent.facing
                if side == "left" then
                    if facing == "north" then self.agent.pos.x = self.agent.pos.x - 1
                    elseif facing == "south" then self.agent.pos.x = self.agent.pos.x + 1
                    elseif facing == "east" then self.agent.pos.z = self.agent.pos.z - 1
                    elseif facing == "west" then self.agent.pos.z = self.agent.pos.z + 1 end
                else
                    if facing == "north" then self.agent.pos.x = self.agent.pos.x + 1
                    elseif facing == "south" then self.agent.pos.x = self.agent.pos.x - 1
                    elseif facing == "east" then self.agent.pos.z = self.agent.pos.z + 1
                    elseif facing == "west" then self.agent.pos.z = self.agent.pos.z - 1 end
                end
                self:save_state()
                self:log(string.format("↪️ Sidestep %s → Pos: x=%s z=%s", side, self.agent.pos.x, self.agent.pos.z))
                undo()
                return true
            end
        end
        undo()
    end

    self:log("⛔ Stuck.")
    return false
end

function Pathfinder:try_targets(targets)
    for _, target in ipairs(targets) do
        self:log(string.format("🎯 Trying target: x=%s z=%s", target.x, target.z))
        local max = 100
        local step = 0
        while step < max do
            local dx = target.x - self.agent.pos.x
            local dz = target.z - self.agent.pos.z
            if math.abs(dx) + math.abs(dz) <= 1 then
                self:log(string.format("✅ Arrived at target: x=%s z=%s", self.agent.pos.x, self.agent.pos.z))
                return true
            end

            if math.abs(dx) >= math.abs(dz) then
                if dx > 0 then self:turn_to("east") else self:turn_to("west") end
            else
                if dz > 0 then self:turn_to("south") else self:turn_to("north") end
            end

            if not self:step_forward(target) then break end
            step = step + 1
        end
        self:log("❌ Could not reach target, trying next option.")
    end
    self:log("🚫 All targets failed.")
    return false
end

return Pathfinder
