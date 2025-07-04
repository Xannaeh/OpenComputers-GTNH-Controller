-- return a Lua table so dofile() gives it directly
return {
  robots = {
    {
      id = "robot_001",
      jobType = "courier",
      status = "idle",
      active = true,
      tasks = {"task_001"},
      x = 0,
      y = 64,
      z = 0
    }
  }
}
