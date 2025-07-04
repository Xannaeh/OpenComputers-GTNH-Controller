local fs = require("filesystem")
local term = require("term")
local gpu = require("component").gpu

local style = require("apps/Style")

local APPS_DIR = "/apps/"

local function getScreenWidth()
    local w, _ = gpu.getResolution()
    return w
end

local function center(text)
    local w = getScreenWidth()
    local x = math.floor((w - #text) / 2)
    gpu.set((x > 0 and x or 1), select(2, term.getCursor()), text)
end

local function sparkleLine()
    local sparkles = {"*", "+", "✦", "✧", "✩"}
    local w = getScreenWidth()
    local line = ""
    for i = 1, w do
        line = line .. sparkles[math.random(1, #sparkles)]
    end
    gpu.setForeground(style.highlight)
    center(line)
end

local function splash()
    gpu.setForeground(style.header)
    center(" __      __       .__                              ")
    center("/  \\    /  \\ ____ |  |   ____  ____   _____   ____ ")
    center("\\   \\/\\/   // __ \\|  | _/ ___\\/  _ \\ /     \\_/ __ \\")
    center(" \\        /\\  ___/|  |_\\  \\__(  <_> )  Y Y  \\  ___/")
    center("  \\__/\\  /  \\___  >____/\\___  >____/|__|_|  /\\___  >")
    center("       \\/       \\/          \\/            \\/     \\/ ")
    print()
    gpu.setForeground(style.header)
    center("+--------------------------------------+")
    center("|                                      |")
    center("|   WELCOME TO THE GTNH CONTROLLER ✨  |")
    center("|                                      |")
    center("+--------------------------------------+")
    gpu.setForeground(style.text)
    sparkleLine()
    os.sleep(0.5)
end

local function progressBar(message, total)
    io.write(message .. " [")
    for i = 1, total do
        io.write("=")
        os.sleep(0.05)
    end
    print("]")
end

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

    splash()

    gpu.setForeground(style.header)
    center("+-------------- STATUS ---------------+")
    gpu.setForeground(style.highlight)
    center("♥ Power: [TODO]")
    center("♥ Alerts: [TODO]")
    center("♥ Notifications: [TODO]")
    gpu.setForeground(style.header)
    center("+-------------------------------------+\n")

    gpu.setForeground(style.header)
    center("+-------------- PROGRAMS -------------+")
    for i, app in ipairs(apps) do
        gpu.setForeground(style.highlight)
        center(i .. ". " .. app)
    end
    gpu.setForeground(style.highlight)
    center((#apps + 1) .. ". Exit")
    gpu.setForeground(style.header)
    center("+-------------------------------------+")

    print()
    gpu.setForeground(style.highlight)
    io.write("Select program number: ")
    gpu.setForeground(style.text)
    local choice = tonumber(term.read())

    progressBar("Launching", 10)

    if choice == #apps + 1 then
        term.clear()
        gpu.setForeground(style.header)
        center("+--------------------------------------+")
        center("|                                      |")
        center("|   Thank you for using GTNH Control   |")
        center("|          Have a great day! ✨        |")
        center("|                                      |")
        center("+--------------------------------------+")
        gpu.setForeground(style.text)
        sparkleLine()
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

main()
