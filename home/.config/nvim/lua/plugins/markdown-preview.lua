--- @docstring
--- Live Markdown previewer using a background Node.js server and WebSocket sync.
return {
  'iamcco/markdown-preview.nvim',
  cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
  ft = { 'markdown' },
  build = function() vim.fn['mkdp#util#install']() end,
  config = function()
    vim.g.mkdp_auto_close = 1
    vim.g.mkdp_refresh_slow = 0
    vim.g.mkdp_theme = 'dark'
  end,
}
