local fs  = require("filesystem")
local ser = require("serialization")

local DataHelper = {}

-- Load a Lua table from a .lua file that does `return {...}`
function DataHelper.loadTable(path)
    if not fs.exists(path) then return nil end
    local ok, tbl = pcall(dofile, path)
    if ok then return tbl else return nil end
end

-- Save a Lua table in OpenComputers serialised format
function DataHelper.saveTable(path, tbl)
    local f = io.open(path, "w")
    f:write("return " .. ser.serialize(tbl))
    f:close()
end

return DataHelper
