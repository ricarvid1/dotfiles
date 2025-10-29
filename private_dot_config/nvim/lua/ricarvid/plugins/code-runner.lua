return {
  "CRAG666/code_runner.nvim",
  config = function()
    require("code_runner").setup({
      filetype = {
        python = "python3 -u",
      },
      -- startinsert (see ':h inserting-ex')
      startinsert = false,
    })
    vim.keymap.set("n", "<leader>rr", ":RunCode<CR>", { noremap = true, silent = false, desc = "Run Code" })
    vim.keymap.set("n", "<leader>rf", ":RunFile<CR>", { noremap = true, silent = false, desc = "Run File" })
    vim.keymap.set("n", "<leader>rt", ":RunFile tab<CR>", { noremap = true, silent = false, desc = "Run File Tab" })
    vim.keymap.set("n", "<leader>rp", ":RunProject<CR>", { noremap = true, silent = false, desc = "Run Project" })
    vim.keymap.set("n", "<leader>rx", ":RunClose<CR>", { noremap = true, silent = false, desc = "Run Close" })
    vim.keymap.set(
      "n",
      "<leader>rjf",
      ":CRFiletype<CR>",
      { noremap = true, silent = false, desc = "Get JSON File" }
    )
    vim.keymap.set(
      "n",
      "<leader>rjp",
      ":CRProjects<CR>",
      { noremap = true, silent = false, desc = "Get JSON Projects" }
    )
  end,
}
