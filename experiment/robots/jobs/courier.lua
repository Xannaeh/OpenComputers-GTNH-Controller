-- courier.lua
-- Courier Job: moves items between locations

local component = require("component")
local robot = require("robot")

local Job = require("job")
local Courier = Job:new()

function Courier:execute()
    print("Courier job started.")

    -- Move to pickup chest
    for i = 1, 3 do
        robot.forward()
    end

    -- Pick up items
    if robot.suck() then
        print("Items collected.")
    else
        print("Nothing to collect.")
    end

    -- Return to base
    for i = 1, 3 do
        robot.back()
    end

    -- Turn 180° to face drop-off chest
    robot.turnAround = function()
        robot.turnLeft()
        robot.turnLeft()
    end

    robot.turnAround()

    -- Move to drop-off chest (3 blocks forward in opposite direction)
    for i = 1, 3 do
        robot.forward()
    end

    -- Drop items
    if robot.drop() then
        print("Items dropped.")
    else
        print("Nothing to drop.")
    end

    -- Return to base
    for i = 1, 3 do
        robot.back()
    end

    -- Turn back to original orientation
    robot.turnAround()

    print("Courier job done.")
end

return Courier
