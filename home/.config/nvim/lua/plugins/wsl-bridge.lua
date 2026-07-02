-- WSL-only plugin: opens URLs / media / preview in a Windows browser from Neovim.
-- Loaded from a bundled local copy under the nvim config, so it works on any
-- fresh WSL install cloned from dotfiles. Skipped entirely outside WSL.

if vim.fn.has 'wsl' ~= 1 then
  return {}
end

local plugin_dir = vim.fn.stdpath 'config' .. '/local-plugins/wsl-preview-bridge.nvim'
if vim.fn.isdirectory(plugin_dir) == 0 then
  return {}
end

return {
  {
    dir = plugin_dir,
    name = 'wsl-preview-bridge',
    dependencies = { 'iamcco/markdown-preview.nvim' },
    config = function()
      require('wsl-preview-bridge').setup {
        focus_delay_ms = 300,
        sync_group = true,
      }
    end,
  },
}
