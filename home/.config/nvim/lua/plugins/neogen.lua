--- @docstring
--- A better annotation generator. Supports Java, Python, C, and Web.
return {
  'danymat/neogen',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  config = function()
    require('neogen').setup {
      snippet_engine = 'luasnip',
      languages = { python = { template = { annotation_convention = 'google_docstrings' } } },
    }
    vim.keymap.set('n', '<leader>cd', function() require('neogen').generate() end, { desc = 'Generate Docstring' })
  end,
}
