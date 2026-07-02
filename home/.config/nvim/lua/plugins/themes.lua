--- @docstring
--- Curated theme collection — 30 dark variants behind the <leader>fc picker.
--- All lazy-loaded (only when selected). Zero startup cost.
return {
  -- ============ KEPT ============
  { 'rebelot/kanagawa.nvim', lazy = true }, -- wave/dragon
  { 'EdenEast/nightfox.nvim', lazy = true }, -- nightfox/carbonfox/duskfox/nordfox/terafox
  { 'sainnhe/sonokai', lazy = true },
  { 'nyoom-engineering/oxocarbon.nvim', lazy = true },
  { 'navarasu/onedark.nvim', lazy = true },
  { 'Mofiqul/vscode.nvim', lazy = true },

  -- ============ NEW REPLACEMENTS ============
  { 'juanedi/predawn.vim', lazy = true }, -- warm dark, cult classic (Jamie Wilson port)
  { 'savq/melange-nvim', lazy = true }, -- warm dark
  { 'olivercederborg/poimandres.nvim', lazy = true }, -- cyberpunk
  { 'ribru17/bamboo.nvim', lazy = true }, -- fresh green
  { 'vague2k/vague.nvim', lazy = true }, -- minimal 2024
  { 'cocopon/iceberg.vim', lazy = true }, -- blueish, cult classic
  { 'bluz71/vim-moonfly-colors', name = 'moonfly', lazy = true },
  { 'bluz71/vim-nightfly-colors', name = 'nightfly', lazy = true },
  { 'NTBBloodbath/doom-one.nvim', lazy = true }, -- Doom Emacs classic
  { 'tiagovla/tokyodark.nvim', lazy = true }, -- even darker tokyo
  { 'miikanissi/modus-themes.nvim', lazy = true }, -- science-based accessible
  { 'sainnhe/edge', lazy = true }, -- clean editor look
  { 'rmehri01/onenord.nvim', lazy = true }, -- Nord + OneDark blend
  { 'Shatur/neovim-ayu', name = 'ayu', lazy = true }, -- ayu-mirage
}
