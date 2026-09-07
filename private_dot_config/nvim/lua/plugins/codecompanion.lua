return {
  {
    "olimorris/codecompanion.nvim",
    version = "^19.0.0",
    opts = {
      adapters = {
        http = {
          gemini = function()
            return require("codecompanion.adapters").extend("gemini", {
              schema = {
                model = {
                  default = "gemini-3.6-flash",
                },
              },
            })
          end,
        },
      },
      interactions = {
        chat = {
          -- You can specify an adapter by name and model (both ACP and HTTP)
          adapter = "opencode",
        },
        inline = {
          adapter = "gemini",
        },
        cmd = {
          adapter = "gemini",
        },
        background = {
          adapter = "gemini",
        },
        cli = {
          agent = "opencode",
        },
      },
      display = {
        chat = {
          window = {
            width = 0.4,
          },
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
      vim.keymap.set({ "n", "v" }, "<leader>cg", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
      vim.keymap.set({ "n", "v" }, "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
      vim.keymap.set("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })

      -- Expand 'cc' into 'CodeCompanion' in the command line
      vim.cmd([[cab cc CodeCompanion]])
    end,
  },
}
