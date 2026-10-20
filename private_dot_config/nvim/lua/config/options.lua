-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Provided by omarchy-nvim; absent on non-Omarchy machines.
pcall(function()
  require("config.remote_clipboard").setup()
end)

vim.filetype.add({
  extension = {
    spc = "spice",
    spi = "spice",
    spice = "spice",
    scs = "spectre",
    cdl = "cdl",
  },
})
