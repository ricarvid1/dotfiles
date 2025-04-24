return {
  "epwalsh/obsidian.nvim",
  version = "*", -- recommended, use latest release instead of latest commit
  lazy = true,
  ft = "markdown",
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
    "hrsh7th/nvim-cmp",
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
    -- Specify how to handle attachments.
    attachments = {
      -- The default folder to place images in via `:ObsidianPasteImg`.
      -- If this is a relative path it will be interpreted as relative to the vault root.
      -- You can always override this per image by passing a full path to the command instead of just a filename.
      img_folder = "assets/imgs", -- This is the default
      -- A function that determines the text to insert in the note when pasting an image.
      -- It takes two arguments, the `obsidian.Client` and an `obsidian.Path` to the image file.
      -- This is the default implementation.
      ---@param client obsidian.Client
      ---@param path obsidian.Path the absolute path to the image file
      ---@return string
      img_text_func = function(client, path)
        path = client:vault_relative_path(path) or path
        return string.format("![%s](../%s)", path.name, path)
      end,
    },
    -- Optional, by default when you use `:ObsidianFollowLink` on a link to an external
    -- URL it will be ignored but you can customize this behavior here.
    ---@param url string
    follow_url_func = function(url)
      -- Open the URL in the default web browser.
      -- vim.fn.jobstart({ "open", url }) -- Mac OS
      vim.fn.jobstart({ "xdg-open", url }) -- linux
      -- vim.cmd(':silent exec "!start ' .. url .. '"') -- Windows
    end, -- see below for full list of options 👇
    -- Either 'wiki' or 'markdown'.
    preferred_link_style = "markdown",
    -- Optional, customize how markdown links are formatted.
    markdown_link_func = function(opts)
      local util = require("obsidian.util")
      local anchor = ""
      local header = ""
      if opts.anchor then
        anchor = opts.anchor.anchor
        header = util.format_anchor_label(opts.anchor)
      elseif opts.block then
        anchor = "#" .. opts.block.id
        header = "#" .. opts.block.id
      end

      local path = util.urlencode(opts.path, { keep_path_sep = true })
      return string.format("[%s%s](../%s%s)", opts.label, header, path, anchor)
    end,
    -- Optional, configure key mappings. These are the defaults. If you don't want to set any keymappings this
    -- way then set 'mappings = {}'.
    mappings = {
      -- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
      ["gf"] = {
        action = function()
          return require("obsidian").util.gf_passthrough()
        end,
        opts = { noremap = false, expr = true, buffer = true },
      },
      -- Toggle check-boxes.
      ["<leader>oh"] = {
        action = "<cmd>ObsidianToggleCheckbox<CR>",
        opts = { buffer = true, desc = "c[H]eckbox" },
      },

      ["<leader>oo"] = {
        action = "<cmd>ObsidianOpen<CR>",
        opts = { buffer = true, desc = "[O]pen" },
      },
      ["<leader>on"] = {
        action = "<cmd>ObsidianNew<CR>",
        opts = { buffer = true, desc = "[N]ew" },
      },
      ["<leader>os"] = {
        action = "<cmd>ObsidianQuickSwitch<CR>",
        opts = { buffer = true, desc = "[S]witch notes" },
      },
      ["<leader>ob"] = {
        action = "<cmd>ObsidianBacklinks<CR>",
        opts = { buffer = true, desc = "[B]acklinks to current" },
      },
      ["<leader>ot"] = {
        action = "<cmd>ObsidianTags<CR>",
        opts = { buffer = true, desc = "[T]ags" },
      },
      ["<leader>ol"] = {
        action = "<cmd>ObsidianLinks<CR>",
        opts = { buffer = true, desc = "[L]inks" },
      },
      ["<leader>ox"] = {
        action = "<cmd>ObsidianExtractNote<CR>",
        opts = { buffer = true, desc = "E[X]tract" },
      },
      ["<leader>ow"] = {
        action = "<cmd>ObsidianWorkspace<CR>",
        opts = { buffer = true, desc = "[W]orkspace switch" },
      },
      ["<leader>oi"] = {
        action = "<cmd>ObsidianPasteImg<CR>",
        opts = { buffer = true, desc = "[I]mg paste" },
      },
      ["<leader>or"] = {
        action = "<cmd>ObsidianRename<CR>",
        opts = { buffer = true, desc = "[R]ename" },
      },
      ["<leader>oe"] = {
        action = "<cmd>ObsidianTemplate<CR>",
        opts = { buffer = true, desc = "Insert t[E]mplate" },
      },
      ["<leader>om"] = {
        action = "<cmd>ObsidianNewFromTemplate<CR>",
        opts = { buffer = true, desc = "New from te[M]plate" },
      },
      ["<leader>oc"] = {
        action = "<cmd>ObsidianTOC<CR>",
        opts = { buffer = true, desc = "TO[C]" },
      },
      ["<leader>of"] = {
        action = "<cmd>ObsidianSearch<CR>",
        opts = { buffer = true, desc = "[F]ind" },
      },
    },
    -- Optional, configure additional syntax highlighting / extmarks.
    -- This requires you have `conceallevel` set to 1 or 2. See `:help conceallevel` for more details.
    -- ui = {
    --   enable = false,
    -- },
  },
}
