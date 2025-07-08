-- agent.lua
-- Loads robot state + static config with clear debug

local fs = require("filesystem")

local Agent = {}

function Agent:new(network)
    local obj = { network = network }

    -- Load static robot config
    if fs.exists("/experiment/data/robot_config.lua") then
        print("🔍 Loading robot_config.lua...")
        local ok, cfg = pcall(dofile, "/experiment/data/robot_config.lua")
        if ok and cfg then
            obj.role = cfg.role or "courier"
            obj.home = cfg.home or { x = 0, y = 5, z = 0 }
            print(string.format("✅ Config: role=%s, home=%s,%s,%s",
                    obj.role, obj.home.x, obj.home.y, obj.home.z))
        else
            print("⚠️ Failed to load config, fallback to courier.")
            obj.role = "courier"
            obj.home = { x = 0, y = 5, z = 0 }
        end
    else
        print("⚠️ No robot_config.lua found, fallback to courier.")
        obj.role = "courier"
        obj.home = { x = 0, y = 5, z = 0 }
    end

    -- Load dynamic robot state
    obj.facing = "south"
    if fs.exists("/experiment/data/robot_state.lua") then
        print("🔍 Loading robot_state.lua...")
        local ok, chunk = pcall(loadfile, "/experiment/data/robot_state.lua")
        if ok and chunk then
            local state = chunk()
            if state then
                obj.pos = state.pos or obj.home
                obj.facing = state.facing or "south"
                print(string.format("✅ State: pos=%s,%s,%s facing=%s",
                        obj.pos.x, obj.pos.y, obj.pos.z, obj.facing))
            else
                obj.pos = obj.home
            end
        else
            obj.pos = obj.home
        end
    else
        obj.pos = obj.home
    end

    print(string.format("🤖 Final: role=%s pos=%s,%s,%s facing=%s",
            obj.role, obj.pos.x, obj.pos.y, obj.pos.z, obj.facing))

    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Agent:run()
    print("🚦 Agent running in mode: " .. self.role)

    if self.role == "mapper" then
        local Mapper = require("jobs.mapper")
        local mapper_job = Mapper:new(self)
        mapper_job:execute()
        print("✅ Mapper run complete.")
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
            print("⏳ No tasks. Waiting...")
            os.sleep(5)
        end
    end
end

return Agent
