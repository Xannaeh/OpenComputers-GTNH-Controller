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
    for i = 1, 30 do
        gpu.setForeground(style.highlight)
        io.write(sparkles[math.random(1, #sparkles)])
        os.sleep(0.05)
    end
    print()
end

local function splash()
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
    print("\n+-------------- STATUS ---------------+")
    gpu.setForeground(style.highlight)
    io.write("♥ ")
    gpu.setForeground(style.text)
    print("Power: [TODO]")
    gpu.setForeground(style.highlight)
    io.write("♥ ")
    gpu.setForeground(style.text)
    print("Alerts: [TODO]")
    gpu.setForeground(style.highlight)
    io.write("♥ ")
    gpu.setForeground(style.text)
    print("Notifications: [TODO]")
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
        center("+--------------------------------------+")
        center("|                                      |")
        center("|   Thank you for using GTNH Control   |")
        center("|            Have a pastel day! ✨     |")
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

return main()
