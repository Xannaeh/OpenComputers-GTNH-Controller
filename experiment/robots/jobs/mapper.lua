-- Fixed Mapper: fully explores all reachable blocks

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
    obj.visited_nodes = {}
    obj.left_turns = { north = "west", west = "south", south = "east", east = "north" }
    obj.directions = { "north", "east", "south", "west" }
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

function Mapper:is_node_visited(x, y, z)
    return self.visited_nodes[x .. "," .. y .. "," .. z] == true
end

function Mapper:mark_node_visited(x, y, z)
    self.visited_nodes[x .. "," .. y .. "," .. z] = true
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

function Mapper:dfs(from_id)
    local x, y, z = self.agent.pos.x, self.agent.pos.y, self.agent.pos.z

    if not self:is_node_visited(x, y, z) then
        local id = "Node_" .. x .. "_" .. y .. "_" .. z
        self:add_node(x, y, z, id)
        self:add_edge(from_id, id, 1)
        self:mark_node_visited(x, y, z)
        from_id = id
    end

    for _, dir in ipairs(self.directions) do
        self:turn_to(dir)
        local nx, ny, nz = self:next_pos()

        if not robot.detect() and not self:is_node_visited(nx, ny, nz) then
            if robot.forward() then
                self.agent.pos.x, self.agent.pos.y, self.agent.pos.z = nx, ny, nz
                self:save_state()
                self:dfs(from_id)

                -- Backtrack
                robot.turnLeft()
                robot.turnLeft()
                robot.forward()
                robot.turnLeft()
                robot.turnLeft()

                self.agent.pos.x, self.agent.pos.y, self.agent.pos.z = x, y, z
                self:save_state()
            end
        end
    end
end

function Mapper:execute()
    local pos = self.agent.pos
    local id = "MapperStart"

    if pos.x == 32 and pos.z == 0 then id = "Charging1"
    elseif pos.x == 35 and pos.z == 2 then id = "Charging2" end

    self:mark_node_visited(pos.x, pos.y, pos.z)
    self:add_node(pos.x, pos.y, pos.z, id)

    self:dfs(id)

    self:save_map()
    self.agent.network:send_update_map(self.map)
    print("✅ Full DFS mapping complete.")
end

return Mapper
