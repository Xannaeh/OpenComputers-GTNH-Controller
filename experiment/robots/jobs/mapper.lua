-- Mapper Job: explores base and writes map nodes + edges

local robot = require("robot")
local component = require("component")
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

function Mapper:explore(x, y, z, id)
    self:mark_visited(x, y, z)
    self:add_node(x, y, z, id)

    local directions = {
        { dx =  1, dz =  0 },
        { dx = -1, dz =  0 },
        { dx =  0, dz =  1 },
        { dx =  0, dz = -1 }
    }

    for _, dir in ipairs(directions) do
        local nx, ny, nz = x + dir.dx, y, z + dir.dz

        if not self:is_visited(nx, ny, nz) then
            if not robot.detect() then -- crude check, adjust to real sensors!
                local new_id = "Node_" .. nx .. "_" .. ny .. "_" .. nz
                self:add_edge(id, new_id, 1) -- edge cost = 1 block for now
                self:explore(nx, ny, nz, new_id)
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

    self:explore(pos.x, pos.y, pos.z, id)
    self:save_map()
    self.agent.network:send_update_map(self.map)
end

return Mapper
