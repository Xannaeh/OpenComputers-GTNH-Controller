local shell = require("shell")
local fs = require("filesystem")

-- Configuration
local REPO_URL = "https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/"
local APPS_DIR = "/apps/"
local BOOT_FILE = "boot.lua"

local function update()
    print("Updating system from GitHub...")
    -- Example: Pull launcher.lua (extend to pull all)
    os.execute("wget -f "..REPO_URL..BOOT_FILE.." /"..BOOT_FILE)
    -- You can expand to pull all folders if you wish
end

local function runLauncher()
    local launcher = loadfile(APPS_DIR.."launcher/launcher.lua")
    if launcher then
        launcher()
    else
        print("Launcher not found!")
    end
end

-- Main
update()
runLauncher()
