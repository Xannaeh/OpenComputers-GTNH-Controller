local fs = require("filesystem")
local component = require("component")

print("🚚 Dispatcher Setup — Initializing...")

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
    print("⚠️ WARNING: No Wireless Network Card found! Add one or tasks won’t broadcast.")
end

-- ✅ Ensure folders
local function ensureDir(path)
    if not fs.exists(path) then
        os.execute("mkdir " .. path)
    end
end

print("📂 Ensuring folders...")
ensureDir("/apps")
ensureDir("/apps/fleet")

-- ✅ Download files
print("📥 Downloading dispatcher files...")
os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/apps/fleet/dispatcher.lua /apps/fleet/dispatcher.lua")
os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/apps/fleet/TaskRegistry.lua /apps/fleet/TaskRegistry.lua")
os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/apps/DataHelper.lua /apps/DataHelper.lua")

print("\n🎉 Dispatcher ready! Run it anytime with: lua /apps/fleet/dispatcher.lua")
