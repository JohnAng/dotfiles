--- @docstring
--- Master Bootstrapper and Facade for Neovim Configuration.
--- Loads core components and initializes the package manager.

require 'core.options'
require 'core.keymaps'
require 'core.autocmds'
require 'core.indent'

--- @docstring
--- Plugin Manager Bootstrapping (lazy.nvim).
--- Dynamically clones and injects the package manager into the Neovim runtime path.
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then error('Error cloning lazy.nvim:\n' .. out) end
end
vim.opt.rtp:prepend(lazypath)

--- @docstring
--- Initialize lazy.nvim and instruct it to autoload the 'plugins' directory.
require('lazy').setup({ import = 'plugins' }, {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = 'CMD',
      config = 'CFG',
      event = 'EVT',
      ft = 'FT',
      init = 'INI',
      keys = 'KEY',
      plugin = 'PLG',
      runtime = 'RT',
      require = 'REQ',
      source = 'SRC',
      start = 'STR',
      task = 'TSK',
      lazy = 'LZ',
    },
  },
})

-- Load the saved theme (if any) — single colorscheme call, no flash.
local ok, saved = pcall(require, 'core.saved_theme')
local theme = (ok and type(saved) == 'string' and saved) or 'tokyonight-night'
pcall(vim.cmd.colorscheme, theme)
