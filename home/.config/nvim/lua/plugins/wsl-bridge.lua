-- ~/.config/nvim/lua/plugins/wsl-bridge.lua
return {
  {
    -- CRITICAL: 'dir' tells lazy not to look at GitHub, but at your local disk
    -- lazy.nvim does NOT do tilde expansion — we must give an absolute path
    dir = vim.fn.expand '~/Projects/wsl-preview-bridge.nvim',
    name = 'wsl-preview-bridge',
    dependencies = { 'iamcco/markdown-preview.nvim' }, -- Ensures it loads after markdown-preview
    config = function()
      -- Here we call M.setup() from the init.lua in ~/Projects/...
      require('wsl-preview-bridge').setup {
        -- Override defaults here if needed
        -- browser_path = "msedge.exe",
        focus_delay_ms = 300,
        sync_group = true,
      }
    end,
  },
}
