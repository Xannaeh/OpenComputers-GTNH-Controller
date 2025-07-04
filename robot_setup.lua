local fs = require("filesystem")
local component = require("component")

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
ensureDir("/data")  -- ✅ Ensure /data before downloading!

print("📥 Downloading robot files...")
os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/apps/DataHelper.lua /apps/DataHelper.lua")
os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/apps/fleet/RobotRegistry.lua /apps/fleet/RobotRegistry.lua")
os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/apps/fleet/Pathfinder.lua /apps/fleet/Pathfinder.lua")
os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/apps/fleet/robot_agent/robot_agent.lua apps/fleet/robot_agent/robot_agent.lua")
os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/apps/fleet/jobs/courier_job.lua /apps/fleet/jobs/courier_job.lua")
os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/data/robots.lua /data/robots.lua")  -- ✅ This will now succeed!

if not fs.exists("/robot_id.txt") then
    print("⚠️ robot_id.txt not found — create one with the robot’s ID to link it to registry!")
else
    print("✅ robot_id.txt found.")
end

print("\n🎉 Robot ready! Now run: lua apps/fleet/robot_agent/robot_agent.lua")
