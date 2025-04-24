return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local conform = require("conform")

    conform.setup({
      log_level = vim.log.levels.DEBUG,
      formatters_by_ft = {
        -- json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        lua = { "stylua" },
        python = { "ruff_format" },
        tex = { "latexindent" },
        bib = { "bibtex-tidy" },
      },
      formatters = {
        latexindent = {
          -- command = vim.fn.expand("~") .. "/src/latexindent.pl/latexindent.pl",
          prepend_args = { "-m" },
        },
      },
      format_on_save = {
        lsp_fallback = true,
        async = false,
        timeout_ms = 1000,
      },
    })

    vim.keymap.set({ "n", "v" }, "<leader>rm", function()
      conform.format({
        lsp_fallback = true,
        async = false,
        timeout_ms = 10000,
      })
    end, { desc = "For[M]at file or range (in visual mode)" })
  end,
}
