return {
  {
    'ibhagwan/fzf-lua',
    -- optional for icon support
    dependencies = { 'echasnovski/mini.icons' },
    opts = {},
    config = function()
      local fzf_lua = require 'fzf-lua'
      fzf_lua.setup { files = { formatter = 'path.dirname_first' } }
      vim.keymap.set('n', '<C-p>', fzf_lua.files, { desc = 'Find files' })
      vim.keymap.set('i', '<C-p>', fzf_lua.files, { desc = 'Find files' })
      vim.keymap.set('n', '<C-g>', fzf_lua.live_grep_glob, { desc = 'Grep' })
      vim.keymap.set('i', '<C-g>', fzf_lua.live_grep_glob, { desc = 'Grep' })
      vim.keymap.set('n', '<leader>o', fzf_lua.lsp_document_symbols, { desc = 'Document Symbols' })
      vim.keymap.set('n', '<leader>sk', fzf_lua.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', fzf_lua.oldfiles, { desc = '[S]earch Old [F]iles' })
      vim.keymap.set('n', '<leader>ss', fzf_lua.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', fzf_lua.grep_cWORD, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', fzf_lua.live_grep_glob, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', fzf_lua.diagnostics_workspace, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', fzf_lua.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader><leader>', fzf_lua.buffers, { desc = '[ ] Find existing buffers' })

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set('n', '<leader>sn', function()
        fzf_lua.files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
    end,
  },
}
