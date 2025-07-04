local fs = require("filesystem")
local component = require("component")

print("🤖 Robot Setup — Initializing...")

-- ✅ Check wireless modem
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
    print("⚠️ WARNING: No Wireless Network Card found! Tasks won’t reach this robot.")
end

-- 📂 Ensure folders
local function ensureDir(path)
    if not fs.exists(path) then
        os.execute("mkdir " .. path)
    end
end

print("📂 Ensuring folders...")
ensureDir("/apps")
ensureDir("/apps/fleet")
ensureDir("/apps/fleet/jobs")
ensureDir("/data")

-- 📥 Download required files
print("📥 Downloading robot files...")
os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/apps/DataHelper.lua /apps/DataHelper.lua")
os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/apps/fleet/RobotRegistry.lua /apps/fleet/RobotRegistry.lua")
os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/apps/fleet/Pathfinder.lua /apps/fleet/Pathfinder.lua")
os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/robot_agent.lua /robot_agent.lua")
os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/apps/fleet/jobs/courier_job.lua /apps/fleet/jobs/courier_job.lua")
os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/data/robots.lua /data/robots.lua")

-- ✅ Confirm ID file
if not fs.exists("/robot_id.txt") then
    print("⚠️ robot_id.txt not found — create it to match registry!")
else
    print("✅ robot_id.txt found.")
end

print("\n🎉 Robot ready! Now run: lua /robot_agent.lua")
