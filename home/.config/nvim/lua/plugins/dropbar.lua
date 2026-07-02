--- @docstring
--- Polished, IDE-like breadcrumbs mechanism operating via the native Neovim 0.10+ winbar.
return {
  'Bekaboo/dropbar.nvim',
  -- Optional, but recommended to prevent loading the fallback if you use dressing.nvim
  dependencies = { 'nvim-telescope/telescope-fzf-native.nvim' },
}
