local fs = require("filesystem")
local term = require("term")
local gpu = require("component").gpu

local style = require("apps/Style")

local APPS_DIR = "/apps/"

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

    gpu.setForeground(style.header)
    print("=== ✨ MAIN MENU ✨ ===\n")

    gpu.setForeground(style.header)
    print("=== STATUS ===")
    gpu.setForeground(style.highlight)
    print("♥ ", style.text, "Power: [TODO]")
    print("♥ ", style.text, "Alerts: [TODO]")
    print("♥ ", style.text, "Notifications: [TODO]\n")

    gpu.setForeground(style.header)
    print("=== Programs ===")
    for i, app in ipairs(apps) do
        gpu.setForeground(style.highlight)
        io.write(i .. ". ")
        gpu.setForeground(style.text)
        print(app)
    end
    gpu.setForeground(style.highlight)
    io.write((#apps + 1) .. ". ")
    gpu.setForeground(style.text)
    print("Exit")

    print()
    gpu.setForeground(style.highlight)
    io.write("Select program number: ")
    gpu.setForeground(style.text)
    local choice = tonumber(term.read())

    if choice == #apps + 1 then
        gpu.setForeground(style.header)
        print("\nGoodbye! Have a lovely day!")
        gpu.setForeground(style.text)
        os.exit()
    elseif choice and apps[choice] then
        local appPath = APPS_DIR .. apps[choice] .. "/" .. apps[choice] .. ".lua"
        local app = loadfile(appPath)
        if app then
            term.clear()
            term.setCursor(1, 1)
            gpu.setForeground(style.header)
            print("=== Running " .. apps[choice] .. " ===")
            gpu.setForeground(style.text)
            app()
        else
            gpu.setForeground(style.highlight)
            print("Error: Failed to load " .. appPath)
            gpu.setForeground(style.text)
        end
    else
        gpu.setForeground(style.highlight)
        print("Invalid choice. Try again.")
        gpu.setForeground(style.text)
    end

    print()
    gpu.setForeground(style.highlight)
    io.write("Press Enter to return to the Main Menu...")
    gpu.setForeground(style.text)
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
