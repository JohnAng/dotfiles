--- @docstring
--- Splits and joins blocks of code (arrays, hashes, parameters) flawlessly using Treesitter.
return {
  'Wansmer/treesj',
  keys = {
    { '<leader>cj', '<cmd>TSJToggle<cr>', desc = 'Toggle Code Split/Join' },
  },
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  config = function() require('treesj').setup { use_default_keymaps = false, max_join_length = 150 } end,
}
