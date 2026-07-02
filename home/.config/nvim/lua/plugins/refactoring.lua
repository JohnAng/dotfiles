--- @docstring
--- Refactoring tools based on Martin Fowler's paradigms (Telescope Integration).
return {
  'ThePrimeagen/refactoring.nvim',
  dependencies = { 'nvim-lua/plenary.nvim', 'nvim-treesitter/nvim-treesitter', 'nvim-telescope/telescope.nvim' },
  keys = {
    -- CRITICAL: Add mode = { 'n', 'x' } to the lazy.nvim spec
    {
      '<leader>cr',
      function() require('telescope').extensions.refactoring.refactors() end,
      mode = { 'n', 'x' },
      desc = 'Code Refactor Menu',
    },
  },
  config = function()
    require('refactoring').setup()
    -- Best Practice: Load the Telescope extension when refactoring initializes
    pcall(require('telescope').load_extension, 'refactoring')
  end,
}
