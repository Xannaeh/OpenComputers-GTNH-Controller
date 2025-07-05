local fs = require("filesystem")
local component = require("component")
local DataHelper = require("apps/DataHelper")

print("🤖 Robot Setup — Initializing...")

local foundWireless = false
for addr, _ in component.list("modem") do
    local m = component.proxy(addr)
    if m.isWireless and m.isWireless() then
        foundWireless = true
        print("✅ Wireless Network Card found: " .. addr)
        break
    end
end

if not foundWireless then
    print("⚠️ WARNING: No Wireless Network Card found! Add one or tasks won’t reach this robot.")
end

local function ensureDir(path)
    if not fs.exists(path) then
        os.execute("mkdir " .. path)
    end
end

print("📂 Ensuring folders...")
ensureDir("/apps")
ensureDir("/apps/fleet")
ensureDir("/apps/fleet/jobs")
ensureDir("/apps/fleet/robot_agent")
ensureDir("/data")

print("📥 Downloading essentials...")
os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/apps/DataHelper.lua /apps/DataHelper.lua")
os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/apps/fleet/RobotRegistry.lua /apps/fleet/RobotRegistry.lua")
os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/apps/fleet/Pathfinder.lua /apps/fleet/Pathfinder.lua")
os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/apps/fleet/robot_agent/robot_agent.lua /apps/fleet/robot_agent/robot_agent.lua")
os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/apps/fleet/jobs/courier_job.lua /apps/fleet/jobs/courier_job.lua")
os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/data/robots.lua /data/robots.lua")

if not fs.exists("/robot_id.txt") then
    print("⚠️ robot_id.txt not found! Create one with your robot ID.")
else
    print("✅ robot_id.txt found.")
end

if not fs.exists("/data/robot_tasks.lua") then
    DataHelper.saveTable("/data/robot_tasks.lua", {})
    print("✅ Created /data/robot_tasks.lua")
else
    print("✅ /data/robot_tasks.lua exists.")
end

print("🎉 Robot setup done! Run with: lua /apps/fleet/robot_agent/robot_agent.lua")
