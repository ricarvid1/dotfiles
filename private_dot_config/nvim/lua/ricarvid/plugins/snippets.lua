return {
  "L3MON4D3/LuaSnip",
  version = "v2.*",
  build = "make install_jsregexp", -- if you're on windows remove this line
  dependencies = {
    "rafamadriz/friendly-snippets",
  },
  opts = {
    -- Enable autotriggered snippets
    enable_autosnippets = true,
    -- Use Tab (or some other key if you prefer) to trigger visual selection
    cut_selection_keys = "<Tab>",
  },
  config = function(_, opts)
    local ls = require("luasnip")
    ls.setup(opts)

    -- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
    require("luasnip.loaders.from_vscode").lazy_load()
    require("luasnip.loaders.from_vscode").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })

    -- Load snippets from my custom luasnip folder
    local config_dir = vim.fn.stdpath("config")
    local snippet_path = config_dir .. "/lua/ricarvid/luasnippets/"
    require("luasnip.loaders.from_lua").lazy_load({ paths = { snippet_path } })

    vim.keymap.set({ "i" }, "<C-k>", function()
      ls.expand()
    end, { silent = true })
    vim.keymap.set({ "i", "s" }, "<C-l>", function()
      ls.jump(1)
    end, { silent = true })
    vim.keymap.set({ "i", "s" }, "<C-h>", function()
      ls.jump(-1)
    end, { silent = true })

    vim.keymap.set({ "i", "s" }, "<C-c>", function()
      if ls.choice_active() then
        ls.change_choice(1)
      end
    end, { silent = true })
  end,
}
