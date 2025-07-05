return {
  tasks = {
    {
      id = "task_001",
      description = "Deliver iron",
      jobType = "courier",
      priority    = 1,
      parent      = false,
      subtasks    = {},
      deleted     = false,
      params = {
        fromName = "BaseInputChest",
        toName = "BaseOutputChest",
        count = 10
      },
      assignedRobot = nil,  -- ✅ leave this NIL for auto-matching!
      deleted = false
    }
  }
}
