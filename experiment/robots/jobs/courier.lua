-- courier.lua
-- Courier Job: moves items between locations

local Job = require("job")

local Courier = Job:new()

function Courier:execute()
    print("Courier job started.")
    -- Add your movement & transfer logic here
end

return Courier
