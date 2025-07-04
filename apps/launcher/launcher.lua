local fs = require("filesystem")
local term = require("term")

local APPS_DIR = "/apps/"

local pink = "\27[35m"
local white = "\27[37m"

local function listApps()
    local apps = {}
    for app in fs.list(APPS_DIR) do
        local path = APPS_DIR .. app
        if fs.isDirectory(path) then
            local name = app:sub(1, -2)
            if name ~= "launcher" then
                table.insert(apps, name)
            end
        end
    end
    table.sort(apps)
    return apps
end

local function showMenu(apps)
    term.clear()
    term.setCursor(1, 1)

    print(pink .. "=== ✨ MAIN MENU ✨ ===" .. white .. "\n")
    print(pink .. "=== STATUS ===" .. white)
    print(pink .. "♥ Power: [TODO]")
    print("♥ Alerts: [TODO]")
    print("♥ Notifications: [TODO]\n")

    print(pink .. "=== Programs ===" .. white)
    for i, app in ipairs(apps) do
        print(pink .. i .. ". " .. app .. white)
    end
    print(pink .. (#apps + 1) .. ". Exit" .. white)

    print("\nSelect program number:")
    local choice = tonumber(term.read())

    if choice == #apps + 1 then
        print("\nGoodbye! Have a lovely day! (｡♥‿♥｡)")
        return false
    elseif choice and apps[choice] then
        local appPath = APPS_DIR .. apps[choice] .. "/" .. apps[choice] .. ".lua"
        local app = loadfile(appPath)
        if app then
            term.clear()
            term.setCursor(1, 1)
            print(pink .. "=== Running " .. apps[choice] .. " ===" .. white)
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
