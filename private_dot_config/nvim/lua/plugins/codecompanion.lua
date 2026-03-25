return {
  {
    "olimorris/codecompanion.nvim",
    version = "^18.0.0",
    opts = {
      interactions = {
        chat = {
          -- You can specify an adapter by name and model (both ACP and HTTP)
          adapter = "gemini",
          model = "gemini-3-flash-preview",
        },
        inline = {
          adapter = "gemini",
          model = "gemini-3-flash-preview",
        },
        cmd = {
          adapter = "gemini",
        },
        background = {
          adapter = "gemini",
        },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function(_, opts)
      -- opts config
      require("codecompanion").setup(opts)
      -- Configuration
      vim.keymap.set({ "n", "v" }, "<leader>ca", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
      vim.keymap.set({ "n", "v" }, "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
      vim.keymap.set("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })

      -- Expand 'cc' into 'CodeCompanion' in the command line
      vim.cmd([[cab cc CodeCompanion]])
    end,
  },
}
