--- @docstring
--- Highly extendable fuzzy finder over lists. Optimized for massive Monorepos.
return {
  'nvim-telescope/telescope.nvim',
  enabled = true,
  -- event = 'VimEnter' was REMOVED
  cmd = 'Telescope', -- Loads if you type the :Telescope command
  dependencies = {
    'nvim-lua/plenary.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make', cond = function() return vim.fn.executable 'make' == 1 end },
    { 'nvim-telescope/telescope-ui-select.nvim' },
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
  },
  -- CRITICAL: Keymaps moved to the lazy property.
  -- We use string <cmd>...<CR> for optimal performance, except when a Lua function is required.
  keys = {
    { '<leader>sh', '<cmd>Telescope help_tags<CR>', desc = 'Search Help' },
    { '<leader>sk', '<cmd>Telescope keymaps<CR>', desc = 'Search Keymaps' },
    { '<leader>sf', '<cmd>Telescope find_files<CR>', desc = 'Search Files' },
    { '<leader>sn', function() require('telescope.builtin').find_files { cwd = vim.fn.stdpath 'config' } end, desc = 'Search Neovim Config' },
    { '<leader>ss', '<cmd>Telescope builtin<CR>', desc = 'Search Select Telescope' },
    { '<leader>sw', '<cmd>Telescope grep_string<CR>', mode = { 'n', 'v' }, desc = 'Search current Word' },
    { '<leader>sg', '<cmd>Telescope live_grep<CR>', desc = 'Search by Grep' },
    { '<leader>sd', '<cmd>Telescope diagnostics<CR>', desc = 'Search Diagnostics' },
    { '<leader>sR', '<cmd>Telescope resume<CR>', desc = 'Search [R]esume last picker' },
    { '<leader>s.', '<cmd>Telescope oldfiles<CR>', desc = 'Search Recent Files' },
    { '<leader>sc', '<cmd>Telescope commands<CR>', desc = 'Search Commands' },
    { '<leader><leader>', '<cmd>Telescope buffers<CR>', desc = 'Find existing buffers' },
  },
  config = function()
    local telescope = require 'telescope'

    telescope.setup {
      defaults = {
        path_display = { 'truncate' },
        file_ignore_patterns = {
          '.git/',
          'node_modules/',
          'target/',
          'build/',
          '%.class',
          '%.o',
          '%.so',
        },
      },
      pickers = {
        find_files = { hidden = true },
        live_grep = { additional_args = function() return { '--hidden' } end },
      },
      extensions = {
        ['ui-select'] = { require('telescope.themes').get_dropdown() },
      },
    }

    pcall(telescope.load_extension, 'fzf')
    pcall(telescope.load_extension, 'ui-select')
  end,
}
