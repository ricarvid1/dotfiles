return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon = require("harpoon")

    -- REQUIRED
    harpoon:setup()
    -- REQUIRED

    --  set keymaps
    local keymap = vim.keymap
    keymap.set("n", "<leader>a", function()
      harpoon:list():add()
    end, { desc = "Harpoon [A]dd" })
    keymap.set("n", "<C-e>", function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = "[H]arpoon g[E]t" })
    -- TODO: Decide whether this is useful and change keys accordingly
    -- keymap.set("n", "<C-h>", function()
    --   harpoon:list():select(1)
    -- end)
    -- keymap.set("n", "<C-t>", function()
    --   harpoon:list():select(2)
    -- end)
    -- keymap.set("n", "<C-n>", function()
    --   harpoon:list():select(3)
    -- end)
    -- keymap.set("n", "<C-s>", function()
    --   harpoon:list():select(4)
    -- end)
    --
    -- Toggle previous & next buffers stored within Harpoon list
    keymap.set("n", "<C-S-P>", function()
      harpoon:list():prev()
    end, { desc = "Toggle previous buffer" })
    keymap.set("n", "<C-S-N>", function()
      harpoon:list():next()
    end, { desc = "Toggle next buffer" })
  end,
}
