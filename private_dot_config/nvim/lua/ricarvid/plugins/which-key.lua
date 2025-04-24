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
      { "<leader>f", group = "[F]ind" }, -- group
      { "<leader>e", group = "[E]xplorer" },
      { "<leader>x", group = "[X]Errors" },
      { "<leader>s", group = "[S]plit" },
      { "<leader>t", group = "[T]ab" },
      { "<leader>w", group = "[W]orkspace" },
      { "<leader>r", group = "[R]un" },
      { "<leader>g", group = "[G]LSP" },
      { "<leader>h", group = "[H]unk" },
      { "<leader>m", group = "[M]arketplace" },
      { "<leader>o", group = "[O]bsidian" },
    })
  end,
}
