--- @docstring
--- SonarQube-style inline test coverage visualizer.
return {
  'andythigpen/nvim-coverage',
  dependencies = { 'nvim-lua/plenary.nvim' },
  cmd = { 'Coverage', 'CoverageToggle', 'CoverageLoad' },
  keys = {
    { '<leader>tv', '<cmd>CoverageToggle<cr>', desc = 'Toggle Test Coverage' },
    { '<leader>tl', '<cmd>CoverageLoad<cr>', desc = 'Load Test Coverage' },
  },
  config = function() require('coverage').setup() end,
}
