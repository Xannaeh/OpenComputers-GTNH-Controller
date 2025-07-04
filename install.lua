-- Create folders
mkdir /apps
mkdir /apps/launcher
mkdir /apps/fleet
mkdir /apps/power
mkdir /apps/net
mkdir /apps/robot_agent
mkdir /data

-- Download boot.lua
wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/boot.lua /boot.lua

-- Download launcher
wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/apps/launcher/launcher.lua /apps/launcher/launcher.lua

-- Download fleet files
wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/apps/fleet/fleet.lua /apps/fleet/fleet.lua
wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/apps/fleet/Job.lua /apps/fleet/Job.lua
wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/apps/fleet/Robot.lua /apps/fleet/Robot.lua

-- Download power manager
wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/apps/power/power.lua /apps/power/power.lua

-- Download net manager
wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/apps/net/net.lua /apps/net/net.lua

-- Download robot agent
wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/apps/robot_agent/robot_agent.lua /apps/robot_agent/robot_agent.lua

-- Download empty data files (optional)
wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/data/config.json /data/config.json
wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/data/recipes.json /data/recipes.json
wget -f https://raw.githubusercontent.com/Xannaeh/OpenComputers-GTNH-Controller/main/data/machines.json /data/machines.json

-- Done! Now run:
boot.lua
