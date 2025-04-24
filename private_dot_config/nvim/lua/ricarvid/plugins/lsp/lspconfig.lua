return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "barreiroleo/ltex_extra.nvim",
    "b0o/schemastore.nvim",
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "j-hui/fidget.nvim", opts = {} },
    { "folke/neodev.nvim", opts = {} },
  },
  config = function()
    -- import lspconfig plugin
    local lspconfig = require("lspconfig")

    -- import mason_lspconfig plugin
    local mason_lspconfig = require("mason-lspconfig")

    -- import cmp-nvim-lsp plugin
    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    local keymap = vim.keymap -- for conciseness

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf, silent = true }

        -- set keybinds
        opts.desc = "Show LSP references"
        keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

        opts.desc = "Go to declaration"
        keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

        opts.desc = "Show LSP definitions"
        keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

        opts.desc = "Show LSP implementations"
        keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

        opts.desc = "Show LSP type definitions"
        keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

        opts.desc = "[A]ctions"
        keymap.set({ "n", "v" }, "<leader>c", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

        opts.desc = "Smart re[N]ame"
        keymap.set("n", "<leader>gn", vim.lsp.buf.rename, opts) -- smart rename

        opts.desc = "Buffer [D]iagnostics"
        keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

        opts.desc = "Line [d]iagnostics"
        keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

        opts.desc = "Previous diagnostic"
        keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

        opts.desc = "Next diagnostic"
        keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

        opts.desc = "Show do[K]umentation under cursor"
        keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

        opts.desc = "[R]estart LSP"
        keymap.set("n", "<leader>gr", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
      end,
    })

    -- used to enable autocompletion (assign to every lsp server config)
    local capabilities = cmp_nvim_lsp.default_capabilities()

    -- Change the Diagnostic symbols in the sign column (gutter)
    -- (not in youtube nvim video)
    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    mason_lspconfig.setup_handlers({
      -- default handler for installed servers
      function(server_name)
        lspconfig[server_name].setup({
          capabilities = capabilities,
        })
      end,
      -- ["graphql"] = function()
      --   -- configure graphql language server
      --   lspconfig["graphql"].setup({
      --     capabilities = capabilities,
      --     filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
      --   })
      -- end,
      ["marksman"] = function()
        -- configure markdown language server
        lspconfig["marksman"].setup({
          capabilities = capabilities,
          filetypes = { "markdown" },
        })
      end,
      ["pyright"] = function()
        -- configure python language server
        lspconfig["pyright"].setup({
          capabilities = capabilities,
          filetypes = { "python" },
        })
      end,
      ["texlab"] = function()
        -- configure the texlab language server
        lspconfig["texlab"].setup({
          capabilities = capabilities,
          filetypes = { "tex" },
        })
      end,
      -- ["ltex"] = function()
      --   -- configure the texlab language server
      --   lspconfig["ltex"].setup({
      --     capabilities = capabilities,
      --     on_attach = function() -- rest of your on_attach process.
      --       require("ltex_extra").setup({
      --         -- table <string> : languages for witch dictionaries will be loaded, e.g. { "es-AR", "en-US" }
      --         -- https://valentjn.github.io/ltex/supported-languages.html#natural-languages
      --         load_langs = { "en-US", "es" }, -- en-US as default
      --       })
      --     end,
      --     filetypes = { "tex", "markdown", "plaintext" },
      --   })
      -- end,
      ["ltex"] = function()
        -- configure the texlab language server
        lspconfig["ltex_plus"].setup({
          capabilities = capabilities,
          on_attach = function(client, bufnr)
            -- rest of your on_attach process.
            require("ltex_extra").setup({
              -- table <string> : languages for witch dictionaries will be loaded, e.g. { "es-AR", "en-US" }
              -- load_langs = { "en-US", "es" }, -- en-US as default
            })
          end,
          -- filetypes = { "tex", "markdown", "plaintext", "gitcommit" },
          settings = {
            ltex = {
              enabled = {
                "bib",
                "context",
                "gitcommit",
                "html",
                "markdown",
                "org",
                "pandoc",
                "plaintex",
                "quarto",
                "mail",
                "mdx",
                "rmd",
                "rnoweb",
                "rst",
                "tex",
                "latex",
                "text",
                "typst",
                "xhtml",
              },
            },
          },
        })
      end,
      ["yamlls"] = function()
        -- configure the yaml language server
        lspconfig["yamlls"].setup({
          settings = {
            yaml = {
              schemaStore = {
                -- You must disable built-in schemaStore support if you want to use
                -- this plugin and its advanced options like `ignore`.
                enable = false,
                -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
                url = "",
              },
              schemas = require("schemastore").yaml.schemas(),
            },
          },
        })
      end,
      ["lua_ls"] = function()
        -- configure lua server (with special settings)
        lspconfig["lua_ls"].setup({
          capabilities = capabilities,
          settings = {
            Lua = {
              -- make the language server recognize "vim" global
              diagnostics = {
                globals = { "vim" },
              },
              completion = {
                callSnippet = "Replace",
              },
            },
          },
        })
      end,
    })
  end,
}
