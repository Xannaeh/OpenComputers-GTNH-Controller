-- setup.lua
-- First-time installer for OpenComputers-GTNH-Controller

local fs = require("filesystem")
local component = require("component")

print("🔍 Checking Components...")
local foundWireless = false
for addr, _ in component.list("modem") do
    local m = component.proxy(addr)
    if m.isWireless and m.isWireless() then
        foundWireless = true
        break
    end
end

if not foundWireless then
    print("⚠️ WARNING: No Wireless Network Card found! Add one for networking.")
else
    print("✅ Wireless Network Card detected!")
end

local function ensureDir(path)
    if not fs.exists(path) then
        os.execute("mkdir " .. path)
    end
end

local function ensureFile(path, url)
    if not fs.exists(path) then
        print("Downloading " .. path)
        os.execute("wget -f " .. url .. " " .. path)
    else
        print("✔ File exists: " .. path)
    end
end

local function main()
    print("📁 Creating folders...")
    ensureDir("/experiment")
    ensureDir("/experiment/robots")
    ensureDir("/experiment/robots/jobs")
    ensureDir("/experiment/server")

    print("⬇️ Downloading robot files...")
    ensureFile("/experiment/robots/agent.lua", "https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/experiment/robots/agent.lua")
    ensureFile("/experiment/robots/job.lua", "https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/experiment/robots/job.lua")
    ensureFile("/experiment/robots/jobs/courier.lua", "https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/experiment/robots/jobs/courier.lua")
    ensureFile("/experiment/robots/jobs/farmer.lua", "https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/experiment/robots/jobs/farmer.lua")
    ensureFile("/experiment/robots/pathfinder.lua", "https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/experiment/robots/pathfinder.lua")
    ensureFile("/experiment/robots/network.lua", "https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/experiment/robots/network.lua")
    ensureFile("/experiment/robots/utils.lua", "https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/experiment/robots/utils.lua")
    ensureFile("/experiment/robots/main.lua", "https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/experiment/robots/main.lua")

    print("⬇️ Downloading server files...")
    ensureFile("/experiment/server/main.lua", "https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/experiment/server/main.lua")
    ensureFile("/experiment/server/registry.lua", "https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/experiment/server/registry.lua")
    ensureFile("/experiment/server/dispatcher.lua", "https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/experiment/server/dispatcher.lua")
    ensureFile("/experiment/server/ui.lua", "https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/experiment/server/ui.lua")
    ensureFile("/experiment/server/network.lua", "https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/experiment/server/network.lua")
    ensureFile("/experiment/server/utils.lua", "https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/experiment/server/utils.lua")

    print("\n✅ Setup done! Run your robot with: lua /experiment/robots/main.lua")
end

main()
