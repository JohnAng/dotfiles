--- @docstring
--- Neovim file explorer: edit your filesystem like a normal buffer.
return {
  'stevearc/oil.nvim',
  lazy = false, -- CRITICAL: Prevents lazy-loading so it can hijack 'nvim .'
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = { default_file_explorer = true, view_options = { show_hidden = true } },
  keys = { { '-', '<cmd>Oil<cr>', desc = 'Open Parent Directory' } },
}
