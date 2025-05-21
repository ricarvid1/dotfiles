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
        python = { "ruff_format", "ruff_fix" },
        tex = { "latexindent" },
        bib = { "bibtex-tidy" },
      },
      formatters = {
        latexindent = {
          -- command = vim.fn.expand("~") .. "/src/latexindent.pl/latexindent.pl",
          prepend_args = { "-m" },
        },
        ruff_format = {
          --ruff_format = { -- This is the custom formatter definition
          -- The 'command' field can be a string or a function
          command = function()
            -- 1. Check for a virtual environment (most common for Python)
            --    vim.env.VIRTUAL_ENV will be set if you're in an activated venv
            if vim.env.VIRTUAL_ENV then
              -- Construct path to ruff inside the venv's bin directory
              return vim.env.VIRTUAL_ENV .. "/bin/ruff"
            end

            -- 2. Fallback to a local 'ruff' in .venv (common setup without activating)
            --    This assumes a .venv directory in the project root
            local cwd = vim.fn.getcwd() -- Get current working directory
            local local_ruff = cwd .. "/.venv/bin/ruff"
            if vim.fn.executable(local_ruff) == 1 then
              return local_ruff
            end

            -- 3. Fallback to a common local bin directory (e.g., node_modules/.bin for JS tools)
            --    Less common for ruff, but useful for other formatters
            local local_bin_ruff = "/home/ricarvid/.local/share/nvim/mason/bin/ruff"
            if vim.fn.executable(local_bin_ruff) == 1 then
              return local_bin_ruff
            end

            -- 4. Finally, fall back to the global 'ruff' in PATH if no local one is found
            return "ruff"
          end,
          -- ruff format is the subcommand for formatting
          args = { "format", "--stdin-filename", "$FILENAME" },
        },
        ruff_fix = {
          --ruff_format = { -- This is the custom formatter definition
          -- The 'command' field can be a string or a function
          command = function()
            -- 1. Check for a virtual environment (most common for Python)
            --    vim.env.VIRTUAL_ENV will be set if you're in an activated venv
            if vim.env.VIRTUAL_ENV then
              -- Construct path to ruff inside the venv's bin directory
              return vim.env.VIRTUAL_ENV .. "/bin/ruff"
            end

            -- 2. Fallback to a local 'ruff' in .venv (common setup without activating)
            --    This assumes a .venv directory in the project root
            local cwd = vim.fn.getcwd() -- Get current working directory
            local local_ruff = cwd .. "/.venv/bin/ruff"
            if vim.fn.executable(local_ruff) == 1 then
              return local_ruff
            end

            -- 3. Fallback to a common local bin directory (e.g., node_modules/.bin for JS tools)
            --    Less common for ruff, but useful for other formatters
            local local_bin_ruff = "/home/ricarvid/.local/share/nvim/mason/bin/ruff"
            if vim.fn.executable(local_bin_ruff) == 1 then
              return local_bin_ruff
            end

            -- 4. Finally, fall back to the global 'ruff' in PATH if no local one is found
            return "ruff"
          end,
          -- ruff format is the subcommand for formatting
          args = { "check", "--fix", "--stdin-filename", "$FILENAME" },
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
