return {
  "echasnovski/mini.nvim",
  version = false, -- Use the latest commit
  config = function()
    -- Better Around/Inside textobjects
    --
    -- Examples:
    --  - va)  - Visually select Around )paren
    --  - yinq - Yank Inside Next 'quote
    --  - ci'  - Change Inside 'quote
    require("mini.ai").setup({ n_lines = 500 })
    -- Better Surround textobjects
    require("mini.surround").setup()
    -- Better Icon support
    require("mini.icons").setup()
    -- Session management
    -- require("mini.sessions").setup()
  end,
}
