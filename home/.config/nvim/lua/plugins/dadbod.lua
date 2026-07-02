--- @docstring
--- The ultimate Database IDE for Neovim. Replaces DataGrip/DBeaver.
return {
  'kristijanhusak/vim-dadbod-ui',
  dependencies = {
    { 'tpope/vim-dadbod', lazy = true },
    { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true },
  },
  cmd = { 'DBUI', 'DBUIToggle', 'DBUIAddConnection', 'DBUIFindBuffer' },
  keys = {
    { '<leader>Du', '<cmd>DBUIToggle<cr>', desc = '[D]atabase [U]I toggle' },
    { '<leader>Df', '<cmd>DBUIFindBuffer<cr>', desc = '[D]atabase find buffer' },
    { '<leader>Da', '<cmd>DBUIAddConnection<cr>', desc = '[D]atabase [A]dd connection' },
  },
  init = function() vim.g.db_ui_use_nerd_fonts = 1 end,
}
