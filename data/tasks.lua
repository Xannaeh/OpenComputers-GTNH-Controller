return {
  tasks = {
    {
      id = "task_001",
      description = "Deliver iron",
      jobType = "courier",
      priority    = 1,
      parent      = false,      -- nil/false is fine
      subtasks    = {},
      deleted     = false,
      params = {
        fromName = "BaseInputChest",
        toName = "BaseOutputChest",
        count = 10
      },
      assignedRobot = "robot_001",
      deleted = false
    }
  }
}
