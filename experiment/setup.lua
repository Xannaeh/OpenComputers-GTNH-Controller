-- setup.lua
-- Bootstraps folders and always refreshes code

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
    print("Downloading new file: " .. path)
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
  ensureDir("/data")

  print("⬇️ Updating robot files...")
  os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/experiment/robots/agent.lua /experiment/robots/agent.lua")
  os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/experiment/robots/job.lua /experiment/robots/job.lua")
  os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/experiment/robots/jobs/courier.lua /experiment/robots/jobs/courier.lua")
  os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/experiment/robots/jobs/farmer.lua /experiment/robots/jobs/farmer.lua")
  os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/experiment/robots/pathfinder.lua /experiment/robots/pathfinder.lua")
  os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/experiment/robots/network.lua /experiment/robots/network.lua")
  os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/experiment/robots/utils.lua /experiment/robots/utils.lua")
  os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/experiment/robots/main.lua /experiment/robots/main.lua")

  print("⬇️ Updating server files...")
  os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/experiment/server/main.lua /experiment/server/main.lua")
  os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/experiment/server/registry.lua /experiment/server/registry.lua")
  os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/experiment/server/dispatcher.lua /experiment/server/dispatcher.lua")
  os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/experiment/server/ui.lua /experiment/server/ui.lua")
  os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/experiment/server/network.lua /experiment/server/network.lua")
  os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/experiment/server/utils.lua /experiment/server/utils.lua")



  print("⬇️ Downloading persistent files...")
  ensureFile("/experiment/data/tasks.lua", "https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/experiment/data/tasks.lua")

  print("\n✅ Setup complete! Run your robot with: lua /experiment/robots/main.lua")
end

main()
