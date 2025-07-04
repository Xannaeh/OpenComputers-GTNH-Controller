local fs = require("filesystem")
local term = require("term")

local APPS_DIR = "/apps/"

local function listApps()
    local apps = {}
    for app in fs.list(APPS_DIR) do
        local path = APPS_DIR .. app
        if fs.isDirectory(path) then
            table.insert(apps, app:sub(1, -2)) -- Remove trailing slash
        end
    end
    return apps
end

local function showMenu(apps)
    print("Available Apps:")
    for i, app in ipairs(apps) do
        print(i..". "..app)
    end
    print("Enter number to launch:")

    local choice = tonumber(term.read())
    if choice and apps[choice] then
        local appPath = APPS_DIR .. apps[choice] .. "/" .. apps[choice] .. ".lua"
        local app = loadfile(appPath)
        if app then
            app()
        else
            print("Failed to load: "..appPath)
        end
    else
        print("Invalid choice.")
    end
end

local function main()
    local apps = listApps()
    if #apps == 0 then
        print("No apps found.")
        return
    end
    showMenu(apps)
end

main()
