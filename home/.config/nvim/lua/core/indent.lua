--- @docstring
--- Per-filetype indentation (single autocmd, cleaner than 15 ftplugin files).
--- Each group sets tabstop/shiftwidth/softtabstop/expandtab for specific filetypes.
--- The global default (options.lua) is 4 spaces + expandtab.

local groups = {
  -- ==================== 2 SPACES (web ecosystem best practice) ====================
  {
    fts = {
      'javascript', 'javascriptreact',
      'typescript', 'typescriptreact',
      'vue', 'svelte', 'astro',
      'html', 'htmldjango', 'xml',
      'css', 'scss', 'sass', 'less',
      'json', 'jsonc', 'json5',
      'yaml', 'yml', 'toml',
      'lua',
      'markdown', 'markdown_inline',
      'ruby', 'elixir',
      'sh', 'bash', 'zsh', 'fish',
      'nix',
      'dart',
    },
    ts = 2, sw = 2, sts = 2, et = true,
  },

  -- ==================== 4 SPACES (C-family / systems) ====================
  {
    fts = {
      'python',
      'java',
      'c', 'cpp', 'objc', 'cs',
      'rust',
      'php',
      'kotlin', 'scala',
      'sql',
    },
    ts = 4, sw = 4, sts = 4, et = true,
  },

  -- ==================== TABS (Go / Makefile best practice) ====================
  {
    fts = { 'go', 'gomod', 'gowork', 'make', 'makefile' },
    ts = 4, sw = 4, sts = 0, et = false,
  },
}

local aug = vim.api.nvim_create_augroup('lang-indent', { clear = true })
for _, g in ipairs(groups) do
  vim.api.nvim_create_autocmd('FileType', {
    group = aug,
    pattern = g.fts,
    callback = function(ev)
      vim.bo[ev.buf].tabstop = g.ts
      vim.bo[ev.buf].shiftwidth = g.sw
      vim.bo[ev.buf].softtabstop = g.sts
      vim.bo[ev.buf].expandtab = g.et
    end,
  })
end
