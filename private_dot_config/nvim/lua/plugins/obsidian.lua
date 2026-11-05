local function get_vaults()
  local vaults = {}
  -- Expand the home directory path
  local path = vim.fn.expand("~/vaults")

  -- globpath returns a string of paths separated by newlines
  -- The '1' as the third argument tells Neovim to return a list (table) instead
  local folders = vim.fn.globpath(path, "*", 0, 1)

  for _, folder_path in ipairs(folders) do
    -- Check if it's actually a directory (and not a loose file)
    if vim.fn.isdirectory(folder_path) == 1 then
      -- Get the folder name (the last part of the path)
      local folder_name = vim.fn.fnamemodify(folder_path, ":t")

      table.insert(vaults, {
        name = folder_name,
        -- We use the original path or re-format with ~ for consistency
        path = "~/vaults/" .. folder_name,
      })
    end
  end
  return vaults
end

return {
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    lazy = true,
    -- ft = "markdown",
    -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
    event = {
      -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
      -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/**.md"
      "BufReadPre " .. vim.fn.expand("~") .. "/vaults/**.md",
      "BufNewFile " .. vim.fn.expand("~") .. "/vaults/**.md",
    },
    ---@module 'obsidian'
    ---@type obsidian.config
    opts = {
      legacy_commands = false,
      -- Workspace
      workspaces = get_vaults(),
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

      -- see below for full list of options 👇
      -- Either 'wiki' or 'markdown'.
      link = {
        style = "markdown",
      },

      checkbox = {
        order = { " ", "x" },
      },

      attachments = {
        confirm_img_paste = false,
      },

      callbacks = {
        enter_note = function(note)
          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = note.bufnr, desc = desc })
          end

          -- Navigation and search
          map("n", "<leader>os", "<cmd>Obsidian quick_switch<CR>", "Switch notes")
          map("n", "<leader>of", "<cmd>Obsidian search<CR>", "Find notes")
          map("n", "<leader>og", "<cmd>Obsidian open<CR>", "Open in Obsidian")
          map("n", "<leader>ow", "<cmd>Obsidian workspace<CR>", "Workspace switch")

          -- Note creation and daily notes
          map("n", "<leader>on", "<cmd>Obsidian new<CR>", "New note")
          map("n", "<leader>od", "<cmd>Obsidian today<CR>", "Daily note (today)")
          map("n", "<leader>oe", "<cmd>Obsidian template<CR>", "Insert template")
          map("n", "<leader>om", "<cmd>Obsidian new_from_template<CR>", "New from template")

          -- Tags and links
          map("n", "<leader>ot", "<cmd>Obsidian tags<CR>", "Tags")
          map("n", "<leader>ol", "<cmd>Obsidian links<CR>", "Links in current note")
          map("v", "<leader>ol", "<cmd>Obsidian link<CR>", "Link selection")
          map("v", "<leader>ox", "<cmd>Obsidian extract_note<CR>", "Extract to note")

          -- Attachments
          map("n", "<leader>oi", "<cmd>Obsidian paste_img<CR>", "Paste image")
        end,
      },
      ui = {
        enable = false, -- set to false to disable all additional syntax features
      },
    },
  },
}
