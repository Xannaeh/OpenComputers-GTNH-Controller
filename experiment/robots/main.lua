-- main.lua
-- Robot entry for network test

package.path = package.path .. ";/experiment/robots/?.lua;/experiment/robots/jobs/?.lua"

local Network = require("network")
local Agent = require("agent")

local net = Network:new()
local agent = Agent:new(net)
agent:run()
