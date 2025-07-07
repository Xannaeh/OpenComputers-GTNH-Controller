-- Mapper Job: explores base by moving, turning, backtracking

local robot = require("robot")
local serialization = require("serialization")
local fs = require("filesystem")
local Job = require("job")

local Mapper = {}
setmetatable(Mapper, { __index = Job })
Mapper.__index = Mapper

function Mapper:new(agent)
    local obj = Job:new()
    setmetatable(obj, Mapper)
    obj.agent = agent
    obj.map = obj:load_map()
    obj.visited = {}
    obj.directions = { "north", "east", "south", "west" }
    obj.left_turns = { north = "west", west = "south", south = "east", east = "north" }
    return obj
end

function Mapper:load_map()
    local f = loadfile("/experiment/data/map.lua")
    return f and f() or { nodes = {}, edges = {} }
end

function Mapper:save_map()
    local f = io.open("/experiment/data/map.lua", "w")
    f:write("return " .. serialization.serialize(self.map))
    f:close()
end

function Mapper:save_state()
    local f = io.open("/experiment/data/robot_state.lua", "w")
    f:write("return " .. serialization.serialize({
        pos = self.agent.pos,
        facing = self.agent.facing
    }))
    f:close()
end

function Mapper:add_node(x, y, z, id)
    table.insert(self.map.nodes, { id = id, x = x, y = y, z = z })
end

function Mapper:add_edge(from_id, to_id, cost)
    table.insert(self.map.edges, { from = from_id, to = to_id, cost = cost })
end

function Mapper:mark_visited(x, y, z)
    self.visited[x .. "," .. y .. "," .. z] = true
end

function Mapper:is_visited(x, y, z)
    return self.visited[x .. "," .. y .. "," .. z] == true
end

function Mapper:turn_to(direction)
    while self.agent.facing ~= direction do
        robot.turnLeft()
        self.agent.facing = self.left_turns[self.agent.facing]
    end
    self:save_state()
end

function Mapper:next_pos()
    local x, y, z = self.agent.pos.x, self.agent.pos.y, self.agent.pos.z
    if self.agent.facing == "north" then z = z - 1
    elseif self.agent.facing == "south" then z = z + 1
    elseif self.agent.facing == "east" then x = x + 1
    elseif self.agent.facing == "west" then x = x - 1 end
    return x, y, z
end

function Mapper:explore(id)
    local x, y, z = self.agent.pos.x, self.agent.pos.y, self.agent.pos.z
    self:mark_visited(x, y, z)
    self:add_node(x, y, z, id)

    for _, dir in ipairs(self.directions) do
        self:turn_to(dir)
        local nx, ny, nz = self:next_pos()
        if not self:is_visited(nx, ny, nz) then
            if not robot.detect() then
                local new_id = "Node_" .. nx .. "_" .. ny .. "_" .. nz
                self:add_edge(id, new_id, 1)

                -- Move forward
                if robot.forward() then
                    self.agent.pos.x, self.agent.pos.y, self.agent.pos.z = nx, ny, nz
                    self:save_state()
                    self:explore(new_id) -- recurse

                    -- Backtrack
                    robot.turnLeft()
                    robot.turnLeft()
                    robot.forward()
                    robot.turnLeft()
                    robot.turnLeft()

                    -- Reset pos after backtracking
                    self.agent.pos.x, self.agent.pos.y, self.agent.pos.z = x, y, z
                    self:save_state()
                end
            end
        end
    end
end

function Mapper:execute()
    local pos = self.agent.pos
    local id = "Unknown"

    if pos.x == 32 and pos.z == 0 then id = "Charging1"
    elseif pos.x == 35 and pos.z == 2 then id = "Charging2"
    else id = "Node_" .. pos.x .. "_" .. pos.y .. "_" .. pos.z end

    self:explore(id)
    self:save_map()
    self.agent.network:send_update_map(self.map)

    print("✅ Mapper finished exploration.")
end

return Mapper
