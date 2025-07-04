-- ✅ apps/DataHelper.lua
local fs = require("filesystem")
local ser = require("serialization")

local DataHelper = {}

function DataHelper.loadJson(path)
    if not fs.exists(path) then return nil end
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
