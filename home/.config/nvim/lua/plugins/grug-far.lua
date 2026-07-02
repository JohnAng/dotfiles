--- @docstring
--- Global Search and Replace engine. Acts as a pure text-based manipulator (Dumb Replace),
--- perfectly complementing the AST-aware LSP Rename.
return {
  'MagicDuck/grug-far.nvim',
  opts = { headerMaxWidth = 80 },
  cmd = 'GrugFar',
  keys = {
    {
      '<leader>sr',
      function() require('grug-far').open { prefills = { search = vim.fn.expand '<cword>' } } end,
      mode = { 'n', 'v' },
      desc = 'Search & [R]eplace (Global · GrugFar)',
    },
  },
}
