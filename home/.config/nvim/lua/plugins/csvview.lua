--- @docstring
--- Renders CSV files in a tabular format natively in Neovim buffers.
return {
  'hat0uma/csvview.nvim',
  config = function()
    require('csvview').setup()
    -- Keybind to toggle the spreadsheet view on and off
    vim.keymap.set('n', '<leader>uc', '<cmd>CsvViewToggle<cr>', { desc = 'Toggle [C]SV View' })
  end,
}
