-- return a Lua table so dofile() gives it directly
return {
  robots = {
    {
      id      = "robot_001",
      jobType = "courier",
      status  = "idle",
      active  = true,
      tasks = {}
    },
    {
      id      = "robot_002",
      jobType = "janitor",
      status  = "idle",
      active  = false,
      tasks = {}
    }
  }
}
