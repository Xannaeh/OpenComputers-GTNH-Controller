-- pathfinder.lua
-- Adds debug logging per task

local robot = require("robot")
local fs = require("filesystem")
local serialization = require("serialization")

local Pathfinder = {}
Pathfinder.__index = Pathfinder

function Pathfinder:new(agent, task_id)
    local obj = {
        agent = agent,
        log_path = "/experiment/logs/debug_path_"..tostring(task_id)..".log"
    }
    fs.makeDirectory("/experiment/logs/")
    local f = io.open(obj.log_path, "w")
    f:write(string.format("📂 Pathfinder Debug Log for Task %s\n", task_id))
    f:close()
    setmetatable(obj, self)
    return obj
end

function Pathfinder:log(msg)
    local f = io.open(self.log_path, "a")
    f:write(msg.."\n")
    f:close()
end

function Pathfinder:save_state()
    local file = io.open("/experiment/data/robot_state.lua", "w")
    file:write("return "..serialization.serialize({
        pos = self.agent.pos,
        facing = self.agent.facing
    }))
    file:close()
end

function Pathfinder:turn_to(dir)
    local left_turns = { north = "west", west = "south", south = "east", east = "north" }
    while self.agent.facing ~= dir do
        robot.turnLeft()
        self.agent.facing = left_turns[self.agent.facing]
        self:log(string.format("↪️ Turned Left → Now facing: %s", self.agent.facing))
        self:save_state()
    end
end

function Pathfinder:step_forward()
    if not robot.detect() then
        if robot.forward() then
            self:log("✅ Stepped forward")
            return true
        end
    end

    self:log("⚠️ Block ahead: sidestepping left")
    robot.turnLeft()
    if not robot.detect() then
        if robot.forward() then
            robot.turnRight()
            self:log("✅ Sidestepped left and resumed")
            return true
        end
    end
    robot.turnRight()

    self:log("⚠️ Sidestepping right...")
    robot.turnRight()
    if not robot.detect() then
        if robot.forward() then
            robot.turnLeft()
            self:log("✅ Sidestepped right and resumed")
            return true
        end
    end
    robot.turnLeft()

    self:log("⛔ Block could not be bypassed.")
    return false
end

function Pathfinder:go_to(target)
    if not target then error("Nil target in go_to") end

    local dx = target.x - self.agent.pos.x
    local dz = target.z - self.agent.pos.z

    self:log(string.format("🔀 Path: Start x=%d z=%d  →  Target x=%d z=%d", self.agent.pos.x, self.agent.pos.z, target.x, target.z))

    if dx ~= 0 then
        self:turn_to(dx > 0 and "east" or "west")
        for i = 1, math.abs(dx) do
            if not self:step_forward() then break end
            self.agent.pos.x = self.agent.pos.x + (dx > 0 and 1 or -1)
            self:log(string.format("Moved X to x=%d", self.agent.pos.x))
            self:save_state()
        end
    end

    if dz ~= 0 then
        self:turn_to(dz > 0 and "south" or "north")
        for i = 1, math.abs(dz) do
            if not self:step_forward() then break end
            self.agent.pos.z = self.agent.pos.z + (dz > 0 and 1 or -1)
            self:log(string.format("Moved Z to z=%d", self.agent.pos.z))
            self:save_state()
        end
    end

    self:log(string.format("✅ Arrived at: x=%d z=%d", self.agent.pos.x, self.agent.pos.z))
end

return Pathfinder
