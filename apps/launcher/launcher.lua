local function showMenu(apps)
    term.clear()
    term.setCursor(1, 1)

    splash()

    gpu.setForeground(style.header)
    print("\n+-------------- STATUS ---------------+")

    -- ♥ Power
    gpu.setForeground(style.highlight)
    io.write("♥ ")
    gpu.setForeground(style.text)
    print("Power: [TODO]")

    -- ♥ Alerts
    gpu.setForeground(style.highlight)
    io.write("♥ ")
    gpu.setForeground(style.text)
    print("Alerts: [TODO]")

    -- ♥ Notifications
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
