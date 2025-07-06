-- courier.lua
-- Courier Job: moves items between locations

local component = require("component")
local robot = require("robot")
local sides = require("sides")

local Job = require("job")
local Courier = Job:new()

function Courier:execute()
    print("Courier job started.")

    -- Example: move forward 3 blocks, grab items, come back
    for i = 1, 3 do
        robot.forward()
    end

    -- Try to suck items from a chest in front
    if robot.suck() then
        print("Items collected.")
    else
        print("Nothing to collect.")
    end

    -- Return to start
    for i = 1, 3 do
        robot.back()
    end

    -- Drop items behind
    if robot.drop(sides.back) then
        print("Items dropped.")
    else
        print("Nothing to drop.")
    end

    print("Courier job done.")
end

return Courier
