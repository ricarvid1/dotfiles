return {
  "lervag/vimtex",
  lazy = false, -- we don't want to lazy load VimTeX
  -- tag = "v2.15", -- uncomment to pin to a specific release
  init = function()
    -- VimTeX configuration goes here
    -- Necessary for VimTeX to load properly. The "indent" is optional.
    -- Note that most plugin managers will do this automatically.
    vim.cmd("filetype plugin indent on")

    -- This enables Neovim's syntax-related features. Without this, some
    -- VimTeX features will not work (see ":help vimtex-requirements" for more info).
    vim.cmd("syntax enable")

    -- Viewer options: One may configure the viewer either by specifying a built-in
    -- viewer method:
    vim.g.vimtex_view_method = "zathura"
    vim.g.vimtex_context_pdf_viewer = "okular" -- external PDF viewer run from vimtex menu command
    -- Don't open QuickFix for warning messages if no errors are present
    vim.g.vimtex_quickfix_open_on_warning = false
    -- Enable formatting using vim
    vim.g.vimtex_format_enabled = true

    -- set keymaps
    -- Use `update` to ensure document is saved before single-shot compilation
    -- local keymap = vim.keymap -- for conciseness
    -- keymap.set("n", "<leader>lh", "<Cmd>update<CR><Cmd>VimtexCompileSS<CR>", { desc = "Vimtex compile single-shot" })
    -- noremap <localleader>c <Cmd>update<CR><Cmd>VimtexCompileSS<CR>
  end,
}
