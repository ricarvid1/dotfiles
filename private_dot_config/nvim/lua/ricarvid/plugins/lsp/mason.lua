return {
  "williamboman/mason.nvim",
  dependencies = {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    -- import mason
    local mason = require("mason")

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
