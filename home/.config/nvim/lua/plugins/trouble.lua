--- @docstring
--- Centralized diagnostic aggregator and AST structure outline (The IDE Bottom/Side Panels).
return {
  'folke/trouble.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  cmd = 'Trouble',
  keys = {
    { '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Project Diagnostics (Trouble)' },
    { '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = 'Buffer Diagnostics (Trouble)' },
    { '<leader>cs', '<cmd>Trouble symbols toggle focus=false<cr>', desc = 'Symbols Outline (Trouble)' },

    -- O(1) Diagnostic Jumping without opening the panel
    { ']x', function() require('trouble').next { skip_groups = true, jump = true } end, desc = 'Next Trouble Diagnostic' },
    { '[x', function() require('trouble').previous { skip_groups = true, jump = true } end, desc = 'Previous Trouble Diagnostic' },
  },
}
