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
      integrations = {
        aerial = true,
        alpha = true,
        cmp = true,
        dashboard = true,
        flash = true,
        grug_far = true,
        gitsigns = true,
        headlines = true,
        illuminate = true,
        indent_blankline = { enabled = true },
        leap = true,
        lsp_trouble = true,
        mason = true,
        markdown = true,
        mini = true,
        native_lsp = {
          enabled = true,
          underlines = {
            errors = { 'undercurl' },
            hints = { 'undercurl' },
            warnings = { 'undercurl' },
            information = { 'underline' },
          },
        },
        navic = { enabled = true, custom_bg = 'lualine' },
        neotest = true,
        neotree = true,
        noice = true,
        notify = true,
        semantic_tokens = true,
        telescope = true,
        treesitter = true,
        treesitter_context = true,
        which_key = true,
      },
      flavour = 'macchiato',
      transparent_background = true,
      show_end_of_buffer = true,
      no_italic = false, -- Force no italic
      no_bold = false, -- Force no bold
      no_underline = false, -- Force no underline

      highlight_overrides = {
        all = function(colours)
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
}
