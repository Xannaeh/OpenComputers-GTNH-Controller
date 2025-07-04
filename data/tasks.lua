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
      deleted     = false,
      params = {
        fromName = "BaseInputChest",
        toName = "BaseOutputChest",
        count = 1
      }
    }
  }
}
