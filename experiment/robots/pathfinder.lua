-- pathfinder.lua
-- Robust sidestep + adjusted stop

local robot = require("robot")
local fs = require("filesystem")
local serialization = require("serialization")

local Pathfinder = {}
Pathfinder.__index = Pathfinder

function Pathfinder:new(agent, task_id)
    local obj = {
        agent = agent,
        log_file = "/experiment/data/debug_path_"..task_id..".log"
    }
    setmetatable(obj, self)
    -- Fresh log for this run
    fs.makeDirectory("/experiment/logs/")
    local f = io.open(obj.log_file, "w")
    f:write("📍 Pathfinder Debug Log ["..task_id.."]\n")
    f:close()
    return obj
end

function Pathfinder:log(msg)
    local f = io.open(self.log_file, "a")
    f:write(msg.."\n")
    f:close()
    print(msg)
end

function Pathfinder:save_state()
    local file = io.open("/experiment/data/robot_state.lua", "w")
    file:write("return "..serialization.serialize({
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
        self:log("↻ Turned Left → Now facing: "..self.agent.facing)
    end
end

function Pathfinder:update_pos_fwd()
    if self.agent.facing == "north" then self.agent.pos.z = self.agent.pos.z - 1
    elseif self.agent.facing == "south" then self.agent.pos.z = self.agent.pos.z + 1
    elseif self.agent.facing == "east" then self.agent.pos.x = self.agent.pos.x + 1
    elseif self.agent.facing == "west" then self.agent.pos.x = self.agent.pos.x - 1
    end
    self:save_state()
end

function Pathfinder:step_forward()
    if not robot.detect() then
        if robot.forward() then
            self:update_pos_fwd()
            self:log("✅ Stepped forward → pos x="..self.agent.pos.x.." z="..self.agent.pos.z)
            return true
        end
    end

    self:log("⚠️ Block ahead, sidestepping left.")
    robot.turnLeft()
    if not robot.detect() then
        if robot.forward() then
            self:update_pos_fwd()
            robot.turnRight()
            self:log("↪️ Sidestepped left → pos x="..self.agent.pos.x.." z="..self.agent.pos.z)
            return true
        end
    end
    robot.turnRight()

    self:log("⚠️ Sidestepping right.")
    robot.turnRight()
    if not robot.detect() then
        if robot.forward() then
            self:update_pos_fwd()
            robot.turnLeft()
            self:log("↩️ Sidestepped right → pos x="..self.agent.pos.x.." z="..self.agent.pos.z)
            return true
        end
    end
    robot.turnLeft()

    self:log("⛔ Cannot bypass obstacle.")
    return false
end

function Pathfinder:adjust_stop_before(target)
    local adjust = { x = target.x, y = target.y, z = target.z }
    if self.agent.pos.x == target.x then
        if target.z > self.agent.pos.z then adjust.z = adjust.z - 1
        else adjust.z = adjust.z + 1 end
    elseif self.agent.pos.z == target.z then
        if target.x > self.agent.pos.x then adjust.x = adjust.x - 1
        else adjust.x = adjust.x + 1 end
    end
    self:log("✅ Stop adjusted: x="..adjust.x.." z="..adjust.z)
    return adjust
end

function Pathfinder:go_to(target)
    local tx, tz = target.x, target.z
    local cx, cz = self.agent.pos.x, self.agent.pos.z
    local dx, dz = tx - cx, tz - cz

    self:log(string.format("📍 Path: Start x=%s z=%s ➜ Target x=%s z=%s", cx, cz, tx, tz))

    if dx ~= 0 then
        if dx > 0 then self:turn_to("east") else self:turn_to("west") end
        for _ = 1, math.abs(dx) do
            if not self:step_forward() then
                self:log("⛔ X blocked.")
                break
            end
        end
    end

    if dz ~= 0 then
        if dz > 0 then self:turn_to("south") else self:turn_to("north") end
        for _ = 1, math.abs(dz) do
            if not self:step_forward() then
                self:log("⛔ Z blocked.")
                break
            end
        end
    end

    self:log(string.format("✅ Arrived at: x=%s z=%s", self.agent.pos.x, self.agent.pos.z))
end

return Pathfinder
