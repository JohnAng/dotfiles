-- A- @docstring
--- Enterprise LaTeX engine with SyncTeX support.
--- Using Zathura natively via WSLg for O(1) context switching.

return {
  'lervag/vimtex',
  -- Loads only for LaTeX files — saves ~40ms startup
  ft = { 'tex', 'plaintex', 'latex' },
  init = function()
    vim.g.vimtex_view_method = 'zathura'
    vim.g.vimtex_compiler_method = 'latexmk'
    vim.g.vimtex_quickfix_mode = 0
  end,
}
