return {
  "obsidian-nvim/obsidian.nvim",
  version = "*", -- recommended, use latest release instead of latest commit
  lazy = true,
  legacy_commands = false,
  -- ft = "markdown",
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  event = {
    -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
    -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/**.md"
    "BufReadPre "
      .. vim.fn.expand("~")
      .. "/vaults/**.md",
    "BufNewFile " .. vim.fn.expand("~") .. "/vaults/**.md",
  },
  dependencies = {
    -- Required.
    "nvim-lua/plenary.nvim",

    -- see below for full list of optional dependencies 👇
    -- completion
    "saghen/blink.cmp",
    -- pickers
    "nvim-telescope/telescope.nvim",
    -- syntax highlighting
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    workspaces = {
      {
        name = "personal",
        path = "~/vaults/personal",
      },
      {
        name = "work",
        path = "~/vaults/work",
      },
      {
        name = "thesis",
        path = "~/vaults/thesis",
      },
    },
    -- Template configuration
    templates = {
      folder = "templates",
      date_format = "%Y-%m-%d",
      time_format = "%H:%M",
      substitutions = {
        year_month = function()
          return os.date("%Y-%m")
        end,
      },
    },

    -- Optional, completion of wiki links, local markdown links, and tags using nvim-cmp.
    completion = {
      -- Enables completion using blink.cmp
      blink = true,
      -- Trigger completion at 2 chars.
      min_chars = 2,
    },

    -- Sets how you follow URLs
    ---@param url string
    follow_url_func = function(url)
      vim.ui.open(url)
      -- vim.ui.open(url, { cmd = { "firefox" } })
    end,
    -- see below for full list of options 👇
    -- Either 'wiki' or 'markdown'.
    preferred_link_style = "markdown",
    callbacks = {
      enter_note = function(_, note)
        vim.keymap.set("n", "<leader>oh", "<cmd>Obsidian toggle_checkbox<cr>", {
          buffer = note.bufnr,
          desc = "c[H]eckbox",
        })
        vim.keymap.set("n", "<leader>oo", "<cmd>Obsidian open<CR>", {
          buffer = note.bufnr,
          desc = "[O]pen",
        })
        vim.keymap.set("n", "<leader>on", "<cmd>Obsidian new<CR>", {
          buffer = note.bufnr,
          desc = "[N]ew",
        })
        vim.keymap.set("n", "<leader>os", "<cmd>Obsidian quick_switch<CR>", {
          buffer = note.bufnr,
          desc = "[S]witch notes",
        })
        vim.keymap.set("n", "<leader>ob", "<cmd>Obsidian backlinks<CR>", {
          buffer = note.bufnr,
          desc = "[B]acklinks to current",
        })
        vim.keymap.set("n", "<leader>ot", "<cmd>Obsidian tags<CR>", {
          buffer = note.bufnr,
          desc = "[T]ags",
        })
        vim.keymap.set("n", "<leader>ol", "<cmd>Obsidian links<CR>", {
          buffer = note.bufnr,
          desc = "[L]inks",
        })
        vim.keymap.set("n", "<leader>ox", "<cmd>Obsidian extract_note<CR>", {
          buffer = note.bufnr,
          desc = "E[X]tract",
        })
        vim.keymap.set("n", "<leader>ow", "<cmd>Obsidian workspace<CR>", {
          buffer = note.bufnr,
          desc = "[W]orkspace switch",
        })
        vim.keymap.set("n", "<leader>oi", "<cmd>Obsidian paste_img<CR>", {
          buffer = note.bufnr,
          desc = "[I]mg paste",
        })
        vim.keymap.set("n", "<leader>or", "<cmd>Obsidian rename<CR>", {
          buffer = note.bufnr,
          desc = "[R]ename",
        })
        vim.keymap.set("n", "<leader>oe", "<cmd>Obsidian template<CR>", {
          buffer = note.bufnr,
          desc = "Insert t[E]mplate",
        })
        vim.keymap.set("n", "<leader>om", "<cmd>Obsidian new_from_template<CR>", {
          buffer = note.bufnr,
          desc = "New from te[M]plate",
        })
        vim.keymap.set("n", "<leader>oc", "<cmd>Obsidian toc<CR>", {
          buffer = note.bufnr,
          desc = "TO[C]",
        })
        vim.keymap.set("n", "<leader>of", "<cmd>Obsidian search<CR>", {
          buffer = note.bufnr,
          desc = "[F]ind",
        })
      end,
    },
    ui = {
      enable = false, -- set to false to disable all additional syntax features
    },
  },
}
