-- pathfinder.lua
-- Robust: clear logs, avoid loops, consistent fallback

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
    f:write("📍 Pathfinder Debug Log for Task " .. tostring(task_id) .. "\n")
    f:close()

    -- Mark start
    obj:mark_visited(agent.pos.x, agent.pos.z)

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

function Pathfinder:mark_visited(x, z)
    self.visited[x .. "," .. z] = true
end

function Pathfinder:is_visited(x, z)
    return self.visited[x .. "," .. z] == true
end

function Pathfinder:next_pos(facing)
    local x, z = self.agent.pos.x, self.agent.pos.z
    if facing == "north" then z = z - 1
    elseif facing == "south" then z = z + 1
    elseif facing == "east" then x = x + 1
    elseif facing == "west" then x = x - 1 end
    return x, z
end

function Pathfinder:step_forward(goal)
    local nx, nz = self:next_pos(self.agent.facing)
    local dist = math.abs(goal.x - nx) + math.abs(goal.z - nz)

    self:log(string.format(
            "➡️ Try: Facing=%s | Now x=%s z=%s | Next x=%s z=%s | Dist=%s",
            self.agent.facing, self.agent.pos.x, self.agent.pos.z, nx, nz, dist
    ))

    -- If next is goal, stop (chest)
    if dist == 0 then
        self:log("✅ Goal block ahead → do not enter.")
        return false
    end

    -- If revisited
    if self:is_visited(nx, nz) then
        self:log(string.format("🚫 Next x=%s z=%s already visited.", nx, nz))
        return false
    end

    -- If blocked
    if robot.detect() then
        self:log(string.format("⛔ Blocked at next x=%s z=%s → marking visited.", nx, nz))
        self:mark_visited(nx, nz)
        return false
    end

    if robot.forward() then
        self.agent.pos.x, self.agent.pos.z = nx, nz
        self:save_state()
        self:mark_visited(nx, nz)
        self:log(string.format(
                "✅ Moved → New x=%s z=%s (Facing %s)",
                nx, nz, self.agent.facing
        ))
        return true
    end

    return false
end

function Pathfinder:face_target_block(target)
    local dx = target.x - self.agent.pos.x
    local dz = target.z - self.agent.pos.z

    if math.abs(dx) > math.abs(dz) then
        if dx > 0 then self:turn_to("east") else self:turn_to("west") end
    else
        if dz > 0 then self:turn_to("south") else self:turn_to("north") end
    end

    self:log(string.format("🎯 Face target block → dx=%s dz=%s → %s", dx, dz, self.agent.facing))
end

function Pathfinder:try_targets(targets)
    for _, target in ipairs(targets) do
        self:log(string.format("🎯 New target: x=%s z=%s", target.x, target.z))
        local max_steps = 200
        local steps = 0

        while steps < max_steps do
            local dx = target.x - self.agent.pos.x
            local dz = target.z - self.agent.pos.z
            if math.abs(dx) + math.abs(dz) <= 1 then
                self:log(string.format("✅ Arrived near target at x=%s z=%s", self.agent.pos.x, self.agent.pos.z))
                return true
            end

            -- Pick best next based on closest unvisited
            local options = {
                { dir = "north", x = self.agent.pos.x, z = self.agent.pos.z - 1 },
                { dir = "east",  x = self.agent.pos.x + 1, z = self.agent.pos.z },
                { dir = "south", x = self.agent.pos.x, z = self.agent.pos.z + 1 },
                { dir = "west",  x = self.agent.pos.x - 1, z = self.agent.pos.z }
            }

            table.sort(options, function(a, b)
                local da = math.abs(target.x - a.x) + math.abs(target.z - a.z)
                local db = math.abs(target.x - b.x) + math.abs(target.z - b.z)
                return da < db
            end)

            local moved = false
            for _, opt in ipairs(options) do
                self:log(string.format(
                        "🧭 Option: Dir=%s Next x=%s z=%s Visited=%s",
                        opt.dir, opt.x, opt.z, tostring(self:is_visited(opt.x, opt.z))
                ))
                if not self:is_visited(opt.x, opt.z) then
                    self:turn_to(opt.dir)
                    if self:step_forward(target) then
                        moved = true
                        break
                    end
                end
            end

            if not moved then
                self:log("⛔ All options blocked or visited → fallback turns.")
                -- Try fallback: force all directions
                local fallback = { "north", "east", "south", "west" }
                for _, dir in ipairs(fallback) do
                    self:turn_to(dir)
                    if self:step_forward(target) then
                        moved = true
                        break
                    end
                end
                if not moved then
                    self:log("💀 Fully stuck.")
                    break
                end
            end

            steps = steps + 1
        end

        self:log("❌ Could not reach this target → trying next.")
    end

    self:log("🚫 All targets failed.")
    return false
end

return Pathfinder
