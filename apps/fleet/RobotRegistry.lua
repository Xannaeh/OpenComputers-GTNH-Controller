local DataHelper = require("apps/DataHelper")

local RobotRegistry = {}
RobotRegistry.__index = RobotRegistry

function RobotRegistry.new()
    local self = setmetatable({}, RobotRegistry)
    self.path   = "/data/robots.lua"
    self.robots = self:load()          -- { robots = { … } }
    return self
end

-- ---------- file IO ----------

function RobotRegistry:load()
    return DataHelper.loadTable(self.path) or { robots = {} }
end

function RobotRegistry:save()
    DataHelper.saveTable(self.path, self.robots)
end

-- ---------- API ----------

function RobotRegistry:register(id, jobType)
    table.insert(self.robots.robots, {
        id      = id,
        jobType = jobType,
        status  = "idle",
        active  = true
    })
    self:save()
end

function RobotRegistry:dismantle(id)
    for _, r in ipairs(self.robots.robots) do
        if r.id == id then
            r.active = false
            break
        end
    end
    self:save()
end

function RobotRegistry:list()
    self.robots = self:load()          -- refresh
    for _, r in ipairs(self.robots.robots) do
        if r.active then
            print(("🤖 %s [%s] – %s"):format(r.id, r.jobType, r.status))
        end
    end
end

return RobotRegistry
