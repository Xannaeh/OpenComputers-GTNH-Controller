-- /data/tasks.lua  (return a normal Lua table!)
return {
  tasks = {
    {
      id          = "task_001",
      description = "Deliver item from A to B",
      jobType     = "courier",
      priority    = 1,
      parent      = false,      -- nil/false is fine
      subtasks    = {},
      deleted     = false
    },
    {
      id          = "task_002",
      description = "Craft advanced circuit",
      jobType     = "crafter",
      priority    = 2,
      parent      = false,
      subtasks    = { "task_003", "task_004" },
      deleted     = false
    },
    {
      id          = "task_003",
      description = "Fetch copper wire",
      jobType     = "courier",
      priority    = 1,
      parent      = "task_002",
      subtasks    = {},
      deleted     = false
    }
  }
}
