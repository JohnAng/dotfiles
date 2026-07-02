-- owl.nvim — Markdown & LaTeX live preview
return {
  'JohnAng/owl.nvim',
  dev = true,   -- lazy will use ~/Projects/owl.nvim locally; remove this line for prod-style clone
  build = function()
    local sep = package.config:sub(1, 1)
    if sep == '\\' then
      vim.fn.system({ 'powershell', '-ExecutionPolicy', 'Bypass', '-File', 'scripts/postinstall.ps1' })
    else
      vim.fn.system({ 'bash', 'scripts/postinstall.sh' })
    end
  end,
  ft = { 'markdown', 'md', 'quarto', 'rmarkdown', 'tex', 'latex' },
  keys = {
    { '<leader>op', function() require('owl').toggle() end,        desc = 'owl: toggle preview' },
    { '<leader>oP', function() require('owl').preview() end,       desc = 'owl: start preview' },
    { '<leader>os', function() require('owl').stop() end,          desc = 'owl: stop preview' },
    { '<leader>oS', function() require('owl').stop_all() end,      desc = 'owl: stop all + shut server' },
    { '<leader>oj', function() require('owl.latex').synctex_here() end, desc = 'owl: SyncTeX to cursor' },
  },
  opts = {
    markdown = { trigger = 'live', scroll_sync = true, auto_bib = true },
    latex    = { viewer = 'auto', engine = 'xelatex', synctex = true },
    log_level = 'info',
  },
}
