return {
  {
    'folke/tokyonight.nvim',
    lazy = false,
    enabled = false,
    priority = 1000,
    opts = {
      style = 'night',
      sidebars = { 'nerdtree' },
      on_colors = function(colors)
        local util = require 'tokyonight.util'

        colors.bg = util.lighten('#1e222a', 0.98)
        colors.bg_dark = colors.bg
        local bg_darker = util.darken(colors.bg, 0.1)
        colors.bg_sidebar = bg_darker
        colors.bg_popup = bg_darker
        colors.bg_popup = bg_darker
        colors.bg_statusline = util.darken(colors.bg, 0.6)
        colors.border = util.darken(colors.bg, 0.2)

        colors.fg = '#abb2bf'
        colors.fg_sidebar = '#abb2bf'

        colors.green = '#7da869'
        colors.orange = '#c18a56'
        colors.green1 = util.darken(colors.fg, 0.6)
        colors.comment = '#3e4451'
      end,
      on_highlights = function(hl, c)
        local util = require 'tokyonight.util'
        local prompt = '#392747'
        hl.TelescopeNormal = {
          bg = c.bg_dark,
          fg = c.fg_dark,
        }
        hl.TelescopeBorder = {
          bg = c.bg_dark,
          fg = c.fg_dark,
        }
        hl.TelescopePromptNormal = {
          bg = prompt,
        }
        hl.TelescopePromptBorder = {
          bg = prompt,
          fg = prompt,
        }
        hl.TelescopePromptTitle = {
          bg = prompt,
          fg = c.fg_dark,
        }
        hl.TelescopePreviewTitle = {
          bg = c.bg_dark,
          fg = c.fg_dark,
        }
        hl.TelescopeResultsTitle = {
          bg = c.bg_dark,
          fg = c.fg_dark,
        }

        hl.pythonBuiltin = {
          fg = c.blue,
          bg = util.darken(c.purple, 0.1),
        }
        hl[ [[@function.method.call]] ] = {
          fg = c.blue,
          bg = util.darken(c.purple, 0.1),
        }
        hl.Statement.bg = util.darken(hl.Statement.fg, 0.1)
        hl.Comment.bg = util.darken(hl.Comment.fg, 0.1)
        hl.Constant.bg = util.darken(hl.Constant.fg, 0.1)
        hl.String.bg = util.darken(hl.String.fg, 0.1)
        hl[ [[@lsp.type.enumMember.python]] ] = { fg = hl.Constant.fg, bg = hl.Constant.bg }
      end,
    },
  },
  {
    'catppuccin/nvim',
    lazy = true,
    name = 'catppuccin',

    init = function()
      -- Load the colorscheme here.
      -- Like many other themes, this one has different styles, and you could load
      vim.cmd.colorscheme 'catppuccin'
    end,
    opts = {
      auto_integratins = true,
      integrations = {
        blink_cmp = { enabled = true, style = 'bordered' },
        native_lsp = {
          enabled = true,
          underlines = {
            errors = { 'undercurl' },
            hints = { 'undercurl' },
            warnings = { 'undercurl' },
            information = { 'underline' },
          },
        },
      },
      flavour = 'frappe',
      transparent_background = false,
      show_end_of_buffer = true,
      no_italic = false, -- Force no italic
      no_bold = false, -- Force no bold
      no_underline = false, -- Force no underline
      color_overrides = {
        frappe = { -- Koda-inspired Frappe palette
          -- Accents / diagnostics
          rosewater = '#ffffff', -- emphasis
          flamingo = '#ffffff',
          pink = '#ffffff',
          mauve = '#777777', -- keywords
          red = '#ff7676', -- danger
          maroon = '#ff7676',
          peach = '#d9ba73', -- warning / constants
          yellow = '#d9ba73',
          green = '#86cd82', -- success
          teal = '#8ebeec', -- info
          sky = '#8ebeec',
          sapphire = '#8ebeec',
          blue = '#8ebeec', -- highlight
          lavender = '#ffffff',

          -- Text
          text = '#b0b0b0', -- main fg
          subtext1 = '#8a8a8a',
          subtext0 = '#777777',

          -- UI overlays
          overlay2 = '#4d4d4d', -- paren
          overlay1 = '#50585d', -- comments
          overlay0 = '#50585d',

          -- Surfaces
          surface2 = '#272727', -- lines
          surface1 = '#4c4c4c',
          surface0 = '#3a3a3a',

          -- Backgrounds
          base = '#101010', -- main bg
          mantle = '#101010',
          crust = '#0d0d0d',
        },
        koda = {
          --   none        = "none",
          --   bg_solid    = "#101010",
          --   bg          = "#101010",
          --   fg          = "#b0b0b0",
          --   line        = "#272727",
          --   paren       = "#4d4d4d",
          --   keyword     = "#777777",
          --   dim         = "#50585d",
          --   comment     = "#50585d",
          --   border      = "#ffffff",
          --   emphasis    = "#ffffff",
          --   func        = "#ffffff",
          --   string      = "#ffffff",
          --   const       = "#d9ba73",
          --   highlight   = "#0058d0",
          --   info        = "#8ebeec",
          --   success     = "#86cd82",
          --   warning     = "#d9ba73",
          --   danger      = "#ff7676",
          -- }
        },
      },
      highlight_overrides = {
        frappe = function(colours)
          local util = require 'catppuccin.utils.colors'
          return {
            BlinkCmpLabel = { fg = colours.text },
            BlinkCmpMenuBorder = { fg = colours.yellow },
            BlinkCmpMenuSelection = { bg = colours.surface0 },
            Delimiter = { fg = colours.text },
            Function = { fg = colours.text },
            Operator = { fg = colours.subtext1 },
            PmenuMatch = { fg = colours.yellow },
            SnacksPickerPreviewCursorLine = { bg = colours.surface2 },
            String = { fg = colours.text },
            ['@lsp.type.enumMember'] = { fg = colours.text },
            ['@module'] = { fg = colours.text },
            ['@string.documentation'] = { fg = colours.text },
            ['@variable.parameter'] = { fg = colours.text },
          }
        end,
        macchiato = function(colours)
          local util = require 'catppuccin.utils.colors'
          local keyword = { fg = colours.mauve }
          local keyword_hl = { fg = colours.mauve, bg = util.darken(colours.mauve, 0.3) }
          local func = { fg = colours.blue }
          local type = { fg = util.lighten(colours.blue, 0.8), bg = util.darken(colours.blue, 0.3) }
          return {
            Comment = {
              fg = colours.overlay0,
              bg = util.darken(colours.overlay0, 0.25),
            },
            Statement = {
              fg = colours.mauve,
              bg = util.darken(colours.mauve, 0.2),
            },
            Constant = {
              fg = colours.peach,
              bg = util.darken(colours.peach, 0.2),
            },
            String = {
              fg = colours.green,
              bg = util.darken(colours.green, 0.2),
            },
            ['@string.documentation'] = {
              fg = colours.teal,
              bg = util.darken(colours.teal, 0.2),
            },
            Type = type,
            ['@type.builtin'] = type,
            Keyword = keyword,
            ['@keyword.return'] = keyword_hl,
            ['@keyword.function'] = keyword,
            ['@keyword.import'] = keyword,
            ['@keyword.conditional'] = keyword,
            ['@keyword.repeat'] = keyword,
            ['@keyword.exception'] = keyword,
            Function = func,
            DiagnosticVirtualTextError = {
              fg = colours.red,
              bg = util.darken(colours.red, 0.4),
            },
            DiagnosticVirtualTextWarn = {
              fg = colours.yellow,
              bg = util.darken(colours.yellow, 0.5),
            },
            DiagnosticVirtualTextInfo = {
              bg = colours.background,
              fg = util.darken(colours.blue, 0.3),
            },
            DiagnosticUnderlineInfo = {
              sp = util.darken(colours.blue, 0.3),
            },
            DiagnosticVirtualTextHint = {
              fg = colours.teal,
              bg = util.darken(colours.teal, 0.5),
            },
            WinSeparator = { fg = '#957CC6', bg = vim.api.nvim_get_hl(0, { name = 'Normal' }).bg },
            WinBar = { fg = '#957CC6', bg = vim.api.nvim_get_hl(0, { name = 'Normal' }).bg },
          }
        end,
      },
    },
  },
  {
    'oskarnurm/koda.nvim',
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      -- require("koda").setup({ transparent = true })
      -- vim.cmd 'colorscheme koda'
    end,
  },
}
