return {
  "olimorris/persisted.nvim",
  event = "BufReadPre", -- this will only start session saving when an actual file was opened
  opts = {
    autosave = true,
  },
}
