# 📚 Project Guidelines — OpenComputers GTNH Controller

This document defines the **rules and principles** for building this OpenComputers robot & server system for GregTech New Horizons.

---

## 🚀 Objective

Build a **modular, reusable, SOLID-structured Lua system** for robots & server orchestration, with clear separation of responsibilities.  
The code must be **well organized, easy to maintain, portable**, and fully commented.

---

## ✅ 📁 Project Folder Structure

```

/OpenComputers-GTNH-Controller/
├── experiment/
│   ├── robots/
│   │   ├── agent.lua          # Core RobotAgent "class"
│   │   ├── job.lua            # Job base class (interface)
│   │   ├── jobs/
│   │   │   ├── courier.lua    # Courier Job class
│   │   │   ├── farmer.lua     # Farmer Job class
│   │   │   ├── ...
│   │   ├── pathfinder.lua     # Pathfinding module
│   │   ├── network.lua        # Networking helper
│   │   ├── utils.lua          # Shared helpers (logging, config)
│   ├── server/
│   │   ├── main.lua           # Main Server App
│   │   ├── registry.lua       # Robot/Task Registry class
│   │   ├── dispatcher.lua     # Task Dispatcher class
│   │   ├── ui.lua             # UI class
│   │   ├── network.lua        # Server-side Networking helper
│   │   ├── utils.lua          # Shared helpers (logging, config)
├── README.md
├── .gitignore

```

**🔒 Note:**
- This folder layout must be respected at all times.
- No mixing server and robot logic in the same file.
- Each module’s responsibility is clear from its name.

---

## ✅ Coding Principles

1️⃣ **SOLID**
- **S**ingle Responsibility: Each class/module does exactly ONE job.
- **O**pen/Closed: Extend functionality by adding new files, never changing stable code.
- **L**iskov Substitution: Any new Job must fully respect the Job interface.
- **I**nterface Segregation: Modules must not depend on functionality they don’t use.
- **D**ependency Inversion: High-level code (RobotAgent) depends on abstractions (Job base), not concrete implementations.

---

2️⃣ **Modular & Reusable**
- Every robot job is a separate file/class.
- Shared logic goes in helpers/util modules.
- No duplicated logic — reuse common routines.

---

3️⃣ **Design Patterns**
- **Strategy:** Jobs are interchangeable behaviors.
- **Factory:** Create Jobs dynamically based on user input.
- **Observer:** Robots report status changes to server.
- **Singleton:** Registries keep single source of truth.
- **Facade:** UI module hides server complexity.

---

4️⃣ **Code Organization**
- Always split concerns:
    - Agent logic
    - Jobs
    - Network helpers
    - Pathfinding
    - Server modules
- Each in its own file or folder.

---

5️⃣ **Documentation**
- Each file has:
    - A clear header comment with its purpose.
    - Comments for each method explaining:
        - What it does
        - Expected input/output
        - Edge cases if needed

---

6️⃣ **Naming**
- Descriptive, consistent names:
    - Classes use `CamelCase`
    - Methods & variables use `snake_case`
    - Filenames match the class/module

---

7️⃣ **Version Control**
- Every new feature/step is committed:
    - `git add`
    - `git commit -m "Clear, descriptive message"`
    - `git push`
- Use `wget` to download new files/scripts step by step.

---

8️⃣ **Updates**
- Robots should pull latest scripts from Git when needed.
- Keep code easily updatable without redeploying hardware.

---

9️⃣ **Testing**
- New modules must be tested in isolation first.
- Start simple, verify one job end-to-end, then expand.

---

## ✅ Do Not Forget

- Keep the code **simple and readable**.
- Favor clear Lua idioms.
- Always prefer small files over big files.
- If in doubt, split it!

---

**Owner:** Xannaeh  
