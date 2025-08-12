return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "barreiroleo/ltex_extra.nvim",
    "b0o/schemastore.nvim",
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "j-hui/fidget.nvim", opts = {} },
    { "folke/neodev.nvim", opts = {} },
  },
  config = function()
    local keymap = vim.keymap -- for conciseness

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
      -- This function is called when an LSP attaches to a buffer.
      -- `ev` is the event object, which contains the buffer number.
      -- `ev.buf` is the buffer number where the LSP is attached.
      -- `callback` is a function that sets up keymaps and other LSP-related configurations
      -- for the buffer.
      -- See `:help vim.api.nvim_create_autocmd` for more details.
      callback = function(ev)
        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf, silent = true }

        -- set keybinds
        opts.desc = "[G]o to LSP [R]eferences"
        keymap.set("n", "gR", require("telescope.builtin").lsp_references, opts) -- show definition, references

        opts.desc = "[G]o to [D]eclaration"
        keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

        opts.desc = "[G]o to LSP [D]efinitions"
        keymap.set("n", "gd", require("telescope.builtin").lsp_definitions, opts) -- show lsp definitions

        opts.desc = "[G]o to LSP [I]mplementations"
        keymap.set("n", "gi", require("telescope.builtin").lsp_implementations, opts) -- show lsp implementations

        opts.desc = "Show LSP type definitions"
        keymap.set("n", "gt", require("telescope.builtin").lsp_type_definitions, opts) -- show lsp type definitions

        -- Fuzzy find all the symbols in your current document.
        --  Symbols are things like variables, functions, types, etc.
        opts.desc = "[O]pen Document symbols"
        keymap.set("n", "gO", require("telescope.builtin").lsp_document_symbols, opts)

        -- Fuzzy find all the symbols in your current workspace.
        --  Similar to document symbols, except searches over your entire project.
        opts.desc = "[W]orkspace symbols"
        keymap.set("n", "gW", require("telescope.builtin").lsp_dynamic_workspace_symbols, opts)

        opts.desc = "[A]ctions"
        keymap.set({ "n", "v" }, "<leader>c", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

        opts.desc = "Smart re[N]ame"
        keymap.set("n", "grn", vim.lsp.buf.rename, opts) -- smart rename

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

    -- Diagnostic Config
    -- See :help vim.diagnostic.Opts
    vim.diagnostic.config({
      severity_sort = true,
      float = { border = "rounded", source = "if_many" },
      underline = { severity = vim.diagnostic.severity.ERROR },
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = "󰅚 ",
          [vim.diagnostic.severity.WARN] = "󰀪 ",
          [vim.diagnostic.severity.INFO] = "󰋽 ",
          [vim.diagnostic.severity.HINT] = "󰌶 ",
        },
      },
      virtual_text = {
        source = "if_many",
        spacing = 2,
        format = function(diagnostic)
          local diagnostic_message = {
            [vim.diagnostic.severity.ERROR] = diagnostic.message,
            [vim.diagnostic.severity.WARN] = diagnostic.message,
            [vim.diagnostic.severity.INFO] = diagnostic.message,
            [vim.diagnostic.severity.HINT] = diagnostic.message,
          }
          return diagnostic_message[diagnostic.severity]
        end,
      },
    })

    -- Enable the following language servers
    --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
    --
    --  Add any additional override configuration in the following tables. Available keys are:
    --  - cmd (table): Override the default command used to start the server
    --  - filetypes (table): Override the default list of associated filetypes for the server
    --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
    --  - settings (table): Override the default settings passed when initializing the server.
    vim.lsp.enable("pyright")
    vim.lsp.enable("marksman")
    vim.lsp.enable("texlab")
    -- rust_analyzer = {},
    vim.lsp.config("lua_ls", {
      -- cmd = { ... },
      -- filetypes = { ... },
      -- capabilities = {},
      settings = {
        Lua = {
          -- make the language server recognize "vim" global
          diagnostics = {
            globals = { "vim" },
          },
          completion = {
            callSnippet = "Replace",
          },
          -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
          -- diagnostics = { disable = { 'missing-fields' } },
        },
      },
    })
    vim.lsp.enable("lua_ls")
    vim.lsp.config("ltex_plus", {
      on_attach = function(client, bufnr)
        -- rest of your on_attach process.
        require("ltex_extra").setup({
          -- table <string> : languages for witch dictionaries will be loaded, e.g. { "es-AR", "en-US" }
          -- load_langs = { "en-US", "es" }, -- en-US as default
        })
      end,
      settings = { ltex = {} },
    })
    vim.lsp.enable("ltex_plus")
    vim.lsp.config("yamlls", {
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
    vim.lsp.enable("yamlls")
  end,
}
