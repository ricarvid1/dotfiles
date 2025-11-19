return {
  "nvim-telescope/telescope.nvim",
  tag = "v0.1.9",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-tree/nvim-web-devicons",
    "folke/todo-comments.nvim",
    "nvim-telescope/telescope-ui-select.nvim",
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    telescope.setup({
      defaults = {
        path_display = { "smart" },
        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous, -- move to prev result
            ["<C-j>"] = actions.move_selection_next, -- move to next result
            -- ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
          },
        },
      },
      extensions = {
        ["ui-select"] = {
          require("telescope.themes").get_dropdown(),
        },
      },
    })

    telescope.load_extension("fzf")
    telescope.load_extension("ui-select")

    -- set keymaps
    local keymap = vim.keymap -- for conciseness

    -- See `:help telescope.builtin`
    local builtin = require("telescope.builtin")
    keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find Help" })
    keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "Find Keymaps" })
    keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
    keymap.set("n", "<leader>fl", builtin.builtin, { desc = "Find Select Telescope" })
    keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "Find current Word" })
    keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Find by Grep" })
    keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "Find Diagnostics" })
    keymap.set("n", "<leader>fr", builtin.resume, { desc = "Find Resume" })
    keymap.set("n", "<leader>f.", builtin.oldfiles, { desc = 'Find Recent Files ("." for repeat)' })
    keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })
    keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "Find existing buffers" })

    -- Slightly advanced example of overriding default behavior and theme
    keymap.set("n", "<leader>/", function()
      -- You can pass additional configuration to telescope to change theme, layout, etc.
      builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
        winblend = 10,
        previewer = false,
      }))
    end, { desc = "Fuzzily search in current buffer" })

    -- Shortcut for searching your neovim configuration files
    keymap.set("n", "<leader>fn", function()
      builtin.find_files({ cwd = vim.fn.stdpath("config") })
    end, { desc = "Find Neovim files" })
  end,
}
