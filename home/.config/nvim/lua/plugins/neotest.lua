--- @docstring
--- An extensible framework for interacting with tests within Neovim.
return {
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-lua/plenary.nvim',
    'antoinemadec/FixCursorHold.nvim',
    'nvim-treesitter/nvim-treesitter',
    'nvim-neotest/neotest-python',
    'rcasia/neotest-java', -- Java Support
    'nvim-neotest/neotest-jest', -- Web Support
  },
  -- CRITICAL: The plugin loads ONLY when one of these keys is pressed
  keys = {
    { '<leader>tr', function() require('neotest').run.run() end, desc = 'Test Run Nearest' },
    { '<leader>tf', function() require('neotest').run.run(vim.fn.expand '%') end, desc = 'Test Run File' },
    { '<leader>ts', function() require('neotest').summary.toggle() end, desc = 'Test Summary Toggle' },
    { '<leader>to', function() require('neotest').output_panel.toggle() end, desc = 'Test Output Panel' },
  },
  config = function()
    require('neotest').setup {
      adapters = {
        require 'neotest-python' { dap = { justMyCode = false } },
        require 'neotest-java',
        require 'neotest-jest' { jestCommand = 'npm test --', env = { CI = true }, cwd = function() return vim.fn.getcwd() end },
      },
    }
  end,
}
