local fs = require("filesystem")
local term = require("term")

local APPS_DIR = "/apps/"

local function listApps()
    local apps = {}
    for app in fs.list(APPS_DIR) do
        local path = APPS_DIR .. app
        if fs.isDirectory(path) then
            table.insert(apps, app:sub(1, -2))
        end
    end
    table.sort(apps)
    return apps
end

local function showMenu(apps)
    term.clear()
    term.setCursor(1, 1)

    print("=== MAIN MENU ===\n")
    print("=== STATUS ===")
    print("- Power: [TODO]")
    print("- Alerts: [TODO]")
    print("- Notifications: [TODO]\n")

    print("=== Programs ===")
    for i, app in ipairs(apps) do
        print(i .. ". " .. app)
    end
    print(#apps + 1 .. ". Exit")

    print("\nSelect program number:")
    local choice = tonumber(term.read())

    if choice == #apps + 1 then
        print("\nExiting launcher. Goodbye!")
        return false
    elseif choice and apps[choice] then
        local appPath = APPS_DIR .. apps[choice] .. "/" .. apps[choice] .. ".lua"
        local app = loadfile(appPath)
        if app then
            term.clear()
            term.setCursor(1, 1)
            print("=== Running " .. apps[choice] .. " ===\n")
            app()
        else
            print("Error: Failed to load " .. appPath)
        end
    else
        print("Invalid choice. Try again.")
    end

    print("\nPress Enter to return to the Main Menu...")
    term.read()
    return true
end

local function main()
    while true do
        local apps = listApps()
        if #apps == 0 then
            print("No apps found.")
            break
        end
        local keepGoing = showMenu(apps)
        if not keepGoing then break end
    end
end

return main()
