-- pathfinder.lua
-- Refined: robust debug logging + sidestep position updates

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
    -- Fresh log for this run
    fs.makeDirectory("/experiment/logs/")
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
        self:log(string.format("🔄 Turned Left → Now facing: %s", self.agent.facing))
    end
end

function Pathfinder:step_forward()
    if not robot.detect() then
        if robot.forward() then
            self:update_pos_fwd()
            self:log("✅ Stepped forward → New pos: x=" .. self.agent.pos.x .. " z=" .. self.agent.pos.z)
            return true
        end
    end

    self:log("⚠️ Block ahead: sidestepping left...")
    robot.turnLeft()
    if not robot.detect() then
        if robot.forward() then
            self:update_pos_fwd()
            self:log("↪️ Sidestepped left → New pos: x=" .. self.agent.pos.x .. " z=" .. self.agent.pos.z)
            robot.turnRight()
            return true
        end
    end
    robot.turnRight()

    self:log("⚠️ Sidestepping right...")
    robot.turnRight()
    if not robot.detect() then
        if robot.forward() then
            self:update_pos_fwd()
            self:log("↩️ Sidestepped right → New pos: x=" .. self.agent.pos.x .. " z=" .. self.agent.pos.z)
            robot.turnLeft()
            return true
        end
    end
    robot.turnLeft()

    self:log("⛔ Cannot bypass obstacle, blocked!")
    return false
end

function Pathfinder:update_pos_fwd()
    local facing = self.agent.facing
    if facing == "north" then
        self.agent.pos.z = self.agent.pos.z - 1
    elseif facing == "south" then
        self.agent.pos.z = self.agent.pos.z + 1
    elseif facing == "east" then
        self.agent.pos.x = self.agent.pos.x + 1
    elseif facing == "west" then
        self.agent.pos.x = self.agent.pos.x - 1
    end
    self:save_state()
end

function Pathfinder:go_to(target)
    if not target then error("Pathfinder:go_to() called with nil target") end

    local tx, tz = tonumber(target.x), tonumber(target.z)
    local cx, cz = tonumber(self.agent.pos.x), tonumber(self.agent.pos.z)

    local dx = tx - cx
    local dz = tz - cz

    self:log(string.format("📍 Path: Start x=%s z=%s ➜ Target x=%s z=%s", cx, cz, tx, tz))

    -- X axis
    if dx ~= 0 then
        if dx > 0 then self:turn_to("east") else self:turn_to("west") end
        for i = 1, math.abs(dx) do
            if not self:step_forward() then
                self:log("⛔ X blocked.")
                break
            end
        end
    end

    -- Z axis
    if dz ~= 0 then
        if dz > 0 then self:turn_to("south") else self:turn_to("north") end
        for i = 1, math.abs(dz) do
            if not self:step_forward() then
                self:log("⛔ Z blocked.")
                break
            end
        end
    end

    self:log(string.format("✅ Arrived at: x=%s z=%s", self.agent.pos.x, self.agent.pos.z))
end

return Pathfinder
