return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 500
  end,
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
  config = function()
    local wk = require("which-key")
    wk.add({
      { "<leader>f", group = "Find" }, -- group
      { "<leader>e", group = "Explorer" },
      { "<leader>x", group = "Errors" },
      { "<leader>s", group = "Split" },
      { "<leader>t", group = "Tab" },
      { "<leader>w", group = "Workspace" },
      { "<leader>r", group = "Run" },
      { "<leader>g", group = "LSP" },
      { "<leader>h", group = "Hunk" },
      { "<leader>m", group = "Marketplace" },
      { "<leader>o", group = "Obsidian" },
    })
  end,
}
