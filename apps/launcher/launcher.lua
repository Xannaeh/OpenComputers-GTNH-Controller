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
    return apps
end

local function showMenu(apps)
    term.clear()
    term.setCursor(1, 1)
    print("Available Apps:")
    for i, app in ipairs(apps) do
        print(i .. ". " .. app)
    end
    print(#apps + 1 .. ". Exit")
    print("Enter number to launch:")

    local choice = tonumber(term.read())
    if choice == #apps + 1 then
        print("Goodbye!")
        return false
    elseif choice and apps[choice] then
        local appPath = APPS_DIR .. apps[choice] .. "/" .. apps[choice] .. ".lua"
        local app = loadfile(appPath)
        if app then
            app()
        else
            print("Failed to load: " .. appPath)
        end
    else
        print("Invalid choice.")
    end
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
