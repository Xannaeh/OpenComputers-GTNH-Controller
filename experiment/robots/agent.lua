-- agent.lua
-- Loads robot state AND static config separately

local fs = require("filesystem")

local Agent = {}

function Agent:new(network)
    local obj = { network = network }

    -- Load static config
    if fs.exists("/experiment/data/config.lua") then
        local cfg = dofile("/experiment/data/robot_config.lua")
        obj.role = cfg.role or "courier"
        obj.home = cfg.home or { x = 32, y = 5, z = 0 }
    else
        obj.role = "courier"
        obj.home = { x = 32, y = 5, z = 0 }
    end

    obj.facing = "south"

    if fs.exists("/experiment/data/robot_state.lua") then
        print("🗂️ Found saved robot_state.lua, loading...")
        local ok, chunk = pcall(loadfile, "/experiment/data/robot_state.lua")
        if ok and chunk then
            local state = chunk()
            if state then
                obj.pos = state.pos or obj.home
                obj.facing = state.facing or "south"
            else
                obj.pos = obj.home
            end
        else
            obj.pos = obj.home
        end
    else
        obj.pos = obj.home
    end

    print(string.format("✅ Loaded: pos=%s,%s,%s facing=%s role=%s",
            obj.pos.x, obj.pos.y, obj.pos.z, obj.facing, obj.role))

    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Agent:run()
    print("🤖 Running as role: " .. self.role)

    if self.role == "mapper" then
        local Mapper = require("jobs.mapper")
        local mapper_job = Mapper:new(self)
        mapper_job:execute()
        print("🗺️ Mapper job done.")
        return
    end

    while true do
        local task = self.network:request_task()
        if task then
            if task.type == "courier" then
                local Courier = require("jobs.courier")
                local courier_job = Courier:new(self)
                courier_job:execute(task)
            end
            self.network:report_done(task.id or "unknown")
            os.sleep(3)
        else
            print("No tasks, waiting...")
            os.sleep(5)
        end
    end
end

return Agent
