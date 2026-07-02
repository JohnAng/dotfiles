--- @docstring
--- Magical Neovim Git interface.
return {
  'NeogitOrg/neogit',
  dependencies = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope.nvim', 'sindrets/diffview.nvim' },
  cmd = 'Neogit',
  keys = {
    { '<leader>gs', '<cmd>Neogit<cr>', desc = 'Git Status' },
    { '<leader>gd', '<cmd>DiffviewOpen<cr>', desc = 'Git Diff Workspace' },
    { '<leader>gc', '<cmd>DiffviewClose<cr>', desc = 'Git Diff Close' },
  },
  opts = { integrations = { telescope = true, diffview = true } },
}
