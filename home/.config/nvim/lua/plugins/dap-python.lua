--- @docstring
--- Python-specific extension for nvim-dap. Handles Virtual Environments natively.
return {
  'mfussenegger/nvim-dap-python',
  ft = 'python',
  dependencies = { 'mfussenegger/nvim-dap', 'rcarriga/nvim-dap-ui' },
  config = function()
    local debugpy_path = vim.fn.stdpath 'data' .. '/mason/packages/debugpy/venv/bin/python'
    require('dap-python').setup(debugpy_path)
    vim.keymap.set('n', '<leader>dpr', function() require('dap-python').test_method() end, { desc = 'Debug Python Test Method' })
  end,
}
