--- @docstring
--- Buffer tabline (Chrome-style tabs for open buffers).
return {
  'akinsho/bufferline.nvim',
  version = '*',
  event = 'VeryLazy',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  keys = {
    { '<S-h>', '<cmd>BufferLineCyclePrev<cr>', desc = 'Prev Buffer' },
    { '<S-l>', '<cmd>BufferLineCycleNext<cr>', desc = 'Next Buffer' },
    { '[b', '<cmd>BufferLineCyclePrev<cr>', desc = 'Prev Buffer' },
    { ']b', '<cmd>BufferLineCycleNext<cr>', desc = 'Next Buffer' },
    { '[B', '<cmd>BufferLineMovePrev<cr>', desc = 'Move Buffer Left' },
    { ']B', '<cmd>BufferLineMoveNext<cr>', desc = 'Move Buffer Right' },
    { '<leader>bp', '<cmd>BufferLineTogglePin<cr>', desc = 'Toggle [P]in Buffer' },
    { '<leader>bd', function() require('mini.bufremove').delete(0, false) end, desc = '[D]elete Buffer (keep window)' },
    { '<leader>bD', function() require('mini.bufremove').delete(0, true) end, desc = 'Force [D]elete Buffer' },
    { '<leader>bc', '<cmd>BufferLinePickClose<cr>', desc = '[C]lose Buffer (pick)' },
    { '<leader>bo', '<cmd>BufferLineCloseOthers<cr>', desc = 'Close [O]ther Buffers' },
    { '<leader>br', '<cmd>BufferLineCloseRight<cr>', desc = 'Close buffers to [R]ight' },
    { '<leader>bl', '<cmd>BufferLineCloseLeft<cr>', desc = 'Close buffers to [L]eft' },
  },
  opts = {
    options = {
      mode = 'buffers',
      themable = true,
      diagnostics = 'nvim_lsp',
      diagnostics_indicator = function(_, _, diag)
        local icons = { error = ' ', warning = ' ', info = ' ' }
        local ret = (diag.error and icons.error .. diag.error .. ' ' or '') .. (diag.warning and icons.warning .. diag.warning or '')
        return vim.trim(ret)
      end,
      always_show_bufferline = false,
      show_buffer_close_icons = true,
      show_close_icon = false,
      offsets = {
        { filetype = 'neo-tree', text = 'File Explorer', highlight = 'Directory', text_align = 'left' },
      },
    },
  },
}
