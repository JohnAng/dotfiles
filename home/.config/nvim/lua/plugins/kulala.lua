--- @docstring
--- Minimal REST Client for Neovim. Replaces Postman/Insomnia.
return {
  'mistweaverco/kulala.nvim',
  ft = 'http',
  keys = {
    { '<leader>R', function() require('kulala').run() end, desc = 'Run HTTP Request' },
    { '<leader>Rt', function() require('kulala').toggle_view() end, desc = 'Toggle Headers/Body' },
  },
  config = function() require('kulala').setup() end,
}
