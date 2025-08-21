return {
  "olimorris/persisted.nvim",
  event = "BufReadPre", -- this will only start session saving when an actual file was opened
  config = function()
    vim.keymap.set("n", "<leader>wr", "<cmd>SessionToggle<cr>", { desc = "Restore session" })
  end,
}
