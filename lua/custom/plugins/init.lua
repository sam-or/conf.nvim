-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {

  -- Mutliple cursors
  {
    'mg979/vim-visual-multi',
    init = function()
      vim.cmd [[let g:VM_leader = ';']]
    end,
    config = function()
      -- vim.g.VM_maps = {}
      -- vim.g.VM_maps['Undo'] = 'u'
      -- vim.g.VM_maps['Redo'] = '<C-r>'
      --
    end,
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' }, -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
  },
  {
    'MagicDuck/grug-far.nvim',
    config = function()
      require('grug-far').setup {
        -- options, see Configuration section below
        -- there are no required options atm
        -- engine = 'ripgrep' is default, but 'astgrep' can be specified
      }
    end,
  },
  {
    'kkoomen/vim-doge',
    build = ':call doge#install()',
    ft = 'python',
    config = function()
      vim.g.doge_doc_standard_python = 'google'
    end,
  },
}
