
# 🧩 OpenComputers GTNH Base Controller — Full Architecture Plan

## ✅ 1️⃣ Final Physical Architecture

### 🔵 Main Base Control Rack
- **Type:** 1 Server Rack
- **Inside:** Multiple Server Blades (each a virtual computer)
- **Screen:** 1 big Touchscreen Monitor wired to Blade #1
- **Wireless Card(s):** All blades have at least 1 wired or wireless card for inter-blade + robot comms.
- **Internet Card:** Only on Blade #1 for future external webpage/API.

### 🔵 External Nodes
- **Robots:** Mobile wireless agents (crafting, farming, transport)
- **Optional Peripheral Controllers:** Simple PCs in remote clusters if needed (e.g. big chemical plants far away). Many setups won’t need them if robots handle bridging.

---

## ✅ 2️⃣ Blade Breakdown

| Blade | Role | What Runs |
|-------|------|-----------|
| Blade 1 | Launcher + User Auth + Notifications + Emergency Shutdown | `/apps/launcher` + `/apps/notifications` + `/apps/emergency` |
| Blade 2 | Storage Manager | `/apps/storage` |
| Blade 3 | Crafting Manager | `/apps/crafting` |
| Blade 4 | Fleet Manager | `/apps/fleet` |
| Blade 5 | Power Manager | `/apps/power` |
| Blade 6 | Farm Manager | `/apps/farm` |
| Blade 7 | Optional: Analytics | `/apps/analytics` |
| Blade 8 | Optional: Security / Remote Terminals | `/apps/security` + `/apps/remote` |

➡️ You don’t have to max the rack out now — add more blades later.

---

## ✅ 3️⃣ Suggested Robot Fleet

| Robot Type | Purpose | Recommended Count | Hardware |
|------------|---------|-------------------|----------|
| Crafter Bots | Carry crafting jobs, feed machines, bridge wireless | 2–4 | Inventory Upgrade, Adapter Upgrade, Wireless Card |
| Farmer Bots | IC2 crop grid management | 1–2 per farm zone | Farming Tools, Wireless Card, Adapter Upgrade |
| Courier Bots | Transfer items between isolated areas (like a drone) | 1–2 | Inventory Upgrade, Wireless Card |
| Maintenance Bots | Refill fuel, replace electrodes, do maintenance jobs | Optional | Wireless Card, Adapter Upgrade |
| Scout Bots | Optional for GPS mapping or remote monitoring | Optional | GPS Upgrade if you run an OC GPS net |

➡️ Total recommended: ~5–10 robots for a big base. They don’t have to run all at once in early stages!

---

## ✅ 4️⃣ Final Folder Structure (Per Blade)

### 🔵 Blade 1: User Launcher & Core Control

```
/boot.lua
/apps/
  launcher/
    launcher.lua
    ui.lua
    dashboard.lua
    config.json
    users.json
  notifications/
    notifications.lua
    ui.lua
    log.json
  emergency/
    emergency.lua
/lib/
  net.lua
  serialization.lua
  ui_lib.lua
```

### 🔵 Blade 2: Storage Manager

```
/boot.lua
/apps/
  storage/
    storage.lua
    ui.lua
    config.json
    storage.json
    recipes.json
/lib/
  net.lua
  serialization.lua
```

### 🔵 Blade 3: Crafting Manager

```
/boot.lua
/apps/
  crafting/
    crafting.lua
    ui.lua
    Recipe.lua
    config.json
    recipes.json
    crafting_queue.json
/lib/
  net.lua
  serialization.lua
```

### 🔵 Blade 4: Fleet Manager

```
/boot.lua
/apps/
  fleet/
    fleet.lua
    ui.lua
    Job.lua
    Robot.lua
    config.json
    robots.json
    jobs.json
/lib/
  net.lua
  serialization.lua
```

### 🔵 Blade 5: Power Manager

```
/boot.lua
/apps/
  power/
    power.lua
    ui.lua
    PowerNode.lua
    config.json
    grid.json
/lib/
  net.lua
  serialization.lua
```

### 🔵 Blade 6: Farm Manager

```
/boot.lua
/apps/
  farm/
    farm.lua
    ui.lua
    Field.lua
    config.json
    crops.json
/lib/
net.lua
serialization.lua
```

### 🔵 Blade 7+ (Optional)

Same idea → self-contained apps. Each with:

- `main.lua`
- helper classes
- config/data
- local UI

---

## ✅ 5️⃣ Key Network Design

- All blades communicate over `net.lua` → standardizes messages (`send`, `receive`, `reply`).
- Robots run `robot_agent.lua` → connect to Fleet Manager wirelessly → register → pull jobs → report status.
- Launcher (Blade 1) shows snapshots:
    - Calls `/apps/power/power.lua` on Blade 5 for energy status.
    - Calls `/apps/notifications/notifications.lua` for latest logs.
    - Emergency shutdown calls broadcast to all blades to kill machines.

---

## ✅ 6️⃣ Example Future: Web API

- Add a `/apps/webapi/` to Blade 1.
- Uses `internet.lua` → push `/apps/power/grid.json`, `/apps/notifications/log.json`, `/apps/robots/robots.json` to your web server every X seconds.
- Real-time webpage → same snapshot you see in-game → fully integrated.

---

## ✅ 7️⃣ Final Physical Hardware

You need in Creative:

- 1× Server Rack
- ~6–8 Server Blades
- 1× Screen (size as big as you want)
- 1× Tier 3 Keyboard
- 1–2 Tier 3 Power Supplies to run the rack
- ~5–10 Robots with necessary upgrades
- Enough Wireless Routers or Switches for connections
- Adapter upgrades for each robot if they interact with blocks

---

## ✅ 8️⃣ Key Advantages

✔️ **Distributed:** each Blade runs its own Lua OS → no single Lua computer overloaded.  
✔️ **Portable:** each `/apps/{app}` is reusable on any OC computer.  
✔️ **Wireless:** robots link machine clusters → no cables.  
✔️ **Scalable:** add new blades when you add new base sections (e.g. Lab, Fusion Monitor).  
✔️ **Extensible:** push live data to your phone/website later!

---

## ✅ Git Commit Message Example

\`\`\`
git add docs/architecture_plan.md
git commit -m "Add full GTNH Base Controller architecture plan [docs]"
\`\`\`

