return {
  "echasnovski/mini.nvim",
  version = false, -- Use the latest commit
  config = function()
    -- Better Around/Inside textobjects
    --
    -- Examples:
    --  - va)  - [V]isually select [A]round [)]paren
    --  - yinq - [Y]ank [I]nside [N]ext [']quote
    --  - ci'  - [C]hange [I]nside [']quote
    require("mini.ai").setup({ n_lines = 500 })
    -- Better Surround textobjects
    require("mini.surround").setup()
    -- Better Icon support
    require("mini.icons").setup()
    -- Session management
    -- require("mini.sessions").setup()
  end,
}
