--- @docstring
--- Displays a popup with possible key bindings of the command you started typing.
return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  opts = {
    delay = 0,
    icons = { mappings = vim.g.have_nerd_font },
    spec = {
      { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
      { '<leader>t', group = '[T]est', mode = { 'n', 'v' } },
      { '<leader>T', group = '[T]erminal (float/split)', mode = { 'n' } },
      { '<leader>b', group = '[B]uffer', mode = { 'n' } },
      { '<leader>D', group = '[D]atabase (Dadbod)', mode = { 'n' } },
      { '<leader>u', group = '[U]I / Toggle', mode = { 'n', 'v' } },
      { '<leader>f', group = '[F]ormat / [F]ind Theme', mode = { 'n', 'v' } },
      { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      { '<leader>g', group = '[G]it Tools', mode = { 'n', 'v' } },
      { '<leader>d', group = '[D]ebug', mode = { 'n', 'v' } },
      { '<leader>c', group = '[C]ode Actions & Refactor', mode = { 'n', 'v' } },
      { '<leader>r', group = '[R]un Code', mode = { 'n', 'v' } },
      { '<leader>q', group = 'Session ([Q]uit)', mode = { 'n' } },
      { '<leader>x', group = 'Diagnostics / Trouble', mode = { 'n', 'v' } },
      { '<leader>R', group = 'REST (Kulala)', mode = { 'n' } },
      { 'gr', group = 'LSP Actions', mode = { 'n' } },
      { '[', group = 'Prev', mode = { 'n' } },
      { ']', group = 'Next', mode = { 'n' } },
    },
  },
}
