return {
  {
    'dmtrKovalenko/fff.nvim',
    enabled = true,
    build = function()
      -- downloads a prebuilt binary or falls back to cargo build
      require('fff.download').download_or_build_binary()
    end,
    -- for nixos:
    -- build = "nix run .#release",
    opts = {
      debug = {
        enabled = true,
        show_scores = true,
      },
      layout = {
        height = 0.9,
        width = 0.9,
        prompt_position = 'top',
      },
    },
    lazy = false, -- the plugin lazy-initialises itself
    keys = {
      { '<c-p>', function() require('fff').find_files() end, desc = 'FFFind files' },
      { '<c-g>', function() require('fff').live_grep() end, desc = 'LiFFFe grep' },
      -- { '<c-g>', function() require('fff').live_grep { grep = { modes = { 'fuzzy', 'plain' } } } end, desc = 'Live fffuzy grep' },
      { '<leader>sw', function() require('fff').live_grep { query = vim.fn.expand '<cword>' } end, desc = 'Search current word' },
      { '<leader>sr', function() require('fff').resume() end, desc = 'Resume last search' },
    },
  },
}
