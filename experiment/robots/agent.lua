-- agent.lua
-- Loads position from state or sets defaults

local fs = require("filesystem")
local serialization = require("serialization")

local Agent = {}

function Agent:new(network)
    local obj = { network = network }

    if fs.exists("/experiment/data/robot_state.lua") then
        local ok, chunk = pcall(loadfile, "/experiment/data/robot_state.lua")
        if ok and chunk then
            local state = chunk()
            obj.pos = state.pos
            obj.facing = state.facing
            print("✅ Loaded robot state:", obj.pos.x, obj.pos.y, obj.pos.z, "facing", obj.facing)
        else
            print("⚠️ Failed to load robot state. Using defaults.")
            obj.pos = { x = 32, y = 5, z = 0 }
            obj.facing = "south"
        end
    else
        obj.pos = { x = 32, y = 5, z = 0 }
        obj.facing = "south"
        print("ℹ️ No robot_state.lua found. Using defaults.")
    end

    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Agent:run()
    while true do
        local task = self.network:request_task()
        if task then
            -- Example: dynamic job load
            if task.type == "courier" then
                local Courier = require("jobs.courier")
                local courier_job = Courier:new(self) -- pass Agent self
                courier_job:execute(task)
            end
            self.network:report_done(task.id or "unknown")
            os.sleep(3)
        else
            print("No tasks, waiting...")
            os.sleep(5)
        end
        os.sleep(5)
    end
end

return Agent
