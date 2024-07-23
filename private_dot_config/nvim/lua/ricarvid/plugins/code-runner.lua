return {
  "CRAG666/code_runner.nvim",
  config = function()
    require("code_runner").setup({
      filetype = {
        python = "python3 -u",
      },
    })
    vim.keymap.set("n", "<leader>rr", ":RunCode<CR>", { noremap = true, silent = false, desc = "[R]un Code" })
    vim.keymap.set("n", "<leader>rf", ":RunFile<CR>", { noremap = true, silent = false, desc = "[R]un [F]ile" })
    vim.keymap.set(
      "n",
      "<leader>rft",
      ":RunFile tab<CR>",
      { noremap = true, silent = false, desc = "[R]un [F]ile [T]ab" }
    )
    vim.keymap.set("n", "<leader>rp", ":RunProject<CR>", { noremap = true, silent = false, desc = "[R]un [P]roject" })
    vim.keymap.set("n", "<leader>rc", ":RunClose<CR>", { noremap = true, silent = false, desc = "[R]un [C]lose" })
  end,
}
