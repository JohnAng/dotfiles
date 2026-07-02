--- @docstring
--- CLion-like CMake integration for C/C++ projects.
return {
  'Civitasv/cmake-tools.nvim',
  ft = { 'c', 'cpp', 'objc', 'objcpp', 'h', 'hpp' },
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    require('cmake-tools').setup {
      cmake_generate_options = { '-DCMAKE_EXPORT_COMPILE_COMMANDS=1' },
    }
    vim.keymap.set('n', '<leader>cmg', '<cmd>CMakeGenerate<cr>', { desc = 'CMake Generate' })
    vim.keymap.set('n', '<leader>cmb', '<cmd>CMakeBuild<cr>', { desc = 'CMake Build' })
    vim.keymap.set('n', '<leader>cmr', '<cmd>CMakeRun<cr>', { desc = 'CMake Run' })
    vim.keymap.set('n', '<leader>cmd', '<cmd>CMakeDebug<cr>', { desc = 'CMake Debug' })
  end,
}
