local fs = require("filesystem")

local function nuke(path)
    if fs.exists(path) then
        fs.remove(path)
        print("Deleted: " .. path)
    else
        print("Already gone: " .. path)
    end
end

local function main()
    print("\n⚠️  WARNING: RESETTING ALL DATA ⚠️\n")
    nuke("/data/robots.json")
    nuke("/data/tasks.json")
    nuke("/data/machines.json")
    nuke("/data/recipes.json")
    nuke("/data/config.json")

    print("\n✅ Data nuked! Re-run setup.lua to restore fresh config files.\n")
end

main()
