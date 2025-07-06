-- main.lua
-- Robot main entry point for testing Agent + Courier
package.path = package.path .. ";/experiment/robots/?.lua"

local Job = require("job")
local Courier = require("jobs.courier")
local Agent = require("agent")

local courier_job = Courier:new()
local agent = Agent:new(courier_job)

agent:run()
