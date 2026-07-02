--- @docstring
--- Sticky scroll mechanism. Pins the function/class signature to the top of the window.
return {
  'nvim-treesitter/nvim-treesitter-context',
  event = { 'BufReadPre', 'BufNewFile' },
  opts = {
    max_lines = 3, -- How many lines the window should span.
    multiline_threshold = 1, -- Maximum number of lines to show for a single context.
  },
}
