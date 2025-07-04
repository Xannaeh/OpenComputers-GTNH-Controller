local fs = require("filesystem")

local function ensureDir(path)
    if not fs.exists(path) then
        os.execute("mkdir " .. path)
    end
end

local function ensureFile(path, url)
    if not fs.exists(path) then
        print("Downloading " .. path)
        os.execute("wget -f " .. url .. " " .. path)
    else
        print("File exists: " .. path)
    end
end

local function main()
    print("Creating folders...")
    ensureDir("/apps")
    ensureDir("/apps/launcher")
    ensureDir("/apps/fleet")
    ensureDir("/apps/fleet/robot_agent")
    ensureDir("/apps/fleet/jobs")
    ensureDir("/apps/power")
    ensureDir("/apps/net")
    ensureDir("/data")

    print("Downloading app files...")
    os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/boot.lua /boot.lua")
    os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/apps/launcher/launcher.lua /apps/launcher/launcher.lua")
    os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/apps/fleet/fleet.lua /apps/fleet/fleet.lua")
    os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/apps/fleet/Job.lua /apps/fleet/Job.lua")
    os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/apps/fleet/RobotRegistry.lua /apps/fleet/RobotRegistry.lua")
    os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/apps/fleet/TaskRegistry.lua /apps/fleet/TaskRegistry.lua")
    os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/apps/fleet/robot_agent/robot_agent.lua /apps/fleet/robot_agent/robot_agent.lua")
    os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/apps/fleet/jobs/courier_job.lua /apps/fleet/jobs/courier_job.lua")
    os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/apps/power/power.lua /apps/power/power.lua")
    os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/apps/net/net.lua /apps/net/net.lua")
    os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/apps/DataHelper.lua /apps/DataHelper.lua")
    os.execute("wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/apps/Style.lua /apps/Style.lua")

    print("Ensuring data files...")
    ensureFile("/data/config.json", "https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/data/config.json")
    ensureFile("/data/recipes.json", "https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/data/recipes.json")
    ensureFile("/data/machines.json", "https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/data/machines.json")
    ensureFile("/data/robots.json", "https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/data/robots.json")
    ensureFile("/data/tasks.json", "https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/data/tasks.json")

    print("\n✅ Setup done! Now run: boot.lua")
end

main()
