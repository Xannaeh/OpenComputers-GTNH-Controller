local DataHelper = require("apps/DataHelper")

local RobotRegistry = {}
RobotRegistry.__index = RobotRegistry

function RobotRegistry.new()
    return setmetatable({ path = "/data/robots.lua" }, RobotRegistry)
end

-- ---------- file I/O ----------
function RobotRegistry:load()
    return DataHelper.loadTable(self.path) or { robots = {} }
end

function RobotRegistry:save(tbl)
    DataHelper.saveTable(self.path, tbl)
end

-- ---------- public API ----------
function RobotRegistry:register(id, jobType)
    local d = self:load()
    table.insert(d.robots, {
        id      = id,
        jobType = jobType,
        status  = "idle",
        active  = true
    })
    self:save(d)
end

function RobotRegistry:dismantle(id)
    local d = self:load()
    for _, r in ipairs(d.robots) do
        if r.id == id then r.active = false break end
    end
    self:save(d)
end

function RobotRegistry:list()
    local d = self:load()
    for _, r in ipairs(d.robots) do
        if r.active then
            print(("🤖 %s [%s] – %s"):format(r.id, r.jobType, r.status))
        end
    end
end

return RobotRegistry
