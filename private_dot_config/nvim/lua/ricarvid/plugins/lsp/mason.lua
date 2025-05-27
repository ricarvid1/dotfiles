return {
  "williamboman/mason.nvim",
  -- version = "^1.0.0",
  dependencies = {
    {
      "williamboman/mason-lspconfig.nvim",
      -- version = "^1.0.0",
    },
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    -- import mason
    local mason = require("mason")

    -- import mason-lspconfig
    local mason_lspconfig = require("mason-lspconfig")

    local mason_tool_installer = require("mason-tool-installer")
    -- enable mason and configure icons
    mason.setup({
      -- Uncomment to test Mason registry
      -- registries = {
      --   "file:/home/ricarvid/src/mason-registry/",
      -- },
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    mason_lspconfig.setup({
      -- list of servers for mason to install
      ensure_installed = {
        "lua_ls",
        "pyright",
        "texlab",
        "ltex",
        "pyright",
        "yamlls",
        "marksman",
      },
    })

    mason_tool_installer.setup({
      ensure_installed = {
        "prettier", -- prettier formatter
        "stylua", -- lua formatter
        "ruff", -- python formatter
        -- { "latexindent", version = "v3.24.4" }, -- tex formatter
      },
    })
  end,
}
