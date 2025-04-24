return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      transparent_background = false, -- disables setting the background color.
      -- term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        notify = false,
        mini = {
          enabled = true,
          indentscope_color = "",
        },
        -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
        aerial = true,
        which_key = true,
      },
    })
    -- setup must be called before loading
    vim.cmd("colorscheme catppuccin")
    vim.api.nvim_set_hl(0, "ColorColumn", { ctermbg = 0, bg = "#333333" })
  end,
  -- === Tokyonight settings ===
  -- "folke/tokyonight.nvim",
  -- priority = 1000,
  -- config = function()
  --   local transparent = false -- set to true if you would like to enable transparency
  --
  --   local bg = "#011628"
  --   local bg_dark = "#011423"
  --   local bg_highlight = "#143652"
  --   local bg_search = "#0A64AC"
  --   local bg_visual = "#275378"
  --   local fg = "#CBE0F0"
  --   local fg_dark = "#B4D0E9"
  --   local fg_gutter = "#627E97"
  --   local border = "#547998"
  --
  --   require("tokyonight").setup({
  --     style = "night",
  --     transparent = transparent,
  --     styles = {
  --       sidebars = transparent and "transparent" or "dark",
  --       floats = transparent and "transparent" or "dark",
  --     },
  --     on_colors = function(colors)
  --       colors.bg = bg
  --       colors.bg_dark = transparent and colors.none or bg_dark
  --       colors.bg_float = transparent and colors.none or bg_dark
  --       colors.bg_highlight = bg_highlight
  --       colors.bg_popup = bg_dark
  --       colors.bg_search = bg_search
  --       colors.bg_sidebar = transparent and colors.none or bg_dark
  --       colors.bg_statusline = transparent and colors.none or bg_dark
  --       colors.bg_visual = bg_visual
  --       colors.border = border
  --       colors.fg = fg
  --       colors.fg_dark = fg_dark
  --       colors.fg_float = fg
  --       colors.fg_gutter = fg_gutter
  --       colors.fg_sidebar = fg_dark
  --     end,
  --   })
  --
  --   vim.cmd("colorscheme tokyonight")
  --   vim.api.nvim_set_hl(0, "ColorColumn", { ctermbg = 0, bg = "#333333" })
  -- end,
}
