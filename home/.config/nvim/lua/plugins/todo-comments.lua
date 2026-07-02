--- @docstring
--- Highlight, list and search todo comments in your projects.
return {
  'folke/todo-comments.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = { signs = false },
  keys = {
    { '<leader>st', '<cmd>TodoTelescope<cr>', desc = 'Search TODOs' },
  },
}
