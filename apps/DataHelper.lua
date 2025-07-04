local fs  = require("filesystem")
local ser = require("serialization")

local DataHelper = {}

-- -------- core helpers (Lua-serialised files) ----------
function DataHelper.loadTable(path)
    if not fs.exists(path) then return nil end
    local ok, tbl = pcall(dofile, path)
    return ok and tbl or nil
end

function DataHelper.saveTable(path, tbl)
    local f = io.open(path, "w")
    f:write("return " .. ser.serialize(tbl))
    f:close()
end

-- -------- compatibility shims (old JSON-style names) ---
-- they simply forward to the new table helpers, so anything
-- still calling loadJson / saveJson will keep working.
function DataHelper.loadJson(path)  return DataHelper.loadTable(path) end
function DataHelper.saveJson(path,t) DataHelper.saveTable(path,t)    end

return DataHelper
