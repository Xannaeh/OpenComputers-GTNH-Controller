-- 📂 DataHelper.lua — shared JSON read/write for robots, tasks, config, etc.

local fs = require("filesystem")
local ser = require("serialization")

local DataHelper = {}

function DataHelper.loadJson(path)
    if not fs.exists(path) then return {} end
    local file = io.open(path, "r")
    local data = ser.unserialize(file:read("*a"))
    file:close()
    return data
end

function DataHelper.saveJson(path, data)
    local file = io.open(path, "w")
    file:write(ser.serialize(data))
    file:close()
end

return DataHelper
