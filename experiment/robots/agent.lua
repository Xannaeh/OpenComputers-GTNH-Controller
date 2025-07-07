-- agent.lua
-- Loads robot state or uses defaults. Supports static role config.

local fs = require("filesystem")

local Agent = {}

function Agent:new(network)
    local obj = { network = network }

    obj.home = { x = 32, y = 5, z = 0 }
    obj.facing = "south"
    obj.role = "courier" -- default fallback

    if fs.exists("/experiment/data/robot_state.lua") then
        print("🗂️ Found saved robot_state.lua, loading...")
        local ok, chunk = pcall(loadfile, "/experiment/data/robot_state.lua")
        if ok and chunk then
            local state = chunk()
            if state then
                obj.pos = state.pos or obj.home
                obj.facing = state.facing or "south"
                obj.role = state.role or "courier"
                print(string.format(
                        "✅ Loaded pos: x=%s y=%s z=%s facing=%s role=%s",
                        obj.pos.x, obj.pos.y, obj.pos.z, obj.facing, obj.role
                ))
            else
                print("⚠️ Loaded chunk but no data. Using defaults.")
                obj.pos = obj.home
            end
        else
            print("⚠️ Failed to load robot_state chunk. Using defaults.")
            obj.pos = obj.home
        end
    else
        print("ℹ️ No robot_state.lua found. Using defaults.")
        obj.pos = obj.home
    end

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
        return -- Mapper only runs once for now
    end

    while true do
        local task = self.network:request_task()
        if task then
            if task.type == "courier" and self.role == "courier" then
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
        os.sleep(5)
    end
end

return Agent
