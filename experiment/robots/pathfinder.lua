-- pathfinder.lua
-- Final: robust fallback rotate, visited cache per leg

local robot = require("robot")
local fs = require("filesystem")
local serialization = require("serialization")

local Pathfinder = {}
Pathfinder.__index = Pathfinder

function Pathfinder:new(agent, task_id)
    local obj = {
        agent = agent,
        log_file = "/experiment/data/debug_path_" .. tostring(task_id) .. ".log",
        visited = {}
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

function Pathfinder:mark_visited()
    local key = self.agent.pos.x .. "," .. self.agent.pos.z
    self.visited[key] = true
end

function Pathfinder:was_visited()
    local key = self.agent.pos.x .. "," .. self.agent.pos.z
    return self.visited[key] == true
end

function Pathfinder:step_forward(goal)
    local dx = goal.x - self.agent.pos.x
    local dz = goal.z - self.agent.pos.z
    if math.abs(dx) + math.abs(dz) == 1 then
        self:log("✅ Chest reached → stop forward.")
        return false
    end

    if not robot.detect() then
        if robot.forward() then
            self:update_pos_forward()
            self:mark_visited()
            self:log(string.format("✅ Forward → Pos: x=%s z=%s", self.agent.pos.x, self.agent.pos.z))
            return true
        end
    end

    return false
end

function Pathfinder:try_step_or_rotate(goal)
    if self:step_forward(goal) then return true end

    local fallback = { "north", "east", "south", "west" }
    for _, dir in ipairs(fallback) do
        self:turn_to(dir)
        if self:step_forward(goal) then return true end
    end

    self:log("⛔ All fallback rotations blocked.")
    return false
end

function Pathfinder:try_targets(targets)
    self.visited = {} -- fresh per leg

    for _, target in ipairs(targets) do
        self:log(string.format("🎯 Trying target: x=%s z=%s", target.x, target.z))
        local max = 200
        local steps = 0
        while steps < max do
            local dx = target.x - self.agent.pos.x
            local dz = target.z - self.agent.pos.z
            if math.abs(dx) + math.abs(dz) <= 1 then
                self:log(string.format("✅ Arrived: x=%s z=%s", self.agent.pos.x, self.agent.pos.z))
                return true
            end

            if self:was_visited() then
                self:log("🚫 Loop detected at current pos → break.")
                break
            end

            if math.abs(dx) >= math.abs(dz) then
                if dx > 0 then self:turn_to("east") else self:turn_to("west") end
            else
                if dz > 0 then self:turn_to("south") else self:turn_to("north") end
            end

            if not self:try_step_or_rotate(target) then break end
            steps = steps + 1
        end
        self:log("❌ Could not reach this target, trying next.")
    end

    self:log("🚫 All target spots failed.")
    return false
end

return Pathfinder
