--- @docstring
--- AST-aware bracket pair colorization.
--- Reduces cognitive load in deeply nested scopes using Treesitter.
return {
  'HiPhish/rainbow-delimiters.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local rainbow_delimiters = require 'rainbow-delimiters'
    vim.g.rainbow_delimiters = {
      strategy = {
        [''] = rainbow_delimiters.strategy['global'],
        vim = rainbow_delimiters.strategy['local'],
      },
      query = {
        [''] = 'rainbow-delimiters',
        lua = 'rainbow-blocks',
      },
      -- Picks up TokyoNight's native rainbow highlight groups automatically
      highlight = {
        'RainbowDelimiterRed',
        'RainbowDelimiterYellow',
        'RainbowDelimiterBlue',
        'RainbowDelimiterOrange',
        'RainbowDelimiterGreen',
        'RainbowDelimiterViolet',
        'RainbowDelimiterCyan',
      },
    }
  end,
}
