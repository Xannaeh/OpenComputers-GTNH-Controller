-- pathfinder.lua
-- Robust: sidestep with stuck counter + facing lock

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

function Pathfinder:face_target(target)
    -- Face the target to align robot front
    local dx = target.x - self.agent.pos.x
    local dz = target.z - self.agent.pos.z
    if math.abs(dx) > math.abs(dz) then
        if dx > 0 then self:turn_to("east") else self:turn_to("west") end
    else
        if dz > 0 then self:turn_to("south") else self:turn_to("north") end
    end
end

function Pathfinder:update_pos_forward()
    local f = self.agent.facing
    if f == "north" then self.agent.pos.z = self.agent.pos.z - 1
    elseif f == "south" then self.agent.pos.z = self.agent.pos.z + 1
    elseif f == "east" then self.agent.pos.x = self.agent.pos.x + 1
    elseif f == "west" then self.agent.pos.x = self.agent.pos.x - 1 end
    self:save_state()
end

function Pathfinder:update_pos_sidestep(side)
    local f = self.agent.facing
    if side == "left" then
        if f == "north" then self.agent.pos.x = self.agent.pos.x - 1
        elseif f == "south" then self.agent.pos.x = self.agent.pos.x + 1
        elseif f == "east" then self.agent.pos.z = self.agent.pos.z - 1
        elseif f == "west" then self.agent.pos.z = self.agent.pos.z + 1 end
    elseif side == "right" then
        if f == "north" then self.agent.pos.x = self.agent.pos.x + 1
        elseif f == "south" then self.agent.pos.x = self.agent.pos.x - 1
        elseif f == "east" then self.agent.pos.z = self.agent.pos.z + 1
        elseif f == "west" then self.agent.pos.z = self.agent.pos.z - 1 end
    end
    self:save_state()
end

function Pathfinder:step_forward()
    if not robot.detect() then
        if robot.forward() then
            self:update_pos_forward()
            self:log("✅ Forward → Pos: x="..self.agent.pos.x.." z="..self.agent.pos.z)
            return true
        end
    end

    self:log("⚠️ Block → Try sidestep left")
    robot.turnLeft()
    if not robot.detect() then
        if robot.forward() then
            self:update_pos_sidestep("left")
            self:log("↪️ Sidestep left → Pos: x="..self.agent.pos.x.." z="..self.agent.pos.z)
            robot.turnRight()
            return true
        end
    end
    robot.turnRight()

    self:log("⚠️ Sidestep right")
    robot.turnRight()
    if not robot.detect() then
        if robot.forward() then
            self:update_pos_sidestep("right")
            self:log("↩️ Sidestep right → Pos: x="..self.agent.pos.x.." z="..self.agent.pos.z)
            robot.turnLeft()
            return true
        end
    end
    robot.turnLeft()

    self:log("⛔ Fully blocked.")
    return false
end

function Pathfinder:adjust_stop_before(target)
    local adjust = { x = target.x, y = target.y, z = target.z }
    if self.agent.pos.x == target.x then
        if target.z > self.agent.pos.z then adjust.z = adjust.z - 1 else adjust.z = adjust.z + 1 end
    elseif self.agent.pos.z == target.z then
        if target.x > self.agent.pos.x then adjust.x = adjust.x - 1 else adjust.x = adjust.x + 1 end
    end
    self:log("✅ Adjust stop: x="..adjust.x.." z="..adjust.z)
    return adjust
end

function Pathfinder:go_to(target)
    self:log("🚩 Path Start: x="..self.agent.pos.x.." z="..self.agent.pos.z.." ➜ Target x="..target.x.." z="..target.z)
    local stuck = 0
    while true do
        local dx = target.x - self.agent.pos.x
        local dz = target.z - self.agent.pos.z
        local dist = math.abs(dx) + math.abs(dz)
        if dist <= 1 then
            self:log("✅ Close enough.")
            break
        end
        if math.abs(dx) >= math.abs(dz) then
            if dx > 0 then self:turn_to("east") else self:turn_to("west") end
        else
            if dz > 0 then self:turn_to("south") else self:turn_to("north") end
        end

        if self:step_forward() then
            stuck = 0
        else
            stuck = stuck + 1
            if stuck >= 5 then
                self:log("⛔ Stuck! Giving up.")
                break
            end
        end
    end
    self:log("✅ Arrived at: x="..self.agent.pos.x.." z="..self.agent.pos.z)
end

return Pathfinder
