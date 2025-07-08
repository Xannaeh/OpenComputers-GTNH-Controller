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
    obj.turn_left = { north = "west", west = "south", south = "east", east = "north" }
    obj.turn_right = { north = "east", east = "south", south = "west", west = "north" }
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

function Mapper:mark(x, y, z)
    self.visited[x .. "," .. y .. "," .. z] = true
end

function Mapper:is_marked(x, y, z)
    return self.visited[x .. "," .. y .. "," .. z]
end

function Mapper:add_node(x, y, z)
    table.insert(self.map.nodes, { id = "Node_" .. x .. "_" .. y .. "_" .. z, x = x, y = y, z = z })
end

function Mapper:add_edge(from, to, blocked)
    table.insert(self.map.edges, { from = from, to = to, blocked = blocked })
end

function Mapper:turn_to(target)
    while self.agent.facing ~= target do
        -- Always prefer left first (simpler)
        robot.turnLeft()
        self.agent.facing = self.turn_left[self.agent.facing]
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
    local id = "Node_" .. x .. "_" .. y .. "_" .. z

    if not self:is_marked(x, y, z) then
        self:add_node(x, y, z)
        self:mark(x, y, z)
    end

    for _, dir in ipairs(self.directions) do
        self:turn_to(dir)
        local nx, ny, nz = self:next_pos()
        local nid = "Node_" .. nx .. "_" .. ny .. "_" .. nz

        if robot.detect() then
            self:add_edge(id, nid, true)
        elseif not self:is_marked(nx, ny, nz) then
            self:add_edge(id, nid, false)

            if robot.forward() then
                self.agent.pos.x, self.agent.pos.y, self.agent.pos.z = nx, ny, nz
                self:save_state()

                self:dfs(nid)

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
    local start_id = "Node_" .. pos.x .. "_" .. pos.y .. "_" .. pos.z

    self:add_node(pos.x, pos.y, pos.z)
    self:mark(pos.x, pos.y, pos.z)

    self:dfs(start_id)

    self:save_map()
    self.agent.network:send_update_map(self.map)
    print("✅ Mapping done. Map saved & sent.")
end

return Mapper
