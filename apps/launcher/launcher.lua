local fs = require("filesystem")
local term = require("term")

local APPS_DIR = "/apps/"

-- 🌸 Pastel theme: best ANSI combo
local pink = "\27[35m"
local blue = "\27[36m"
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

    print(pink .. "=== ✨ MAIN MENU ✨ ===\n" .. white)

    print(pink .. "=== STATUS ===")
    print("♥ Power: [TODO]")
    print("♥ Alerts: [TODO]")
    print("♥ Notifications: [TODO]\n" .. white)

    print(pink .. "=== Programs ===" .. white)
    for i, app in ipairs(apps) do
        print(pink .. i .. ". " .. app .. white)
    end
    print(pink .. (#apps + 1) .. ". Exit" .. white)

    print("\n" .. blue .. "Select program number:" .. white)
    local choice = tonumber(term.read())

    if choice == #apps + 1 then
        print("\nGoodbye! Have a lovely day! (｡♥‿♥｡)")
        os.exit()
    elseif choice and apps[choice] then
        local appPath = APPS_DIR .. apps[choice] .. "/" .. apps[choice] .. ".lua"
        local app = loadfile(appPath)
        if app then
            term.clear()
            term.setCursor(1, 1)
            print(pink .. "=== Running " .. apps[choice] .. " ===" .. white)
            app()
        else
            print(blue .. "Error: Failed to load " .. appPath .. white)
        end
    else
        print(blue .. "Invalid choice. Try again." .. white)
    end

    print("\n" .. blue .. "Press Enter to return to the Main Menu..." .. white)
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
