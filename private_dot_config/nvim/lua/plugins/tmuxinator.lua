return {
  {
    "christoomey/vim-tmux-navigator",
    cond = function()
      return vim.env.HERDR_PANE_ID == nil
    end,
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
      "TmuxNavigatorProcessList",
    },
    keys = {
      { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
      { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
      { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
      { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
      { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
    },
  },
  {
    "bojackduy/nvim-herdr-navigation",
    submodules = false,
    cond = function()
      return vim.env.HERDR_PANE_ID ~= nil
    end,
    event = "VeryLazy",
    init = function(plugin)
      vim.opt.rtp:prepend(plugin.dir .. "/nvim-herdr-navigation")
    end,
    config = function()
      vim.schedule(function()
        require("herdr-navigation").setup({
          tmux_compat_commands = true,
          keybindings = {
            left = "<C-h>",
            down = "<C-j>",
            up = "<C-k>",
            right = "<C-l>",
          },
        })
      end)
    end,
  },
}
