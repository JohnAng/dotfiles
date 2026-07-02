--- @docstring
--- Yank ring: history of all yanks + cycle with <C-n>/<C-p> after paste.
--- Also substitution paste and telescope search of the history.
return {
  'gbprod/yanky.nvim',
  event = { 'BufReadPost', 'BufNewFile' },
  dependencies = { 'nvim-telescope/telescope.nvim' },
  keys = {
    { 'y', '<Plug>(YankyYank)', mode = { 'n', 'x' }, desc = 'Yank text (yanky)' },
    { 'p', '<Plug>(YankyPutAfter)', mode = { 'n', 'x' }, desc = 'Put yanked (after)' },
    { 'P', '<Plug>(YankyPutBefore)', mode = { 'n', 'x' }, desc = 'Put yanked (before)' },
    { 'gp', '<Plug>(YankyGPutAfter)', mode = { 'n', 'x' }, desc = 'G-put yanked (after)' },
    { 'gP', '<Plug>(YankyGPutBefore)', mode = { 'n', 'x' }, desc = 'G-put yanked (before)' },
    { '<C-n>', '<Plug>(YankyCycleForward)', desc = 'Cycle yank history →' },
    { '<C-p>', '<Plug>(YankyCycleBackward)', desc = 'Cycle yank history ←' },
    { '<leader>sy', function() require('telescope').extensions.yank_history.yank_history {} end, desc = 'Search [Y]ank history' },
  },
  opts = {
    ring = {
      history_length = 100,
      storage = 'shada',
      sync_with_numbered_registers = true,
      cancel_event = 'update',
    },
    picker = {
      select = { action = nil },
      telescope = {
        use_default_mappings = true,
        mappings = nil,
      },
    },
    system_clipboard = {
      sync_with_ring = true, -- WSL clipboard yanks go into the ring
    },
    highlight = {
      on_put = true,
      on_yank = true,
      timer = 300,
    },
  },
  config = function(_, opts)
    require('yanky').setup(opts)
    pcall(require('telescope').load_extension, 'yank_history')
  end,
}
