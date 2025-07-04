local fs = require("filesystem")
local term = require("term")
local gpu = require("component").gpu

local style = require("apps/Style")
local APPS_DIR = "/apps/"

local function splash()
    gpu.setForeground(style.header)
    print(" __      __       .__                              ")
    print("/  \\    /  \\ ____ |  |   ____  ____   _____   ____ ")
    print("\\   \\/\\/   // __ \\|  | _/ ___\\/  _ \\ /     \\_/ __ \\")
    print(" \\        /\\  ___/|  |_\\  \\__(  <_> )  Y Y  \\  ___/")
    print("  \\__/\\  /  \\___  >____/\\___  >____/|__|_|  /\\___  >")
    print("       \\/       \\/          \\/            \\/     \\/ ")
    print()

    local emoji = style.emojis[math.random(#style.emojis)]

    print("+--------------------------------------+")
    print("|                                      |")
    print("|   WELCOME TO THE GTNH CONTROLLER " .. emoji .. "  |")
    print("|                                      |")
    print("+--------------------------------------+")

    -- Random sparkle line
    local sparkle = style.sparkleStyles[math.random(#style.sparkleStyles)]
    gpu.setForeground(style.highlight)
    print(sparkle)

    -- 💖 Run the helper — no more nil!
    style.printSignature()

    gpu.setForeground(style.text)
end



local function progressBar(message, total)
    io.write(message .. " [")
    for i = 1, total do
        io.write("=")
        os.sleep(0.03)
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

    splash() -- draws header, sparkle, cat, fortune

    -- 👉 Do NOT call term.clear() again! Just print status + menu after splash.

    gpu.setForeground(style.header)
    print("\n+-------------- STATUS ---------------+")
    gpu.setForeground(style.highlight)
    print("♥ Power: [TODO]")
    print("♥ Alerts: [TODO]")
    print("♥ Notifications: [TODO]")
    gpu.setForeground(style.header)
    print("+-------------------------------------+\n")

    gpu.setForeground(style.header)
    print("+-------------- PROGRAMS -------------+")
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
    gpu.setForeground(style.header)
    print("+-------------------------------------+")

    print()
    gpu.setForeground(style.highlight)
    io.write("Select program number: ")
    gpu.setForeground(style.text)
    local choice = tonumber(term.read())

    progressBar("Launching", 10)

    if choice == #apps + 1 then
        term.clear()
        gpu.setForeground(style.header)
        print("+--------------------------------------+")
        print("|                                      |")
        print("|   Thank you for using GTNH Control   |")
        print("|          Have a pastel day! ✨        |")
        print("|                                      |")
        print("+--------------------------------------+")
        gpu.setForeground(style.highlight)
        local sparkle = style.sparkleStyles[math.random(#style.sparkleStyles)]
        print(sparkle)
        -- Add signature at exit too, if you like:
        style.printSignature()
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

main()
