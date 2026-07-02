--- @docstring
--- Parser generator tool and incremental parsing library.
--- Highlight + indent + auto_install handled by configs.setup.
return {
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  build = ':TSUpdate',
  branch = 'master',
  config = function()
    require('nvim-treesitter.configs').setup {
      ensure_installed = {
        'c', 'cpp', 'java', 'python', 'html', 'css', 'javascript',
        'typescript', 'tsx', 'lua', 'vim', 'vimdoc', 'bash', 'markdown',
        'markdown_inline', 'json', 'yaml', 'toml', 'regex', 'query',
      },
      auto_install = true,

      -- Prevents auto_install from a broken LaTeX compiler
      ignore_install = { 'latex' },

      highlight = {
        enable = true,
        -- LaTeX is handled by VimTeX
        disable = { 'latex' },
        additional_vim_regex_highlighting = false,
      },

      -- CRITICAL: The indent module handles indentexpr correctly on its own.
      -- The old manual autocmd had the wrong path (nvim-treesitter.indentexpr -> nil)
      -- and was the ACTUAL cause of "jumps to start of line" on new lines!
      indent = { enable = true, disable = { 'python' } }, -- The vim ftplugin for python is more correct
    }
  end,
}
